part of 'auth.dart';

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
