import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luminous/pages/Scan/medicine_scan.dart';
import 'package:luminous/pages/Search/search.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
    final controller = Get.put(UserController(), permanent: true);
    controller.sessionReady.value = true;
  });

  tearDown(() {
    ToastUtils.instance.dismiss();
  });

  testWidgets('scan entry shows source picker sheet before scanning', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () => showMedicineScanSourceSheet(context),
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('拍摄'), findsOneWidget);
    expect(find.text('从相册选择'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
  });

  testWidgets('search view auto searches with initial keyword', (tester) async {
    final calls = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: SearchView(
          initialKeyword: '阿莫西林',
          autoSearchOnInit: true,
          searchExecutor:
              ({required keyword, required page, required pageSize}) async {
                calls.add(keyword);
                return const MedicineSearchResult(
                  items: [
                    MedicineItem(
                      serialNo: '1',
                      approvalNo: '国药准字H20000001',
                      productName: '阿莫西林胶囊',
                      dosageForm: '胶囊剂',
                      specification: '0.5g*24粒',
                      marketingAuthorizationHolder: '示例药业',
                      manufacturer: '示例制药',
                      drugCode: '86900000000001',
                      drugCodeRemark: '',
                    ),
                  ],
                  total: 1,
                  page: 1,
                  pageSize: 20,
                );
              },
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(calls, <String>['阿莫西林']);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, '阿莫西林');
    expect(find.text('阿莫西林胶囊'), findsOneWidget);
  });
}
