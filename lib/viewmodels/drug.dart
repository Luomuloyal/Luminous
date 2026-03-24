import 'package:flutter/material.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/responsive_quick_grid.dart';

/// 药品页（Drug）相关的数据结构与小组件。
///
/// 该文件承担两部分职责：
/// - `DrugQuickEntry`：描述“快捷入口”卡片的数据；
/// - `DrugMedicineCardViewModel/DrugMyMedicineCard`：把数据库行转换为 UI 友好数据并渲染卡片；
/// - `DrugQuickEntryCard`：渲染快捷入口卡片。
class DrugQuickEntry {
  /// 创建一个快捷入口数据对象。
  const DrugQuickEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.routeName,
  });

  /// 卡片主标题。
  final String title;

  /// 卡片副标题。
  final String subtitle;

  /// 卡片图标。
  final IconData icon;

  /// 卡片主色（用于图标背景和图标本身）。
  final Color color;

  /// 点击后跳转的路由名。
  ///
  /// 为空表示该入口走自定义逻辑（例如打开拍照识别或药品选择器）。
  final String routeName;
}

/// “我的药品”列表卡片的展示模型。
///
/// 作用：把数据库查询出来的 `Map<String, dynamic>` 行数据规范化为 UI 渲染直接使用的字段，
/// 避免在 Widget build 中大量拼字符串和判断，减少重复工作。
class DrugMedicineCardViewModel {
  /// 创建一个药品卡片展示模型。
  DrugMedicineCardViewModel({
    required this.productName,
    required this.subtitle,
    required this.metaText,
    required this.sourceLabel,
    required this.sourceColor,
    required this.dateText,
  });

  /// 从数据库行数据构建卡片展示模型。
  ///
  /// 该方法会做：
  /// - 字段兜底与字符串化；
  /// - 副标题/元信息拼接；
  /// - 来源徽标映射；
  /// - 创建日期格式化。
  factory DrugMedicineCardViewModel.fromRow(Map<String, dynamic> row) {
    // 剂型字段。
    final dosageForm = (row['dosageForm'] ?? '').toString();
    // 规格字段。
    final specification = (row['specification'] ?? '').toString();
    // 生产单位字段。
    final manufacturer = (row['manufacturer'] ?? '').toString();
    // 批准文号字段。
    final approvalNo = (row['approvalNo'] ?? '').toString();
    // 来源字段（scan/manual 等）。
    final source = (row['source'] ?? '').toString();
    // 创建时间戳（毫秒）。
    final createdAt = row['createdAt'];

    // 副标题组成：剂型 + 规格。
    final subtitleParts = <String>[
      if (dosageForm.isNotEmpty) dosageForm,
      if (specification.isNotEmpty) specification,
    ];

    // 元信息组成：生产单位 + 批准文号。
    final metaParts = <String>[
      if (manufacturer.isNotEmpty) manufacturer,
      if (approvalNo.isNotEmpty) '批准文号: $approvalNo',
    ];

    return DrugMedicineCardViewModel(
      productName: (row['productName'] ?? '未知药品').toString(),
      subtitle: subtitleParts.join(' · '),
      metaText: metaParts.join('  '),
      sourceLabel: source.isEmpty ? '' : (source == 'scan' ? '拍照识别' : '手动搜索'),
      sourceColor: source == 'scan'
          ? const Color(0xFF10B981)
          : const Color(0xFF0EA5E9),
      dateText: _formatDate(createdAt),
    );
  }

  /// 药品名称（为空时一般会兜底为“未知药品”）。
  final String productName;

  /// 副标题（剂型 + 规格）。
  final String subtitle;

  /// 额外元信息（厂家/批准文号等拼接文本）。
  final String metaText;

  /// 来源徽标文本（例如“拍照识别”“手动搜索”）。
  final String sourceLabel;

  /// 来源徽标颜色。
  final Color sourceColor;

  /// 创建日期显示文本（yyyy-MM-dd）。
  final String dateText;
}

/// “我的药品”列表中的单个药品卡片组件。
///
/// 该组件只负责展示，点击/删除行为通过回调交由页面处理。
class DrugMyMedicineCard extends StatelessWidget {
  /// 创建一个药品卡片组件。
  const DrugMyMedicineCard({
    super.key,
    required this.row,
    required this.onDelete,
    required this.onTap,
  });

  /// 数据库行数据。
  final Map<String, dynamic> row;

