import 'package:flutter/material.dart';

/// 顶部浅色渐变横幅配色基底。
class SoftBannerPalette {
  /// 主渐变起始色。
  final Color startColor;

  /// 主渐变结束色。
  final Color endColor;

  /// 横幅装饰色。
  final Color accentColor;

  /// 主文字颜色。
  final Color textColor;

  /// 次文字颜色。
  final Color secondaryTextColor;

  /// 轻按钮/胶囊背景色。
  final Color surfaceColor;

  /// 轻按钮/胶囊文字色。
  final Color surfaceTextColor;

  /// 描边颜色。
  final Color borderColor;

  /// 阴影颜色。
  final Color shadowColor;

  /// 创建一个横幅配色基底。
  const SoftBannerPalette({
    required this.startColor,
    required this.endColor,
    required this.accentColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.surfaceColor,
    required this.surfaceTextColor,
    required this.borderColor,
    required this.shadowColor,
  });

  /// 根据配色基底生成横幅主题。
  SoftBannerTheme createTheme() {
    return SoftBannerTheme._(
      startColor: startColor,
      endColor: endColor,
      accentColor: accentColor,
      textColor: textColor,
      secondaryTextColor: secondaryTextColor,
      surfaceColor: surfaceColor,
      surfaceTextColor: surfaceTextColor,
      borderColor: borderColor,
      shadowColor: shadowColor,
    );
  }
}

/// 顶部浅色渐变横幅主题。
class SoftBannerTheme {
  final Color startColor;
  final Color endColor;
  final Color accentColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color surfaceColor;
  final Color surfaceTextColor;
  final Color borderColor;
  final Color shadowColor;

  const SoftBannerTheme._({
    required this.startColor,
    required this.endColor,
    required this.accentColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.surfaceColor,
    required this.surfaceTextColor,
    required this.borderColor,
    required this.shadowColor,
  });
}

/// 预设的横幅配色基底集合。
class SoftBannerPalettes {
  SoftBannerPalettes._();

  static const SoftBannerPalette home = SoftBannerPalette(
    startColor: Color(0xFFE9FFFA),
    endColor: Color(0xFFEAF3FF),
    accentColor: Color(0xFF5BB9F0),
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF475569),
    surfaceColor: Color(0xCCFFFFFF),
    surfaceTextColor: Color(0xFF0F766E),
    borderColor: Color(0xFFD7F5F1),
    shadowColor: Color(0x140F172A),
  );

  static const SoftBannerPalette album = SoftBannerPalette(
    startColor: Color(0xFFF9F7EE),
    endColor: Color(0xFFEAF4FF),
    accentColor: Color(0xFFF2C45B),
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF475569),
    surfaceColor: Color(0xCCFFFFFF),
    surfaceTextColor: Color(0xFF9A5800),
    borderColor: Color(0xFFF5E7C0),
    shadowColor: Color(0x140F172A),
  );

  static const SoftBannerPalette mine = SoftBannerPalette(
    startColor: Color(0xFFF0FFFA),
    endColor: Color(0xFFEAF3FF),
    accentColor: Color(0xFFF4C54F),
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF475569),
    surfaceColor: Color(0xCCFFFFFF),
    surfaceTextColor: Color(0xFF0F766E),
    borderColor: Color(0xFFD7F5F1),
    shadowColor: Color(0x140F172A),
  );

  static const SoftBannerPalette auth = SoftBannerPalette(
    startColor: Color(0xFFEAF6FF),
    endColor: Color(0xFFEFFAFE),
    accentColor: Color(0xFF7CC4F8),
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF475569),
    surfaceColor: Color(0xCCFFFFFF),
    surfaceTextColor: Color(0xFF0F4C81),
    borderColor: Color(0xFFD9ECFF),
    shadowColor: Color(0x140F172A),
  );
}

/// 浅色渐变横幅容器。
class SoftBannerCard extends StatelessWidget {
  const SoftBannerCard({
    super.key,
    required this.palette,
    required this.builder,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  final SoftBannerPalette palette;

  /// 允许调用方根据 theme 调整前景色（标题、chip、按钮等）。
  final Widget Function(BuildContext context, SoftBannerTheme theme) builder;

  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = palette.createTheme();
    final mainBlob = _BlobSpec(
      width: 118,
      height: 118,
      top: -44,
      right: -42,
      color: theme.accentColor.withValues(alpha: 0.16),
    );
    final sparkBlob = _BlobSpec(
      width: 24,
      height: 24,
      top: 32,
      right: 72,
      color: theme.accentColor.withValues(alpha: 0.28),
    );
    final cornerBlob = _BlobSpec(
      width: 132,
      height: 132,
      bottom: -70,
      left: -66,
      color: theme.accentColor.withValues(alpha: 0.08),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: theme.borderColor),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.startColor, theme.endColor],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned(
              top: mainBlob.top,
              right: mainBlob.right,
              child: _SoftBannerBlob.fromSpec(mainBlob),
            ),
            Positioned(
              top: sparkBlob.top,
              right: sparkBlob.right,
              child: _SoftBannerBlob.fromSpec(sparkBlob),
            ),
            Positioned(
              bottom: cornerBlob.bottom,
              left: cornerBlob.left,
              child: _SoftBannerBlob.fromSpec(cornerBlob),
            ),
            Padding(padding: padding, child: builder(context, theme)),
          ],
        ),
      ),
    );
  }
}

class _SoftBannerBlob extends StatelessWidget {
  const _SoftBannerBlob._({
    required this.width,
    required this.height,
    required this.color,
  });

  factory _SoftBannerBlob.fromSpec(_BlobSpec spec) {
    return _SoftBannerBlob._(
      width: spec.width,
      height: spec.height,
      color: spec.color,
    );
  }

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _BlobSpec {
  const _BlobSpec({
    required this.width,
    required this.height,
    this.top,
    this.right,
    this.bottom,
    this.left,
    required this.color,
  });

  final double width;
  final double height;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final Color color;
}
