import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/stores/my_medicine_repository.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/utils/loading_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';

/// 药品页控制器。
///
/// 负责管理：
/// - "我的药品"列表加载与同步；
/// - 用户切换后的自动刷新；
/// - 删除药品后的刷新与提示。
class DrugController extends GetxController {
  DrugController({MyMedicineRepository? repository})
    : _repository = repository ?? myMedicineRepository;

  final MyMedicineRepository _repository;

  ProviderSubscription? _userWorker;
  List<Map<String, dynamic>> _myMedicines = const <Map<String, dynamic>>[];
  bool _loadingMedicines = false;
  bool _reloadQueued = false;
  int _loadRequestId = 0;

  /// 当前"我的药品"列表。
  List<Map<String, dynamic>> get myMedicines => _myMedicines;

  /// 当前是否正在加载药品列表。
  bool get loadingMedicines => _loadingMedicines;

  /// 当前登录用户 id。
  String get userId =>
      globalProviderContainer.read(currentUserProvider)?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    _userWorker = globalProviderContainer.listen(currentUserProvider, (
      previous,
      next,
    ) {
      unawaited(loadMyMedicines());
    });
    unawaited(loadMyMedicines());
  }

  @override
  void onClose() {
    _userWorker?.close();
    super.onClose();
  }

  /// 从本地数据库加载"我的药品"列表，并在登录态下同步远端。
  Future<void> loadMyMedicines() async {
    final scopedUserId = userId.trim();
    if (_loadingMedicines) {
      _reloadQueued = true;
      return;
    }

    final requestId = ++_loadRequestId;
    _loadingMedicines = true;
    update();

    try {
      final rows = await _repository.loadLocalRows(userId: scopedUserId);
      if (!_canApplyLoadResult(requestId, scopedUserId)) {
        return;
      }
      _myMedicines = rows;
      update();

      if (scopedUserId.isNotEmpty) {
        try {
          await _repository.syncRemote(scopedUserId);
          final syncedRows = await _repository.loadLocalRows(
            userId: scopedUserId,
          );
          if (!_canApplyLoadResult(requestId, scopedUserId)) {
            return;
          }
          _myMedicines = syncedRows;
        } catch (error) {
          if (!_canApplyLoadResult(requestId, scopedUserId)) {
            return;
          }
          _showError(error);
        }
      }
    } catch (_) {
      if (_canApplyLoadResult(requestId, scopedUserId)) {
        _showToast(_l10n?.drugLoadFailedToast ?? '加载我的药品失败');
      }
    } finally {
      if (_isActiveLoadRequest(requestId) && !isClosed) {
        _loadingMedicines = false;
        update();
      }
      if (_isActiveLoadRequest(requestId) && _reloadQueued && !isClosed) {
        _reloadQueued = false;
        unawaited(loadMyMedicines());
      }
    }
  }

  /// 删除一条"我的药品"记录。
  Future<void> deleteMedicine(Map<String, dynamic> row) async {
    try {
      await _repository.deleteMedicine(row, userId: userId);
      await loadMyMedicines();
      if (!isClosed) {
        _showToast(_l10n?.drugDeletedToast ?? '已从我的药品中移除');
      }
    } catch (_) {
      if (!isClosed) {
        _showToast(_l10n?.drugDeleteFailedToast ?? '删除失败');
      }
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
}
