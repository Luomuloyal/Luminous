import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/core/providers/locale_provider.dart';
import 'package:luminous/core/providers/theme_provider.dart';
import 'package:luminous/router/app_router.dart';

/// 构建应用根组件。
///
/// 当前项目使用原生 `MaterialApp.router` 结合 GoRouter 路由表体系。
class RootAppWidget extends ConsumerWidget {
  const RootAppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeMode = ref.read(themeProvider.notifier).themeMode;
    final locale = ref.read(localeProvider.notifier).locale;
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
  final spec = _safeThemeSpec(style);
  final scaffoldBackground = _softenedLightBackground(spec.lightBackground);
  final lightOnSurfaceVariant = _lightOnSurfaceVariant(spec);
  final lightOutline = _lightOutline(spec);
  final lightDivider = _lightDivider(spec);
  final lightCardBorder = _lightCardBorder(spec);
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: spec.lightPrimary,
        brightness: Brightness.light,
      ).copyWith(
        primary: spec.lightPrimary,
        secondary: spec.lightSecondary,
        tertiary: spec.lightTertiary,
        surface: Colors.white,
        onSurfaceVariant: lightOnSurfaceVariant,
        outline: lightOutline,
        outlineVariant: lightDivider,
        shadow: const Color(0xFF0F172A),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBackground,
    canvasColor: scaffoldBackground,
    dividerColor: lightDivider,
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
        side: BorderSide(color: lightCardBorder),
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
  final spec = _safeThemeSpec(style);
  final scaffoldBackground = _softenedDarkBackground(spec.darkBackground);
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

_AppThemeSpec _themeSpecFor(AppThemeStyle style) {
  switch (style) {
    case AppThemeStyle.softGlow:
      return const _AppThemeSpec(
        lightPrimary: Color(0xFF3FA9E8),
        lightSecondary: Color(0xFFCAA4E8),
        lightTertiary: Color(0xFFF1CB8A),
        lightBackground: Color(0xFFF7FBFF),
        darkPrimary: Color(0xFFA6DBFF),
        darkSecondary: Color(0xFFD8C1FF),
        darkTertiary: Color(0xFFE9D08E),
        darkBackground: Color(0xFF0B1524),
        darkSurface: Color(0xFF14243A),
        darkSurfaceAlt: Color(0xFF1E3351),
      );
    case AppThemeStyle.moonMist:
      return const _AppThemeSpec(
        lightPrimary: Color(0xFF5A8FE6),
        lightSecondary: Color(0xFF9AA5F2),
        lightTertiary: Color(0xFFC5D3FF),
        lightBackground: Color(0xFFF3F7FD),
        darkPrimary: Color(0xFFAACBFF),
        darkSecondary: Color(0xFFC3C8FF),
        darkTertiary: Color(0xFF8FAEED),
        darkBackground: Color(0xFF081523),
        darkSurface: Color(0xFF122435),
        darkSurfaceAlt: Color(0xFF1A314A),
      );
    case AppThemeStyle.divineTree:
      return const _AppThemeSpec(
        lightPrimary: Color(0xFF8FA85C),
        lightSecondary: Color(0xFFD8BD71),
        lightTertiary: Color(0xFFAFCC92),
        lightBackground: Color(0xFFFBFAF0),
        darkPrimary: Color(0xFFD1E4A0),
        darkSecondary: Color(0xFFE1CB85),
        darkTertiary: Color(0xFF9BC68A),
        darkBackground: Color(0xFF0B120C),
        darkSurface: Color(0xFF15231A),
        darkSurfaceAlt: Color(0xFF203327),
      );
    case AppThemeStyle.illusion:
      return const _AppThemeSpec(
        lightPrimary: Color(0xFF9272E6),
        lightSecondary: Color(0xFFB89BEF),
        lightTertiary: Color(0xFF88A0E8),
        lightBackground: Color(0xFFF7F4FF),
        darkPrimary: Color(0xFFD0C0FF),
        darkSecondary: Color(0xFFA99AEF),
        darkTertiary: Color(0xFF87A0E4),
        darkBackground: Color(0xFF110B1E),
        darkSurface: Color(0xFF1F1730),
        darkSurfaceAlt: Color(0xFF2B1F45),
      );
    case AppThemeStyle.lightSand:
      return const _AppThemeSpec(
        lightPrimary: Color(0xFFBD9C7D),
        lightSecondary: Color(0xFFD6B1A6),
        lightTertiary: Color(0xFFC89072),
        lightBackground: Color(0xFFFAF1E9),
        darkPrimary: Color(0xFFE0C6AF),
        darkSecondary: Color(0xFFD8B1A7),
        darkTertiary: Color(0xFFC89074),
        darkBackground: Color(0xFF17110D),
        darkSurface: Color(0xFF241B15),
        darkSurfaceAlt: Color(0xFF32251E),
      );
  }
}

const _AppThemeSpec _fallbackThemeSpec = _AppThemeSpec(
  lightPrimary: Color(0xFF3FA9E8),
  lightSecondary: Color(0xFFCAA4E8),
  lightTertiary: Color(0xFFF1CB8A),
  lightBackground: Color(0xFFF7FBFF),
  darkPrimary: Color(0xFFA6DBFF),
  darkSecondary: Color(0xFFD8C1FF),
  darkTertiary: Color(0xFFE9D08E),
  darkBackground: Color(0xFF0B1524),
  darkSurface: Color(0xFF14243A),
  darkSurfaceAlt: Color(0xFF1E3351),
);

_AppThemeSpec _safeThemeSpec(AppThemeStyle style) {
  try {
    final spec = _themeSpecFor(style) as _AppThemeSpec?;
    return spec ?? _fallbackThemeSpec;
  } catch (_) {
    return _fallbackThemeSpec;
  }
}

Color _softenedLightBackground(Color themedBackground) {
  return Color.lerp(const Color(0xFFF7F9FC), themedBackground, 0.72)!;
}

Color _softenedDarkBackground(Color themedBackground) {
  return Color.lerp(const Color(0xFF0C1118), themedBackground, 0.72)!;
}

Color _lightOnSurfaceVariant(_AppThemeSpec spec) {
  return Color.alphaBlend(
    Color.lerp(
      spec.lightPrimary,
      spec.lightSecondary,
      0.42,
    )!.withValues(alpha: 0.10),
    const Color(0xFF65758A),
  );
}

Color _lightOutline(_AppThemeSpec spec) {
  return Color.alphaBlend(
    Color.lerp(
      spec.lightPrimary,
      spec.lightSecondary,
      0.48,
    )!.withValues(alpha: 0.16),
    const Color(0xFFD9E2ED),
  );
}

Color _lightDivider(_AppThemeSpec spec) {
  return Color.alphaBlend(
    Color.lerp(
      spec.lightSecondary,
      spec.lightTertiary,
      0.42,
    )!.withValues(alpha: 0.12),
    const Color(0xFFE2E8F0),
  );
}

Color _lightCardBorder(_AppThemeSpec spec) {
  return Color.alphaBlend(
    Color.lerp(
      spec.lightPrimary,
      spec.lightTertiary,
      0.34,
    )!.withValues(alpha: 0.12),
    const Color(0xFFE4EAF2),
  );
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
