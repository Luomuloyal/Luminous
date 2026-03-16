/// 安全辅助（AI 风险提示）相关的数据模型。
///
/// 当前接口返回的是纯文本，后续如果升级为结构化 JSON，可以在这里扩展字段。
class MedicineAiSafetyResult {
  /// AI 返回的风险提示/用药建议文本。
  final String text;

  /// 创建一个安全辅助结果对象。
  const MedicineAiSafetyResult({required this.text});

  /// 从后端 JSON 反序列化为 `MedicineAiSafetyResult`。
  factory MedicineAiSafetyResult.fromJson(Map<String, dynamic> json) {
    return MedicineAiSafetyResult(text: (json['text'] ?? '').toString());
  }

  /// 是否包含有效文本内容。
  bool get hasText => text.trim().isNotEmpty;
}
