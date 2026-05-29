import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/locale_provider.dart';
import 'package:luminous/core/providers/shared_preferences_provider.dart';
import 'package:luminous/core/startup/root_app_widget.dart';
import 'package:luminous/core/theme/ornaments/ornament_provider.dart';
import 'package:luminous/features/auth/data/session_sync_service.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/startup/app_startup_warmup.dart';
import 'package:luminous/utils/app_i18n_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Riverpod: 在运行之前异步获取 SharedPreferences，避免每次初始化都闪白。
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  // 注入无 context 的本地化辅助。
  AppI18nText.init(
    readLocalePreference: () => container.read(localeProvider).preference,
  );

  runApp(
    UncontrolledProviderScope(container: container, child: const LuminousApp()),
  );
}

class LuminousApp extends ConsumerStatefulWidget {
  const LuminousApp({super.key});

  @override
  ConsumerState<LuminousApp> createState() => _LuminousAppState();
}

class _LuminousAppState extends ConsumerState<LuminousApp> {
  AppStartupWarmup? _startupWarmup;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final container = ProviderScope.containerOf(context);
    _startupWarmup = AppStartupWarmup(
      restoreUserSession: ref.read(userSessionProvider.notifier).restore,
      warmOrnaments: () async {
        final ornamentNotifier = ref.read(ornamentProvider.notifier);
        if (!ornamentNotifier.isReady) {
          await ornamentNotifier.init();
        }
        await ornamentNotifier.warmup();
      },
      readCurrentUserId: () => container.read(currentUserProvider)?.id,
      sessionSyncService: container.read(sessionSyncServiceProvider),
    );
    _startupWarmup!.start();
  }

  @override
  Widget build(BuildContext context) {
    return const RootAppWidget();
  }
}
