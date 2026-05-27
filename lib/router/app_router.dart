import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/main_shell/presentation/main_shell.dart';
import 'package:luminous/features/drug/presentation/pages/medicine_detail_page.dart';
import 'package:luminous/features/scan/presentation/scan.dart';
import 'package:luminous/features/search/presentation/search.dart';
import 'package:luminous/features/settings/presentation/settings.dart'
    show
        SettingsPage,
        ProfileSettingsPage,
        ThemeSettingsPage,
        LanguageSettingsPage;
import 'package:luminous/shared/models/medicine.dart';
import 'package:luminous/features/medicine_picker/presentation/medicine_picker.dart';
import 'dart:typed_data';

import 'package:luminous/features/checkin/presentation/checkin.dart';
import 'package:luminous/features/legal/presentation/legal.dart';
import 'package:luminous/features/login/presentation/login.dart';
import 'package:luminous/features/reminders/presentation/reminders.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';
import 'package:luminous/features/mine/presentation/mine.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:luminous/features/register/presentation/register.dart';
import 'package:luminous/features/safety/presentation/safety.dart';
import 'package:luminous/utils/loading_utils.dart'; // 沿用原本的 NavigatorKey 做兼容

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: LoadingUtils.navigatorKey, // 兼容现有依赖 navigatorKey 的全屏 Loading
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return RegisterPage(
            authApi: extra?['authApi'] as AuthApi? ?? const AuthApi(),
            initialIdentifierType:
                extra?['initialIdentifierType'] as AuthIdentifierType? ??
                AuthIdentifierType.email,
            initialIdentifier: extra?['initialIdentifier'] as String? ?? '',
            initialCode: extra?['initialCode'] as String? ?? '',
          );
        },
      ),
      GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const MedicineScanPage(
          mode: ScanEntryMode.result,
          promptSourceOnStart: true,
        ),
      ),
      GoRoute(
        path: '/reminders',
        builder: (context, state) => const ReminderListPage(),
      ),
      GoRoute(
        path: '/checkin',
        builder: (context, state) => const CheckInPage(),
      ),
      GoRoute(
        path: '/safety',
        builder: (context, state) => const SafetyAssistPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/browse-history',
        builder: (context, state) => const BrowseHistoryPage(),
      ),
      GoRoute(
        path: '/user-agreement',
        builder: (context, state) => const UserAgreementPage(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: '/profile-settings',
        builder: (context, state) => const ProfileSettingsPage(),
      ),
      GoRoute(
        path: '/theme-settings',
        builder: (context, state) => const ThemeSettingsPage(),
      ),
      GoRoute(
        path: '/language-settings',
        builder: (context, state) => const LanguageSettingsPage(),
      ),
      GoRoute(
        path: '/medicine-picker',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MedicinePickerPage(
            title: extra?['title'] as String? ?? '选择药品',
          );
        },
      ),
      GoRoute(
        path: '/medicine-detail',
        name: 'medicine-detail',
        builder: (context, state) {
          final item = state.extra as MedicineItem;
          return MedicineDetailPage(initialItem: item);
        },
      ),
      GoRoute(
        path: '/reminder-edit',
        builder: (context, state) {
          final initial = state.extra as ReminderPlan?;
          return ReminderEditPage(initial: initial);
        },
      ),
    ],
  );
});
