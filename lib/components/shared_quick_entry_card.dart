import 'package:flutter/material.dart';
import 'package:luminous/components/quick_entry_style.dart';
import 'package:luminous/components/responsive_quick_grid.dart';

/// Shared quick-entry card used by Home, Mine and Drug sections.
class SharedQuickEntryCard extends StatelessWidget {
  const SharedQuickEntryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.metrics,
    this.repaintBoundary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final ResponsiveQuickGridMetrics? metrics;
  final bool repaintBoundary;

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final resolvedMetrics =
            metrics ??
            ResponsiveQuickGridMetrics.fromWidth(
              constraints.maxWidth,
              textScaleFactor: MediaQuery.textScalerOf(context).scale(1),
            );
        final compact = resolvedMetrics.isCompact;
        final style = resolveQuickEntryVisualStyle(context, color);

        return InkWell(
          borderRadius: BorderRadius.circular(kQuickEntryCardRadius),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(kQuickEntryCardRadius),
              border: Border.all(color: style.border),
            ),
            child: Padding(
              padding: resolvedMetrics.itemPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    child: SizedBox(
                      width: resolvedMetrics.iconBoxSize,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: style.iconBackground,
                            borderRadius: BorderRadius.circular(
                              resolvedMetrics.iconBorderRadius,
                            ),
                            border: Border.all(color: style.iconBorder),
                          ),
                          child: Icon(
                            icon,
                            size: resolvedMetrics.iconSize,
                            color: style.iconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: resolvedMetrics.titleSpacing),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 14 : 14.5,
                      fontWeight: FontWeight.w800,
                      color: style.titleColor,
                      height: 1.2,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                  ),
                  SizedBox(height: resolvedMetrics.subtitleSpacing),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 11.5 : 12,
                      color: style.subtitleColor,
                      fontWeight: FontWeight.w600,
                      height: compact ? 1.25 : 1.3,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (repaintBoundary) {
      return RepaintBoundary(child: content);
    }
    return content;
  }
}
