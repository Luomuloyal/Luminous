import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/app.dart';

void main() {
  testWidgets('App should render', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LuminousApp()));
    expect(find.text('新的首页将从这里开始重建：先完成响应式视觉系统，再逐步接入喝水、提醒、健康快照和 Lumi 建议。'), findsOneWidget);
  });
}
