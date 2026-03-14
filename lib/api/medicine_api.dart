import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/DioRequest.dart';
import 'package:luminous/viewmodels/medicine.dart';

// MedicineApi：药品服务接口封装层
//
// 设计原则：
// - 页面不直接拼路径/字段名，只调用这里的方法
// - 统一使用 ApiResult<T> + decoder，把 result 解析为强类型对象
// - Loading 由页面自行控制（搜索与分页更适合局部 loading，而非全屏弹窗）
class MedicineApi {
  MedicineApi._();

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

  static Future<ApiResult<MedicineItem>> fetchDetail({
    String? drugCode,
    String? approvalNo,
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
    );
  }

  static Future<ApiResult<MedicineAiDetailResult>> fetchAiDetail({
    String? drugCode,
    String? approvalNo,
  }) {
    return dioRequest.post<MedicineAiDetailResult>(
      HttpConstants.MEDICINE_AI_DETAIL,
      data: <String, dynamic>{
        if (drugCode != null && drugCode.trim().isNotEmpty)
          'drugCode': drugCode.trim(),
        if (approvalNo != null && approvalNo.trim().isNotEmpty)
          'approvalNo': approvalNo.trim(),
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
    );
  }
}
