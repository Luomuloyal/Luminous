import 'package:flutter/material.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/responsive_quick_grid.dart';
import 'package:luminous/components/shared_quick_entry_card.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/components/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:luminous/viewmodels/mine.dart';

/// 我的页（Mine）可复用 UI 组件集合。
///
/// 页面层负责：
/// - 登录态判断；
/// - 点击事件与路由跳转；
/// 这里负责：
/// - 背景装饰；
/// - ProfileCard、QuickActions、Menu 的布局与样式。
class MineProfileCard extends StatelessWidget {
  const MineProfileCard({
    super.key,
    required this.palette,
    required this.user,
    required this.onTapProfile,
    required this.onTapAction,
    this.loggedInActionLabel,
  });

  /// 顶部横幅配色。
  final SoftBannerPalette palette;

  /// 当前登录用户（未登录时为 null）。
  final UserSafe? user;

  /// 点击头像/昵称区域回调。
  final VoidCallback onTapProfile;

  /// 点击右侧按钮回调（登录态与未登录态由页面层自行定义跳转）。
  final VoidCallback onTapAction;

  /// 登录后的右侧按钮文案（可选，未传时使用本地化默认文案）。
  final String? loggedInActionLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLoggedIn = user?.hasData ?? false;
    final displayUser = user;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = isCompactLayoutWidth(constraints.maxWidth);

        return SoftBannerCard(
          palette: palette,
          ornamentKey: 'mine.profile',
          padding: EdgeInsets.all(compact ? 16 : 18),
          builder: (context, theme) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: onTapProfile,
                      child: Container(
                        width: compact ? 52 : 56,
                        height: compact ? 52 : 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.surfaceColor,
                          border: Border.all(color: theme.borderColor),
                        ),
                        child: Icon(
                          isLoggedIn
                              ? Icons.verified_user_rounded
                              : Icons.person_outline_rounded,
                          color: theme.accentColor,
                          size: compact ? 26 : 28,
                        ),
                      ),
                    ),
                    SizedBox(width: compact ? 12 : 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: onTapProfile,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLoggedIn
                                  ? displayUser!.displayTitle
                                  : (l10n?.mineProfileLoginNow ?? '立即登录'),
                              style: TextStyle(
                                color: theme.textColor,
                                fontSize: compact ? 18 : 20,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isLoggedIn
                                  ? displayUser!.displaySubtitle
                                  : (l10n?.mineProfileLoginHint ??
                                        '登录后可管理账号信息与同步个人数据'),
                              style: TextStyle(
                                color: theme.secondaryTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: compact ? 8 : 10),
                    FilledButton(
                      onPressed: onTapAction,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.surfaceColor,
                        foregroundColor: theme.surfaceTextColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        minimumSize: Size(compact ? 72 : 88, compact ? 36 : 40),
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 14 : 16,
                        ),
                      ),
                      child: Text(
                        isLoggedIn
                            ? (loggedInActionLabel ??
                                  l10n?.mineLoggedInActionLabel ??
                                  '设置')
                            : (l10n?.mineProfileLoginAction ?? '去登录'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TintedStatusChip(
                      icon: isLoggedIn
                          ? Icons.cloud_done_rounded
                          : Icons.phone_android_rounded,
                      text: isLoggedIn
                          ? (l10n?.mineProfileChipAccountConnected ?? '账号已连接')
                          : (l10n?.mineProfileChipLocalOnly ?? '当前本地体验'),
                      color: theme.surfaceTextColor,
                      backgroundColor: theme.surfaceColor,
                      borderColor: theme.surfaceTextColor.withValues(
                        alpha: isDark ? 0.28 : 0.20,
                      ),
                      iconSize: 16,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w700,
                      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                    ),
                    TintedStatusChip(
                      icon: Icons.image_outlined,
                      text: l10n?.mineProfileChipImageLocalOnly ?? '原图仅本机保存',
                      color: theme.surfaceTextColor,
                      backgroundColor: theme.surfaceColor,
                      borderColor: theme.surfaceTextColor.withValues(
                        alpha: isDark ? 0.28 : 0.20,
                      ),
                      iconSize: 16,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w700,
                      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                    ),
                    TintedStatusChip(
                      icon: Icons.auto_awesome_rounded,
                      text: isLoggedIn
                          ? (l10n?.mineProfileChipSyncEnabled ?? '可同步轻量结果')
                          : (l10n?.mineProfileChipSyncAfterLogin ?? '登录后开启轻同步'),
                      color: theme.surfaceTextColor,
                      backgroundColor: theme.surfaceColor,
                      borderColor: theme.surfaceTextColor.withValues(
                        alpha: isDark ? 0.28 : 0.20,
                      ),
                      iconSize: 16,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w700,
                      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// 我的页主布局组件。
///
/// 该组件是纯布局/展示组件，所有点击逻辑由页面层通过回调注入。
class MinePage extends StatelessWidget {
  const MinePage({
    super.key,
    required this.headerPalette,
    required this.profileCard,
    required this.quickActions,
    required this.onTapQuickAction,
    required this.onTapBrowseHistory,
    required this.onTapSecurity,
    required this.onTapAbout,
  });

  /// 顶部横幅配色。
  final SoftBannerPalette headerPalette;

  /// 顶部用户信息卡。
  final Widget profileCard;

  /// 快捷入口列表数据。
  final List<MineQuickActionData> quickActions;

  /// 点击某个快捷入口回调（传入其 id）。
  final ValueChanged<String> onTapQuickAction;

  /// 点击“浏览记录”回调。
  final VoidCallback onTapBrowseHistory;

  /// 点击“账号与安全”回调。
  final VoidCallback onTapSecurity;

  /// 点击“关于”回调。
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

  /// 快捷入口数据列表。
  final List<MineQuickActionData> items;

  /// 点击某个入口回调。
  final ValueChanged<MineQuickActionData> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = isCompactLayoutWidth(constraints.maxWidth);
        final metrics = ResponsiveQuickGridMetrics.fromWidth(
          constraints.maxWidth - ((compact ? 12 : 14) * 2),
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: metrics.gridDelegate,
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
    required this.onTapSecurity,
    required this.onTapAbout,
  });

  /// 点击“浏览记录”回调。
  final VoidCallback onTapBrowseHistory;

  /// 点击“账号与安全”回调。
  final VoidCallback onTapSecurity;

  /// 点击“关于”回调。
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
              _MineMenuItem(
                compact: compact,
                icon: Icons.history_rounded,
                title: l10n?.mineMenuHistoryTitle ?? '浏览记录',
                subtitle: l10n?.mineMenuHistorySubtitle ?? '你最近查看过的药品',
                accentColor: scheme.secondary,
                onTap: onTapBrowseHistory,
              ),
              Divider(height: 1, color: dividerColor),
              _MineMenuItem(
                compact: compact,
                icon: Icons.shield_rounded,
                title: l10n?.mineMenuSecurityTitle ?? '账号与安全',
                subtitle: l10n?.mineMenuSecuritySubtitle ?? '隐私设置与安全选项',
                accentColor: scheme.primary,
                onTap: onTapSecurity,
              ),
              Divider(height: 1, color: dividerColor),
              _MineMenuItem(
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

class _MineMenuItem extends StatelessWidget {
  const _MineMenuItem({
    required this.compact,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  /// 当前是否使用手机端紧凑布局。
  final bool compact;

  /// 左侧图标。
  final IconData icon;

  /// 主标题。
  final String title;

  /// 副标题。
  final String subtitle;

  final Color accentColor;

  /// 点击回调。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: compact ? 14 : 14.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
