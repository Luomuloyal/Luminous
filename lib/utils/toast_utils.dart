import 'package:flutter/material.dart';

class ToastUtils {
  ToastUtils._();

  static final ToastUtils instance = ToastUtils._();

  void show(
    BuildContext context,
    String msg, {
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    final message = msg.trim();
    if (message.isEmpty) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          duration: duration,
          elevation: 0,
          backgroundColor: const Color(0xE6000000),
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
