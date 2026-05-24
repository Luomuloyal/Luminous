import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:luminous/api/safety_api.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/utils/loading_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/shared/models/medicine.dart';
import 'package:luminous/features/safety/presentation/models/safety.dart';

typedef QueryMedicineAiSafety =
    Future<ApiResult<MedicineAiSafetyResult>> Function({
      String? userId,
      required String mode,
      required List<Map<String, String>> medicines,
      bool refresh,
      CancelToken? cancelToken,
    });

/// 安全辅助页控制器。
///
/// 负责管理：
/// - 查询模式切换；
/// - 选中药品；
/// - AI 查询与取消；
/// - 页面级提示文案分发。
class SafetyAssistController extends GetxController {
  SafetyAssistController({QueryMedicineAiSafety? queryApi})
    : _queryApi = queryApi ?? SafetyApi.query;

  static const String singleMode = 'single';
  static const String pairMode = 'pair';

  final QueryMedicineAiSafety _queryApi;

  String _mode = singleMode;
  MedicineItem? _a;
  MedicineItem? _b;
  bool _loading = false;
  CancelToken? _queryCancelToken;
  MedicineAiSafetyResult? _result;

  String get mode => _mode;
  MedicineItem? get medicineA => _a;
  MedicineItem? get medicineB => _b;
  bool get loading => _loading;
  MedicineAiSafetyResult? get result => _result;
  bool get loggedIn =>
      (globalProviderContainer.read(currentUserProvider)?.hasData ?? false);
  bool get ready => _a != null && (_mode == singleMode || _b != null);

  int get selectedCount {
    var count = 0;
    if (_a != null) {
      count++;
    }
    if (_mode == pairMode && _b != null) {
      count++;
    }
    return count;
  }

  @override
  void onClose() {
    _queryCancelToken?.cancel('controller closed');
    _queryCancelToken = null;
    super.onClose();
  }

  void setMode(String nextMode) {
    if (_mode == nextMode) {
      return;
    }
    _mode = nextMode;
    if (_mode == singleMode) {
      _b = null;
    }
    _result = null;
    update();
  }

  void setMedicine({required int slot, required MedicineItem item}) {
    if (slot == 0) {
      _a = item;
    } else {
      _b = item;
    }
    _result = null;
    update();
  }

  /// 发起安全辅助查询。
  Future<void> query({bool refresh = false}) async {
    final a = _a;
    final b = _b;
    if (a == null) {
      _showToast(
        _l10n?.safetyToastSelectMedicine ?? 'Please select a medicine first',
      );
      return;
    }
    if (_mode == pairMode && b == null) {
      _showToast(
        _l10n?.safetyToastSelectSecondMedicine ??
            'Please select one more medicine',
      );
      return;
    }

    _queryCancelToken?.cancel('new query started');
    final cancelToken = CancelToken();
    _queryCancelToken = cancelToken;
    _loading = true;
    update();

    try {
      final medicines = <Map<String, String>>[
        {
          'drugCode': a.drugCode,
          'approvalNo': a.approvalNo,
          'productName': a.productName,
        },
        if (_mode == pairMode && b != null)
          {
            'drugCode': b.drugCode,
            'approvalNo': b.approvalNo,
            'productName': b.productName,
          },
      ];

      final response = await _queryApi(
        userId: _userId.isEmpty ? null : _userId,
        mode: _mode,
        medicines: medicines,
        refresh: refresh,
        cancelToken: cancelToken,
      );
      if (isClosed) {
        return;
      }
      _result = response.result;
      if (!_result!.hasText) {
        _showToast(_l10n?.safetyToastAiNoContent ?? 'AI returned no content');
      }
    } catch (error) {
      if (isClosed || _isCanceledError(error)) {
        return;
      }
      _showError(error);
    } finally {
      if (identical(_queryCancelToken, cancelToken)) {
        _queryCancelToken = null;
      }
      if (!isClosed) {
        _loading = false;
        update();
      }
    }
  }

  /// 取消当前查询。
  void cancelQuery() {
    _queryCancelToken?.cancel('user canceled');
    _queryCancelToken = null;
    if (_loading && !isClosed) {
      _loading = false;
      update();
    }
    _showToast(_queryCanceledText());
  }

  /// 下拉刷新时重新发起一次查询。
  Future<void> refreshResult() async {
    if (!ready || _loading) {
      return;
    }
    await query(refresh: true);
  }

  String get _userId =>
      globalProviderContainer.read(currentUserProvider)?.id ?? '';

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

  String _queryCanceledText() {
    final locale = (_l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh')
        ? '已取消安全分析查询'
        : 'Safety analysis query canceled';
  }

  bool _isCanceledError(Object error) {
    if (error is DioException && error.type == DioExceptionType.cancel) {
      return true;
    }
    final text = error.toString().toLowerCase();
    return text.contains('cancel') || text.contains('canceled');
  }
}
