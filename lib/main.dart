import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:luminous/routes/routes.dart';
import 'package:luminous/stores/token_manager.dart';
import 'package:luminous/stores/user_controller.dart';

// 入口文件说明：
// 1) 初始化 Flutter Binding，确保插件（SharedPreferences 等）可用
// 2) 初始化 TokenManager（本阶段未接 token，但保留初始化，方便后续扩展）
// 3) 注入 GetX 的 UserController，并从本地恢复登录态（safeUser）
//
// 注意：
// - Get.find<UserController>() 会在页面构造时触发，因此必须保证在 runApp 之前 Get.put 完成。
// - 详细架构与演进过程见：lib/project_guide.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await tokenManager.init();
  final userController = Get.put(UserController(), permanent: true);
  await userController.init();
  runApp(getRootWidget());
}
