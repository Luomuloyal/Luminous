import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/pages/CheckIn/checkin.dart';
import 'package:luminous/pages/Legal/legal_documents.dart';
import 'package:luminous/pages/Login/login.dart';
import 'package:luminous/pages/Main/main.dart';
import 'package:luminous/pages/Register/register.dart';
import 'package:luminous/pages/Reminders/reminder_list.dart';
import 'package:luminous/pages/Safety/safety_assist.dart';
import 'package:luminous/pages/Scan/medicine_scan.dart';
import 'package:luminous/pages/Search/search.dart';
import 'package:luminous/pages/Settings/settings.dart';
import 'package:luminous/stores/theme_controller.dart';
import 'package:luminous/utils/loading_utils.dart';

/// 构建应用根组件。
///
/// 当前项目使用原生 `MaterialApp` 路由表，不依赖 `GetMaterialApp`。
Widget getRootWidget() {
  final themeController = Get.find<ThemeController>();
  return Obx(() {
    final style = themeController.themeStyle.value;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: LoadingUtils.navigatorKey,
      theme: _buildLightTheme(style),
      darkTheme: _buildDarkTheme(style),
      themeMode: themeController.themeMode,
      initialRoute: '/',
      routes: getRootRoutes(),
    );
  });
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
    '/settings': (context) => const SettingsPage(),
    '/user-agreement': (context) => const UserAgreementPage(),
    '/privacy-policy': (context) => const PrivacyPolicyPage(),
  };
}

ThemeData _buildLightTheme(AppThemeStyle style) {
  final spec = _themeSpecFor(style);
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: spec.lightPrimary,
        brightness: Brightness.light,
      ).copyWith(
        primary: spec.lightPrimary,
        secondary: spec.lightSecondary,
        tertiary: spec.lightTertiary,
        surface: Colors.white,
        onSurfaceVariant: const Color(0xFF64748B),
        outline: const Color(0xFFDDE5F0),
        shadow: const Color(0xFF0F172A),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: spec.lightBackground,
    canvasColor: spec.lightBackground,
    dividerColor: const Color(0xFFE2E8F0),
    shadowColor: const Color(0xFF0F172A),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF0F172A),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: Color(0xFFE4EAF2)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: spec.lightPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: spec.lightPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: Color(0xFFCBD5E1)),
      fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return spec.lightPrimary;
        }
        return Colors.white;
      }),
      checkColor: const WidgetStatePropertyAll<Color>(Colors.white),
    ),
    switchTheme: const SwitchThemeData(
      trackOutlineColor: WidgetStatePropertyAll<Color>(Colors.transparent),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: spec.lightPrimary.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12.5,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          color: selected ? spec.lightPrimary : AppUiConstants.TAB_INACTIVE,
        );
      }),
    ),
  );
}

ThemeData _buildDarkTheme(AppThemeStyle style) {
  final spec = _themeSpecFor(style);
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: spec.darkPrimary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: spec.darkPrimary,
        surface: spec.darkSurface,
        secondary: spec.darkSecondary,
        tertiary: spec.darkTertiary,
        onSurfaceVariant: const Color(0xFF97A6BA),
        outline: const Color(0xFF334155),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: spec.darkBackground,
    canvasColor: spec.darkBackground,
    dividerColor: const Color(0xFF334155),
    shadowColor: Colors.black,
    dialogTheme: DialogThemeData(
      backgroundColor: spec.darkSurface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: spec.darkSurface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: spec.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF131E30),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: Color(0xFF334155)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: spec.darkSurfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: spec.darkPrimary,
        foregroundColor: const Color(0xFF082F49),
        minimumSize: const Size(0, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: spec.darkPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: Color(0xFF475569)),
      fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return spec.darkPrimary;
        }
        return spec.darkSurfaceAlt;
      }),
      checkColor: const WidgetStatePropertyAll<Color>(Color(0xFF082F49)),
    ),
    switchTheme: const SwitchThemeData(
      trackOutlineColor: WidgetStatePropertyAll<Color>(Colors.transparent),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: spec.darkPrimary.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12.5,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          color: selected ? spec.darkPrimary : const Color(0xFF94A3B8),
        );
      }),
    ),
  );
}

_AppThemeSpec _themeSpecFor(AppThemeStyle style) {
  switch (style) {
    case AppThemeStyle.softGlow:
      return const _AppThemeSpec(
        lightPrimary: Color(0xFF18A9F4),
        lightSecondary: Color(0xFFC796FF),
        lightTertiary: Color(0xFFF2CF67),
        lightBackground: Color(0xFFF9FBFF),
        darkPrimary: Color(0xFF83DCFF),
        darkSecondary: Color(0xFFE2C8FF),
        darkTertiary: Color(0xFFF6DE86),
        darkBackground: Color(0xFF0B1526),
        darkSurface: Color(0xFF152239),
        darkSurfaceAlt: Color(0xFF203250),
      );
    case AppThemeStyle.moonMist:
      return const _AppThemeSpec(
        lightPrimary: Color(0xFF5689EE),
        lightSecondary: Color(0xFF8476F0),
        lightTertiary: Color(0xFF79C9DA),
        lightBackground: Color(0xFFF4F7FD),
        darkPrimary: Color(0xFFA7BEFF),
        darkSecondary: Color(0xFFC8BEFF),
        darkTertiary: Color(0xFF83CFDF),
        darkBackground: Color(0xFF08111C),
        darkSurface: Color(0xFF102033),
        darkSurfaceAlt: Color(0xFF1A2C45),
      );
  }
}

class _AppThemeSpec {
  const _AppThemeSpec({
    required this.lightPrimary,
    required this.lightSecondary,
    required this.lightTertiary,
    required this.lightBackground,
    required this.darkPrimary,
    required this.darkSecondary,
    required this.darkTertiary,
    required this.darkBackground,
    required this.darkSurface,
    required this.darkSurfaceAlt,
  });

  final Color lightPrimary;
  final Color lightSecondary;
  final Color lightTertiary;
  final Color lightBackground;
  final Color darkPrimary;
  final Color darkSecondary;
  final Color darkTertiary;
  final Color darkBackground;
  final Color darkSurface;
  final Color darkSurfaceAlt;
}
