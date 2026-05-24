import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/core/theme/ornaments/ornament_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 认证页面（登录/注册）可复用的 UI 组件集合。
///
/// 设计目标：
/// - 登录页与注册页共用相同风格的 Hero 卡、方法切换器、验证码卡、协议行；
/// - 页面本身只负责状态与交互，把可复用 UI 抽到 components 层。
class AuthMethodItem {
  /// 选项显示文本（例如“密码登录”“验证码登录”）。
  final String label;

  /// 当前选项是否处于选中状态。
  final bool selected;

  /// 点击该选项时的回调。
  final VoidCallback onTap;

  /// 创建一个方法切换器选项对象。
  const AuthMethodItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });
}

/// 登录/注册共用的页面骨架。
///
/// 重点处理两件事：
/// - 键盘弹出时只平滑抬升滚动内容，避免 `Scaffold` 整页生硬 resize；
/// - 保持移动端/宽屏端一致的内容宽度和滚动行为。
class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    super.key,
    required this.children,
    this.backgroundColor,
  });

  final List<Widget> children;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 600;
    final horizontalPadding = screenWidth < 600 ? 16.0 : 24.0;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scaffoldBackground = backgroundColor ?? theme.scaffoldBackgroundColor;
    final authPalette = SoftBannerPalettes.authOf(context);
    final canvasSecondary = Color.lerp(scheme.secondary, scheme.tertiary, 0.5)!;

    return Scaffold(
      backgroundColor: scaffoldBackground,
      resizeToAvoidBottomInset: false,
      body: AppCanvas(
        accentColor: authPalette.accentColor,
        secondaryAccentColor: canvasSecondary,
        baseColor: scaffoldBackground,
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(child: _AuthBackdropDecoration()),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 420 : double.infinity,
                  ),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      6,
                      horizontalPadding,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthBackdropDecoration extends StatelessWidget {
  const _AuthBackdropDecoration();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Color.lerp(scheme.primary, scheme.secondary, 0.22)!;
    final secondary = Color.lerp(scheme.secondary, scheme.tertiary, 0.40)!;
    final tertiary = Color.lerp(scheme.tertiary, scheme.primary, 0.26)!;

    return Stack(
      children: [
        Positioned(
          top: -42,
          left: -30,
          child: _AuthBackdropOrb(
            size: 176,
            color: primary.withValues(alpha: isDark ? 0.15 : 0.11),
          ),
        ),
        Positioned(
          top: 86,
          right: -24,
          child: _AuthBackdropOrb(
            size: 146,
            color: secondary.withValues(alpha: isDark ? 0.12 : 0.09),
          ),
        ),
        Positioned(
          left: 22,
          right: 22,
          top: 156,
          child: Container(
            height: 118,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary.withValues(alpha: isDark ? 0.06 : 0.05),
                  secondary.withValues(alpha: isDark ? 0.05 : 0.035),
                  tertiary.withValues(alpha: isDark ? 0.06 : 0.05),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: -36,
          bottom: 120,
          child: _AuthBackdropOrb(
            size: 190,
            color: tertiary.withValues(alpha: isDark ? 0.11 : 0.08),
          ),
        ),
      ],
    );
  }
}

class _AuthBackdropOrb extends StatelessWidget {
  const _AuthBackdropOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.45,
            spreadRadius: size * 0.08,
          ),
        ],
      ),
    );
  }
}

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

/// 登录页底部的协议提示文本。
class AuthLegalHint extends StatelessWidget {
  const AuthLegalHint({
    super.key,
    required this.onTapAgreement,
    required this.onTapPrivacy,
  });

