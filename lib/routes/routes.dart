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
  final spec = _safeThemeSpec(style);
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
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: Color(0xFFE4EAF2)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color.alphaBlend(
        spec.lightPrimary.withValues(alpha: 0.035),
        const Color(0xFFF7F9FC),
      ),
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
  final spec = _safeThemeSpec(style);
  final darkOnSurface = const Color(0xFFF2F6FF);
  final darkOnSurfaceVariant = Color.alphaBlend(
    spec.darkPrimary.withValues(alpha: 0.24),
    const Color(0xFFA6B4C7),
  );
  final darkOutline = Color.alphaBlend(
    spec.darkPrimary.withValues(alpha: 0.20),
    const Color(0xFF32445B),
  );
  final darkDivider = Color.alphaBlend(
    spec.darkPrimary.withValues(alpha: 0.15),
    const Color(0xFF2A3A4F),
  );
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: spec.darkPrimary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: spec.darkPrimary,
        surface: spec.darkSurface,
        secondary: spec.darkSecondary,
        tertiary: spec.darkTertiary,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkOnSurfaceVariant,
        outline: darkOutline,
        outlineVariant: darkDivider,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: spec.darkBackground,
    canvasColor: spec.darkBackground,
    dividerColor: darkDivider,
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
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: darkOnSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: spec.darkSurface,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: darkOutline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color.alphaBlend(
        spec.darkPrimary.withValues(alpha: 0.08),
        spec.darkSurfaceAlt,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: TextStyle(
        color: darkOnSurfaceVariant.withValues(alpha: 0.88),
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
        foregroundColor: spec.darkBackground,
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
      side: BorderSide(color: darkOutline),
      fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return spec.darkPrimary;
        }
        return spec.darkSurfaceAlt;
      }),
      checkColor: WidgetStatePropertyAll<Color>(spec.darkBackground),
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
          color: selected
              ? spec.darkPrimary
              : darkOnSurfaceVariant.withValues(alpha: 0.92),
        );
      }),
    ),
  );
}

_AppThemeSpec _themeSpecFor(AppThemeStyle style) {
  switch (style) {
    case AppThemeStyle.softGlow:
      return const _AppThemeSpec(
        lightPrimary: Color(0xFF2DA7E7),
        lightSecondary: Color(0xFFC78DE8),
        lightTertiary: Color(0xFFF3C983),
        lightBackground: Color(0xFFF8FBFF),
        darkPrimary: Color(0xFF90DBFF),
        darkSecondary: Color(0xFFD8B8FF),
        darkTertiary: Color(0xFFF0D184),
        darkBackground: Color(0xFF0A1424),
        darkSurface: Color(0xFF13223A),
        darkSurfaceAlt: Color(0xFF1D3050),
      );
    case AppThemeStyle.moonMist:
      return const _AppThemeSpec(
        lightPrimary: Color(0xFF3A82F6),
        lightSecondary: Color(0xFF7E8EF8),
        lightTertiary: Color(0xFFA4BCFF),
        lightBackground: Color(0xFFF1F6FF),
        darkPrimary: Color(0xFF9DC8FF),
        darkSecondary: Color(0xFFB0B8FF),
        darkTertiary: Color(0xFF75A6E9),
        darkBackground: Color(0xFF061423),
        darkSurface: Color(0xFF0F233A),
        darkSurfaceAlt: Color(0xFF17365A),
      );
    case AppThemeStyle.divineTree:
      return const _AppThemeSpec(
        lightPrimary: Color(0xFF8CAF4B),
        lightSecondary: Color(0xFFDFC05D),
        lightTertiary: Color(0xFFAECB63),
        lightBackground: Color(0xFFFAFBEF),
        darkPrimary: Color(0xFFD0E386),
        darkSecondary: Color(0xFFE4C977),
        darkTertiary: Color(0xFF99C97A),
        darkBackground: Color(0xFF0A120C),
        darkSurface: Color(0xFF142218),
        darkSurfaceAlt: Color(0xFF1F3124),
      );
    case AppThemeStyle.illusion:
      return const _AppThemeSpec(
        lightPrimary: Color(0xFF9D68F0),
        lightSecondary: Color(0xFFC39CFF),
        lightTertiary: Color(0xFF7D91EB),
        lightBackground: Color(0xFFF8F3FF),
        darkPrimary: Color(0xFFD4B8FF),
        darkSecondary: Color(0xFFAF93F1),
        darkTertiary: Color(0xFF7A8DE0),
        darkBackground: Color(0xFF120A20),
        darkSurface: Color(0xFF1F1632),
        darkSurfaceAlt: Color(0xFF2C1D46),
      );
    case AppThemeStyle.lightSand:
      return const _AppThemeSpec(
        lightPrimary: Color(0xFFBDA286),
        lightSecondary: Color(0xFFCDA6A7),
        lightTertiary: Color(0xFFBD8A6E),
        lightBackground: Color(0xFFF7EFE7),
        darkPrimary: Color(0xFFDAC2A9),
        darkSecondary: Color(0xFFCBA4A8),
        darkTertiary: Color(0xFFBF9076),
        darkBackground: Color(0xFF17110D),
        darkSurface: Color(0xFF231A14),
        darkSurfaceAlt: Color(0xFF31241D),
      );
  }
}

const _AppThemeSpec _fallbackThemeSpec = _AppThemeSpec(
  lightPrimary: Color(0xFF2DA7E7),
  lightSecondary: Color(0xFFC78DE8),
  lightTertiary: Color(0xFFF3C983),
  lightBackground: Color(0xFFF8FBFF),
  darkPrimary: Color(0xFF90DBFF),
  darkSecondary: Color(0xFFD8B8FF),
  darkTertiary: Color(0xFFF0D184),
  darkBackground: Color(0xFF0A1424),
  darkSurface: Color(0xFF13223A),
  darkSurfaceAlt: Color(0xFF1D3050),
);

_AppThemeSpec _safeThemeSpec(AppThemeStyle style) {
  try {
    final spec = _themeSpecFor(style) as _AppThemeSpec?;
    return spec ?? _fallbackThemeSpec;
  } catch (_) {
    return _fallbackThemeSpec;
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
