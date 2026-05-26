import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/safety/presentation/safety.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/core/providers/shared_preferences_provider.dart';
import 'package:luminous/features/safety/presentation/providers/safety_provider.dart';
import 'package:luminous/features/drug/presentation/providers/medicine_detail_provider.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:luminous/shared/models/medicine.dart';
import 'package:luminous/features/safety/presentation/models/safety.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/session_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'medicine detail refreshes with refresh=true on reanalyze',
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

      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          detailFetchProvider.overrideWith(
            (ref) =>
                ({String? drugCode, String? approvalNo, cancelToken}) async {
                  return ApiResult<MedicineItem>(
                    code: '1',
                    msg: 'ok',
                    result: item,
                  );
                },
          ),
          aiFetchProvider.overrideWith(
            (ref) =>
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
          ),
        ],
      );

      final notifier = container.read(detailProvider.notifier);
      notifier.initialize(item);

      await notifier.loadAiDetail();
      await notifier.loadAiDetail(refresh: true);

      expect(refreshCalls, [false, true]);
    },
  );

  testWidgets(
    'safety assist shows cached banner and refreshes with refresh=true',
    (tester) async {
      final refreshCalls = <bool>[];

      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          safetyQueryProvider.overrideWith(
            (ref) =>
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
          ),
        ],
      );
      setGlobalProviderContainer(container);
      addTearDown(() {
        resetGlobalProviderContainerForTest();
        container.dispose();
      });

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

      container.read(safetyProvider.notifier)
          .setMedicine(slot: 0, item: item);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('zh'),
            supportedLocales: const <Locale>[Locale('zh'), Locale('en')],
            localizationsDelegates:
                GlobalMaterialLocalizations.delegates,
            home: const SafetyAssistPage(),
          ),
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
