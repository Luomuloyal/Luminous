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
            ResponsiveQuickGridMetrics.fromWidth(constraints.maxWidth);
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: compact ? 14 : 14.5,
                            fontWeight: FontWeight.w800,
                            color: style.titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: resolvedMetrics.subtitleSpacing),
                        Flexible(
                          child: Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: compact ? 11.5 : 12,
                              color: style.subtitleColor,
                              fontWeight: FontWeight.w600,
                              height: compact ? 1.2 : 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
