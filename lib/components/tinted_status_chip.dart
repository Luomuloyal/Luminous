import 'package:flutter/material.dart';
import 'package:luminous/components/app_surface.dart';

/// Reusable tinted status chip with icon + text.
class TintedStatusChip extends StatelessWidget {
  const TintedStatusChip({
    super.key,
    this.icon,
    required this.text,
    required this.color,
    this.surfaceLightAlpha = 0.10,
    this.surfaceDarkAlpha = 0.18,
    this.borderLightAlpha = 0.14,
    this.borderDarkAlpha = 0.24,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.iconColor,
    this.showBorder = true,
    this.iconSize = 14,
    this.iconTextSpacing = 6,
    this.fontSize = 11.8,
    this.fontWeight = FontWeight.w700,
    this.expandText = false,
    this.textMaxLines,
    this.textOverflow,
    this.mainAxisSize = MainAxisSize.min,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  final IconData? icon;
  final String text;
  final Color color;
  final double surfaceLightAlpha;
  final double surfaceDarkAlpha;
  final double borderLightAlpha;
  final double borderDarkAlpha;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;
  final bool showBorder;
  final double iconSize;
  final double iconTextSpacing;
  final double fontSize;
  final FontWeight fontWeight;
  final bool expandText;
  final int? textMaxLines;
  final TextOverflow? textOverflow;
  final MainAxisSize mainAxisSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final resolvedBackground =
        backgroundColor ??
        appTintedSurface(
          context,
          color,
          lightAlpha: surfaceLightAlpha,
          darkAlpha: surfaceDarkAlpha,
        );
    final resolvedBorder =
        borderColor ??
        appTintedBorder(
          context,
          color,
          lightAlpha: borderLightAlpha,
          darkAlpha: borderDarkAlpha,
        );
    final resolvedTextColor = textColor ?? color;
    final resolvedIconColor = iconColor ?? resolvedTextColor;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: BorderRadius.circular(999),
        border: showBorder ? Border.all(color: resolvedBorder) : null,
      ),
      child: Row(
        mainAxisSize: mainAxisSize,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: resolvedIconColor),
            SizedBox(width: iconTextSpacing),
          ],
          if (expandText)
            Expanded(
              child: Text(
                text,
                maxLines: textMaxLines,
                overflow: textOverflow,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: resolvedTextColor,
                ),
              ),
            )
          else
            Text(
              text,
              maxLines: textMaxLines,
              overflow: textOverflow,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: resolvedTextColor,
              ),
            ),
        ],
      ),
    );
  }
}
