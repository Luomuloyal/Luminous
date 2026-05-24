import 'package:flutter/material.dart';
import 'package:luminous/shared/layout/app_breakpoints.dart';

/// Top-level adaptive shell for switching between phone and wide navigation.
class AppAdaptiveScaffold extends StatelessWidget {
  const AppAdaptiveScaffold({
    super.key,
    required this.windowClass,
    required this.body,
    required this.backgroundColor,
    this.compactBottomNavigationBar,
    this.wideNavigationPane,
    this.extendCompactBody = true,
  });

  final AppWindowClass windowClass;
  final Widget body;
  final Color backgroundColor;
  final Widget? compactBottomNavigationBar;
  final Widget? wideNavigationPane;
  final bool extendCompactBody;

  @override
  Widget build(BuildContext context) {
    if (windowClass.usesBottomNavigation) {
      return Scaffold(
        backgroundColor: backgroundColor,
        extendBody: extendCompactBody,
        body: body,
        bottomNavigationBar: compactBottomNavigationBar,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          ?wideNavigationPane,
          Expanded(child: body),
        ],
      ),
    );
  }
}
