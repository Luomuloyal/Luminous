import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:luminous/api/scan_api.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/scan/presentation/models/selected_scan_image.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/album/data/album_local_store.dart';
import 'package:luminous/utils/loading_utils.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/scan_image_processing.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/features/scan/presentation/models/scan.dart';

/// 药物识别页控制器。
///
/// 负责管理：
/// - 当前识别图片；
/// - 识别请求与取消；
/// - 候选结果与选中项；
/// - 保存到应用相册的状态。
class MedicineScanController extends GetxController {
  MedicineScanController({AlbumLocalStore? albumStore})
    : _albumStore = albumStore ?? albumLocalStore;

  final AlbumLocalStore _albumStore;

  Uint8List? _photoBytes;
  String _photoMimeType = 'image/jpeg';
  bool _scanning = false;
  bool _savingToAlbum = false;
  MedicineScanResult? _scanResult;
  int _selectedIndex = 0;
  String? _lastError;
  CancelToken? _scanCancelToken;
  int _scanRequestVersion = 0;

  Uint8List? get photoBytes => _photoBytes;
  bool get scanning => _scanning;
  bool get savingToAlbum => _savingToAlbum;
  MedicineScanResult? get scanResult => _scanResult;
  int get selectedIndex => _selectedIndex;
  String? get lastError => _lastError;

  /// 当前选中的候选结果。
  ScanCandidate? get selectedCandidate {
    final result = _scanResult;
    if (result == null || result.candidates.isEmpty) {
      return null;
    }
    final index = _selectedIndex.clamp(0, result.candidates.length - 1);
    return result.candidates[index];
  }

  /// 当前是否可以保存到应用相册。
  bool get canSaveToAlbum =>
      _photoBytes != null && _scanResult != null && !_savingToAlbum;

  /// 当前搜索关键词。
  String get searchKeyword => _buildSearchKeyword(selectedCandidate);

  /// 当前是否可以跳转搜索。
  bool get canSearch => searchKeyword.isNotEmpty;

  @override
  void onClose() {
    _scanCancelToken?.cancel('controller closed');
    _scanCancelToken = null;
    super.onClose();
  }

  /// 选择候选药品。
  void selectCandidate(int index) {
    final result = _scanResult;
    if (result == null || result.candidates.isEmpty) {
      return;
    }
    _selectedIndex = index.clamp(0, result.candidates.length - 1);
    update();
  }

  /// 处理页面进入后的首次识别流。
  Future<void> handleEntryFlow({
    SelectedScanImage? initialImage,
    required bool promptSourceOnStart,
    required Future<SelectedScanImage?> Function() pickImage,
    VoidCallback? onPromptCancelled,
  }) async {
    if (initialImage != null) {
      await applySelectedImage(initialImage);
      return;
    }
    if (!promptSourceOnStart) {
      return;
    }
    await pickAndScan(pickImage: pickImage, onCancelled: onPromptCancelled);
  }

  /// 调起选图流程并在成功后立即识别。
  Future<void> pickAndScan({
    required Future<SelectedScanImage?> Function() pickImage,
    VoidCallback? onCancelled,
  }) async {
    final image = await pickImage();
    if (image == null) {
      onCancelled?.call();
      return;
    }
    await applySelectedImage(image);
  }

  /// 应用一张已经读取完成的识别图片。
  Future<void> applySelectedImage(SelectedScanImage image) {
    return applyImageAndScan(bytes: image.bytes, mimeType: image.mimeType);
  }

