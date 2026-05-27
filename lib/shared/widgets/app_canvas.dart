import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 全局浅色环境背景。
///
/// 不直接给每个组件叠彩色块，而是在页面底层铺一层很淡的环境光，
/// 让页面更柔和、卡片更干净。
class AppCanvas extends StatelessWidget {
  const AppCanvas({
    super.key,
    required this.child,
    required this.accentColor,
    this.secondaryAccentColor = const Color(0xFFDCCEFF),
    this.baseColor,
  });

  final Widget child;
  final Color accentColor;
  final Color secondaryAccentColor;
  final Color? baseColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = baseColor ?? theme.scaffoldBackgroundColor;
    final midBlend = Color.lerp(accentColor, secondaryAccentColor, 0.5)!;
    final topTint = Color.alphaBlend(
      accentColor.withValues(alpha: isDark ? 0.04 : 0.024),
      background,
    );
    final bottomTint = Color.alphaBlend(
      secondaryAccentColor.withValues(alpha: isDark ? 0.036 : 0.022),
      background,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.5, 1],
          colors: [topTint, background, bottomTint],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -140,
            right: -130,
            child: _CanvasOrb(
              size: 320,
              colors: [
                accentColor.withValues(alpha: isDark ? 0.045 : 0.052),
                accentColor.withValues(alpha: 0),
              ],
            ),
          ),
          Positioned(
            top: 252,
            left: -102,
            child: _CanvasOrb(
              size: 246,
              colors: [
                midBlend.withValues(alpha: isDark ? 0.022 : 0.028),
                accentColor.withValues(alpha: 0),
              ],
            ),
          ),
          Positioned(
            bottom: -148,
            left: -124,
            child: _CanvasOrb(
              size: 342,
              colors: [
                secondaryAccentColor.withValues(alpha: isDark ? 0.04 : 0.05),
                secondaryAccentColor.withValues(alpha: 0),
              ],
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// 带有 [AppCanvas] 背景的通用页面骨架。
///
/// 适合"透明 AppBar + 渐变环境光背景"的详情/选择类页面：
/// - 让背景连续覆盖到状态栏与 AppBar 区域；
/// - 统一处理状态栏图标明暗；
/// - 让内容区域默认从 AppBar 下方开始，避免压到标题栏。
/// - 通过 [maxContentWidth] 可在宽屏上限制内容可读宽度。
class AppCanvasPageScaffold extends StatelessWidget {
  const AppCanvasPageScaffold({
    super.key,
    required this.child,
    required this.accentColor,
    this.secondaryAccentColor = const Color(0xFFDCCEFF),
    this.baseColor,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.reserveAppBarSpace = true,
    this.safeAreaBottom = false,
    this.appBarSpacing,
    this.maxContentWidth,
  });

  final Widget child;
  final Color accentColor;
  final Color secondaryAccentColor;
  final Color? baseColor;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool reserveAppBarSpace;
  final bool safeAreaBottom;
  final double? appBarSpacing;

  /// 内容最大宽度，用于在大屏上限制阅读宽度。
  ///
  /// 为 `null` 时不约束（默认），适用于紧凑布局。设置后内容将居中显示，
  /// 最大宽度不会超过该值。典型取值参考 [AppContentWidths]。
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = baseColor ?? theme.scaffoldBackgroundColor;
    final toolbarHeight = appBar?.preferredSize.height ?? 0.0;
    final resolvedSpacing = (appBarSpacing ?? toolbarHeight)
        .clamp(0.0, double.infinity)
        .toDouble();
    final topSpacing = appBar == null || !reserveAppBarSpace
        ? 0.0
        : resolvedSpacing;
    final isDark = theme.brightness == Brightness.dark;
    final overlayStyle =
        (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: background,
              systemNavigationBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            );

    Widget bodyContent = AppCanvas(
      accentColor: accentColor,
      secondaryAccentColor: secondaryAccentColor,
      baseColor: background,
      child: SafeArea(
        bottom: safeAreaBottom,
        child: Column(
          children: [
            if (topSpacing > 0) SizedBox(height: topSpacing),
            Expanded(child: child),
          ],
        ),
      ),
    );

    if (maxContentWidth != null && maxContentWidth! > 0) {
      bodyContent = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth!),
          child: bodyContent,
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: background,
        extendBodyBehindAppBar: appBar != null,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
        body: bodyContent,
      ),
    );
  }
}

class _CanvasOrb extends StatelessWidget {
  const _CanvasOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
