import 'package:flutter/material.dart';
import 'package:luminous/constants/constants.dart';
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
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppUiConstants.PAGE_BACKGROUND,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _HorizontalSlidePageTransitionsBuilder(),
          TargetPlatform.iOS: _HorizontalSlidePageTransitionsBuilder(),
          TargetPlatform.linux: _HorizontalSlidePageTransitionsBuilder(),
          TargetPlatform.macOS: _HorizontalSlidePageTransitionsBuilder(),
          TargetPlatform.windows: _HorizontalSlidePageTransitionsBuilder(),
          TargetPlatform.fuchsia: _HorizontalSlidePageTransitionsBuilder(),
        },
      ),
    ),
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
    '/scan': (context) => const MedicineScanPage(
      mode: ScanEntryMode.result,
      promptSourceOnStart: true,
    ),
    '/reminders': (context) => const ReminderListPage(),
    '/checkin': (context) => const CheckInPage(),
    '/safety': (context) => const SafetyAssistPage(),
  };
}

/// 轻量的全局页面切换动画。
///
/// 新页面从右向左轻推进入，并附带很弱的透明度过渡，
/// 避免复杂变换导致低端机掉帧。
class _HorizontalSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const _HorizontalSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final primary = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );
    final secondary = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );
    final incoming = Tween<Offset>(
      begin: const Offset(0.07, 0),
      end: Offset.zero,
    ).animate(primary);
    final outgoing = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.02, 0),
    ).animate(secondary);
    final opacity = Tween<double>(begin: 0.95, end: 1).animate(primary);

    return SlideTransition(
      position: outgoing,
      child: SlideTransition(
        position: incoming,
        child: FadeTransition(opacity: opacity, child: child),
      ),
    );
  }
}
