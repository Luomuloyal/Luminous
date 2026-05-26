import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/drug/data/my_medicine_repository.dart';
import 'package:luminous/shared/models/medicine.dart';

/// Drug 模块 MyMedicineRepository 注入 provider。
final drugRepoProvider = Provider<MyMedicineRepository>(
  (ref) => myMedicineRepository,
);

/// 药品页状态。
class DrugState {
  const DrugState({
    this.myMedicines = const [],
    this.loadingMedicines = false,
    this.isClosed = false,
  });

  final List<Map<String, dynamic>> myMedicines;
  final bool loadingMedicines;
  final bool isClosed;

  DrugState copyWith({
    List<Map<String, dynamic>>? myMedicines,
    bool? loadingMedicines,
    bool? isClosed,
  }) {
    return DrugState(
      myMedicines: myMedicines ?? this.myMedicines,
      loadingMedicines: loadingMedicines ?? this.loadingMedicines,
      isClosed: isClosed ?? this.isClosed,
    );
  }
}

/// 药品页状态管理器。
///
/// 替代旧 GetX `DrugController`，管理"我的药品"列表加载、同步与删除。
class DrugNotifier extends Notifier<DrugState> {
  MyMedicineRepository get _repo => ref.read(drugRepoProvider);

  bool _reloadQueued = false;
  int _loadRequestId = 0;

  String get _userId => ref.read(currentUserProvider)?.id ?? '';

  @override
  DrugState build() {
    ref.listen(currentUserProvider, (prev, next) {
      unawaited(loadMyMedicines());
    });

    // 初始加载
    Future.microtask(() {
      if (!state.isClosed) loadMyMedicines();
    });

    return const DrugState();
  }

  /// 从本地数据库加载"我的药品"列表，并在登录态下同步远端。
  ///
  /// 返回加载过程中可能发生的错误，供 page 层显示 toast。
  Future<String?> loadMyMedicines() async {
    final scopedUserId = _userId.trim();
    if (state.loadingMedicines) {
      _reloadQueued = true;
      return null;
    }

    final requestId = ++_loadRequestId;
    state = state.copyWith(loadingMedicines: true);

    try {
      final rows = await _repo.loadLocalRows(userId: scopedUserId);
      if (!_canApplyLoadResult(requestId, scopedUserId)) return null;
      state = state.copyWith(myMedicines: rows);

      if (scopedUserId.isNotEmpty) {
        try {
          await _repo.syncRemote(scopedUserId);
          final syncedRows = await _repo.loadLocalRows(userId: scopedUserId);
          if (!_canApplyLoadResult(requestId, scopedUserId)) return null;
          state = state.copyWith(myMedicines: syncedRows);
        } catch (error) {
          if (!_canApplyLoadResult(requestId, scopedUserId)) return null;
          return _extractError(error);
        }
      }
    } catch (_) {
      if (_canApplyLoadResult(requestId, scopedUserId)) {
        return 'drugLoadFailed';
      }
    } finally {
      if (_isActiveLoadRequest(requestId) && !state.isClosed) {
        state = state.copyWith(loadingMedicines: false);
      }
      if (_isActiveLoadRequest(requestId) && _reloadQueued && !state.isClosed) {
        _reloadQueued = false;
        unawaited(loadMyMedicines());
      }
    }
    return null;
  }

  /// 删除一条"我的药品"记录。
  ///
  /// 返回 null 表示成功，返回错误消息表示失败。
  Future<String?> deleteMedicine(Map<String, dynamic> row) async {
    try {
      await _repo.deleteMedicine(row, userId: _userId);
      await loadMyMedicines();
      return null; // 成功，page 层显示 "已移除" toast
    } catch (_) {
      return 'drugDeleteFailed';
    }
  }

  /// 把数据库行数据转换为 `MedicineItem`。
  MedicineItem toMedicineItem(Map<String, dynamic> row) {
    return MedicineItem(
      serialNo: '',
      approvalNo: (row['approvalNo'] ?? '').toString(),
      productName: (row['productName'] ?? '').toString(),
      dosageForm: (row['dosageForm'] ?? '').toString(),
      specification: (row['specification'] ?? '').toString(),
      marketingAuthorizationHolder: '',
      manufacturer: (row['manufacturer'] ?? '').toString(),
      drugCode: (row['drugCode'] ?? '').toString(),
      drugCodeRemark: '',
    );
  }

  bool _canApplyLoadResult(int requestId, String scopedUserId) {
    return !state.isClosed &&
        _isActiveLoadRequest(requestId) &&
        scopedUserId == _userId.trim();
  }

  bool _isActiveLoadRequest(int requestId) {
    return requestId == _loadRequestId;
  }

  String? _extractError(Object error) {
    final s = error.toString();
    if (s.isEmpty) return null;
    return s;
  }
}

/// 药品页状态 provider。
final drugProvider = NotifierProvider<DrugNotifier, DrugState>(() {
  return DrugNotifier();
});
