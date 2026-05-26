import 'package:json_annotation/json_annotation.dart';
import 'package:luminous/utils/app_i18n_text.dart';

part 'medicine.g.dart';

/// 药品搜索、详情、AI 解读共用的数据模型。
@JsonSerializable(createFactory: false)
class MedicineItem {
  /// 药品表中的序号字段。
  final String serialNo;

  /// 批准文号。
  final String approvalNo;

  /// 产品名称。
  final String productName;

  /// 剂型。
  final String dosageForm;

  /// 规格。
  final String specification;

  /// 上市许可持有人。
  final String marketingAuthorizationHolder;

  /// 生产厂家。
  final String manufacturer;

  /// 药品编码。
  final String drugCode;

  /// 药品编码备注。
  final String drugCodeRemark;

  /// 创建一个药品对象。
  const MedicineItem({
    required this.serialNo,
    required this.approvalNo,
    required this.productName,
    required this.dosageForm,
    required this.specification,
    required this.marketingAuthorizationHolder,
    required this.manufacturer,
    required this.drugCode,
    required this.drugCodeRemark,
  });

  /// 从后端 JSON 反序列化为 `MedicineItem`。
  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      serialNo: (json['serialNo'] ?? '').toString(),
      approvalNo: (json['approvalNo'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      dosageForm: (json['dosageForm'] ?? '').toString(),
      specification: (json['specification'] ?? '').toString(),
      marketingAuthorizationHolder: (json['marketingAuthorizationHolder'] ?? '')
          .toString(),
      manufacturer: (json['manufacturer'] ?? '').toString(),
      drugCode: (json['drugCode'] ?? '').toString(),
      drugCodeRemark: (json['drugCodeRemark'] ?? '').toString(),
    );
  }

  /// 当前药品是否具备可用于详情查询的身份字段。
  @JsonKey(includeToJson: false)
  bool get hasIdentity => drugCode.isNotEmpty || approvalNo.isNotEmpty;

  /// 页面展示时的主标题。
  ///
  /// 若产品名称为空，则回退为“未知药品”。
  @JsonKey(includeToJson: false)
  String get displayName => productName.isEmpty
      ? AppI18nText.pick(zh: '未知药品', en: 'Unknown medicine')
      : productName;

  /// 页面展示时的副标题。
  ///
  /// 由剂型和规格组合而成。
  @JsonKey(includeToJson: false)
  String get displaySubtitle {
    final parts = <String>[
      if (dosageForm.isNotEmpty) dosageForm,
      if (specification.isNotEmpty) specification,
    ];
    return parts.isEmpty
        ? AppI18nText.pick(zh: '暂无规格信息', en: 'No specification info')
        : parts.join(' · ');
  }

  /// 页面展示时的补充提示信息。
  ///
  /// 优先使用生产厂家，其次使用上市许可持有人。
  @JsonKey(includeToJson: false)
  String get displayTips {
    if (manufacturer.isNotEmpty) {
      return manufacturer;
    }
    if (marketingAuthorizationHolder.isNotEmpty) {
      return marketingAuthorizationHolder;
    }
    return '';
  }

  /// 页面展示时的徽标文本。
  ///
  /// 优先展示剂型，没有剂型时回退为“药品”。
  @JsonKey(includeToJson: false)
  String get displayBadge {
    if (dosageForm.isNotEmpty) {
      return dosageForm;
    }
    return AppI18nText.pick(zh: '药品', en: 'Medicine');
  }

  Map<String, dynamic> toJson() => _$MedicineItemToJson(this);
}

/// 药品搜索接口的分页结果。
@JsonSerializable(createFactory: false)
class MedicineSearchResult {
  /// 当前页返回的药品列表。
  final List<MedicineItem> items;

  /// 符合条件的总记录数。
  final int total;

  /// 当前页码。
  final int page;

  /// 每页大小。
  final int pageSize;

  /// 创建一个搜索结果对象。
  const MedicineSearchResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  /// 从后端 JSON 反序列化为 `MedicineSearchResult`。
  factory MedicineSearchResult.fromJson(Map<String, dynamic> json) {
    /// 原始 items 字段，可能不是严格的 `List<Map<String, dynamic>>`。
    final rawItems = json['items'];

    /// 解析后的药品对象列表。
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => MedicineItem.fromJson(e.cast<String, dynamic>()))
              .toList()
        : <MedicineItem>[];

    return MedicineSearchResult(
      items: items,
      total: int.tryParse((json['total'] ?? '').toString()) ?? items.length,
      page: int.tryParse((json['page'] ?? '').toString()) ?? 1,
      pageSize: _parsePageSize(json['pageSize'], fallback: 20),
    );
  }

  /// 当前分页结果是否还有下一页数据可继续加载。
  @JsonKey(includeToJson: false)
  bool get hasMore => page * pageSize < total;

  Map<String, dynamic> toJson() => _$MedicineSearchResultToJson(this);
}

/// 安全解析分页大小。
///
/// 若后端未返回合法 pageSize，则回退到调用方给定的默认值。
int _parsePageSize(dynamic value, {required int fallback}) {
  /// 尝试解析得到的 pageSize 数值。
  final parsed = int.tryParse((value ?? '').toString());
  if (parsed != null && parsed > 0) {
    return parsed;
  }
  return fallback;
}

/// AI 药品详情解读结果。
@JsonSerializable(createFactory: false)
class MedicineAiDetailResult {
  /// AI 返回的纯文本解读内容。
  final String text;

  /// 结果来源：`cache` 或 `generated`。
  final String source;

  /// 缓存写入时间。
  final DateTime? cachedAt;

  /// 缓存过期时间。
  final DateTime? expiresAt;

  /// 创建一个 AI 解读结果对象。
  const MedicineAiDetailResult({
    required this.text,
    this.source = 'generated',
    this.cachedAt,
    this.expiresAt,
  });

  /// 从后端 JSON 反序列化为 `MedicineAiDetailResult`。
  factory MedicineAiDetailResult.fromJson(Map<String, dynamic> json) {
    return MedicineAiDetailResult(
      text: (json['text'] ?? '').toString(),
      source: (json['source'] ?? 'generated').toString(),
      cachedAt: _parseAiTimestamp(json['cachedAt']),
      expiresAt: _parseAiTimestamp(json['expiresAt']),
    );
  }

  /// AI 是否返回了有效文本。
  @JsonKey(includeToJson: false)
  bool get hasText => text.trim().isNotEmpty;

  @JsonKey(includeToJson: false)
  bool get isCached => source.trim().toLowerCase() == 'cache';

  Map<String, dynamic> toJson() => _$MedicineAiDetailResultToJson(this);
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
