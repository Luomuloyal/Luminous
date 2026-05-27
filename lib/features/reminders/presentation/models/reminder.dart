import 'package:json_annotation/json_annotation.dart';

import 'package:luminous/utils/app_i18n_text.dart';

part 'reminder.g.dart';

/// 提醒中绑定的单个药品引用。
@JsonSerializable(createFactory: false)
class ReminderMedicineRef {
  final String drugCode;
  final String approvalNo;
  final String productName;

  const ReminderMedicineRef({
    this.drugCode = '',
    this.approvalNo = '',
    required this.productName,
  });

  factory ReminderMedicineRef.fromJson(Map<String, dynamic> json) {
    return ReminderMedicineRef(
      drugCode: (json['drugCode'] ?? '').toString().trim(),
      approvalNo: (json['approvalNo'] ?? '').toString().trim(),
      productName: (json['productName'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => _$ReminderMedicineRefToJson(this);
}

/// 用药提醒计划对象。
///
/// 该对象既用于：
/// - 后端接口的序列化/反序列化；
/// - 本地 SQLite 缓存（reminders 表）。
@JsonSerializable(createFactory: false)
class ReminderPlan {
  /// 提醒计划 id（后端可能返回 `id` 或 `_id`）。
  final String id;

  /// 所属用户 id。
  final String userId;

  /// 提醒时间（HH:mm）。
  final String time;

  /// 药品编码（可选）。
  final String drugCode;

  /// 批准文号（可选）。
  final String approvalNo;

  /// 药品名称（用于通知标题/列表标题）。
  final String productName;

  /// 当前提醒绑定的药品列表。
  final List<ReminderMedicineRef> medicines;

  /// 服用剂量（例如 1 粒 / 5 ml）。
  final String dosage;

  /// 提醒副标题（例如“早餐后服用 1 粒”）。
  final String subtitle;

  /// 是否启用该提醒。
  final bool enabled;

  /// 重复规则（当前主要支持 daily）。
  final String repeatRule;

  /// 提醒方式（当前主要支持 notification）。
  final String method;

  /// 生效开始日期（yyyy-MM-dd，留空表示不限制）。
  final String startDate;

  /// 生效结束日期（yyyy-MM-dd，留空表示不限制）。
  final String endDate;

  /// 创建一个提醒计划对象。
  const ReminderPlan({
    required this.id,
    required this.userId,
    required this.time,
    required this.drugCode,
    required this.approvalNo,
    required this.productName,
    this.medicines = const [],
    this.dosage = '',
    required this.subtitle,
    required this.enabled,
    required this.repeatRule,
    required this.method,
    this.startDate = '',
    this.endDate = '',
  });

  /// 从后端 JSON 反序列化为 `ReminderPlan`。
  factory ReminderPlan.fromJson(Map<String, dynamic> json) {
    final legacyDrugCode = (json['drugCode'] ?? '').toString().trim();
    final legacyApprovalNo = (json['approvalNo'] ?? '').toString().trim();
    final legacyProductName = (json['productName'] ?? '').toString().trim();
    final medicines = _parseMedicines(
      json['medicines'],
      fallbackDrugCode: legacyDrugCode,
      fallbackApprovalNo: legacyApprovalNo,
      fallbackProductName: legacyProductName,
    );
    final productName = legacyProductName.isNotEmpty
        ? legacyProductName
        : _composeProductName(medicines);
    final primary = medicines.isNotEmpty ? medicines.first : null;

    return ReminderPlan(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      drugCode: legacyDrugCode.isNotEmpty
          ? legacyDrugCode
          : (primary?.drugCode ?? ''),
      approvalNo: legacyApprovalNo.isNotEmpty
          ? legacyApprovalNo
          : (primary?.approvalNo ?? ''),
      productName: productName,
      medicines: medicines,
      dosage: (json['dosage'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      enabled: json['enabled'] != false,
      repeatRule: (json['repeatRule'] ?? 'daily').toString(),
      method: (json['method'] ?? 'notification').toString(),
      startDate: (json['startDate'] ?? '').toString(),
      endDate: (json['endDate'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => _$ReminderPlanToJson(this);

  /// 是否有有效 id。
  ///
  /// 在部分流程中可用它判断“这是新增还是更新”。
  @JsonKey(includeToJson: false)
  bool get hasId => id.trim().isNotEmpty;

  /// 页面展示用的标题（时间 + 药品名）。
  ///
  /// 例如：`08:30 维生素D`。
  @JsonKey(includeToJson: false)
  String get displayTitle {
    final t = time.trim();
    final name = productName.trim().isNotEmpty
        ? productName.trim()
        : _composeProductName(medicines);
    final n = name.isEmpty
        ? AppI18nText.pick(zh: '未知药品', en: 'Unknown medicine')
        : name;
    return t.isEmpty ? n : '$t $n';
  }
}

List<ReminderMedicineRef> _parseMedicines(
  dynamic raw, {
  required String fallbackDrugCode,
  required String fallbackApprovalNo,
  required String fallbackProductName,
}) {
  final medicines = <ReminderMedicineRef>[];
  final dedupe = <String>{};

  if (raw is List) {
    for (final item in raw) {
      if (item is! Map) {
        continue;
      }
      final medicine = ReminderMedicineRef.fromJson(
        item.cast<String, dynamic>(),
      );
      if (medicine.productName.trim().isEmpty) {
        continue;
      }
      final key =
          '${medicine.drugCode.trim()}|${medicine.approvalNo.trim()}|${medicine.productName.trim()}';
      if (dedupe.add(key)) {
        medicines.add(medicine);
      }
    }
  }

  if (medicines.isNotEmpty) {
    return medicines;
  }

  final fallbackName = fallbackProductName.trim();
  if (fallbackName.isEmpty) {
    return const [];
  }

  return <ReminderMedicineRef>[
    ReminderMedicineRef(
      drugCode: fallbackDrugCode.trim(),
      approvalNo: fallbackApprovalNo.trim(),
      productName: fallbackName,
    ),
  ];
}

String _composeProductName(List<ReminderMedicineRef> medicines) {
  final names = medicines
      .map((item) => item.productName.trim())
      .where((name) => name.isNotEmpty)
      .toList(growable: false);
  if (names.isEmpty) {
    return '';
  }
  return names.toSet().join('、');
}

/// 提醒计划列表接口返回模型。
@JsonSerializable(createFactory: false, createToJson: false)
class ReminderListResult {
  /// 当前用户的提醒计划列表。
  final List<ReminderPlan> items;

  /// 创建一个提醒列表结果对象。
  const ReminderListResult({required this.items});

  /// 从后端 JSON 反序列化为 `ReminderListResult`。
  factory ReminderListResult.fromJson(Map<String, dynamic> json) {
    /// 原始 items 字段，类型可能不稳定。
    final raw = json['items'];

    /// 解析后的提醒计划对象列表。
    final items = raw is List
        ? raw
              .whereType<Map>()
              .map((e) => ReminderPlan.fromJson(e.cast<String, dynamic>()))
              .toList()
        : <ReminderPlan>[];
    return ReminderListResult(items: items);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'items': items.map((e) => e.toJson()).toList(),
      };
}
