import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShellState {
  const ShellState({this.currentIndex = 0});

  final int currentIndex;

  ShellState copyWith({int? currentIndex}) {
    return ShellState(currentIndex: currentIndex ?? this.currentIndex);
  }
}

class ShellNotifier extends Notifier<ShellState> {
  @override
  ShellState build() => const ShellState();

  void selectTab(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

final shellProvider = NotifierProvider<ShellNotifier, ShellState>(
  ShellNotifier.new,
);
