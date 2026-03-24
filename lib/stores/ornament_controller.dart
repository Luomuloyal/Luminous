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
    final templateHash = _stableHash(
      '$seed::template::$ornamentKey::${family.name}',
    );
    final variantHash = _stableHash(
      '$seed::variant::$ornamentKey::${family.name}',
    );
    final index = templateHash % templates.length;
    final base = templates[index];

    return buildVariantOrnamentLayout(
      base,
      id: '${base.id}-v${variantHash % 997}',
      family: family,
      mirrorX: variantHash.isEven,
      mirrorY: family == AppOrnamentFamily.section
          ? variantHash % 4 == 0
          : variantHash % 6 == 0,
      scale: _pickScale(variantHash, family),
      shiftX: _pickShift(
        variantHash >> 4,
        family == AppOrnamentFamily.banner ? 28 : 36,
      ),
      shiftY: _pickShift(
        variantHash >> 10,
        family == AppOrnamentFamily.banner ? 18 : 24,
      ),
      rotationDelta: _pickRotation(variantHash >> 16),
      swapColorRoles: variantHash % 5 == 0,
    );
  }

  double _pickScale(int hash, AppOrnamentFamily family) {
    final min = family == AppOrnamentFamily.banner ? 0.88 : 0.84;
    final max = family == AppOrnamentFamily.banner ? 1.18 : 1.16;
    final t = ((hash >> 2) & 0xFF) / 255;
    return min + (max - min) * t;
  }

  double _pickShift(int hash, double amplitude) {
    final t = (hash & 0xFF) / 255;
    return (t * 2 - 1) * amplitude;
  }

  double _pickRotation(int hash) {
    final t = (hash & 0xFF) / 255;
    return (t * 2 - 1) * 0.18;
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
