import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_color_tokens.dart';

@immutable
class AppThemeSurface extends ThemeExtension<AppThemeSurface> {
  const AppThemeSurface({
    required this.canvas,
    required this.canvasSoft,
    required this.canvasSoft2,
    required this.hairline,
    required this.hairlineStrong,
    required this.body,
    required this.mute,
    required this.link,
    required this.linkSoft,
    required this.success,
    required this.error,
    required this.warning,
  });

  final Color canvas;
  final Color canvasSoft;
  final Color canvasSoft2;
  final Color hairline;
  final Color hairlineStrong;
  final Color body;
  final Color mute;
  final Color link;
  final Color linkSoft;
  final Color success;
  final Color error;
  final Color warning;

  static const AppThemeSurface light = AppThemeSurface(
    canvas: AppColorTokens.canvas,
    canvasSoft: AppColorTokens.canvasSoft,
    canvasSoft2: AppColorTokens.canvasSoft2,
    hairline: AppColorTokens.hairline,
    hairlineStrong: AppColorTokens.hairlineStrong,
    body: AppColorTokens.body,
    mute: AppColorTokens.mute,
    link: AppColorTokens.link,
    linkSoft: AppColorTokens.linkSoft,
    success: AppColorTokens.success,
    error: AppColorTokens.error,
    warning: AppColorTokens.warning,
  );

  static const AppThemeSurface dark = AppThemeSurface(
    canvas: Color(0xFF111111),
    canvasSoft: Color(0xFF171717),
    canvasSoft2: Color(0xFF1F1F1F),
    hairline: Color(0xFF2A2A2A),
    hairlineStrong: Color(0xFF4A4A4A),
    body: Color(0xFFCECECE),
    mute: Color(0xFF9A9A9A),
    link: AppColorTokens.link,
    linkSoft: Color(0xFF1A2A42),
    success: AppColorTokens.success,
    error: Color(0xFFFF6363),
    warning: Color(0xFFFFC861),
  );

  @override
  AppThemeSurface copyWith({
    Color? canvas,
    Color? canvasSoft,
    Color? canvasSoft2,
    Color? hairline,
    Color? hairlineStrong,
    Color? body,
    Color? mute,
    Color? link,
    Color? linkSoft,
    Color? success,
    Color? error,
    Color? warning,
  }) {
    return AppThemeSurface(
      canvas: canvas ?? this.canvas,
      canvasSoft: canvasSoft ?? this.canvasSoft,
      canvasSoft2: canvasSoft2 ?? this.canvasSoft2,
      hairline: hairline ?? this.hairline,
      hairlineStrong: hairlineStrong ?? this.hairlineStrong,
      body: body ?? this.body,
      mute: mute ?? this.mute,
      link: link ?? this.link,
      linkSoft: linkSoft ?? this.linkSoft,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
    );
  }

  @override
  ThemeExtension<AppThemeSurface> lerp(
    covariant ThemeExtension<AppThemeSurface>? other,
    double t,
  ) {
    if (other is! AppThemeSurface) return this;
    return AppThemeSurface(
      canvas: Color.lerp(canvas, other.canvas, t) ?? canvas,
      canvasSoft: Color.lerp(canvasSoft, other.canvasSoft, t) ?? canvasSoft,
      canvasSoft2: Color.lerp(canvasSoft2, other.canvasSoft2, t) ?? canvasSoft2,
      hairline: Color.lerp(hairline, other.hairline, t) ?? hairline,
      hairlineStrong:
          Color.lerp(hairlineStrong, other.hairlineStrong, t) ??
          hairlineStrong,
      body: Color.lerp(body, other.body, t) ?? body,
      mute: Color.lerp(mute, other.mute, t) ?? mute,
      link: Color.lerp(link, other.link, t) ?? link,
      linkSoft: Color.lerp(linkSoft, other.linkSoft, t) ?? linkSoft,
      success: Color.lerp(success, other.success, t) ?? success,
      error: Color.lerp(error, other.error, t) ?? error,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
    );
  }
}
