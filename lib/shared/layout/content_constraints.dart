import 'package:luminous/shared/layout/app_breakpoints.dart';

/// 各宽度档位对应的推荐内容最大宽度。
///
/// 用于 [AppCanvasPageScaffold.maxContentWidth] 等需要在大屏上
/// 限制内容的可读宽度的场景。
abstract final class AppContentWidths {
  /// compact 档不限制宽度。
  static const double compact = double.infinity;

  /// medium 档推荐最大宽度。
  static const double medium = 640;

  /// expanded 档推荐最大宽度。
  static const double expanded = 800;

  /// webExpanded 档推荐最大宽度。
  static const double webExpanded = 840;

  /// 根据给定的 [AppWindowClass] 返回对应的推荐最大宽度。
  ///
  /// compact 返回 `null` 表示不限制宽度，其余返回对应的固定值。
  static double? fromWindowClass(AppWindowClass windowClass) {
    switch (windowClass) {
      case AppWindowClass.compact:
        return null;
      case AppWindowClass.medium:
        return medium;
      case AppWindowClass.expanded:
        return expanded;
      case AppWindowClass.webExpanded:
        return webExpanded;
    }
  }
}
