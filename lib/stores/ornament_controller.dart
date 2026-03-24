import 'dart:async';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:luminous/components/app_ornaments.dart';

/// 会话级装饰布局控制器。
///
/// 启动后异步生成一次 session seed：
/// - 不阻塞首帧；
/// - 本次运行内稳定；
/// - 完整重启应用后允许变化。
class OrnamentController extends GetxController {
  final RxInt revision = 0.obs;
  final math.Random _random = math.Random();

  int? _sessionSeed;
  bool _warming = false;

  bool get isReady => _sessionSeed != null;

  /// 异步预热装饰 seed。
  Future<void> warmup() async {
    if (_warming || isReady) {
      return;
    }
    _warming = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 28));
      _sessionSeed =
          DateTime.now().microsecondsSinceEpoch ^ _random.nextInt(1 << 30);
      revision.value++;
    } finally {
      _warming = false;
    }
  }

  /// 根据稳定 key 返回本次会话内固定的装饰模板。
  AppOrnamentLayout? resolveLayout({
    required String ornamentKey,
    required AppOrnamentFamily family,
  }) {
    final seed = _sessionSeed;
    if (seed == null) {
      return null;
    }

    final templates = switch (family) {
      AppOrnamentFamily.banner => kBannerSessionLayouts,
      AppOrnamentFamily.section => kSectionSessionLayouts,
    };
    final index =
        _stableHash('$seed::$ornamentKey::${family.name}') % templates.length;
    return templates[index];
  }

  int _stableHash(String value) {
    var hash = 0x811C9DC5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
