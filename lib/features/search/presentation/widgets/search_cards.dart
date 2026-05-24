import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/core/theme/ornaments/ornament_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/viewmodels/search.dart';

/// 搜索页（Search）可复用 UI 组件集合。
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
    this.ornamentVisibilityScale = 1,
  });

  final Widget child;
  final bool decorated;
  final Color? accentColor;
  final Color? secondaryColor;
  final String? ornamentKey;
  final double ornamentVisibilityScale;

  Widget _buildContent(
    BuildContext context, {
    required bool ornamentsDisabled,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedAccent = accentColor ?? scheme.primary;
    final resolvedSecondary =
        secondaryColor ?? Color.lerp(scheme.secondary, scheme.tertiary, 0.5)!;
    final baseColor = scheme.surface.withValues(alpha: isDark ? 0.42 : 0.82);
    final borderColor = appTintedBorder(
      context,
      resolvedAccent,
      lightAlpha: 0.16,
      darkAlpha: 0.24,
    );

    if (ornamentsDisabled) {
      return AppSurfaceCard(
        radius: 16,
        color: baseColor,
        borderColor: borderColor,
        child: child,
      );
    }

    if (decorated) {
      return AppSectionCard(
        radius: 16,
        padding: EdgeInsets.zero,
        accentColor: resolvedAccent,
        secondaryColor: resolvedSecondary,
        baseColor: baseColor,
        ornamentKey: ornamentKey,
        ornamentVisibilityScale: ornamentVisibilityScale,
        surfaceBorderColor: borderColor,
        child: child,
      );
    }

    return AppSectionCard(
      radius: 16,
      padding: EdgeInsets.zero,
      accentColor: resolvedAccent,
      secondaryColor: resolvedSecondary,
      baseColor: baseColor,
      ornamentKey: 'search.item',
      ornamentVisibilityScale: ornamentVisibilityScale,
      surfaceBorderColor: borderColor,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (maybeOrnamentContainerOf(context) == null) {
      return _buildContent(context, ornamentsDisabled: false);
    }
    return Consumer(
      builder: (context, ref, _) {
        final ornamentState = ref.watch(ornamentProvider);
        return _buildContent(
          context,
          ornamentsDisabled: ornamentState.isDisabled,
        );
      },
    );
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

  final SearchResultItemData item;
  final VoidCallback onTap;
  final bool isAdded;
  final VoidCallback? onAdd;

  String _resolveDosageType() {
    final source = '${item.badge} ${item.subtitle}'.toLowerCase();
    if (source.contains('注射') ||
        source.contains('针') ||
        source.contains('inject')) {
      return 'inject';
    }
    if (source.contains('胶囊') || source.contains('capsule')) {
      return 'capsule';
    }
    if (source.contains('片') || source.contains('tablet')) {
      return 'tablet';
    }
    if (source.contains('颗粒') || source.contains('granule')) {
      return 'granule';
    }
    if (source.contains('口服液') ||
        source.contains('糖浆') ||
        source.contains('混悬') ||
        source.contains('liquid') ||
        source.contains('syrup')) {
      return 'liquid';
    }
    return 'default';
  }

  IconData _resolveDosageIcon(String type) {
    switch (type) {
      case 'inject':
        return Icons.vaccines_rounded;
      case 'capsule':
        return Icons.medication_rounded;
      case 'tablet':
        return Icons.bubble_chart_rounded;
      case 'granule':
        return Icons.grain;
      case 'liquid':
        return Icons.water_drop_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  Color _resolveDosageColor(String type) {
    switch (type) {
      case 'inject':
        return const Color(0xFFE11D48);
      case 'capsule':
        return const Color(0xFF2563EB);
      case 'tablet':
        return const Color(0xFFEA580C);
      case 'granule':
        return const Color(0xFF7C3AED);
      case 'liquid':
        return const Color(0xFF0891B2);
      default:
        return const Color(0xFF475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
    final dosageType = _resolveDosageType();
    final dosageColor = _resolveDosageColor(dosageType);
    final dosageIcon = _resolveDosageIcon(dosageType);

    return SearchSurfaceCard(
      ornamentVisibilityScale: 0.2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: dosageColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: dosageColor.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(dosageIcon, size: 19, color: dosageColor),
              ),
              const SizedBox(width: 8),
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
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 110),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
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
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.8,
                        color: subtitleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.tips.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.tips,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.2,
                          color: subtitleColor.withValues(alpha: 0.86),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
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
                              size: 13,
                              color: isAdded
                                  ? const Color(0xFF16A34A)
                                  : scheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAdded
                                  ? (l10n?.searchResultAddedLabel ?? '已添加')
                                  : (l10n?.searchResultAddActionLabel ??
                                        '添加到我的药品'),
                              style: TextStyle(
                                fontSize: 11.5,
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
