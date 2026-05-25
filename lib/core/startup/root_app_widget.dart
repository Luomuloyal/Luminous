import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/core/providers/locale_provider.dart';
import 'package:luminous/core/providers/theme_provider.dart';
import 'package:luminous/core/theme/app_theme_spec.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/router/app_router.dart';

/// 构建应用根组件。
///
/// 当前项目使用原生 `MaterialApp.router` 结合 GoRouter 路由表体系。
/// 主题色板规格已迁至 `lib/core/theme/app_theme_spec.dart`。
class RootAppWidget extends ConsumerWidget {
  const RootAppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeMode = ref.read(themeProvider.notifier).themeMode;
    final locale = ref.watch(localeProvider).locale;
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appName ?? 'Luminous',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      theme: _buildLightTheme(themeState.style),
      darkTheme: _buildDarkTheme(themeState.style),
      themeMode: themeMode,
    );
  }
}

ThemeData _buildLightTheme(AppThemeStyle style) {
  final spec = safeThemeSpec(style);
  final scaffoldBackground = softenedLightBackground(spec.lightBackground);
  final onSurfaceVariant = lightOnSurfaceVariant(spec);
  final outline = lightOutline(spec);
  final divider = lightDivider(spec);
  final cardBorder = lightCardBorder(spec);
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: spec.lightPrimary,
        brightness: Brightness.light,
      ).copyWith(
        primary: spec.lightPrimary,
        secondary: spec.lightSecondary,
        tertiary: spec.lightTertiary,
        surface: Colors.white,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: divider,
        shadow: const Color(0xFF0F172A),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBackground,
    canvasColor: scaffoldBackground,
    dividerColor: divider,
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
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: cardBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color.alphaBlend(
        Color.lerp(
          spec.lightPrimary,
          spec.lightSecondary,
          0.30,
        )!.withValues(alpha: 0.04),
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
  final spec = safeThemeSpec(style);
  final scaffoldBackground = softenedDarkBackground(spec.darkBackground);
  final darkOnSurface = const Color(0xFFF2F6FF);
  final darkAccentMix = Color.lerp(spec.darkPrimary, spec.darkSecondary, 0.44)!;
  final darkOnSurfaceVariant = Color.alphaBlend(
    darkAccentMix.withValues(alpha: 0.22),
    const Color(0xFFA6B4C7),
  );
  final darkOutline = Color.alphaBlend(
    darkAccentMix.withValues(alpha: 0.18),
    const Color(0xFF32445B),
  );
  final darkDivider = Color.alphaBlend(
    Color.lerp(
      spec.darkSecondary,
      spec.darkTertiary,
      0.42,
    )!.withValues(alpha: 0.16),
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
    scaffoldBackgroundColor: scaffoldBackground,
    canvasColor: scaffoldBackground,
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
