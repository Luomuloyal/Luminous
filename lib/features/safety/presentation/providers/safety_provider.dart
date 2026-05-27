import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/api/safety_api.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/shared/models/medicine.dart';
import 'package:luminous/features/safety/presentation/models/safety.dart';
import 'package:luminous/utils/dio_request.dart';

typedef QueryMedicineAiSafety = Future<ApiResult<MedicineAiSafetyResult>> Function({
  String? userId,
  required String mode,
  required List<Map<String, String>> medicines,
  bool refresh,
  CancelToken? cancelToken,
});

final safetyQueryProvider = Provider<QueryMedicineAiSafety>(
  (ref) => SafetyApi.query,
);

class SafetyState {
  const SafetyState({
    this.mode = 'single',
    this.medicineA,
    this.medicineB,
    this.loading = false,
    this.result,
  });

  final String mode;
  final MedicineItem? medicineA;
  final MedicineItem? medicineB;
  final bool loading;
  final MedicineAiSafetyResult? result;

  bool get ready => medicineA != null && (mode == 'single' || medicineB != null);

  int get selectedCount {
    var c = 0;
    if (medicineA != null) c++;
    if (mode == 'pair' && medicineB != null) c++;
    return c;
  }

  SafetyState copyWith({
    String? mode,
    MedicineItem? medicineA,
    MedicineItem? medicineB,
    bool? loading,
    MedicineAiSafetyResult? result,
  }) {
    return SafetyState(
      mode: mode ?? this.mode,
      medicineA: medicineA ?? this.medicineA,
      medicineB: medicineB ?? this.medicineB,
      loading: loading ?? this.loading,
      result: result ?? this.result,
    );
  }
}

class SafetyNotifier extends Notifier<SafetyState> {
  CancelToken? _queryCancelToken;

  QueryMedicineAiSafety get _queryApi => ref.read(safetyQueryProvider);
  String get _userId => ref.read(currentUserProvider)?.id ?? '';

  @override
  SafetyState build() {
    ref.onDispose(() {
      _queryCancelToken?.cancel('notifier closed');
    });
    return const SafetyState();
  }

  void setMode(String nextMode) {
    if (state.mode == nextMode) return;
    state = state.copyWith(
      mode: nextMode,
      medicineB: nextMode == 'single' ? null : state.medicineB,
      result: null,
    );
  }

  void setMedicine({required int slot, required MedicineItem item}) {
    state = state.copyWith(
      medicineA: slot == 0 ? item : state.medicineA,
      medicineB: slot == 1 ? item : state.medicineB,
      result: null,
    );
  }

  /// 返回错误消息供 page 层 toast。null=成功。
  Future<String?> query({bool refresh = false}) async {
    final a = state.medicineA;
    final b = state.medicineB;
    if (a == null) return 'selectMedicine';
    if (state.mode == 'pair' && b == null) return 'selectSecond';

    _queryCancelToken?.cancel('new query');
    final cancelToken = CancelToken();
    _queryCancelToken = cancelToken;
    state = state.copyWith(loading: true);

    try {
      final medicines = <Map<String, String>>[
        {'drugCode': a.drugCode, 'approvalNo': a.approvalNo, 'productName': a.productName},
        if (state.mode == 'pair' && b != null)
          {'drugCode': b.drugCode, 'approvalNo': b.approvalNo, 'productName': b.productName},
      ];
      final response = await _queryApi(
        userId: _userId.isEmpty ? null : _userId,
        mode: state.mode,
        medicines: medicines,
        refresh: refresh,
        cancelToken: cancelToken,
      );
      state = state.copyWith(result: response.result);
      if (!response.result.hasText) return 'aiNoContent';
    } catch (error) {
      if (_isCanceledError(error)) return null;
      return error.toString();
    } finally {
      if (identical(_queryCancelToken, cancelToken)) _queryCancelToken = null;
      state = state.copyWith(loading: false);
    }
    return null;
  }

  String cancelQuery() {
    _queryCancelToken?.cancel('user canceled');
    _queryCancelToken = null;
    state = state.copyWith(loading: false);
    return '已取消获取安全辅助信息';
  }

  Future<String?> refreshResult() async {
    if (!state.ready || state.loading) return null;
    return query(refresh: true);
  }

  bool _isCanceledError(Object error) {
    if (error is DioException && error.type == DioExceptionType.cancel) return true;
    return error.toString().toLowerCase().contains('cancel');
  }
}

final safetyProvider = NotifierProvider<SafetyNotifier, SafetyState>(() {
  return SafetyNotifier();
});
