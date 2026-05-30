import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class AppToast {
  const AppToast._();

  static Future<bool?> show(BuildContext context, String message) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>();

    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: surface?.body.withValues(alpha: 0.92) ?? Colors.black87,
      textColor: surface?.canvas ?? Colors.white,
      fontSize: 14,
    );
  }
}
