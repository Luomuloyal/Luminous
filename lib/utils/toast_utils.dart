import 'package:flutter/material.dart';

/// 统一轻提示工具。
///
/// 当前基于 `SnackBar` 实现，负责把普通文本消息展示给用户。
class ToastUtils {
  /// 私有构造函数，保证只通过单例使用。
  ToastUtils._();

  /// 全局单例实例。
  static final ToastUtils instance = ToastUtils._();

  /// 显示一条 Toast/SnackBar 提示。
  ///
  /// - `context`：当前页面上下文；
  /// - `msg`：要展示的提示文本；
  /// - `toastduration`：提示持续时长。
  void show(
    BuildContext context,
    String msg, {
    Duration toastduration = const Duration(seconds: 2),
  }) {
    /// 去除首尾空白后的提示文案。
    final message = msg.trim();
    if (message.isEmpty) {
      return;
    }

    /// 当前页面可用的 ScaffoldMessenger。
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(56, 0, 56, 20),
          duration: toastduration,
          elevation: 0,
          backgroundColor: const Color.fromARGB(230, 35, 150, 150),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
  }
}
