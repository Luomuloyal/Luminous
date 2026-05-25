import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/main_shell/presentation/providers/main_shell_provider.dart';

void main() {
  test('main shell notifier selects tab and marks it as loaded', () {
    final container = ProviderContainer();
    addTearDown(() => container.dispose());

    final notifier = container.read(mainShellProvider.notifier);
    final initialState = container.read(mainShellProvider);

    // 初始状态：第 0 个 Tab 选中且已加载，其余未加载
    expect(initialState.currentIndex, 0);
    expect(initialState.loadedIndexes, contains(0));
    expect(initialState.loadedIndexes.contains(2), isFalse);

    // 切换到第 2 个 Tab
    notifier.selectTab(2);
    final afterSelect = container.read(mainShellProvider);
    expect(afterSelect.currentIndex, 2);
    expect(afterSelect.loadedIndexes, containsAll(<int>{0, 2}));
  });
}
