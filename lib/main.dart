import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/theme/ornaments/ornament_provider.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luminous/routes/routes.dart';
import 'package:luminous/startup/app_startup_warmup.dart';
import 'package:luminous/core/providers/shared_preferences_provider.dart';

import 'package:luminous/core/providers/global_provider_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Riverpod: 在运行之前异步获取 SharedPreferences，避免每次初始化都闪白。
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  setGlobalProviderContainer(container);

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
  late final AppStartupWarmup _startupWarmup;

  @override
  void initState() {
    super.initState();
    _startupWarmup = AppStartupWarmup(
      restoreUserSession: ref.read(userSessionProvider.notifier).restore,
      warmOrnaments: () async {
        final ornamentNotifier = ref.read(ornamentProvider.notifier);
        if (!ornamentNotifier.isReady) {
          await ornamentNotifier.init();
        }
        await ornamentNotifier.warmup();
      },
    );
    _startupWarmup.start();
  }

  @override
  Widget build(BuildContext context) {
    return const RootAppWidget();
  }
}
