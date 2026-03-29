import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/viewmodels/my_medicine.dart';

/// “我的药品”远端接口封装。
class MyMedicineApi {
  /// 私有构造函数，当前类只提供静态方法。
  MyMedicineApi._();

  /// 获取当前用户的“我的药品”列表。
  static Future<ApiResult<MyMedicineListResult>> list({
    required String userId,
  }) {
    return dioRequest.post<MyMedicineListResult>(
      HttpConstants.MY_MEDICINE_LIST,
      data: <String, dynamic>{'userId': userId.trim()},
      decoder: (json) {
        if (json is Map<String, dynamic>) {
          return MyMedicineListResult.fromJson(json);
        }
        if (json is Map) {
          return MyMedicineListResult.fromJson(json.cast<String, dynamic>());
        }
        return const MyMedicineListResult(items: []);
      },
      showLoading: false,
    );
  }

  /// 新增或更新一条“我的药品”记录。
  static Future<ApiResult<MyMedicineRecord>> upsert({
    required String userId,
    String? id,
    required String identityKey,
    String? drugCode,
    String? approvalNo,
    required String productName,
    String? dosageForm,
    String? specification,
    String? manufacturer,
    String source = 'search',
  }) {
    return dioRequest.post<MyMedicineRecord>(
      HttpConstants.MY_MEDICINE_UPSERT,
      data: <String, dynamic>{
        'userId': userId.trim(),
        if (id != null && id.trim().isNotEmpty) 'id': id.trim(),
        'identityKey': identityKey.trim(),
        if (drugCode != null && drugCode.trim().isNotEmpty)
          'drugCode': drugCode.trim(),
        if (approvalNo != null && approvalNo.trim().isNotEmpty)
          'approvalNo': approvalNo.trim(),
        'productName': productName.trim(),
        'dosageForm': (dosageForm ?? '').trim(),
        'specification': (specification ?? '').trim(),
        'manufacturer': (manufacturer ?? '').trim(),
        'source': source.trim(),
      },
      decoder: (json) => MyMedicineRecord.fromJson(_asMap(json)),
      showLoading: false,
    );
  }

  /// 删除一条“我的药品”记录。
  static Future<ApiResult<bool>> delete({
    required String userId,
    String? id,
    String? identityKey,
  }) {
    return dioRequest.post<bool>(
      HttpConstants.MY_MEDICINE_DELETE,
      data: <String, dynamic>{
        'userId': userId.trim(),
        if (id != null && id.trim().isNotEmpty) 'id': id.trim(),
        if (identityKey != null && identityKey.trim().isNotEmpty)
          'identityKey': identityKey.trim(),
      },
      decoder: (json) {
        if (json is bool) return json;
        if (json is num) return json != 0;
        final text = (json ?? '').toString().trim().toLowerCase();
        return text == 'true' || text == '1' || text == 'ok';
      },
      showLoading: false,
    );
  }

  /// 把动态对象安全转换为 `Map<String, dynamic>`。
  static Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    if (json is Map) {
      return json.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }
}
