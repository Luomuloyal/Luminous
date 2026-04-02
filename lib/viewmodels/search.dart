/// 搜索结果卡片使用的展示数据模型。
class SearchResultItemData {
  /// 药品/结果名称。
  final String name;

  /// 结果副标题（剂型 + 规格等）。
  final String subtitle;

  /// 结果补充提示（厂家等）。
  final String tips;

  /// 右上角徽标文本。
  final String badge;

  /// 创建一个搜索结果展示数据对象。
  const SearchResultItemData({
    required this.name,
    required this.subtitle,
    required this.tips,
    required this.badge,
  });
}
