import 'package:flutter/material.dart';

enum PopupMode { info, success, warning, error }

class PopupUtils {
  PopupUtils._();
  static final PopupUtils instance = PopupUtils._();

  // 阀门控制: 阀门开启时，忽略后续弹窗，避免排队
  bool showLoading = false;

  void showToast(
    BuildContext context,
    String? msg, {
    PopupMode mode = PopupMode.info,
    Duration duration = const Duration(milliseconds: 700),
  }) {
    if (msg == null || msg.trim().isEmpty) {
      return;
    }
    if (showLoading) {
      return;
    }

    showLoading = true;
    Future.delayed(duration, () {
      showLoading = false;
    });

    final _ToastVisual visual = _resolveVisual(mode);

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          width: 180,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          backgroundColor: visual.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              Icon(visual.icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  msg,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  _ToastVisual _resolveVisual(PopupMode mode) {
    switch (mode) {
      case PopupMode.success:
        return const _ToastVisual(
          icon: Icons.check_circle_rounded,
          backgroundColor: Color(0xFF16A34A),
        );
      case PopupMode.warning:
        return const _ToastVisual(
          icon: Icons.warning_amber_rounded,
          backgroundColor: Color(0xFFF59E0B),
        );
      case PopupMode.error:
        return const _ToastVisual(
          icon: Icons.error_rounded,
          backgroundColor: Color(0xFFDC2626),
        );
      case PopupMode.info:
        return const _ToastVisual(
          icon: Icons.info_rounded,
          backgroundColor: Color(0xFF0EA5E9),
        );
    }
  }
}

class _ToastVisual {
  final IconData icon;
  final Color backgroundColor;

  const _ToastVisual({required this.icon, required this.backgroundColor});
}
