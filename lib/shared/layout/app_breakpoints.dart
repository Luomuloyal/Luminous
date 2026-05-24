/// Global app width classes used by adaptive shells and page variants.
enum AppWindowClass {
  compact,
  medium,
  expanded,
  webExpanded;

  static AppWindowClass fromWidth(double width) {
    final safeWidth = width.isFinite && width > 0 ? width : 0;
    if (safeWidth >= AppBreakpoints.webExpanded) {
      return AppWindowClass.webExpanded;
    }
    if (safeWidth >= AppBreakpoints.expanded) {
      return AppWindowClass.expanded;
    }
    if (safeWidth >= AppBreakpoints.medium) {
      return AppWindowClass.medium;
    }
    return AppWindowClass.compact;
  }

  bool get isCompact => this == AppWindowClass.compact;
  bool get isMedium => this == AppWindowClass.medium;
  bool get isExpanded => this == AppWindowClass.expanded;
  bool get isWebExpanded => this == AppWindowClass.webExpanded;
  bool get usesBottomNavigation => isCompact;
  bool get usesNavigationRail => !isCompact;
  bool get usesExtendedNavigation => isExpanded || isWebExpanded;
}

abstract final class AppBreakpoints {
  static const double compact = 0;
  static const double medium = 600;
  static const double expanded = 840;
  static const double webExpanded = 1200;
}
