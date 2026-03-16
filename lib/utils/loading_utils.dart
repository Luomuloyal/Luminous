import 'package:flutter/material.dart';

/// 全局 Loading 弹窗工具。
///
/// 通过 `navigatorKey` 在应用任意位置展示/关闭统一的阻塞式 Loading。
class LoadingUtils {
  /// 私有构造函数，当前类只作为静态工具使用。
  LoadingUtils._();

  /// 全局导航 key。
  ///
  /// `MaterialApp` 会把它挂到根导航器上，便于在非页面上下文中弹出 Loading。
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// 当前仍未结束的 Loading 请求数量。
  ///
  /// 用计数方式处理并发请求，避免一个请求先结束就把另一个请求的 Loading 关掉。
  static int _loadingCount = 0;

  /// 当前屏幕上是否已经有 Loading 弹窗在显示。
  static bool _isVisible = false;

  /// 显示全局 Loading 弹窗。
  ///
  /// 如果已有 Loading 在显示，则只增加计数，不重复弹出。
  static void show({String text = '加载中...'}) {
    _loadingCount++;
    if (_isVisible) {
      return;
    }

    /// 当前根导航器上下文。
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

  /// 隐藏全局 Loading 弹窗。
  ///
  /// 只有当计数减到 0 并且当前确实有 Loading 显示时，才会真正执行关闭。
  static void hide() {
    if (_loadingCount <= 0) {
      _loadingCount = 0;
      return;
    }

    _loadingCount--;
    if (_loadingCount > 0 || !_isVisible) {
      return;
    }

    /// 当前根导航器状态对象。
    final navigator = navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
    }
  }
}
