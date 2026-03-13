import 'package:flutter/material.dart';

class LoadingUtils {
  LoadingUtils._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static int _loadingCount = 0;
  static bool _isVisible = false;

  static void show({String text = '加载中...'}) {
    _loadingCount++;
    if (_isVisible) {
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null) {
      _loadingCount = 0;
      return;
    }

    _isVisible = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: Center(
            child: Container(
              width: 128,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xE6000000),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _isVisible = false;
    });
  }

  static void hide() {
    if (_loadingCount <= 0) {
      _loadingCount = 0;
      return;
    }

    _loadingCount--;
    if (_loadingCount > 0 || !_isVisible) {
      return;
    }

    final navigator = navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
    }
  }
}
