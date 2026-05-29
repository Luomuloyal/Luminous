import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/login/presentation/login.dart';
import 'package:luminous/features/register/presentation/register.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/shared_preferences_provider.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() {
    ToastUtils.instance.dismiss();
  });

  Widget createLoginWidget({AuthApi? authApi}) {
    final api = authApi ?? FakeAuthApi();
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginPage(authApi: api),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return RegisterPage(
              authApi: extra?['authApi'] as AuthApi? ?? api,
              initialIdentifierType:
                  extra?['initialIdentifierType'] as AuthIdentifierType? ??
                  AuthIdentifierType.email,
              initialIdentifier: extra?['initialIdentifier'] as String? ?? '',
              initialCode: extra?['initialCode'] as String? ?? '',
            );
          },
        ),
      ],
    );
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp.router(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  testWidgets('tap login with empty fields shows email error', (tester) async {
    await tester.pumpWidget(createLoginWidget());

    await tester.ensureVisible(find.text('登录'));
    await tester.tap(find.text('登录'));
    await tester.pump();

    expect(find.text('请输入邮箱'), findsWidgets);
  });

  testWidgets('invalid email shows email format error before network', (
    tester,
  ) async {
    await tester.pumpWidget(createLoginWidget());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'tester');
    await tester.enterText(fields.at(1), 'Abc123');

    await tester.ensureVisible(find.text('登录'));
    await tester.tap(find.text('登录'));
    await tester.pump();

    expect(find.text('邮箱格式不正确'), findsWidgets);
  });

  testWidgets(
    'code login not registered prompts auto register and prefills form',
    (tester) async {
      final fakeAuth = FakeAuthApi(throwNotRegisteredOnCodeLogin: true);
      await tester.pumpWidget(createLoginWidget(authApi: fakeAuth));

      await tester.tap(find.text('验证码登录'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'tester@example.com');
      await tester.tap(find.text('发送验证码'));
      await tester.pump();
      ToastUtils.instance.dismiss();
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.text('登录'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('账号未注册'), findsOneWidget);
      await tester.tap(find.text('去注册'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(RegisterPage), findsOneWidget);
      final registerFields = tester
          .widgetList<TextFormField>(
            find.descendant(
              of: find.byType(RegisterPage),
              matching: find.byType(TextFormField),
            ),
          )
          .toList();
      expect(registerFields[1].controller?.text, 'tester@example.com');
      // Email code field
      expect(registerFields[2].controller?.text, '123456');

      await tester.pump(const Duration(seconds: 60));
      ToastUtils.instance.dismiss();
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('send code enters cooldown after success', (tester) async {
    await tester.pumpWidget(createLoginWidget());

    await tester.tap(find.text('验证码登录'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'tester@example.com',
    );
    await tester.tap(find.text('发送验证码'));
    await tester.pump();

    expect(find.text('60s'), findsOneWidget);

    final cooldownButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '60s'),
    );
    expect(cooldownButton.onPressed, isNull);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('59s'), findsOneWidget);

    await tester.pump(const Duration(seconds: 59));
    ToastUtils.instance.dismiss();
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'register submits without extra svg captcha when business code session exists',
    (tester) async {
      final fakeAuth = FakeAuthApi();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: RegisterPage(
              authApi: fakeAuth,
              initialIdentifierType: AuthIdentifierType.phone,
              initialIdentifier: '13800138000',
              initialCode: '123456',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(3), 'Abc123');
      await tester.enterText(fields.at(4), 'Abc123');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox), warnIfMissed: false);
      await tester.pump();

      final submitButton = find.widgetWithText(FilledButton, '注册');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(fakeAuth.lastRegisteredPhone, '13800138000');
      ToastUtils.instance.dismiss();
      await tester.pump();
    },
  );

  testWidgets('register blocks submit without business code session', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RegisterPage(
            authApi: FakeAuthApi(),
            initialIdentifierType: AuthIdentifierType.phone,
            initialIdentifier: '13800138000',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(2), '123456');
    await tester.enterText(fields.at(3), 'Abc123');
    await tester.enterText(fields.at(4), 'Abc123');
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox), warnIfMissed: false);
    await tester.pump();

    final submitButton = find.widgetWithText(FilledButton, '注册');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('请先获取当前账号的验证码'), findsOneWidget);
    ToastUtils.instance.dismiss();
    await tester.pump();
  });
}

class FakeAuthApi extends AuthApi {
  FakeAuthApi({this.throwNotRegisteredOnCodeLogin = false});

  final bool throwNotRegisteredOnCodeLogin;
  String lastRegisteredPhone = '';
  String lastRegisteredEmail = '';

  @override
  Future<ApiResult<CodeTicketResult>> sendEmailCode({
    required String email,
    required AuthCodeScene scene,
  }) async {
    return const ApiResult<CodeTicketResult>(
      code: '1',
      msg: 'ok',
      result: CodeTicketResult(id: 'email-code-1'),
    );
  }

  @override
  Future<ApiResult<CodeTicketResult>> sendPhoneCode({
    required String phone,
    required AuthCodeScene scene,
  }) async {
    return const ApiResult<CodeTicketResult>(
      code: '1',
      msg: 'ok',
      result: CodeTicketResult(id: 'phone-code-1'),
    );
  }

  @override
  Future<ApiResult<LoginResult>> loginWithPassword({
    required AuthIdentifierType identifierType,
    required String identifier,
    required String password,
  }) async {
    return ApiResult<LoginResult>(
      code: '1',
      msg: '登录成功',
      result: LoginResult(
        user: UserSafe(
          id: 'user-1',
          username: identifier,
          email: identifierType == AuthIdentifierType.email ? identifier : '',
          phone: identifierType == AuthIdentifierType.phone ? identifier : '',
          name: '',
          type: 0,
        ),
        token: '',
        refreshToken: '',
      ),
    );
  }

  @override
  Future<ApiResult<LoginResult>> loginWithCode({
    required AuthIdentifierType identifierType,
    required String identifier,
    required String code,
  }) async {
    if (throwNotRegisteredOnCodeLogin) {
      throw const ApiException('该账号尚未注册，是否前往注册？', code: 'NOT_REGISTERED');
    }

    return ApiResult<LoginResult>(
      code: '1',
      msg: '登录成功',
      result: LoginResult(
        user: UserSafe(
          id: 'user-1',
          username: identifier,
          email: identifierType == AuthIdentifierType.email ? identifier : '',
          phone: identifierType == AuthIdentifierType.phone ? identifier : '',
          name: '',
          type: 0,
        ),
        token: '',
        refreshToken: '',
      ),
    );
  }

  @override
  Future<ApiResult<RegisterResult>> registerWithEmail({
    required String email,
    required String code,
    required String password,
    String username = '',
  }) async {
    lastRegisteredEmail = email;
    return const ApiResult<RegisterResult>(
      code: '1',
      msg: '注册成功',
      result: RegisterResult(id: 'register-1'),
    );
  }

  @override
  Future<ApiResult<RegisterResult>> registerWithPhone({
    required String phone,
    required String code,
    required String password,
    String username = '',
  }) async {
    lastRegisteredPhone = phone;
    return const ApiResult<RegisterResult>(
      code: '1',
      msg: '注册成功',
      result: RegisterResult(id: 'register-1'),
    );
  }
}
