import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:luminous/core/design/app_radius_tokens.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';
import 'package:luminous/core/design/app_shadow_tokens.dart';
import 'package:luminous/core/design/app_typography_tokens.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class AppToast {
  const AppToast._();

  static Future<bool?> show(BuildContext context, String message) async {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>();
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = surface == null
        ? (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF))
        : Color.alphaBlend(
            surface.link.withValues(alpha: isDark ? 0.10 : 0.08),
            isDark ? surface.canvasSoft2 : surface.canvas,
          );
    final textColor = surface == null
        ? (isDark ? Colors.white : const Color(0xFF2A2A2A))
        : surface.body;

    FToast()
      ..init(context)
      ..removeQueuedCustomToasts()
      ..showToast(
        gravity: ToastGravity.CENTER,
        toastDuration: const Duration(milliseconds: 1800),
        fadeDuration: const Duration(milliseconds: 160),
        ignorePointer: true,
        child: _AppToastSurface(
          message: message,
          backgroundColor: backgroundColor,
          borderColor:
              surface?.hairline.withValues(alpha: isDark ? 0.62 : 0.78) ??
              Colors.transparent,
          textColor: textColor,
        ),
      );
    return true;
  }
}

class _AppToastSurface extends StatelessWidget {
  const _AppToastSurface({
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        boxShadow: AppShadowTokens.level4,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.md,
          vertical: AppSpacingTokens.sm,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypographyTokens.mobile(
              textColor,
            ).bodySmStrong.copyWith(decoration: TextDecoration.none),
          ),
        ),
      ),
    );
  }
}
