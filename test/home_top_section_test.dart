import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/home/presentation/home.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';

void main() {
  const palette = SoftBannerPalette(
    startColor: Color(0xFFFFF5F8),
    endColor: Color(0xFFFFF8FC),
    accentColor: Color(0xFFE6A3BB),
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF5B6270),
    surfaceColor: Color(0xD9FFFFFF),
    surfaceTextColor: Color(0xFFAF5E7E),
    borderColor: Color(0xFFF7DDE7),
    shadowColor: Color(0x140F172A),
  );

  Widget buildTestWidget({
    required ValueNotifier<String> tipNotifier,
    required VoidCallback onTapTip,
    required VoidCallback onLongPressTip,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: HomeTopSection(
          palette: palette,
          todayTipListenable: tipNotifier,
          nextText: '下一次提醒: 示例 08:30 维生素D · 早餐后服用 1 粒',
          loadingReminders: false,
          reminderCount: 3,
          onTapTip: onTapTip,
          onLongPressTip: onLongPressTip,
        ),
      ),
    );
  }

  testWidgets('health tip pill responds to tap and long press', (tester) async {
    var tapCount = 0;
    var longPressCount = 0;
    final tipNotifier = ValueNotifier<String>('按时服药，别漏别补');

    await tester.pumpWidget(
      buildTestWidget(
        tipNotifier: tipNotifier,
        onTapTip: () => tapCount++,
        onLongPressTip: () => longPressCount++,
      ),
    );

    final tipPill = find.text('健康小贴士');
    expect(tipPill, findsOneWidget);

    await tester.tap(tipPill);
    await tester.pumpAndSettle();
    expect(tapCount, 1);

    await tester.longPress(tipPill);
    await tester.pumpAndSettle();
    expect(longPressCount, 1);

    tipNotifier.dispose();
  });

  testWidgets('today tip text updates when notifier changes', (tester) async {
    final tipNotifier = ValueNotifier<String>('按时服药，别漏别补');

    await tester.pumpWidget(
      buildTestWidget(
        tipNotifier: tipNotifier,
        onTapTip: () {},
        onLongPressTip: () {},
      ),
    );

    expect(find.text('按时服药，别漏别补'), findsOneWidget);

    tipNotifier.value = '饭前饭后按说明来';
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('饭前饭后按说明来'), findsOneWidget);

    tipNotifier.dispose();
  });
}
