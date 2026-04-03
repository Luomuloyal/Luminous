import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/viewmodels/reminder.dart';

/// 提醒计划接口封装。
class ReminderApi {
  /// 私有构造函数，禁止外部直接创建实例。
  ReminderApi._();

  /// 获取当前用户的提醒计划列表。
  static Future<ApiResult<ReminderListResult>> list({required String userId}) {
    return dioRequest.post<ReminderListResult>(
      HttpConstants.REMINDER_LIST,
      data: <String, dynamic>{'userId': userId.trim()},
      decoder: (json) {
        if (json is Map<String, dynamic>) {
          return ReminderListResult.fromJson(json);
        }
        if (json is Map) {
          return ReminderListResult.fromJson(json.cast<String, dynamic>());
        }
        return const ReminderListResult(items: []);
      },
      showLoading: false,
    );
  }

  /// 新增或更新一条提醒计划。
  ///
  /// 如果 `id` 为空，视为新增；否则视为更新。
  static Future<ApiResult<ReminderPlan>> upsert({
    required String userId,
    String? id,
    required String time,
    String? drugCode,
    String? approvalNo,
    required String productName,
    List<ReminderMedicineRef> medicines = const [],
    String? dosage,
    String? subtitle,
    bool enabled = true,
    String repeatRule = 'daily',
    String method = 'notification',
    String? startDate,
    String? endDate,
  }) {
    final normalizedMedicines = medicines
        .where((item) => item.productName.trim().isNotEmpty)
        .toList(growable: false);

    final resolvedProductName = normalizedMedicines.isNotEmpty
        ? normalizedMedicines
              .map((item) => item.productName.trim())
              .where((name) => name.isNotEmpty)
              .toSet()
              .join('、')
        : productName.trim();

    final primary = normalizedMedicines.isNotEmpty
        ? normalizedMedicines.first
        : null;
    final resolvedDrugCode = (primary?.drugCode ?? drugCode ?? '').trim();
    final resolvedApprovalNo = (primary?.approvalNo ?? approvalNo ?? '').trim();

    return dioRequest.post<ReminderPlan>(
      HttpConstants.REMINDER_UPSERT,
      data: <String, dynamic>{
        'userId': userId.trim(),
        if (id != null && id.trim().isNotEmpty) 'id': id.trim(),
        'time': time.trim(),
        if (resolvedDrugCode.isNotEmpty) 'drugCode': resolvedDrugCode,
        if (resolvedApprovalNo.isNotEmpty) 'approvalNo': resolvedApprovalNo,
        'productName': resolvedProductName,
        if (normalizedMedicines.isNotEmpty)
          'medicines': normalizedMedicines
              .map((item) => item.toJson())
              .toList(growable: false),
        'dosage': (dosage ?? '').trim(),
        'subtitle': (subtitle ?? '').trim(),
        'enabled': enabled,
        'repeatRule': repeatRule,
        'method': method,
        if (startDate != null && startDate.trim().isNotEmpty)
          'startDate': startDate.trim(),
        if (endDate != null && endDate.trim().isNotEmpty)
          'endDate': endDate.trim(),
      },
      decoder: (json) => ReminderPlan.fromJson(_asMap(json)),
      showLoading: true,
      loadingText: AppI18nText.pick(zh: '保存中...', en: 'Saving...'),
    );
  }

  /// 删除一条提醒计划。
  ///
  /// 返回值会被规范化为布尔类型，表示删除是否成功。
  static Future<ApiResult<bool>> delete({
    required String userId,
    required String id,
  }) {
    return dioRequest.post<bool>(
      HttpConstants.REMINDER_DELETE,
      data: <String, dynamic>{'userId': userId.trim(), 'id': id.trim()},
      decoder: (json) {
        if (json is bool) return json;
        if (json is num) return json != 0;
        final s = (json ?? '').toString().trim().toLowerCase();
        return s == 'true' || s == '1' || s == 'ok';
      },
      showLoading: false,
    );
  }

  /// 把动态 JSON 对象安全转换为 Map。
  static Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return json.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }
}
