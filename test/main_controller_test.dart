import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/main_shell/presentation/controllers/main_controller.dart';

void main() {
  test('main controller selects tab and marks it as loaded', () {
    final controller = MainController(pageCount: 4, secondaryPageCount: 4);

    expect(controller.currentIndex, 0);
    expect(controller.shouldLoadTab(0), isTrue);
    expect(controller.shouldLoadTab(2), isFalse);

    controller.selectTab(2);

    expect(controller.currentIndex, 2);
    expect(controller.shouldLoadTab(2), isTrue);
    expect(controller.loadedIndexes, containsAll(<int>{0, 2}));
  });
}