  /// 应用新图片并发起识别。
  Future<void> applyImageAndScan({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    _lastError = null;
    _scanResult = null;
    _selectedIndex = 0;
    _photoBytes = bytes;
    _photoMimeType = mimeType;
    update();
    await _scan(bytes);
  }

  /// 保存当前识别结果到应用相册。
  Future<void> saveToAppAlbum() async {
    final bytes = _photoBytes;
    final result = _scanResult;
    final selected = selectedCandidate;
    if (bytes == null || result == null || _savingToAlbum) {
      return;
    }

    _savingToAlbum = true;
    update();

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final userId =
          globalProviderContainer.read(currentUserProvider)?.id ?? '';
      await _albumStore.saveScanRecord(
        userId: userId,
        drugCode: selected?.drugCode,
        approvalNo: selected?.approvalNo,
        productName: selected?.productName,
        imageBytes: bytes,
        imageMimeType: _photoMimeType,
        preferredThumbBase64: result.thumbBase64,
        takenAt: now,
      );
      if (isClosed) {
        return;
      }
      _showToast(_l10n?.scanSavedToAlbumToast ?? 'Added to in-app album');
    } catch (error) {
      if (isClosed) {
        return;
      }
      _showError(
        error,
        fallback: _l10n?.scanSaveToAlbumFailedToast ?? 'Failed to add to album',
      );
    } finally {
      if (!isClosed) {
        _savingToAlbum = false;
        update();
      }
    }
  }

  Future<void> _scan(Uint8List bytes) async {
    final requestId = ++_scanRequestVersion;
    _scanCancelToken?.cancel('new scan started');
    final cancelToken = CancelToken();
    _scanCancelToken = cancelToken;
    _scanning = true;
    update();

    try {
      final base64 = await encodeScanImageBase64(bytes);
      if (isClosed || requestId != _scanRequestVersion) {
        return;
      }

      final response = await ScanApi.scanMedicine(
        userId: globalProviderContainer.read(currentUserProvider)?.id,
        imageBase64: base64,
        mimeType: _photoMimeType,
        cancelToken: cancelToken,
      );
      if (isClosed || requestId != _scanRequestVersion) {
        return;
      }

      final result = response.result;
      _scanResult = result;
      _selectedIndex = _findBestCandidateIndex(result);
    } catch (error) {
      if (isClosed ||
          requestId != _scanRequestVersion ||
          _isCanceledError(error)) {
        return;
      }
      _lastError = MessageUtils.extractError(error);
    } finally {
      if (identical(_scanCancelToken, cancelToken)) {
        _scanCancelToken = null;
      }
      if (!isClosed && requestId == _scanRequestVersion) {
        _scanning = false;
        update();
      }
    }
  }

  int _findBestCandidateIndex(MedicineScanResult result) {
    if (result.candidates.isEmpty) {
      return 0;
    }
    for (final entry in result.candidates.asMap().entries) {
      if (entry.value.hasIdentity) {
        return entry.key;
      }
    }
    return 0;
  }

  String _buildSearchKeyword(ScanCandidate? candidate) {
    if (candidate == null) {
      return '';
    }
    if (candidate.productName.trim().isNotEmpty) {
      return candidate.productName.trim();
    }
    if (candidate.approvalNo.trim().isNotEmpty) {
      return candidate.approvalNo.trim();
    }
    if (candidate.manufacturer.trim().isNotEmpty) {
      return candidate.manufacturer.trim();
    }
    return '';
  }

  AppLocalizations? get _l10n {
    final context = _context;
    if (context == null) {
      return null;
    }
    return AppLocalizations.of(context);
  }

  BuildContext? get _context => LoadingUtils.navigatorKey.currentContext;

  void _showToast(String message) {
    final context = _context;
    if (context == null) {
      return;
    }
    ToastUtils.instance.show(context, message);
  }

  void _showError(Object error, {String? fallback}) {
    final context = _context;
    if (context == null) {
      return;
    }
    ToastUtils.instance.showError(context, error, fallback: fallback);
  }

  bool _isCanceledError(Object error) {
    if (error is DioException && error.type == DioExceptionType.cancel) {
      return true;
    }
    final text = error.toString().toLowerCase();
    return text.contains('cancel') || text.contains('canceled');
  }
}
