import 'package:flutter/material.dart';
import 'package:luminous/pages/Login/login.dart';
import 'package:luminous/pages/Main/main.dart';
import 'package:luminous/pages/Register/register.dart';
import 'package:luminous/pages/Search/search.dart';
import 'package:luminous/utils/loading_utils.dart';

// routes.dart：应用路由表
//
// 当前使用原生 MaterialApp 路由（不依赖 GetMaterialApp），GetX 仅用于状态/依赖注入。
// 这样做的好处：路由体系清晰，后续如果要引入更复杂的路由方案也容易替换。
// 返回APP根级组件
Widget getRootWidget() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    navigatorKey: LoadingUtils.navigatorKey,
    initialRoute: '/',
    routes: getRootRoutes(),
  );
}

Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    '/': (context) => const MainPage(),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterView(),
    '/search': (context) => const SearchView(),
  };
}
