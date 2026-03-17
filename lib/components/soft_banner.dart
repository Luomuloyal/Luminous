import 'dart:math';

import 'package:flutter/material.dart';

/// 顶部浅色渐变横幅配色基底（不含随机 accent）。
class SoftBannerPalette {
  /// 主渐变起始色。
  final Color startColor;

  /// 主渐变结束色。
  final Color endColor;

  /// accent 颜色候选集（右上角小色块会从这里随机取一个）。
  final List<Color> accentPalette;

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
    required this.accentPalette,
    required this.textColor,
    required this.secondaryTextColor,
    required this.surfaceColor,
    required this.surfaceTextColor,
    required this.borderColor,
    required this.shadowColor,
  });

  /// 根据基底 + 随机 accent 生成最终主题。
  SoftBannerTheme createTheme({Random? random}) {
    final seeded = random ?? Random();
    final accent = accentPalette.isEmpty
        ? const Color(0xFF60A5FA)
        : accentPalette[seeded.nextInt(accentPalette.length)];
    return SoftBannerTheme._(
      startColor: startColor,
      endColor: endColor,
      accentColor: accent,
      textColor: textColor,
      secondaryTextColor: secondaryTextColor,
      surfaceColor: surfaceColor,
      surfaceTextColor: surfaceTextColor,
      borderColor: borderColor,
      shadowColor: shadowColor,
    );
  }
}

/// 顶部浅色渐变横幅主题（含随机 accent）。
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

  /// accent 颜色候选：蓝/粉等，作为“右上角小色块”的随机来源。
  static const List<Color> playfulAccents = [
    Color(0xFF60A5FA), // blue
    Color(0xFFF472B6), // pink
    Color(0xFFA78BFA), // violet
    Color(0xFF34D399), // green
    Color(0xFFFBBF24), // amber
  ];

  static const SoftBannerPalette home = SoftBannerPalette(
    startColor: Color(0xFFE9FFFA),
    endColor: Color(0xFFEAF3FF),
    accentPalette: playfulAccents,
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF475569),
    surfaceColor: Color(0xCCFFFFFF),
    surfaceTextColor: Color(0xFF0F766E),
    borderColor: Color(0xFFD7F5F1),
    shadowColor: Color(0x140F172A),
  );

  static const SoftBannerPalette album = SoftBannerPalette(
    startColor: Color(0xFFF4F1FF),
    endColor: Color(0xFFEAF3FF),
    accentPalette: playfulAccents,
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF475569),
    surfaceColor: Color(0xCCFFFFFF),
    surfaceTextColor: Color(0xFF3730A3),
    borderColor: Color(0xFFE6E2FF),
    shadowColor: Color(0x140F172A),
  );

  static const SoftBannerPalette mine = SoftBannerPalette(
    startColor: Color(0xFFF0FFFA),
    endColor: Color(0xFFEAF3FF),
    accentPalette: playfulAccents,
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
    accentPalette: playfulAccents,
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF475569),
    surfaceColor: Color(0xCCFFFFFF),
    surfaceTextColor: Color(0xFF0F4C81),
    borderColor: Color(0xFFD9ECFF),
    shadowColor: Color(0x140F172A),
  );
}

/// 浅色渐变横幅容器（内部会生成一次随机 accent 并保持稳定）。
class SoftBannerCard extends StatefulWidget {
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
  State<SoftBannerCard> createState() => _SoftBannerCardState();
}

class _SoftBannerCardState extends State<SoftBannerCard> {
  late final Random _random;
  late final SoftBannerTheme _theme;
  late final _BlobSpec _mainBlob;
  late final _BlobSpec _sparkBlob;
  late final _BlobSpec _cornerBlob;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _theme = widget.palette.createTheme(random: _random);
    _mainBlob = _BlobSpec(
      width: 98 + _random.nextInt(28).toDouble(),
      height: 98 + _random.nextInt(28).toDouble(),
      top: -(38 + _random.nextInt(16)).toDouble(),
      right: -(38 + _random.nextInt(16)).toDouble(),
      color: _theme.accentColor.withValues(alpha: 0.18),
    );
    _sparkBlob = _BlobSpec(
      width: 18 + _random.nextInt(10).toDouble(),
      height: 18 + _random.nextInt(10).toDouble(),
      top: (22 + _random.nextInt(22)).toDouble(),
      right: (52 + _random.nextInt(36)).toDouble(),
      color: _theme.accentColor.withValues(alpha: 0.32),
    );
    _cornerBlob = _BlobSpec(
      width: 112 + _random.nextInt(38).toDouble(),
      height: 112 + _random.nextInt(38).toDouble(),
      bottom: -(58 + _random.nextInt(18)).toDouble(),
      left: -(58 + _random.nextInt(18)).toDouble(),
      color: _theme.accentColor.withValues(alpha: 0.08),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        border: Border.all(color: _theme.borderColor),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_theme.startColor, _theme.endColor],
        ),
        boxShadow: [
          BoxShadow(
            color: _theme.shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Stack(
          children: [
            Positioned(
              top: _mainBlob.top,
              right: _mainBlob.right,
              child: _SoftBannerBlob.fromSpec(_mainBlob),
            ),
            Positioned(
              top: _sparkBlob.top,
              right: _sparkBlob.right,
              child: _SoftBannerBlob.fromSpec(_sparkBlob),
            ),
            Positioned(
              bottom: _cornerBlob.bottom,
              left: _cornerBlob.left,
              child: _SoftBannerBlob.fromSpec(_cornerBlob),
            ),
            Padding(
              padding: widget.padding,
              child: widget.builder(context, _theme),
            ),
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
