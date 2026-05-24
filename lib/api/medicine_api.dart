import 'package:dio/dio.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/shared/models/medicine.dart';

/// 药品服务接口封装层。
///
/// 页面只依赖这个类，不直接关心接口路径和动态字段解析。
class MedicineApi {
  /// 私有构造函数，当前类只提供静态 API 方法。
  MedicineApi._();

  /// 根据关键词搜索药品。
  ///
  /// 支持分页参数，返回强类型的 `MedicineSearchResult`。
  static Future<ApiResult<MedicineSearchResult>> search({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) {
    return dioRequest.post<MedicineSearchResult>(
      HttpConstants.MEDICINE_SEARCH,
      data: <String, dynamic>{
        'keyword': keyword.trim(),
        'page': page,
        'pageSize': pageSize,
      },
      decoder: (json) {
        if (json is Map<String, dynamic>) {
          return MedicineSearchResult.fromJson(json);
        }
        if (json is Map) {
          return MedicineSearchResult.fromJson(json.cast<String, dynamic>());
        }
        return const MedicineSearchResult(
          items: [],
          total: 0,
          page: 1,
          pageSize: 20,
        );
      },
      showLoading: false,
    );
  }

  /// 探测后端是否可达。
  ///
  /// 兼容两种健康检查响应：
  /// - 标准 `{code,msg,result}` 包装；
  /// - 纯 HTTP 200 + 任意 JSON。
  static Future<bool> isBackendReachable() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: GlobalConstants.BASE_URL,
        connectTimeout: const Duration(milliseconds: 1600),
        receiveTimeout: const Duration(milliseconds: 1600),
      ),
    );
    try {
      final response = await dio.get<dynamic>('/health');
      if (response.statusCode != 200) {
        return false;
      }
      final data = response.data;
      if (data is Map && data['code'] != null) {
        return data['code'].toString() == GlobalConstants.SUCCESS_CODE;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 查询药品详情。
  ///
  /// 可以通过 `drugCode`、`approvalNo` 或两者组合定位目标药品。
  static Future<ApiResult<MedicineItem>> fetchDetail({
    String? drugCode,
    String? approvalNo,
    CancelToken? cancelToken,
  }) {
    return dioRequest.post<MedicineItem>(
      HttpConstants.MEDICINE_DETAIL,
      data: <String, dynamic>{
        if (drugCode != null && drugCode.trim().isNotEmpty)
          'drugCode': drugCode.trim(),
        if (approvalNo != null && approvalNo.trim().isNotEmpty)
          'approvalNo': approvalNo.trim(),
      },
      decoder: (json) {
        if (json is Map<String, dynamic>) {
          return MedicineItem.fromJson(json);
        }
        if (json is Map) {
          return MedicineItem.fromJson(json.cast<String, dynamic>());
        }
        return const MedicineItem(
          serialNo: '',
          approvalNo: '',
          productName: '',
          dosageForm: '',
          specification: '',
          marketingAuthorizationHolder: '',
          manufacturer: '',
          drugCode: '',
          drugCodeRemark: '',
        );
      },
      showLoading: false,
      cancelToken: cancelToken,
    );
  }

  /// 获取药品 AI 解读内容。
  ///
  /// 这个接口主要为详情页的“AI 智能解读”区域提供文本数据。
  static Future<ApiResult<MedicineAiDetailResult>> fetchAiDetail({
    String? drugCode,
    String? approvalNo,
    bool refresh = false,
    CancelToken? cancelToken,
  }) {
    return dioRequest.post<MedicineAiDetailResult>(
      HttpConstants.MEDICINE_AI_DETAIL,
      data: <String, dynamic>{
        if (drugCode != null && drugCode.trim().isNotEmpty)
          'drugCode': drugCode.trim(),
        if (approvalNo != null && approvalNo.trim().isNotEmpty)
          'approvalNo': approvalNo.trim(),
        'refresh': refresh,
      },
      decoder: (json) {
        if (json is Map<String, dynamic>) {
          return MedicineAiDetailResult.fromJson(json);
        }
        if (json is Map) {
          return MedicineAiDetailResult.fromJson(json.cast<String, dynamic>());
        }
        return const MedicineAiDetailResult(text: '');
      },
      showLoading: false,
      options: Options(
        receiveTimeout: const Duration(
          seconds: GlobalConstants.AI_SAFETY_RECEIVE_TIMEOUT,
        ),
      ),
      cancelToken: cancelToken,
    );
  }
}
