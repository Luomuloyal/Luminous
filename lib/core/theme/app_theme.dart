import 'package:flutter/material.dart';
import 'package:luminous/core/constants/app_colors.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.seed,
    brightness: Brightness.light,
  );

  static final dark = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.seed,
    brightness: Brightness.dark,
  );
}
