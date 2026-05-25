// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:get/get.dart';

/// [DEPRECATED] 旧 GetX 主页面控制器。
///
/// 已由 `lib/features/main_shell/presentation/providers/main_shell_provider.dart`
/// 中的 [MainShellNotifier] 替代。本文件仅保留为历史参考，不应在新代码中使用。
@Deprecated('Use MainShellNotifier (Riverpod) instead')
class MainController extends GetxController {
  MainController({required this.pageCount, required this.secondaryPageCount});

  final int pageCount;
  final int secondaryPageCount;

  final Set<int> _loadedIndexes = <int>{0};
  final Set<int> _preloadedSecondaryIndexes = <int>{};
  int _currentIndex = 0;
  bool _backgroundPreloadStarted = false;
  bool _secondaryPreloadStarted = false;

  Set<int> get loadedIndexes => Set<int>.unmodifiable(_loadedIndexes);
  Set<int> get preloadedSecondaryIndexes =>
      Set<int>.unmodifiable(_preloadedSecondaryIndexes);
  int get currentIndex => _currentIndex;

  @override
  void onInit() {
    super.onInit();
    unawaited(preloadTabsInBackground());
    unawaited(preloadSecondaryPagesInBackground());
  }

  void selectTab(int index) {
    if (_currentIndex == index && _loadedIndexes.contains(index)) {
      return;
    }
    _loadedIndexes.add(index);
    _currentIndex = index;
    update();
  }

  bool shouldLoadTab(int index) => _loadedIndexes.contains(index);

  bool shouldPreloadSecondary(int index) =>
      _preloadedSecondaryIndexes.contains(index);

  Future<void> preloadTabsInBackground() async {
    if (_backgroundPreloadStarted || pageCount <= 0) {
      return;
    }
    _backgroundPreloadStarted = true;

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (isClosed) {
      return;
    }

    for (var index = 0; index < pageCount; index++) {
      if (isClosed) {
        return;
      }
      if (_loadedIndexes.contains(index)) {
        continue;
      }
      _loadedIndexes.add(index);
      update();
      await Future<void>.delayed(const Duration(milliseconds: 420));
    }
  }

  Future<void> preloadSecondaryPagesInBackground() async {
    if (_secondaryPreloadStarted || secondaryPageCount <= 0) {
      return;
    }
    _secondaryPreloadStarted = true;

    const delayedStarts = <int>[1200, 1300, 1400, 1500];

    for (var index = 0; index < secondaryPageCount; index++) {
      if (isClosed) {
        return;
      }
      await Future<void>.delayed(
        Duration(milliseconds: delayedStarts[index % delayedStarts.length]),
      );
      if (isClosed) {
        return;
      }
      if (_preloadedSecondaryIndexes.contains(index)) {
        continue;
      }
      _preloadedSecondaryIndexes.add(index);
      update();
    }
  }
}
