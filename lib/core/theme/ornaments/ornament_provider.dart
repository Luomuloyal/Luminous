import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/shared/widgets/ornaments/app_ornaments.dart';
import 'package:luminous/core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppOrnamentTransparencyPreference {
  t0,
  t25,
  t50,
  t75,
  t100;

  int get transparencyPercent {
    return switch (this) {
      AppOrnamentTransparencyPreference.t0 => 0,
      AppOrnamentTransparencyPreference.t25 => 25,
      AppOrnamentTransparencyPreference.t50 => 50,
      AppOrnamentTransparencyPreference.t75 => 75,
      AppOrnamentTransparencyPreference.t100 => 100,
    };
  }

  static AppOrnamentTransparencyPreference fromStorage(String? value) {
    return AppOrnamentTransparencyPreference.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppOrnamentTransparencyPreference.t50,
    );
  }
}

class OrnamentState {
  const OrnamentState({required this.transparencyPercent, this.sessionSeed});

  final int transparencyPercent;
  final int? sessionSeed;

  bool get isReady => sessionSeed != null;

  double get visibilityFactor {
    return ((100 - transparencyPercent) / 100).clamp(0.0, 1.0).toDouble();
  }

  bool get isDisabled => visibilityFactor <= 0;

  AppOrnamentTransparencyPreference? get matchedPreset {
    final current = transparencyPercent;
    for (final preset in AppOrnamentTransparencyPreference.values) {
      if (preset.transparencyPercent == current) {
        return preset;
      }
    }
    return null;
  }

  OrnamentState copyWith({int? transparencyPercent, int? sessionSeed}) {
    return OrnamentState(
      transparencyPercent: transparencyPercent ?? this.transparencyPercent,
      sessionSeed: sessionSeed ?? this.sessionSeed,
    );
  }
}

class OrnamentNotifier extends Notifier<OrnamentState> {
  static const int minTransparencyPercent = 0;
  static const int maxTransparencyPercent = 100;
  static const int transparencyStep = 5;

  final math.Random _random = math.Random();
  bool _warming = false;

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  OrnamentState build() {
    final raw = _prefs.get(GlobalConstants.ORNAMENT_TRANSPARENCY_KEY);

    final resolved = switch (raw) {
      int value => normalizeTransparencyPercent(value),
      double value => normalizeTransparencyPercent(value.round()),
      String value => _resolveTransparencyPercentFromString(value),
      _ => AppOrnamentTransparencyPreference.t50.transparencyPercent,
    };

    return OrnamentState(transparencyPercent: resolved);
  }

  bool get isReady => state.isReady;

  Future<void> init() async {
    final raw = _prefs.get(GlobalConstants.ORNAMENT_TRANSPARENCY_KEY);
    if (raw is! int || raw != state.transparencyPercent) {
      await _prefs.setInt(
        GlobalConstants.ORNAMENT_TRANSPARENCY_KEY,
        state.transparencyPercent,
      );
    }
  }

  int normalizeTransparencyPercent(int rawPercent) {
    final clamped = rawPercent.clamp(
      minTransparencyPercent,
      maxTransparencyPercent,
    );
    final rounded = ((clamped / transparencyStep).round() * transparencyStep)
        .clamp(minTransparencyPercent, maxTransparencyPercent);
    return rounded;
  }

  Future<void> setTransparencyPreference(
    AppOrnamentTransparencyPreference preference,
  ) async {
    await setTransparencyPercent(preference.transparencyPercent);
  }

  Future<void> setTransparencyPercent(int percent) async {
    final normalized = normalizeTransparencyPercent(percent);
    if (state.transparencyPercent == normalized) {
      return;
    }
    state = state.copyWith(transparencyPercent: normalized);
    await _prefs.setInt(GlobalConstants.ORNAMENT_TRANSPARENCY_KEY, normalized);
  }

  Future<void> warmup() async {
    if (_warming || state.isReady || state.isDisabled) {
      return;
    }
    _warming = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 28));
      state = state.copyWith(
        sessionSeed:
            DateTime.now().microsecondsSinceEpoch ^ _random.nextInt(1 << 30),
      );
    } finally {
      _warming = false;
    }
  }

  AppOrnamentLayout? resolveLayout({
    required String ornamentKey,
    required AppOrnamentFamily family,
  }) {
    final seed = state.sessionSeed;
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

  int _resolveTransparencyPercentFromString(String rawValue) {
    final parsedPercent = int.tryParse(rawValue);
    if (parsedPercent != null) {
      return normalizeTransparencyPercent(parsedPercent);
    }
    final mappedPreset = AppOrnamentTransparencyPreference.fromStorage(
      rawValue,
    );
    return mappedPreset.transparencyPercent;
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

final ornamentProvider = NotifierProvider<OrnamentNotifier, OrnamentState>(() {
  return OrnamentNotifier();
});

ProviderContainer? maybeOrnamentContainerOf(BuildContext context) {
  try {
    return ProviderScope.containerOf(context, listen: false);
  } on StateError {
    return null;
  }
}
