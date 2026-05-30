import 'package:flutter/material.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';

@immutable
class AppLayoutScale {
  const AppLayoutScale({
    required this.pageHorizontalPadding,
    required this.sectionVerticalPadding,
    required this.heroVerticalPadding,
    required this.cardPadding,
    required this.cardPaddingLarge,
    required this.componentGap,
    required this.maxContentWidth,
  });

  final double pageHorizontalPadding;
  final double sectionVerticalPadding;
  final double heroVerticalPadding;
  final double cardPadding;
  final double cardPaddingLarge;
  final double componentGap;
  final double maxContentWidth;
}

abstract final class AppLayoutTokens {
  static AppLayoutScale resolve(double width) {
    if (width < AppBreakpoints.mobile) {
      return const AppLayoutScale(
        pageHorizontalPadding: AppSpacingTokens.md,
        sectionVerticalPadding: AppSpacingTokens.x2l,
        heroVerticalPadding: AppSpacingTokens.x4l,
        cardPadding: AppSpacingTokens.md,
        cardPaddingLarge: AppSpacingTokens.lg,
        componentGap: AppSpacingTokens.sm,
        maxContentWidth: 560,
      );
    }

    if (width < AppBreakpoints.tablet) {
      return const AppLayoutScale(
        pageHorizontalPadding: AppSpacingTokens.lg,
        sectionVerticalPadding: AppSpacingTokens.x4l,
        heroVerticalPadding: AppSpacingTokens.x5l,
        cardPadding: AppSpacingTokens.lg,
        cardPaddingLarge: AppSpacingTokens.xl,
        componentGap: AppSpacingTokens.md,
        maxContentWidth: 760,
      );
    }

    if (width < AppBreakpoints.desktop) {
      return const AppLayoutScale(
        pageHorizontalPadding: AppSpacingTokens.xl,
        sectionVerticalPadding: AppSpacingTokens.x4l,
        heroVerticalPadding: AppSpacingTokens.x5l,
        cardPadding: AppSpacingTokens.lg,
        cardPaddingLarge: AppSpacingTokens.xl,
        componentGap: AppSpacingTokens.md,
        maxContentWidth: 1040,
      );
    }

    return const AppLayoutScale(
      pageHorizontalPadding: AppSpacingTokens.xl,
      sectionVerticalPadding: AppSpacingTokens.x5l,
      heroVerticalPadding: AppSpacingTokens.section,
      cardPadding: AppSpacingTokens.lg,
      cardPaddingLarge: AppSpacingTokens.xl,
      componentGap: AppSpacingTokens.lg,
      maxContentWidth: 1400,
    );
  }
}
