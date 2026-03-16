/// 用药提醒计划对象。
///
/// 该对象既用于：
/// - 后端接口的序列化/反序列化；
/// - 本地 SQLite 缓存（reminders 表）。
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

  /// 提醒副标题（例如“早餐后服用 1 粒”）。
  final String subtitle;

  /// 是否启用该提醒。
  final bool enabled;

  /// 重复规则（当前主要支持 daily）。
  final String repeatRule;

  /// 提醒方式（当前主要支持 notification）。
  final String method;

  /// 创建一个提醒计划对象。
  const ReminderPlan({
    required this.id,
    required this.userId,
    required this.time,
    required this.drugCode,
    required this.approvalNo,
    required this.productName,
    required this.subtitle,
    required this.enabled,
    required this.repeatRule,
    required this.method,
  });

  /// 从后端 JSON 反序列化为 `ReminderPlan`。
  factory ReminderPlan.fromJson(Map<String, dynamic> json) {
    return ReminderPlan(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      drugCode: (json['drugCode'] ?? '').toString(),
      approvalNo: (json['approvalNo'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      enabled: json['enabled'] != false,
      repeatRule: (json['repeatRule'] ?? 'daily').toString(),
      method: (json['method'] ?? 'notification').toString(),
    );
  }

  /// 序列化为 JSON Map，用于接口上报或本地持久化。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'time': time,
      'drugCode': drugCode,
      'approvalNo': approvalNo,
      'productName': productName,
      'subtitle': subtitle,
      'enabled': enabled,
      'repeatRule': repeatRule,
      'method': method,
    };
  }

  /// 是否有有效 id。
  ///
  /// 在部分流程中可用它判断“这是新增还是更新”。
  bool get hasId => id.trim().isNotEmpty;

  /// 页面展示用的标题（时间 + 药品名）。
  ///
  /// 例如：`08:30 维生素D`。
  String get displayTitle {
    final t = time.trim();
    final n = productName.trim().isEmpty ? '未知药品' : productName.trim();
    return t.isEmpty ? n : '$t $n';
  }
}

/// 提醒计划列表接口返回模型。
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
}
