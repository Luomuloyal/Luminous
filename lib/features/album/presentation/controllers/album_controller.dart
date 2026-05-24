import 'dart:typed_data';

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:luminous/stores/album_local_store.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/utils/loading_utils.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/album.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 相册页控制器。
class AlbumController extends GetxController {
  AlbumController({AlbumLocalStore? albumStore})
    : _albumStore = albumStore ?? albumLocalStore;

  final AlbumLocalStore _albumStore;

  ProviderSubscription? _userWorker;
  bool _loading = false;
  String? _error;
  List<AlbumEntry> _entries = const <AlbumEntry>[];
  bool _reloadQueued = false;
  int _loadRequestId = 0;

  bool get loading => _loading;
  String? get error => _error;
  List<AlbumEntry> get entries => _entries;
  bool get isLoggedIn =>
      (globalProviderContainer.read(currentUserProvider)?.hasData ?? false);
  String get userId =>
      globalProviderContainer.read(currentUserProvider)?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    _userWorker = globalProviderContainer.listen(currentUserProvider, (
      previous,
      next,
    ) {
      unawaited(load());
    });
    unawaited(load());
  }

  @override
  void onClose() {
    _userWorker?.close();
    super.onClose();
  }

  Future<void> load() async {
    final scopedUserId = userId.trim();
    if (_loading) {
      _reloadQueued = true;
      return;
    }

    final requestId = ++_loadRequestId;
    _loading = true;
    _error = null;
    update();

    try {
      final local = await _albumStore.loadEntries(userId: scopedUserId);
      if (!_canApplyLoadResult(requestId, scopedUserId)) {
        return;
      }
      _entries = local;
    } catch (error) {
      if (!_canApplyLoadResult(requestId, scopedUserId)) {
        return;
      }
      _error = MessageUtils.extractError(error);
    } finally {
      if (_isActiveLoadRequest(requestId) && !isClosed) {
        _loading = false;
        update();
      }
      if (_isActiveLoadRequest(requestId) && _reloadQueued && !isClosed) {
        _reloadQueued = false;
        unawaited(load());
      }
    }
  }

  MedicineItem toMedicineItem(AlbumEntry entry) {
    return MedicineItem(
      serialNo: '',
      approvalNo: entry.approvalNo,
      productName: entry.productName,
      dosageForm: '',
      specification: '',
      marketingAuthorizationHolder: '',
      manufacturer: '',
      drugCode: entry.drugCode,
      drugCodeRemark: '',
    );
  }

  Future<Uint8List?> readImageBytes(String imagePath) {
    return _albumStore.readImageBytes(imagePath);
  }

  bool _canApplyLoadResult(int requestId, String scopedUserId) {
    return !isClosed &&
        _isActiveLoadRequest(requestId) &&
        scopedUserId == userId.trim();
  }

  bool _isActiveLoadRequest(int requestId) {
    return requestId == _loadRequestId;
  }

  AppLocalizations? get _l10n {
    final context = _context;
    if (context == null) {
      return null;
    }
    return AppLocalizations.of(context);
  }

  BuildContext? get _context => LoadingUtils.navigatorKey.currentContext;

  void showToast(String message) {
    final context = _context;
    if (context == null) {
      return;
    }
    ToastUtils.instance.show(context, message);
  }

  String missingIdentityToast() {
    return _l10n?.albumDetailMissingIdentityToast ??
        '该记录缺少 drugCode/approvalNo，无法查看详情';
  }

  String thumbnailOnlyToast() {
    return _l10n?.albumRescanThumbnailOnlyToast ?? '当前记录仅保存缩略图，无法高质量重识别';
  }

  String readOriginalFailedToast() {
    return _l10n?.albumRescanReadOriginalFailedToast ?? '原图读取失败，无法重识别';
  }
}
