import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:luminous/routes/routes.dart';
import 'package:luminous/stores/token_manager.dart';
import 'package:luminous/stores/user_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await tokenManager.init();
  final userController = Get.put(UserController(), permanent: true);
  await userController.init();
  runApp(getRootWidget());
}