  final VoidCallback onTapAgreement;
  final VoidCallback onTapPrivacy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final linkColor = Color.lerp(scheme.primary, scheme.secondary, 0.20)!;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n.authLegalPrefix,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
            height: 1.45,
          ),
        ),
        GestureDetector(
          onTap: onTapAgreement,
          child: Text(
            l10n.authUserAgreementTitle,
            style: TextStyle(
              fontSize: 11.5,
              color: linkColor,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ),
        Text(
          l10n.authLegalAnd,
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),
        GestureDetector(
          onTap: onTapPrivacy,
          child: Text(
            l10n.authPrivacyPolicyTitle,
            style: TextStyle(
              fontSize: 11.5,
              color: linkColor,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ),
      ],
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

/// 认证方式切换器。
///
/// 通常用于“邮箱登录/验证码登录”等切换场景，选中项使用高亮背景。
class AuthMethodSwitcher extends StatelessWidget {
  /// 创建一个方法切换器组件。
  const AuthMethodSwitcher({super.key, required this.items, this.accentColor});

  /// 可选项列表。
  final List<AuthMethodItem> items;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = accentColor ?? scheme.primary;
    final selectedStart = Color.lerp(accent, scheme.secondary, 0.16)!;
    final selectedEnd = Color.lerp(accent, scheme.tertiary, 0.10)!;
    const segmentSpacing = 8.0;
    final outerBackground = Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.07 : 0.032),
      theme.cardTheme.color ?? theme.colorScheme.surface,
    );
    final outerBorder = Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.16 : 0.10),
      scheme.outline,
    );
    final selectedIndex = items.indexWhere((item) => item.selected);
    final resolvedSelectedIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: outerBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outerBorder),
        boxShadow: isDark
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x100F172A),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final segmentWidth =
                (constraints.maxWidth - (items.length - 1) * segmentSpacing) /
                items.length;
            final selectedLeft =
                resolvedSelectedIndex * (segmentWidth + segmentSpacing);

            return SizedBox(
              height: 38,
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    left: selectedLeft,
                    top: 0,
                    width: segmentWidth,
                    height: 38,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [selectedStart, selectedEnd],
                        ),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: accent.withValues(alpha: isDark ? 0.28 : 0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(
                              alpha: isDark ? 0.16 : 0.20,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: items
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(
                              right: entry.key == items.length - 1
                                  ? 0
                                  : segmentSpacing,
                            ),
                            child: SizedBox(
                              width: segmentWidth,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(11),
                                  overlayColor:
                                      const WidgetStatePropertyAll<Color>(
                                        Colors.transparent,
                                      ),
                                  splashFactory: NoSplash.splashFactory,
                                  onTap: entry.value.onTap,
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 160,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      style: TextStyle(
                                        color: entry.value.selected
                                            ? Colors.white
                                            : (isDark
                                                  ? scheme.onSurface
                                                  : scheme.onSurface.withValues(
                                                      alpha: 0.84,
                                                    )),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                      child: Text(entry.value.label),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 协议与隐私政策勾选行。
///
/// 用于登录/注册页底部，统一实现“勾选 + 文本跳转”的交互。
class AuthAgreementRow extends StatelessWidget {
  /// 创建一个协议勾选行组件。
  const AuthAgreementRow({
    super.key,
    required this.agreed,
    required this.onChanged,
    required this.onTapAgreement,
    required this.onTapPrivacy,
  });

  /// 当前是否已勾选同意。
  final bool agreed;

  /// 勾选状态变更回调。
  final ValueChanged<bool> onChanged;

  /// 点击“用户协议”回调。
  final VoidCallback onTapAgreement;

  /// 点击“隐私政策”回调。
  final VoidCallback onTapPrivacy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final linkColor = Color.lerp(scheme.primary, scheme.secondary, 0.20)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: agreed,
          onChanged: (value) => onChanged(value ?? false),
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        ),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onChanged(!agreed),
                child: Text(
                  l10n.authAgreementPrefix,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTapAgreement,
                child: Text(
                  l10n.authUserAgreementTitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: linkColor,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(!agreed),
                child: Text(
                  l10n.authLegalAnd,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTapPrivacy,
                child: Text(
                  l10n.authPrivacyPolicyTitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: linkColor,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
