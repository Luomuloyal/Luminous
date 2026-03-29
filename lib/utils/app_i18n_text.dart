import 'dart:ui' as ui;

import 'package:get/get.dart';

/// 轻量文本本地化助手。
///
/// 适用于没有 BuildContext 的底层模块（如 utils/store/viewmodel）。
class AppI18nText {
  AppI18nText._();

  static bool get isChinese {
    final languageCode =
        (Get.locale?.languageCode.isNotEmpty == true
                ? Get.locale!.languageCode
                : ui.PlatformDispatcher.instance.locale.languageCode)
            .toLowerCase();
    return languageCode.startsWith('zh');
  }

  static String pick({required String zh, required String en}) {
    return isChinese ? zh : en;
  }
}
