/// 打卡相关的数据模型。
///
/// 当前该文件主要用于承载“打卡创建”接口的返回结果。
class CheckinCreateResult {
  /// 打卡记录 id（后端可能返回 `id` 或 `_id`）。
  final String id;

  /// 创建一个打卡创建结果对象。
  const CheckinCreateResult({required this.id});

  /// 从后端 JSON 反序列化为 `CheckinCreateResult`。
  factory CheckinCreateResult.fromJson(Map<String, dynamic> json) {
    return CheckinCreateResult(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
    );
  }

  /// 是否包含有效 id。
  bool get hasId => id.trim().isNotEmpty;
}
