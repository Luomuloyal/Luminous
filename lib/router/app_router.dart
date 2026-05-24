import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/main_shell/presentation/main_shell.dart';
import 'package:luminous/features/scan/presentation/scan.dart';
import 'package:luminous/features/search/presentation/search.dart';
import 'package:luminous/features/settings/presentation/settings.dart';

import 'package:luminous/pages/CheckIn/checkin.dart';
import 'package:luminous/pages/Legal/legal_documents.dart';
import 'package:luminous/pages/Login/login.dart';
import 'package:luminous/pages/Mine/browse_history.dart';
import 'package:luminous/pages/Register/register.dart';
import 'package:luminous/pages/Reminders/reminder_list.dart';
import 'package:luminous/pages/Safety/safety_assist.dart';
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
        builder: (context, state) => const RegisterView(),
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
    ],
  );
});
