import 'package:flutter/material.dart';
import 'package:luminous/pages/Login/login.dart';
import 'package:luminous/pages/Main/main.dart';
import 'package:luminous/pages/Register/register.dart';
import 'package:luminous/pages/Search/search.dart';
import 'package:luminous/utils/loading_utils.dart';

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
