import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:luminous/utils/message_utils.dart';

/// 轻提示出现位置。
enum ToastPlacement { top, bottom }

/// 轻提示视觉类型。
enum ToastTone { info, error }

/// 统一轻提示工具。
///
/// 当前基于 `OverlayEntry` 实现，支持顶部与底部两种提示位置。
class ToastUtils {
  /// 私有构造函数，保证只通过单例使用。
  ToastUtils._();

  static const double _topSafeGap = 34;
  static const double _bottomSafeGap = 92;

  /// 全局单例实例。
  static final ToastUtils instance = ToastUtils._();

  OverlayEntry? _activeEntry;
  Timer? _dismissTimer;

  /// 显示一条轻提示。
  ///
  /// - `context`：当前页面上下文；
  /// - `msg`：要展示的提示文本；
  /// - `toastduration`：提示持续时长；
  /// - `placement`：提示位置，默认底部。
  void show(
    BuildContext context,
    String msg, {
    Duration toastduration = const Duration(seconds: 2),
    ToastPlacement placement = ToastPlacement.bottom,
  }) {
    final raw = msg.trim();
    final shouldNormalize =
        raw.contains('\n') ||
        raw.contains('Exception') ||
        raw.contains('DioException') ||
        raw.contains('StackTrace') ||
        raw.contains('(package:') ||
        raw.contains('package:') ||
        raw.length > 120;
    final message = shouldNormalize
        ? MessageUtils.normalize(raw, fallback: '', maxLength: 80)
        : raw;
    if (message.isEmpty) {
      return;
    }

    _showOverlay(
      context,
      message: message,
      toastduration: toastduration,
      placement: placement,
      tone: ToastTone.info,
    );
  }

  /// 显示一条顶部轻提示。
  void showTop(
    BuildContext context,
    String msg, {
    Duration toastduration = const Duration(seconds: 2),
  }) {
    show(
      context,
      msg,
      toastduration: toastduration,
      placement: ToastPlacement.top,
    );
  }

  /// 显示一条“错误提示”。
  ///
  /// 错误默认从顶部出现，更容易和普通底部提示区分开。
  void showError(
    BuildContext context,
    Object? error, {
    String fallback = '操作失败，请稍后重试',
    Duration toastduration = const Duration(seconds: 2),
  }) {
    _logError(error);
    final message = MessageUtils.extractError(
      error,
      fallback: fallback,
      maxLength: 36,
    );
    if (message.isEmpty) {
      return;
    }

    _showOverlay(
      context,
      message: message,
      toastduration: toastduration,
      placement: ToastPlacement.top,
      tone: ToastTone.error,
    );
  }

  void _logError(Object? error) {
    if (!kDebugMode || error == null) {
      return;
    }

    debugPrint('[ToastError] $error');
    if (error is Error) {
      debugPrintStack(stackTrace: error.stackTrace);
    }
  }

  void _showOverlay(
    BuildContext context, {
    required String message,
    required Duration toastduration,
    required ToastPlacement placement,
    required ToastTone tone,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    _clearActiveToast();

    final mediaQuery = MediaQuery.maybeOf(context);
    final topInset = mediaQuery?.padding.top ?? 0;
    final bottomInset = mediaQuery?.padding.bottom ?? 0;
    final style = _ToastStyle.fromTone(tone);

    _activeEntry = OverlayEntry(
      builder: (context) {
        return _ToastOverlay(
          message: message,
          placement: placement,
          topOffset: topInset + _topSafeGap,
          bottomOffset: bottomInset + _bottomSafeGap,
          style: style,
        );
      },
    );

    overlay.insert(_activeEntry!);
    _dismissTimer = Timer(toastduration, _clearActiveToast);
  }

  /// 立即关闭当前提示。
  void dismiss() {
    _clearActiveToast();
  }

  void _clearActiveToast() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _activeEntry?.remove();
    _activeEntry = null;
  }
}

class _ToastOverlay extends StatelessWidget {
  const _ToastOverlay({
    required this.message,
    required this.placement,
    required this.topOffset,
    required this.bottomOffset,
    required this.style,
  });

  final String message;
  final ToastPlacement placement;
  final double topOffset;
  final double bottomOffset;
  final _ToastStyle style;

  @override
  Widget build(BuildContext context) {
    final alignedToast = Align(
      alignment: placement == ToastPlacement.top
          ? Alignment.topCenter
          : Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: style.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: style.borderColor),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120F172A),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                14,
                placement == ToastPlacement.bottom ? 14 : 11,
                14,
                placement == ToastPlacement.bottom ? 14 : 11,
              ),
              child: Row(
                children: [
                  Icon(style.icon, size: 18, color: style.accentColor),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: style.textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: placement == ToastPlacement.top ? topOffset : 0,
            bottom: placement == ToastPlacement.bottom ? bottomOffset : 0,
          ),
          child: alignedToast,
        ),
      ),
    );
  }
}

class _ToastStyle {
  const _ToastStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.accentColor,
    required this.textColor,
    required this.icon,
  });

  factory _ToastStyle.fromTone(ToastTone tone) {
    switch (tone) {
      case ToastTone.error:
        return const _ToastStyle(
          backgroundColor: Color(0xFFFFF6F7),
          borderColor: Color(0xFFF5CDD3),
          accentColor: Color(0xFFDC5B73),
          textColor: Color(0xFF8A2742),
          icon: Icons.error_outline_rounded,
        );
      case ToastTone.info:
        return const _ToastStyle(
          backgroundColor: Color(0xFFF7FCFF),
          borderColor: Color(0xFFD8ECF6),
          accentColor: Color(0xFF2FA7C7),
          textColor: Color(0xFF33586B),
          icon: Icons.info_outline_rounded,
        );
    }
  }

  final Color backgroundColor;
  final Color borderColor;
  final Color accentColor;
  final Color textColor;
  final IconData icon;
}
