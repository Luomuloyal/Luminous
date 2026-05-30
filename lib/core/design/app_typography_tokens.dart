import 'package:flutter/material.dart';

@immutable
class AppTypographyScale {
  const AppTypographyScale({
    required this.displayXl,
    required this.displayLg,
    required this.displayMd,
    required this.displaySm,
    required this.bodyLg,
    required this.bodyMd,
    required this.bodyMdStrong,
    required this.bodySm,
    required this.bodySmStrong,
    required this.caption,
    required this.captionMono,
    required this.code,
    required this.buttonMd,
    required this.buttonLg,
  });

  final TextStyle displayXl;
  final TextStyle displayLg;
  final TextStyle displayMd;
  final TextStyle displaySm;
  final TextStyle bodyLg;
  final TextStyle bodyMd;
  final TextStyle bodyMdStrong;
  final TextStyle bodySm;
  final TextStyle bodySmStrong;
  final TextStyle caption;
  final TextStyle captionMono;
  final TextStyle code;
  final TextStyle buttonMd;
  final TextStyle buttonLg;
}

abstract final class AppTypographyTokens {
  static const String sansFamily = 'Geist';
  static const String monoFamily = 'Geist Mono';
  static const String sansFallback = 'Inter';

  static AppTypographyScale mobile(Color color) {
    return AppTypographyScale(
      displayXl: _sans(
        color: color,
        fontSize: 34,
        height: 40 / 34,
        weight: FontWeight.w600,
        letterSpacing: -1.2,
      ),
      displayLg: _sans(
        color: color,
        fontSize: 28,
        height: 34 / 28,
        weight: FontWeight.w600,
        letterSpacing: -0.9,
      ),
      displayMd: _sans(
        color: color,
        fontSize: 22,
        height: 28 / 22,
        weight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      displaySm: _sans(
        color: color,
        fontSize: 18,
        height: 24 / 18,
        weight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      bodyLg: _sans(
        color: color,
        fontSize: 17,
        height: 26 / 17,
        weight: FontWeight.w400,
      ),
      bodyMd: _sans(
        color: color,
        fontSize: 15,
        height: 22 / 15,
        weight: FontWeight.w400,
      ),
      bodyMdStrong: _sans(
        color: color,
        fontSize: 15,
        height: 22 / 15,
        weight: FontWeight.w500,
      ),
      bodySm: _sans(
        color: color,
        fontSize: 13,
        height: 18 / 13,
        weight: FontWeight.w400,
        letterSpacing: -0.16,
      ),
      bodySmStrong: _sans(
        color: color,
        fontSize: 13,
        height: 18 / 13,
        weight: FontWeight.w500,
        letterSpacing: -0.16,
      ),
      caption: _sans(
        color: color,
        fontSize: 11,
        height: 14 / 11,
        weight: FontWeight.w400,
      ),
      captionMono: _mono(
        color: color,
        fontSize: 11,
        height: 14 / 11,
      ),
      code: _mono(
        color: color,
        fontSize: 12,
        height: 18 / 12,
      ),
      buttonMd: _sans(
        color: color,
        fontSize: 13,
        height: 18 / 13,
        weight: FontWeight.w500,
      ),
      buttonLg: _sans(
        color: color,
        fontSize: 15,
        height: 22 / 15,
        weight: FontWeight.w500,
      ),
    );
  }

  static AppTypographyScale desktop(Color color) {
    return AppTypographyScale(
      displayXl: _sans(
        color: color,
        fontSize: 48,
        height: 48 / 48,
        weight: FontWeight.w600,
        letterSpacing: -2.4,
      ),
      displayLg: _sans(
        color: color,
        fontSize: 32,
        height: 40 / 32,
        weight: FontWeight.w600,
        letterSpacing: -1.28,
      ),
      displayMd: _sans(
        color: color,
        fontSize: 24,
        height: 32 / 24,
        weight: FontWeight.w600,
        letterSpacing: -0.96,
      ),
      displaySm: _sans(
        color: color,
        fontSize: 20,
        height: 28 / 20,
        weight: FontWeight.w600,
        letterSpacing: -0.6,
      ),
      bodyLg: _sans(
        color: color,
        fontSize: 18,
        height: 28 / 18,
        weight: FontWeight.w400,
      ),
      bodyMd: _sans(
        color: color,
        fontSize: 16,
        height: 24 / 16,
        weight: FontWeight.w400,
      ),
      bodyMdStrong: _sans(
        color: color,
        fontSize: 16,
        height: 24 / 16,
        weight: FontWeight.w500,
      ),
      bodySm: _sans(
        color: color,
        fontSize: 14,
        height: 20 / 14,
        weight: FontWeight.w400,
        letterSpacing: -0.28,
      ),
      bodySmStrong: _sans(
        color: color,
        fontSize: 14,
        height: 20 / 14,
        weight: FontWeight.w500,
        letterSpacing: -0.28,
      ),
      caption: _sans(
        color: color,
        fontSize: 12,
        height: 16 / 12,
        weight: FontWeight.w400,
      ),
      captionMono: _mono(
        color: color,
        fontSize: 12,
        height: 16 / 12,
      ),
      code: _mono(
        color: color,
        fontSize: 13,
        height: 20 / 13,
      ),
      buttonMd: _sans(
        color: color,
        fontSize: 14,
        height: 20 / 14,
        weight: FontWeight.w500,
      ),
      buttonLg: _sans(
        color: color,
        fontSize: 16,
        height: 24 / 16,
        weight: FontWeight.w500,
      ),
    );
  }

  static TextStyle _sans({
    required Color color,
    required double fontSize,
    required double height,
    required FontWeight weight,
    double? letterSpacing,
  }) {
    return TextStyle(
      color: color,
      fontFamily: sansFamily,
      fontFamilyFallback: const <String>[
        sansFallback,
        'system-ui',
        'sans-serif',
      ],
      fontSize: fontSize,
      height: height,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _mono({
    required Color color,
    required double fontSize,
    required double height,
  }) {
    return TextStyle(
      color: color,
      fontFamily: monoFamily,
      fontFamilyFallback: const <String>[
        'ui-monospace',
        'SFMono-Regular',
        'Menlo',
        'Monaco',
        'monospace',
      ],
      fontSize: fontSize,
      height: height,
      fontWeight: FontWeight.w400,
    );
  }
}
