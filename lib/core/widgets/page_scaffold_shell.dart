import 'package:flutter/material.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/responsive_content_frame.dart';

class PageScaffoldShell extends StatelessWidget {
  const PageScaffoldShell({
    super.key,
    required this.title,
    this.description,
    this.actions,
    required this.children,
    this.scrollable = true,
  });

  final String title;
  final String? description;
  final List<Widget>? actions;
  final List<Widget> children;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageHeader(
          title: title,
          description: description,
          actions: actions,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        ...children,
      ],
    );

    final content = ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width < AppBreakpoints.mobile
              ? AppSpacingTokens.lg
              : AppSpacingTokens.xl,
        ),
        child: body,
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(color: surface.canvasSoft),
      child: SafeArea(
        child: scrollable
            ? SingleChildScrollView(child: content)
            : content,
      ),
    );
  }
}

class PageSectionCard extends StatelessWidget {
  const PageSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final layout = AppLayoutTokens.resolve(width);
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level3,
      ),
      child: Padding(
        padding: EdgeInsets.all(layout.cardPaddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: typography.displaySm),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacingTokens.xs),
                        Text(
                          subtitle!,
                          style: typography.bodySm.copyWith(color: surface.body),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppSpacingTokens.lg),
            child,
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.description,
    required this.actions,
    required this.typography,
    required this.surface,
  });

  final String title;
  final String? description;
  final List<Widget>? actions;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: typography.displayLg),
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: AppSpacingTokens.xs),
                Text(
                  description!,
                  style: typography.bodyMd.copyWith(color: surface.body),
                ),
              ],
            ],
          ),
        ),
        if (actions != null && actions!.isNotEmpty) ...[
          const SizedBox(width: AppSpacingTokens.lg),
          Wrap(
            spacing: AppSpacingTokens.sm,
            runSpacing: AppSpacingTokens.sm,
            children: actions!,
          ),
        ],
      ],
    );
  }
}
