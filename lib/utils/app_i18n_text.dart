import 'dart:ui' as ui;

import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/core/providers/locale_provider.dart';

/// 轻量文本本地化助手。
///
/// 适用于没有 BuildContext 的底层模块（如 utils/store/viewmodel）。
class AppI18nText {
  AppI18nText._();

  static bool get isChinese {
    final languageCode = _currentLanguageCode.toLowerCase();
    return languageCode.startsWith('zh');
  }

  static String pick({required String zh, required String en}) {
    return isChinese ? zh : en;
  }

  static String get _currentLanguageCode {
    try {
      final preference = globalProviderContainer
          .read(localeProvider)
          .preference;
      switch (preference) {
        case AppLocalePreference.zh:
          return 'zh';
        case AppLocalePreference.en:
          return 'en';
        case AppLocalePreference.system:
          break;
      }
    } catch (_) {
      // Tests and early startup can call this before the app container exists.
    }

    return ui.PlatformDispatcher.instance.locale.languageCode;
  }
}
