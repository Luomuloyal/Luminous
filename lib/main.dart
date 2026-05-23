import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/theme/ornaments/ornament_provider.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luminous/routes/routes.dart';
import 'package:luminous/startup/app_startup_warmup.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/stores/providers/shared_preferences_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Riverpod: 在运行之前异步获取 SharedPreferences，避免每次初始化都闪白。
  final prefs = await SharedPreferences.getInstance();

  final userController = Get.put(UserController(), permanent: true);
  userController.markSessionPending();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: LuminousApp(userController: userController),
    ),
  );
}

class LuminousApp extends ConsumerStatefulWidget {
  const LuminousApp({super.key, required this.userController});

  final UserController userController;

  @override
  ConsumerState<LuminousApp> createState() => _LuminousAppState();
}

class _LuminousAppState extends ConsumerState<LuminousApp> {
  late final AppStartupWarmup _startupWarmup;

  @override
  void initState() {
    super.initState();
    _startupWarmup = AppStartupWarmup(
      userController: widget.userController,
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
    // 监听 Riverpod 中的用户信息并同步到旧有的 UserController
    ref.listen(currentUserProvider, (previous, next) {
      widget.userController.user.value = next;
    });

    ref.listen(userSessionReadyProvider, (previous, next) {
      widget.userController.sessionReady.value = next;
    });

    return const RootAppWidget();
  }
}