  /// 点击删除按钮回调。
  final VoidCallback onDelete;

  /// 点击卡片回调。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    /// 将原始行数据转换为 UI 渲染友好的展示模型。
    final item = DrugMedicineCardViewModel.fromRow(row);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF475569);
    final metaColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF94A3B8);
    final dateColor = isDark
        ? const Color(0xFF7F8DA3)
        : const Color(0xFFB0BAC8);

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);

          return AppSurfaceCard(
            radius: 16,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 10 : 12,
                  compact ? 10 : 12,
                  compact ? 10 : 12,
                  compact ? 10 : 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: compact ? 40 : 44,
                      height: compact ? 40 : 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(compact ? 12 : 14),
                      ),
                      child: Icon(
                        Icons.medication_rounded,
                        color: const Color(0xFF0EA5E9),
                        size: compact ? 22 : 24,
                      ),
                    ),
                    SizedBox(width: compact ? 10 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: compact ? 14.5 : 15,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                          if (item.subtitle.isNotEmpty) ...[
                            SizedBox(height: compact ? 2 : 3),
                            Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: compact ? 12 : 12.5,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                          if (item.metaText.isNotEmpty) ...[
                            SizedBox(height: compact ? 2 : 3),
                            Text(
                              item.metaText,
                              style: TextStyle(
                                fontSize: compact ? 11 : 11.5,
                                color: metaColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: compact ? 5 : 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (item.sourceLabel.isNotEmpty)
                                _DrugBadge(
                                  text: item.sourceLabel,
                                  color: item.sourceColor,
                                ),
                              if (item.dateText.isNotEmpty)
                                Text(
                                  item.dateText,
                                  style: TextStyle(
                                    fontSize: compact ? 10.5 : 11,
                                    color: dateColor,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onDelete,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, top: 2),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: compact ? 19 : 20,
                          color: Colors.red.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 药品页“快捷入口”区域的单个入口卡片组件。
class DrugQuickEntryCard extends StatelessWidget {
  /// 创建一个快捷入口卡片组件。
  const DrugQuickEntryCard({
    super.key,
    required this.item,
    required this.onTap,
    this.metrics,
  });

  /// 当前入口的数据对象。
  final DrugQuickEntry item;

  /// 点击回调。
  final VoidCallback onTap;

  /// 由外层网格计算好的响应式尺寸。
  final ResponsiveQuickGridMetrics? metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedMetrics =
            metrics ??
            ResponsiveQuickGridMetrics.fromWidth(constraints.maxWidth);
        final compact = resolvedMetrics.isCompact;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final background = isDark
            ? const Color(0xFF182336)
            : const Color(0xFFF8FAFC);
        final border = isDark
            ? const Color(0xFF334155)
            : const Color(0xFFE2E8F0);
        final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subtitleColor = isDark
            ? const Color(0xFFCBD5E1)
            : const Color(0xFF64748B);

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: resolvedMetrics.itemPadding,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  child: SizedBox(
                    width: resolvedMetrics.iconBoxSize,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            resolvedMetrics.iconBorderRadius,
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.color,
                          size: resolvedMetrics.iconSize,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: resolvedMetrics.titleSpacing),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: compact ? 14 : 14.5,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: resolvedMetrics.subtitleSpacing),
                      Flexible(
                        child: Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: compact ? 11.5 : 12,
                            fontWeight: FontWeight.w600,
                            color: subtitleColor,
                            height: compact ? 1.2 : 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DrugBadge extends StatelessWidget {
  const _DrugBadge({required this.text, required this.color});

  /// 徽标显示文本。
  final String text;

  /// 徽标主题色。
  final Color color;

  @override
  Widget build(BuildContext context) {
    final compact = isCompactLayoutWidth(MediaQuery.sizeOf(context).width);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 7,
        vertical: compact ? 2.5 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: compact ? 10.5 : 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// 将毫秒时间戳格式化为 `yyyy-MM-dd`。
///
/// - 输入为空或不可解析时返回空字符串；
/// - 这样 UI 层可以用 `isNotEmpty` 判断是否展示日期。
String _formatDate(dynamic createdAt) {
  if (createdAt == null) {
    return '';
  }
  final milliseconds = createdAt is int
      ? createdAt
      : int.tryParse(createdAt.toString());
  if (milliseconds == null || milliseconds <= 0) {
    return '';
  }
  final date = DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: false);
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
