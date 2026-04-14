import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:luminous/api/medicine_api.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/utils/loading_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';

/// 药品详情页控制器。
///
/// 负责管理：
/// - 基础详情请求；
/// - AI 解读请求；
/// - 页面级请求状态与取消逻辑。
class MedicineDetailController extends GetxController {
  MedicineDetailController({required MedicineItem initialItem})
    : _item = initialItem;

  MedicineItem _item;
  bool _loadingDetail = false;
  MedicineAiDetailResult? _aiResult;
  bool _loadingAi = false;
  CancelToken? _detailCancelToken;
  CancelToken? _aiCancelToken;

  /// 当前展示的药品对象。
  MedicineItem get item => _item;

  /// 是否正在加载基础详情。
  bool get loadingDetail => _loadingDetail;

  /// AI 解读结果。
  MedicineAiDetailResult? get aiResult => _aiResult;

  /// 是否正在加载 AI 解读。
  bool get loadingAi => _loadingAi;

  @override
  void onInit() {
    super.onInit();
    loadDetail();
  }

  @override
  void onClose() {
    _detailCancelToken?.cancel('controller closed');
    _detailCancelToken = null;
    _aiCancelToken?.cancel('controller closed');
    _aiCancelToken = null;
    super.onClose();
  }

  /// 拉取药品基础详情。
  Future<void> loadDetail() async {
    if (_loadingDetail || !_item.hasIdentity) {
      return;
    }

    _detailCancelToken?.cancel('new detail request started');
    final cancelToken = CancelToken();
    _detailCancelToken = cancelToken;
    _loadingDetail = true;
    update();

    try {
      final response = await MedicineApi.fetchDetail(
        drugCode: _item.drugCode,
        approvalNo: _item.approvalNo,
        cancelToken: cancelToken,
      );
      if (isClosed) {
        return;
      }
      if (response.result.productName.isNotEmpty) {
        _item = response.result;
      }
    } catch (error) {
      if (isClosed || _isCanceledError(error)) {
        return;
      }
      _showError(error);
    } finally {
      if (identical(_detailCancelToken, cancelToken)) {
        _detailCancelToken = null;
      }
      if (!isClosed) {
        _loadingDetail = false;
        update();
      }
    }
  }

  /// 拉取 AI 药品解读。
  Future<void> loadAiDetail() async {
    if (_loadingAi || !_item.hasIdentity) {
      return;
    }

    _aiCancelToken?.cancel('new ai detail request started');
    final cancelToken = CancelToken();
    _aiCancelToken = cancelToken;
    _loadingAi = true;
    update();

    try {
      final response = await MedicineApi.fetchAiDetail(
        drugCode: _item.drugCode,
        approvalNo: _item.approvalNo,
        cancelToken: cancelToken,
      );
      if (isClosed) {
        return;
      }
      _aiResult = response.result;
      if (!_aiResult!.hasText) {
        _showToast(_l10n?.medicineDetailAiNoContentToast ?? 'AI接口暂无返回内容');
      }
    } catch (error) {
      if (isClosed || _isCanceledError(error)) {
        return;
      }
      if (_isLikelyNetworkFailure(error)) {
        _showError(
          error,
          fallback:
              _l10n?.medicineDetailAiNetworkErrorToast ?? '网络访问失败，请检查网络后重试',
        );
      } else {
        _showError(error);
      }
    } finally {
      if (identical(_aiCancelToken, cancelToken)) {
        _aiCancelToken = null;
      }
      if (!isClosed) {
        _loadingAi = false;
        update();
      }
    }
  }

  /// 取消当前 AI 解读请求。
  void cancelAiDetail() {
    _aiCancelToken?.cancel('user canceled');
    _aiCancelToken = null;
    if (_loadingAi && !isClosed) {
      _loadingAi = false;
      update();
    }
    _showToast(_cancelToastText());
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

  String _cancelToastText() {
    final locale = (_l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh') ? '已取消获取详细信息' : 'Detailed query canceled';
  }

  bool _isCanceledError(Object error) {
    if (error is DioException && error.type == DioExceptionType.cancel) {
      return true;
    }
    final text = error.toString().toLowerCase();
    return text.contains('cancel') || text.contains('canceled');
  }

  bool _isLikelyNetworkFailure(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('timeout') ||
        text.contains('socket') ||
        text.contains('connection') ||
        text.contains('network') ||
        text.contains('xmlhttprequest') ||
        text.contains('failed host lookup');
  }
}
