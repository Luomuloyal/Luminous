import 'package:json_annotation/json_annotation.dart';
import 'package:luminous/utils/app_i18n_text.dart';

part 'scan.g.dart';

// 药品识别相关的数据模型。
//
// 该文件用于承载 `/medicine-scan` 接口返回的数据结构，并提供一些 UI 友好的展示字段。

/// 药品识别候选结果对象。
@JsonSerializable(createFactory: false)
class ScanCandidate {
  /// 识别结果对应的药品编码（本位码）。
  final String drugCode;

  /// 识别结果对应的批准文号。
  final String approvalNo;

  /// 识别结果对应的产品名称。
  final String productName;

  /// 剂型（片剂/胶囊/注射液等）。
  final String dosageForm;

  /// 规格（如 0.5g、10ml 等）。
  final String specification;

  /// 生产单位/厂家。
  final String manufacturer;

  /// 识别置信度分数（0.0-1.0 或其它区间，取决于后端实现）。
  final double score;

  /// 创建一个候选结果对象。
  const ScanCandidate({
    required this.drugCode,
    required this.approvalNo,
    required this.productName,
    required this.dosageForm,
    required this.specification,
    required this.manufacturer,
    required this.score,
  });

  /// 从后端 JSON 反序列化为 `ScanCandidate`。
  factory ScanCandidate.fromJson(Map<String, dynamic> json) {
    return ScanCandidate(
      drugCode: (json['drugCode'] ?? '').toString(),
      approvalNo: (json['approvalNo'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      dosageForm: (json['dosageForm'] ?? '').toString(),
      specification: (json['specification'] ?? '').toString(),
      manufacturer: (json['manufacturer'] ?? '').toString(),
      score: _parseDouble(json['score']),
    );
  }

  /// 当前候选是否具备“可用于后续详情查询”的身份字段。
  ///
  /// 只要 drugCode 或 approvalNo 任意一个非空即可。
  @JsonKey(includeToJson: false)
  bool get hasIdentity =>
      drugCode.trim().isNotEmpty || approvalNo.trim().isNotEmpty;

  /// 页面展示用的候选标题（优先使用产品名称）。
  @JsonKey(includeToJson: false)
  String get displayName => productName.trim().isEmpty
      ? AppI18nText.pick(zh: '未知药品', en: 'Unknown medicine')
      : productName.trim();

  /// 页面展示用的候选副标题（剂型 + 规格）。
  @JsonKey(includeToJson: false)
  String get displaySubtitle {
    /// 用于拼接副标题的字段片段。
    final parts = <String>[
      if (dosageForm.trim().isNotEmpty) dosageForm.trim(),
      if (specification.trim().isNotEmpty) specification.trim(),
    ];
    return parts.isEmpty
        ? AppI18nText.pick(zh: '暂无规格信息', en: 'No specification info')
        : parts.join(' · ');
  }

  Map<String, dynamic> toJson() => _$ScanCandidateToJson(this);
}

/// 药品识别接口返回的整体结果对象。
@JsonSerializable(createFactory: false)
class MedicineScanResult {
  /// 识别出的候选药品列表。
  final List<ScanCandidate> candidates;

  /// 服务端返回的缩略图 base64（通常用于相册页/结果页展示）。
  final String thumbBase64;

  /// 创建一个识别结果对象。
  const MedicineScanResult({
    required this.candidates,
    required this.thumbBase64,
  });

  /// 从后端 JSON 反序列化为 `MedicineScanResult`。
  factory MedicineScanResult.fromJson(Map<String, dynamic> json) {
    /// 原始候选数组字段，可能不是严格的 `List<Map<String, dynamic>>`。
    final raw = json['candidates'];

    /// 解析后的候选列表。
    final candidates = raw is List
        ? raw
              .whereType<Map>()
              .map((e) => ScanCandidate.fromJson(e.cast<String, dynamic>()))
              .toList()
        : <ScanCandidate>[];

    return MedicineScanResult(
      candidates: candidates,
      thumbBase64: (json['thumbBase64'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => _$MedicineScanResultToJson(this);
}

/// 将动态类型数值安全解析为 `double`。
///
/// - 如果 value 是 num，直接 toDouble；
/// - 否则尝试按字符串解析；
/// - 解析失败则回退为 0.0。
double _parseDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse((value ?? '').toString()) ?? 0.0;
}

