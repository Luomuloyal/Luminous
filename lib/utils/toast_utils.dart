import 'package:flutter/material.dart';

class ToastUtils {
  ToastUtils._();

  static final ToastUtils instance = ToastUtils._();

  void show(
    BuildContext context,
    String msg, {
    Duration toastduration = const Duration(milliseconds: 1200),
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
          margin: const EdgeInsets.fromLTRB(56, 0, 56, 20),
          duration: toastduration,
          elevation: 0,
          backgroundColor: const Color.fromARGB(230, 51, 113, 113),
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
