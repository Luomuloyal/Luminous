import 'package:flutter/material.dart';
import 'package:luminous/core/constants/app_colors.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColorTokens.primary,
      onPrimary: AppColorTokens.onPrimary,
      surface: AppColorTokens.canvas,
      onSurface: AppColorTokens.ink,
      onSurfaceVariant: AppColorTokens.body,
      outline: AppColorTokens.hairline,
      error: AppColorTokens.error,
      onError: AppColorTokens.onPrimary,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColorTokens.canvasSoft,
    canvasColor: AppColorTokens.canvas,
    dividerColor: AppColorTokens.hairline,
    cardColor: AppColorTokens.canvas,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: AppColorTokens.selectionBackground,
      selectionHandleColor: AppColorTokens.primary,
    ),
    extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.light],
  );

  static final dark = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.seed,
      onPrimary: AppColorTokens.onPrimary,
      surface: Color(0xFF111111),
      onSurface: Color(0xFFF4F4F4),
      onSurfaceVariant: Color(0xFFCECECE),
      outline: Color(0xFF2A2A2A),
      error: Color(0xFFFF6363),
      onError: AppColorTokens.primary,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF111111),
    canvasColor: const Color(0xFF171717),
    dividerColor: const Color(0xFF2A2A2A),
    cardColor: const Color(0xFF171717),
    shadowColor: Colors.black.withValues(alpha: 0.2),
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: AppColorTokens.selectionBackground,
      selectionHandleColor: AppColorTokens.onPrimary,
    ),
    extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.dark],
  );
}
