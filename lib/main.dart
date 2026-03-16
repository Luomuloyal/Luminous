import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:luminous/routes/routes.dart';
import 'package:luminous/stores/token_manager.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/notification_service.dart';

/// 应用入口函数。
///
/// 启动阶段需要先准备好所有“页面一上来就可能依赖”的全局能力，
/// 然后再执行 `runApp`。
Future<void> main() async {
  /// 初始化 Flutter 绑定，确保插件调用可用。
  WidgetsFlutterBinding.ensureInitialized();

  /// 初始化通知服务，确保本地通知调度能力可用。
  await NotificationService.instance.init();

  /// 预热 token 存储能力。
  await tokenManager.init();

  /// 注入全局用户控制器。
  final userController = Get.put(UserController(), permanent: true);

  /// 从本地恢复登录态。
  await userController.init();

  /// 启动根应用组件。
  runApp(getRootWidget());
}
