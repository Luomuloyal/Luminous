import 'dart:math';

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

  /// 每次应用冷启动只生成一次种子，用于整场会话内的横幅配色。
  ///
  /// 这里只做一次轻量随机索引，不做任何 I/O，也不会在页面构建时重复计算。
  static final int _sessionSeed = Random().nextInt(_healingPalettes.length);

  /// 首页横幅配色。
  ///
  /// 每次冷启动只随机一次，整个应用会话中保持稳定。
  static final SoftBannerPalette home = _pick(offset: 0);

  /// 药品页横幅配色。
  ///
  /// 与首页错开固定偏移，避免两个一级页颜色过于相似。
  static final SoftBannerPalette drug = _pick(offset: 4);

  /// 相册横幅配色。
  static final SoftBannerPalette album = _pick(offset: 7);

  /// 我的页横幅配色。
  static final SoftBannerPalette mine = _pick(offset: 10);

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

  static SoftBannerPalette _pick({required int offset}) {
    final index = (_sessionSeed + offset) % _healingPalettes.length;
    return _healingPalettes[index];
  }

  static const List<SoftBannerPalette> _healingPalettes = <SoftBannerPalette>[
    SoftBannerPalette(
      startColor: Color(0xFFFFF5F8),
      endColor: Color(0xFFFFF8FC),
      accentColor: Color(0xFFE6A3BB),
      textColor: Color(0xFF0F172A),
      secondaryTextColor: Color(0xFF5B6270),
      surfaceColor: Color(0xD9FFFFFF),
      surfaceTextColor: Color(0xFFAF5E7E),
      borderColor: Color(0xFFF7DDE7),
      shadowColor: Color(0x140F172A),
    ),
    SoftBannerPalette(
      startColor: Color(0xFFFFF7FB),
      endColor: Color(0xFFFFFBFD),
      accentColor: Color(0xFFDFAED0),
      textColor: Color(0xFF0F172A),
      secondaryTextColor: Color(0xFF5B6270),
      surfaceColor: Color(0xD9FFFFFF),
      surfaceTextColor: Color(0xFFA25F8A),
      borderColor: Color(0xFFF4E0EC),
      shadowColor: Color(0x140F172A),
    ),
    SoftBannerPalette(
      startColor: Color(0xFFF7F4FF),
      endColor: Color(0xFFFBF8FF),
      accentColor: Color(0xFFC0A8E8),
      textColor: Color(0xFF0F172A),
      secondaryTextColor: Color(0xFF5B6270),
      surfaceColor: Color(0xD9FFFFFF),
      surfaceTextColor: Color(0xFF7B67A8),
      borderColor: Color(0xFFE8E0F8),
      shadowColor: Color(0x140F172A),
    ),
    SoftBannerPalette(
      startColor: Color(0xFFF9F6FF),
      endColor: Color(0xFFFDFBFF),
      accentColor: Color(0xFFD0B3EB),
      textColor: Color(0xFF0F172A),
      secondaryTextColor: Color(0xFF5B6270),
      surfaceColor: Color(0xD9FFFFFF),
      surfaceTextColor: Color(0xFF8A68A8),
      borderColor: Color(0xFFEEE4F9),
      shadowColor: Color(0x140F172A),
    ),
    SoftBannerPalette(
      startColor: Color(0xFFFFF5EE),
      endColor: Color(0xFFFFFAF5),
      accentColor: Color(0xFFE7B287),
      textColor: Color(0xFF0F172A),
      secondaryTextColor: Color(0xFF5B6270),
      surfaceColor: Color(0xD9FFFFFF),
      surfaceTextColor: Color(0xFFB57843),
      borderColor: Color(0xFFF6E2D0),
      shadowColor: Color(0x140F172A),
    ),
    SoftBannerPalette(
      startColor: Color(0xFFFFF8F2),
      endColor: Color(0xFFFFFCF7),
      accentColor: Color(0xFFE8C09D),
      textColor: Color(0xFF0F172A),
      secondaryTextColor: Color(0xFF5B6270),
      surfaceColor: Color(0xD9FFFFFF),
      surfaceTextColor: Color(0xFFB27D4C),
      borderColor: Color(0xFFF7E8DA),
      shadowColor: Color(0x140F172A),
    ),
    SoftBannerPalette(
      startColor: Color(0xFFF2FBFC),
      endColor: Color(0xFFF7FCFF),
      accentColor: Color(0xFF94CFD4),
      textColor: Color(0xFF0F172A),
      secondaryTextColor: Color(0xFF5B6270),
      surfaceColor: Color(0xD9FFFFFF),
      surfaceTextColor: Color(0xFF417D85),
      borderColor: Color(0xFFDCEFF1),
      shadowColor: Color(0x140F172A),
    ),
    SoftBannerPalette(
      startColor: Color(0xFFF2FCF8),
      endColor: Color(0xFFF7FEFB),
      accentColor: Color(0xFFA3D7C0),
      textColor: Color(0xFF0F172A),
      secondaryTextColor: Color(0xFF5B6270),
      surfaceColor: Color(0xD9FFFFFF),
      surfaceTextColor: Color(0xFF4B8468),
      borderColor: Color(0xFFDDF1E6),
      shadowColor: Color(0x140F172A),
    ),
    SoftBannerPalette(
      startColor: Color(0xFFF3F8FF),
      endColor: Color(0xFFF8FBFF),
      accentColor: Color(0xFFA8C4E8),
      textColor: Color(0xFF0F172A),
      secondaryTextColor: Color(0xFF5B6270),
      surfaceColor: Color(0xD9FFFFFF),
      surfaceTextColor: Color(0xFF54759A),
      borderColor: Color(0xFFDDE8F7),
      shadowColor: Color(0x140F172A),
    ),
    SoftBannerPalette(
      startColor: Color(0xFFF6F4FF),
      endColor: Color(0xFFFAF8FF),
      accentColor: Color(0xFFC3B2E9),
      textColor: Color(0xFF0F172A),
      secondaryTextColor: Color(0xFF5B6270),
      surfaceColor: Color(0xD9FFFFFF),
      surfaceTextColor: Color(0xFF7A69A8),
      borderColor: Color(0xFFE8E2F8),
      shadowColor: Color(0x140F172A),
    ),
    SoftBannerPalette(
      startColor: Color(0xFFFFF4F1),
      endColor: Color(0xFFFFF8F7),
      accentColor: Color(0xFFE8B8AF),
      textColor: Color(0xFF0F172A),
      secondaryTextColor: Color(0xFF5B6270),
      surfaceColor: Color(0xD9FFFFFF),
      surfaceTextColor: Color(0xFFB47471),
      borderColor: Color(0xFFF6E2DE),
      shadowColor: Color(0x140F172A),
    ),
    SoftBannerPalette(
      startColor: Color(0xFFFFFBEF),
      endColor: Color(0xFFFFFDF6),
      accentColor: Color(0xFFE3D398),
      textColor: Color(0xFF0F172A),
      secondaryTextColor: Color(0xFF5B6270),
      surfaceColor: Color(0xD9FFFFFF),
      surfaceTextColor: Color(0xFF9C8650),
      borderColor: Color(0xFFF3EDD1),
      shadowColor: Color(0x140F172A),
    ),
  ];
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
