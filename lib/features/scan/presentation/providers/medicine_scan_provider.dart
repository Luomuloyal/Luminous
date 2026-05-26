import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/api/scan_api.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/album/data/album_local_store.dart';
import 'package:luminous/features/scan/presentation/models/scan.dart';
import 'package:luminous/utils/scan_image_processing.dart';

final scanAlbumStoreProvider = Provider<AlbumLocalStore>(
  (ref) => albumLocalStore,
);

class ScanState {
  const ScanState({
    this.photoBytes,
    this.scanning = false,
    this.savingToAlbum = false,
    this.scanResult,
    this.selectedIndex = 0,
    this.lastError,
  });

  final Uint8List? photoBytes;
  final bool scanning;
  final bool savingToAlbum;
  final MedicineScanResult? scanResult;
  final int selectedIndex;
  final String? lastError;

  ScanCandidate? get selectedCandidate {
    final r = scanResult;
    if (r == null || r.candidates.isEmpty) return null;
    final idx = selectedIndex.clamp(0, r.candidates.length - 1);
    return r.candidates[idx];
  }

  bool get canSaveToAlbum => photoBytes != null && scanResult != null && !savingToAlbum;
  String get searchKeyword => _buildSearchKeyword(selectedCandidate);
  bool get canSearch => searchKeyword.isNotEmpty;

  String _buildSearchKeyword(ScanCandidate? candidate) {
    if (candidate == null) return '';
    if (candidate.drugCode.trim().isNotEmpty) return candidate.drugCode.trim();
    if (candidate.approvalNo.trim().isNotEmpty) return candidate.approvalNo.trim();
    return candidate.productName.trim();
  }

  ScanState copyWith({
    Uint8List? photoBytes,
    bool? scanning,
    bool? savingToAlbum,
    MedicineScanResult? scanResult,
    int? selectedIndex,
    String? lastError,
  }) {
    return ScanState(
      photoBytes: photoBytes ?? this.photoBytes,
      scanning: scanning ?? this.scanning,
      savingToAlbum: savingToAlbum ?? this.savingToAlbum,
      scanResult: scanResult ?? this.scanResult,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      lastError: lastError ?? this.lastError,
    );
  }
}

class ScanNotifier extends Notifier<ScanState> {
  CancelToken? _scanCancelToken;
  int _scanRequestVersion = 0;
  String _photoMimeType = 'image/jpeg';

  AlbumLocalStore get _albumStore => ref.read(scanAlbumStoreProvider);

  @override
  ScanState build() {
    ref.onDispose(() {
      _scanCancelToken?.cancel('notifier closed');
    });
    return const ScanState();
  }

  void selectCandidate(int index) {
    final r = state.scanResult;
    if (r == null || r.candidates.isEmpty) return;
    state = state.copyWith(selectedIndex: index.clamp(0, r.candidates.length - 1));
  }

  Future<void> applyImageAndScan({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    _photoMimeType = mimeType;
    state = state.copyWith(
      lastError: null,
      scanResult: null,
      selectedIndex: 0,
      photoBytes: bytes,
    );
    await _scan(bytes);
  }

  /// 返回错误消息供 page 层 toast。
  Future<String?> saveToAppAlbum() async {
    final bytes = state.photoBytes;
    final result = state.scanResult;
    final selected = state.selectedCandidate;
    if (bytes == null || result == null || state.savingToAlbum) return null;

    state = state.copyWith(savingToAlbum: true);

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final userId = ref.read(currentUserProvider)?.id ?? '';
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
      return null; // success
    } catch (error) {
      return error.toString();
    } finally {
      state = state.copyWith(savingToAlbum: false);
    }
  }

  Future<void> _scan(Uint8List bytes) async {
    final requestId = ++_scanRequestVersion;
    _scanCancelToken?.cancel('new scan');
    final cancelToken = CancelToken();
    _scanCancelToken = cancelToken;
    state = state.copyWith(scanning: true);

    try {
      final base64 = await encodeScanImageBase64(bytes);
      if (requestId != _scanRequestVersion) return;
      final response = await ScanApi.scanMedicine(
        userId: ref.read(currentUserProvider)?.id,
        imageBase64: base64,
        mimeType: _photoMimeType,
        cancelToken: cancelToken,
      );
      if (requestId != _scanRequestVersion) return;
      state = state.copyWith(scanResult: response.result);
    } catch (error) {
      if (requestId != _scanRequestVersion || _isCanceledError(error)) return;
      state = state.copyWith(lastError: error.toString());
    } finally {
      if (identical(_scanCancelToken, cancelToken)) _scanCancelToken = null;
      if (requestId == _scanRequestVersion) {
        state = state.copyWith(scanning: false);
      }
    }
  }

  bool _isCanceledError(Object error) {
    if (error is DioException && error.type == DioExceptionType.cancel) return true;
    return error.toString().toLowerCase().contains('cancel');
  }
}

final scanProvider = NotifierProvider<ScanNotifier, ScanState>(() {
  return ScanNotifier();
});
