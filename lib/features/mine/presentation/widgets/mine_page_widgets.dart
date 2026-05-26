import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/responsive_quick_grid.dart';
import 'package:luminous/shared/widgets/shared_quick_entry_card.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/mine/presentation/models/mine.dart';

/// 我的页主布局组件。
///
/// 纯布局/展示组件，所有点击逻辑由页面层通过回调注入。
class MinePageLayout extends StatelessWidget {
  const MinePageLayout({
    super.key,
    required this.headerPalette,
    required this.profileCard,
    required this.quickActions,
    required this.onTapQuickAction,
    required this.onTapBrowseHistory,
    this.browseHistorySubtitle,
    this.browseHistoryBadgeText,
    required this.onTapSecurity,
    required this.onTapAbout,
  });

  final SoftBannerPalette headerPalette;
  final Widget profileCard;
  final List<MineQuickActionData> quickActions;
  final ValueChanged<String> onTapQuickAction;
  final VoidCallback onTapBrowseHistory;
  final String? browseHistorySubtitle;
  final String? browseHistoryBadgeText;
  final VoidCallback onTapSecurity;
  final VoidCallback onTapAbout;

  @override
  Widget build(BuildContext context) {
    final compact = isCompactLayoutWidth(MediaQuery.sizeOf(context).width);

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          compact ? 8 : 10,
          16,
          compact ? 20 : 24,
        ),
        children: [
          profileCard,
          SizedBox(height: compact ? 10 : 12),
          MineQuickActionsSection(
            items: quickActions,
            onTap: (item) => onTapQuickAction(item.id),
          ),
          SizedBox(height: compact ? 10 : 12),
          MineMenuCard(
            onTapBrowseHistory: onTapBrowseHistory,
            browseHistorySubtitle: browseHistorySubtitle,
            browseHistoryBadgeText: browseHistoryBadgeText,
            onTapSecurity: onTapSecurity,
            onTapAbout: onTapAbout,
          ),
        ],
      ),
    );
  }
}

/// 快捷入口网格区域。
class MineQuickActionsSection extends StatelessWidget {
  const MineQuickActionsSection({
    super.key,
    required this.items,
    required this.onTap,
  });

  final List<MineQuickActionData> items;
  final ValueChanged<MineQuickActionData> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = isCompactLayoutWidth(constraints.maxWidth);
        final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
        final metrics = ResponsiveQuickGridMetrics.fromWidth(
          constraints.maxWidth,
          textScaleFactor: textScaleFactor,
        );

        return AppSectionCard(
          accentColor: Color.lerp(scheme.secondary, scheme.tertiary, 0.32)!,
          secondaryColor: Color.lerp(scheme.primary, scheme.secondary, 0.48)!,
          ornamentKey: 'mine.quick-actions',
          padding: EdgeInsets.all(metrics.sectionPadding),
          radius: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n?.mineQuickSectionTitle ?? '常用入口',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: appTintedSurface(
                        context,
                        Color.lerp(scheme.secondary, scheme.tertiary, 0.4)!,
                        lightAlpha: 0.10,
                        darkAlpha: 0.20,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: appTintedBorder(
                          context,
                          scheme.secondary,
                          lightAlpha: 0.18,
                          darkAlpha: 0.28,
                        ),
                      ),
                    ),
                    child: Text(
                      l10n?.mineQuickSectionCount(items.length) ??
                          '${items.length} 项',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: scheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                l10n?.mineQuickSectionSubtitle ?? '把账号、同步和设备相关入口集中到一起',
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: compact ? 12 : 14),
              ResponsiveQuickWrap(
                metrics: metrics,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return SharedQuickEntryCard(
                    icon: item.icon,
                    title: item.title,
                    subtitle: item.subtitle,
                    color: item.color,
                    metrics: metrics,
                    repaintBoundary: true,
                    onTap: () => onTap(item),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 菜单卡片区域。
class MineMenuCard extends StatelessWidget {
  const MineMenuCard({
    super.key,
    required this.onTapBrowseHistory,
    this.browseHistorySubtitle,
    this.browseHistoryBadgeText,
    required this.onTapSecurity,
    required this.onTapAbout,
  });

  final VoidCallback onTapBrowseHistory;
  final String? browseHistorySubtitle;
  final String? browseHistoryBadgeText;
  final VoidCallback onTapSecurity;
  final VoidCallback onTapAbout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = isCompactLayoutWidth(constraints.maxWidth);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final dividerColor = scheme.outline.withValues(
          alpha: isDark ? 0.86 : 0.72,
        );

        return AppSectionCard(
          accentColor: Color.lerp(scheme.secondary, scheme.primary, 0.35)!,
          secondaryColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.4)!,
          ornamentKey: 'mine.menu',
          padding: EdgeInsets.zero,
          radius: 18,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  compact ? 12 : 14,
                  14,
                  compact ? 10 : 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.mineMenuTitle ?? '更多设置',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n?.mineMenuSubtitle ?? '把浏览记录、账号安全和版本信息收拢到一个区域',
                      style: TextStyle(
                        fontSize: 12.8,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: dividerColor),
              MineMenuItem(
                compact: compact,
                icon: Icons.history_rounded,
                title: l10n?.mineMenuHistoryTitle ?? '浏览记录',
                subtitle:
                    browseHistorySubtitle ??
                    l10n?.mineMenuHistorySubtitle ??
                    '你最近查看过的药品',
                badgeText: browseHistoryBadgeText,
                accentColor: scheme.secondary,
                onTap: onTapBrowseHistory,
              ),
              Divider(height: 1, color: dividerColor),
              MineMenuItem(
                compact: compact,
                icon: Icons.shield_rounded,
                title: l10n?.mineMenuSecurityTitle ?? '账号与安全',
                subtitle: l10n?.mineMenuSecuritySubtitle ?? '隐私设置与安全选项',
                accentColor: scheme.primary,
                onTap: onTapSecurity,
              ),
              Divider(height: 1, color: dividerColor),
              MineMenuItem(
                compact: compact,
                icon: Icons.info_rounded,
                title: l10n?.mineMenuAboutTitle ?? '关于 Luminous',
                subtitle: l10n?.mineMenuAboutSubtitle ?? '版本信息与使用说明',
                accentColor: scheme.tertiary,
                onTap: onTapAbout,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 菜单中的单个条目。
class MineMenuItem extends StatelessWidget {
  const MineMenuItem({
    super.key,
    required this.compact,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeText,
    required this.accentColor,
    required this.onTap,
  });

  final bool compact;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badgeText;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trimmedBadge = (badgeText ?? '').trim();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: compact ? 10 : 12,
        ),
        child: Row(
          children: [
            Container(
              width: compact ? 36 : 40,
              height: compact ? 36 : 40,
              decoration: BoxDecoration(
                color: appTintedSurface(
                  context,
                  accentColor,
                  lightAlpha: 0.10,
                  darkAlpha: 0.18,
                ),
                borderRadius: BorderRadius.circular(compact ? 12 : 14),
              ),
              child: Icon(icon, color: accentColor, size: compact ? 20 : 24),
            ),
            SizedBox(width: compact ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: compact ? 14 : 14.5,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trimmedBadge.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        TintedStatusChip(
                          text: trimmedBadge,
                          color: accentColor,
                          enablePopup: false,
                          fontSize: 10.6,
                          fontWeight: FontWeight.w800,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: compact ? 1.5 : 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: compact ? 12 : 12.5,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      height: compact ? 1.25 : 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? accentColor.withValues(alpha: 0.84)
                  : accentColor.withValues(alpha: 0.76),
            ),
          ],
        ),
      ),
    );
  }
}
