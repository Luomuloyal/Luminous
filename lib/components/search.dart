import 'package:flutter/material.dart';
import 'package:luminous/components/app_surface.dart';

/// 搜索页（Search）可复用 UI 组件集合。
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

/// 搜索页统一使用的白色表面卡片容器。
///
/// 用于保持搜索框、结果卡片等区域的视觉一致性。
class SearchSurfaceCard extends StatelessWidget {
  const SearchSurfaceCard({
    super.key,
    required this.child,
    this.decorated = false,
    this.accentColor,
    this.secondaryColor,
    this.ornamentKey,
  });

  /// 卡片内部内容。
  final Widget child;
  final bool decorated;
  final Color? accentColor;
  final Color? secondaryColor;
  final String? ornamentKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (decorated) {
      return AppSectionCard(
        radius: 16,
        padding: EdgeInsets.zero,
        accentColor: accentColor ?? scheme.primary,
        secondaryColor:
            secondaryColor ??
            Color.lerp(scheme.secondary, scheme.tertiary, 0.5),
        ornamentKey: ornamentKey,
        child: child,
      );
    }
    return AppSurfaceCard(radius: 16, child: child);
  }
}

/// 搜索结果列表中的单个药品卡片。
///
/// 组件只负责展示，点击卡片和点击“添加”分别通过回调交给页面处理。
class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
    super.key,
    required this.item,
    required this.onTap,
    this.isAdded = false,
    this.onAdd,
  });

  /// 当前卡片对应的展示数据。
  final SearchResultItemData item;

  /// 点击整张卡片回调（通常进入详情页）。
  final VoidCallback onTap;

  /// 是否已添加到"我的药品"
  final bool isAdded;

  /// 点击"添加"回调；传 null 表示禁用（已添加）
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final titleColor = scheme.onSurface;
    final subtitleColor = scheme.onSurfaceVariant;
    final badgeBackground = appTintedSurface(
      context,
      scheme.primary,
      lightAlpha: 0.09,
      darkAlpha: 0.16,
    );
    final badgeTextColor = scheme.primary;
    final addedBackground = appTintedSurface(
      context,
      const Color(0xFF16A34A),
      lightAlpha: 0.08,
      darkAlpha: 0.14,
    );
    final addedBorder = appTintedBorder(
      context,
      const Color(0xFF16A34A),
      lightAlpha: 0.14,
      darkAlpha: 0.20,
    );
    final addBackground = appTintedSurface(
      context,
      scheme.primary,
      lightAlpha: 0.08,
      darkAlpha: 0.14,
    );
    final addBorder = appTintedBorder(
      context,
      scheme.primary,
      lightAlpha: 0.14,
      darkAlpha: 0.20,
    );

    return SearchSurfaceCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 药品图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medication_liquid_rounded,
                  size: 22,
                  color: Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(width: 10),
              // 药品信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 110),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBackground,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.badge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: TextStyle(fontSize: 13, color: subtitleColor),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: subtitleColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.tips,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: subtitleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 添加到我的药品按钮
                    GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isAdded ? addedBackground : addBackground,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isAdded ? addedBorder : addBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAdded
                                  ? Icons.check_circle_rounded
                                  : Icons.add_circle_outline_rounded,
                              size: 14,
                              color: isAdded
                                  ? const Color(0xFF16A34A)
                                  : scheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAdded ? '已添加' : '添加到我的药品',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isAdded
                                    ? const Color(0xFF16A34A)
                                    : scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
