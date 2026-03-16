import 'package:flutter/material.dart';
import 'package:luminous/pages/CheckIn/checkin.dart';
import 'package:luminous/pages/Login/login.dart';
import 'package:luminous/pages/Main/main.dart';
import 'package:luminous/pages/Register/register.dart';
import 'package:luminous/pages/Reminders/reminder_list.dart';
import 'package:luminous/pages/Safety/safety_assist.dart';
import 'package:luminous/pages/Scan/medicine_scan.dart';
import 'package:luminous/pages/Search/search.dart';
import 'package:luminous/utils/loading_utils.dart';

/// 构建应用根组件。
///
/// 当前项目使用原生 `MaterialApp` 路由表，不依赖 `GetMaterialApp`。
Widget getRootWidget() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    navigatorKey: LoadingUtils.navigatorKey,
    initialRoute: '/',
    routes: getRootRoutes(),
  );
}

/// 返回整个应用的命名路由表。
///
/// 所有 `Navigator.pushNamed` 都会通过这里注册的页面进行匹配。
Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    '/': (context) => const MainPage(),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterView(),
    '/search': (context) => const SearchView(),
    '/scan': (context) => const MedicineScanPage(mode: ScanEntryMode.result),
    '/reminders': (context) => const ReminderListPage(),
    '/checkin': (context) => const CheckInPage(),
    '/safety': (context) => const SafetyAssistPage(),
  };
}
