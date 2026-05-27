/// 全局字号 token。
///
/// 页面/组件通过此处的语义化常量引用字号，不直接写 `fontSize: 12.5` 等魔数。
/// 这些值作为 Material `TextTheme` 之外的补充——当前项目未完整覆盖
/// `TextTheme` 全部变体时，优先使用这里的 token。
class AppTypography {
  AppTypography._();

  // -- 通用字号 --

  /// 导航栏 Tab 标签 / 小标签。
  static const double tab = 12.5;

  /// 辅助 / 次要正文（card 副标题、chip 文字、字段标签）。
  static const double bodySmall = 13.0;

  /// 正文（列表项标题、设置项）。
  static const double body = 14.0;

  /// 中等强调文本（卡片标题、section header）。
  static const double bodyLarge = 15.0;

  /// 大标题（页面级标题、banner 主文案）。
  static const double headline = 18.0;

  // -- 特殊场景 --

  /// 卡片内的产品名 / 药名。
  static const double cardTitle = 13.8;

  /// 卡片内的副标题行 / 规格信息。
  static const double cardMeta = 12.2;
}
