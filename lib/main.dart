import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luminous/routes/routes.dart';
import 'package:luminous/startup/app_startup_warmup.dart';
import 'package:luminous/stores/ornament_controller.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/stores/providers/shared_preferences_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Riverpod: 在运行之前异步获取 SharedPreferences，避免每次初始化都闪白。
  final prefs = await SharedPreferences.getInstance();

  final userController = Get.put(UserController(), permanent: true);
  userController.markSessionPending();
  final ornamentController = Get.put(OrnamentController(), permanent: true);

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: LuminousApp(
        userController: userController,
        ornamentController: ornamentController,
      ),
    ),
  );
}

class LuminousApp extends StatefulWidget {
  const LuminousApp({
    super.key,
    required this.userController,
    required this.ornamentController,
  });

  final UserController userController;
  final OrnamentController ornamentController;

  @override
  State<LuminousApp> createState() => _LuminousAppState();
}

class _LuminousAppState extends State<LuminousApp> {
  late final AppStartupWarmup _startupWarmup;

  @override
  void initState() {
    super.initState();
    _startupWarmup = AppStartupWarmup(
      userController: widget.userController,
      ornamentController: widget.ornamentController,
    );
    _startupWarmup.start();
  }

  @override
  Widget build(BuildContext context) {
    return const RootAppWidget();
  }
}
