import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// main_shell 的页面级状态。
///
/// 包含当前选中的 Tab、已加载的 Tab 集合和二级页面预加载集合。
class MainShellState {
  final int currentIndex;
  final Set<int> loadedIndexes;
  final Set<int> preloadedSecondaryIndexes;

  const MainShellState({
    this.currentIndex = 0,
    this.loadedIndexes = const {0},
    this.preloadedSecondaryIndexes = const {},
  });

  MainShellState copyWith({
    int? currentIndex,
    Set<int>? loadedIndexes,
    Set<int>? preloadedSecondaryIndexes,
  }) {
    return MainShellState(
      currentIndex: currentIndex ?? this.currentIndex,
      loadedIndexes: loadedIndexes ?? this.loadedIndexes,
      preloadedSecondaryIndexes:
          preloadedSecondaryIndexes ?? this.preloadedSecondaryIndexes,
    );
  }
}

/// 主页面底部 Tab 状态管理。
///
/// 替代旧 GetX `MainController`。负责：
/// - Tab 选中切换与惰性加载标记
/// - 冷启动后分批预加载剩余 Tab 和二级页面
class MainShellNotifier extends Notifier<MainShellState> {
  /// 底部 Tab 总数（对应 [HomePage, DrugPage, AlbumPage, MinePage]）。
  static const pageCount = 4;

  /// 二级页面总数（对应 Search, Safety, Settings, ProfileSettings）。
  static const secondaryPageCount = 4;

  bool _backgroundPreloadStarted = false;
  bool _secondaryPreloadStarted = false;

  @override
  MainShellState build() {
    Future.microtask(_startPreloading);
    return const MainShellState();
  }

  Future<void> _startPreloading() async {
    await _preloadTabsInBackground();
    await _preloadSecondaryPagesInBackground();
  }

  /// 切换当前选中的 Tab，并标记该 Tab 已加载。
  ///
  /// 与旧 `MainController.selectTab` 行为一致：同 Tab 且已加载时无操作。
  void selectTab(int index) {
    if (state.currentIndex == index && state.loadedIndexes.contains(index)) {
      return;
    }
    state = state.copyWith(
      currentIndex: index,
      loadedIndexes: {...state.loadedIndexes, index},
    );
  }

  /// 对应旧 `MainController.preloadTabsInBackground`。
  ///
  /// 冷启动 900ms 后，以 420ms 间隔逐个标记剩余 Tab 为已加载。
  Future<void> _preloadTabsInBackground() async {
    if (_backgroundPreloadStarted) return;
    _backgroundPreloadStarted = true;

    await Future<void>.delayed(const Duration(milliseconds: 900));

    for (var index = 0; index < pageCount; index++) {
      if (state.loadedIndexes.contains(index)) continue;
      state = state.copyWith(
        loadedIndexes: {...state.loadedIndexes, index},
      );
      await Future<void>.delayed(const Duration(milliseconds: 420));
    }
  }

  /// 对应旧 `MainController.preloadSecondaryPagesInBackground`。
  ///
  /// 以分散的延迟标记二级页面为已预加载。
  Future<void> _preloadSecondaryPagesInBackground() async {
    if (_secondaryPreloadStarted) return;
    _secondaryPreloadStarted = true;

    const delayedStarts = <int>[1200, 1300, 1400, 1500];

    for (var index = 0; index < secondaryPageCount; index++) {
      await Future<void>.delayed(
        Duration(milliseconds: delayedStarts[index % delayedStarts.length]),
      );
      if (state.preloadedSecondaryIndexes.contains(index)) continue;
      state = state.copyWith(
        preloadedSecondaryIndexes: {
          ...state.preloadedSecondaryIndexes,
          index,
        },
      );
    }
  }
}

/// 主页面底部 Tab 状态的 Riverpod provider。
final mainShellProvider =
    NotifierProvider<MainShellNotifier, MainShellState>(
      MainShellNotifier.new,
    );
