import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luminous/features/drug/presentation/drug.dart';
import 'package:luminous/pages/Safety/controllers/safety_assist_controller.dart';
import 'package:luminous/pages/Safety/safety_assist.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/viewmodels/safety.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/session_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
    await createTestProviderContainer();
  });

  tearDown(Get.reset);

  test(
    'medicine detail controller refreshes with refresh=true on reanalyze',
    () async {
      final refreshCalls = <bool>[];
      final item = const MedicineItem(
        serialNo: '',
        approvalNo: 'H123',
        productName: '阿莫西林',
        dosageForm: '胶囊',
        specification: '0.25g',
        marketingAuthorizationHolder: '',
        manufacturer: '',
        drugCode: 'D123',
        drugCodeRemark: '',
      );
      final controller = MedicineDetailController(
        initialItem: item,
        fetchDetail:
            ({String? drugCode, String? approvalNo, cancelToken}) async {
              return ApiResult<MedicineItem>(
                code: '1',
                msg: 'ok',
                result: item,
              );
            },
        fetchAiDetail:
            ({
              String? drugCode,
              String? approvalNo,
              bool refresh = false,
              cancelToken,
            }) async {
              refreshCalls.add(refresh);
              return ApiResult<MedicineAiDetailResult>(
                code: '1',
                msg: 'ok',
                result: MedicineAiDetailResult(
                  text: refresh ? '最新分析内容' : '缓存分析内容',
                  source: refresh ? 'generated' : 'cache',
                  cachedAt: DateTime.parse('2026-04-14T10:30:00Z'),
                  expiresAt: DateTime.parse('2026-04-21T10:30:00Z'),
                ),
              );
            },
      );

      await controller.loadAiDetail();
      await controller.loadAiDetail(refresh: true);

      expect(refreshCalls, [false, true]);
    },
  );

  testWidgets(
    'safety assist shows cached banner and refreshes with refresh=true',
    (tester) async {
      await setTestSessionUser(
        const UserSafe(
          id: 'user-1',
          username: 'tester',
          email: '',
          phone: '13800138000',
          name: '',
          type: 0,
        ),
      );

      final refreshCalls = <bool>[];
      final item = const MedicineItem(
        serialNo: '',
        approvalNo: 'H123',
        productName: '阿莫西林',
        dosageForm: '胶囊',
        specification: '0.25g',
        marketingAuthorizationHolder: '',
        manufacturer: '',
        drugCode: 'D123',
        drugCodeRemark: '',
      );
      final controller = SafetyAssistController(
        queryApi:
            ({
              String? userId,
              required String mode,
              required List<Map<String, String>> medicines,
              bool refresh = false,
              cancelToken,
            }) async {
              refreshCalls.add(refresh);
              return ApiResult<MedicineAiSafetyResult>(
                code: '1',
                msg: 'ok',
                result: MedicineAiSafetyResult(
                  text: refresh ? '最新安全分析' : '缓存安全分析',
                  source: refresh ? 'generated' : 'cache',
                  cachedAt: DateTime.parse('2026-04-14T09:15:00Z'),
                  expiresAt: DateTime.parse('2026-04-21T09:15:00Z'),
                ),
              );
            },
      );
      controller.setMedicine(slot: 0, item: item);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          supportedLocales: const <Locale>[Locale('zh'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: SafetyAssistPage(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check Medication Advice'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('上次 AI 分析结果', findRichText: true),
        findsOneWidget,
      );

      await tester.tap(find.text('重新分析'));
      await tester.pumpAndSettle();

      expect(refreshCalls, [false, true]);
    },
  );
}
