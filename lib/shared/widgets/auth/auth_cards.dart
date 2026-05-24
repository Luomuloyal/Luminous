part of 'auth.dart';

/// 认证页面中用于承载表单的浅色装饰卡片。
///
/// 实现逻辑与手动搜索页保持一致：
/// - 装饰开启时使用 [AppSectionCard] 注入氛围装饰；
/// - 装饰关闭时回退到普通 [AppSurfaceCard]；
/// - 默认把装饰强度压低到 `0.2`，避免喧宾夺主。
class AuthSurfaceCard extends StatelessWidget {
  const AuthSurfaceCard({
    super.key,
    required this.child,
    this.ornamentKey,
    this.ornamentVisibilityScale = 0.2,
    this.radius = 18,
  });

  final Widget child;
  final String? ornamentKey;
  final double ornamentVisibilityScale;
  final double radius;

  Widget _buildContent(
    BuildContext context, {
    required bool ornamentsDisabled,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = Color.lerp(scheme.primary, scheme.secondary, 0.30)!;
    final secondaryColor = Color.lerp(scheme.secondary, scheme.tertiary, 0.45)!;
    final baseColor = scheme.surface.withValues(alpha: isDark ? 0.40 : 0.76);
    final borderColor = appTintedBorder(
      context,
      accentColor,
      lightAlpha: 0.16,
      darkAlpha: 0.22,
    );

    if (ornamentsDisabled) {
      return AppSurfaceCard(
        radius: radius,
        color: baseColor,
        borderColor: borderColor,
        child: child,
      );
    }

    return AppSectionCard(
      radius: radius,
      padding: EdgeInsets.zero,
      accentColor: accentColor,
      secondaryColor: secondaryColor,
      baseColor: baseColor,
      ornamentKey: ornamentKey ?? 'auth.surface',
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

/// 登录/注册页顶部的 Hero 卡片。
///
/// 用于统一展示页面 icon、标题和副标题。
class AuthHeroCard extends StatelessWidget {
  /// 创建一个 Hero 卡片组件。
  const AuthHeroCard({
    super.key,
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ornamentKey,
  });

  /// Hero 卡片使用的浅色横幅配色。
  final SoftBannerPalette palette;

  /// Hero 左侧图标。
  final IconData icon;

  /// Hero 主标题。
  final String title;

  /// Hero 副标题。
  final String subtitle;
  final String? ornamentKey;

  @override
  Widget build(BuildContext context) {
    return SoftBannerCard(
      palette: palette,
      ornamentKey: ornamentKey ?? 'auth.hero.$title',
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      borderRadius: BorderRadius.circular(18),
      builder: (context, theme) {
        return Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.borderColor),
              ),
              child: Icon(icon, color: theme.accentColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.secondaryTextColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
