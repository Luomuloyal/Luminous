import 'package:json_annotation/json_annotation.dart';

part 'safety.g.dart';

/// 安全辅助（AI 风险提示）相关的数据模型。
///
/// 当前接口返回的是纯文本，后续如果升级为结构化 JSON，可以在这里扩展字段。
@JsonSerializable(createFactory: false)
class MedicineAiSafetyResult {
  /// AI 返回的风险提示/用药建议文本。
  final String text;

  /// 结果来源：`cache` 或 `generated`。
  final String source;

  /// 缓存写入时间。
  final DateTime? cachedAt;

  /// 缓存过期时间。
  final DateTime? expiresAt;

  /// 创建一个安全辅助结果对象。
  const MedicineAiSafetyResult({
    required this.text,
    this.source = 'generated',
    this.cachedAt,
    this.expiresAt,
  });

  /// 从后端 JSON 反序列化为 `MedicineAiSafetyResult`。
  factory MedicineAiSafetyResult.fromJson(Map<String, dynamic> json) {
    return MedicineAiSafetyResult(
      text: (json['text'] ?? '').toString(),
      source: (json['source'] ?? 'generated').toString(),
      cachedAt: _parseAiTimestamp(json['cachedAt']),
      expiresAt: _parseAiTimestamp(json['expiresAt']),
    );
  }

  /// 是否包含有效文本内容。
  bool get hasText => text.trim().isNotEmpty;

  bool get isCached => source.trim().toLowerCase() == 'cache';

  Map<String, dynamic> toJson() => _$MedicineAiSafetyResultToJson(this);
}

DateTime? _parseAiTimestamp(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  final text = value.toString().trim();
  if (text.isEmpty) {
    return null;
  }
  final asInt = int.tryParse(text);
  if (asInt != null) {
    return DateTime.fromMillisecondsSinceEpoch(asInt);
  }
  return DateTime.tryParse(text);
}
