import 'package:flutter/material.dart';
import 'package:luminous/pages/Login/login.dart';
import 'package:luminous/pages/Main/main.dart';
import 'package:luminous/pages/Register/register.dart';
import 'package:luminous/pages/Search/search.dart';

// 返回APP根级组件
Widget getRootWidget() {
  return MaterialApp(
    // 命名路由
    initialRoute: "/",
    routes: getRootRoutes(),
  );
}

Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    "/": (context) => MainPage(),
    "/login": (context) => LoginPage(),
    "/register": (context) => RegisterView(),
    "/search": (context) => SearchView(),
  };
}
