import 'package:flutter/material.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/theme/app_theme.dart';

class LuminousApp extends StatelessWidget {
  const LuminousApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Luminous',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
