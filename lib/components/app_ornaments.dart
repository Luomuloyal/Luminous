import 'package:flutter/material.dart';

/// 大分区卡片与横幅使用的轻量装饰样式。
enum AppOrnamentStyle { orbit, comet, petal, halo }

/// 装饰模板所属的卡片族。
enum AppOrnamentFamily { banner, section }

/// 单个装饰节点的形状类型。
enum AppOrnamentNodeShape { orb, pill, ring }

/// 单个装饰节点的透明度层级。
enum AppOrnamentTone { strong, medium, light, spark }

/// 单个装饰节点的取色角色。
enum AppOrnamentColorRole { accent, secondary }

/// 单个装饰节点的布局描述。
class AppOrnamentNodeSpec {
  const AppOrnamentNodeSpec({
    required this.shape,
    required this.alignment,
    required this.width,
    required this.height,
    required this.tone,
    this.colorRole = AppOrnamentColorRole.accent,
    this.offset = Offset.zero,
    this.rotation = 0,
  });

  final AppOrnamentNodeShape shape;
  final Alignment alignment;
  final double width;
  final double height;
  final AppOrnamentTone tone;
  final AppOrnamentColorRole colorRole;
  final Offset offset;
  final double rotation;
}

/// 一整套装饰布局模板。
class AppOrnamentLayout {
  const AppOrnamentLayout({required this.id, required this.nodes});

  final String id;
  final List<AppOrnamentNodeSpec> nodes;
}

const AppOrnamentLayout kBannerOrbitLayout = AppOrnamentLayout(
  id: 'banner-orbit',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topRight,
      width: 122,
      height: 122,
      tone: AppOrnamentTone.strong,
      offset: Offset(40, -42),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topCenter,
      width: 22,
      height: 22,
      tone: AppOrnamentTone.spark,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(36, 22),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomLeft,
      width: 138,
      height: 138,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-52, 66),
    ),
  ],
);

const AppOrnamentLayout kBannerCometLayout = AppOrnamentLayout(
  id: 'banner-comet',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.topCenter,
      width: 154,
      height: 86,
      tone: AppOrnamentTone.strong,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(22, -34),
      rotation: -0.26,
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.centerLeft,
      width: 18,
      height: 18,
      tone: AppOrnamentTone.spark,
      offset: Offset(18, -10),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.bottomRight,
      width: 168,
      height: 92,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(42, 56),
      rotation: 0.34,
    ),
  ],
);

const AppOrnamentLayout kBannerPetalLayout = AppOrnamentLayout(
  id: 'banner-petal',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topLeft,
      width: 104,
      height: 104,
      tone: AppOrnamentTone.strong,
      offset: Offset(-24, -32),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.centerRight,
      width: 56,
      height: 56,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(16, -18),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.center,
      width: 16,
      height: 16,
      tone: AppOrnamentTone.spark,
      offset: Offset(30, -6),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomCenter,
      width: 132,
      height: 132,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-18, 62),
    ),
  ],
);

const AppOrnamentLayout kBannerHaloLayout = AppOrnamentLayout(
  id: 'banner-halo',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.ring,
      alignment: Alignment.topLeft,
      width: 118,
      height: 118,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-28, -34),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topRight,
      width: 32,
      height: 32,
      tone: AppOrnamentTone.strong,
      offset: Offset(4, 14),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.center,
      width: 14,
      height: 14,
      tone: AppOrnamentTone.spark,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(6, -18),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomRight,
      width: 142,
      height: 142,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(54, 72),
    ),
  ],
);

const AppOrnamentLayout kBannerDriftLayout = AppOrnamentLayout(
  id: 'banner-drift',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.centerLeft,
      width: 164,
      height: 90,
      tone: AppOrnamentTone.strong,
      offset: Offset(-74, -12),
      rotation: 0.28,
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topRight,
      width: 20,
      height: 20,
      tone: AppOrnamentTone.spark,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-16, 8),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomCenter,
      width: 94,
      height: 94,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(42, 48),
    ),
  ],
);

const AppOrnamentLayout kBannerCanopyLayout = AppOrnamentLayout(
  id: 'banner-canopy',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.ring,
      alignment: Alignment.topCenter,
      width: 124,
      height: 124,
      tone: AppOrnamentTone.medium,
      offset: Offset(-18, -52),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.centerLeft,
      width: 54,
      height: 54,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-8, -6),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.centerRight,
      width: 120,
      height: 68,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(62, 18),
      rotation: -0.34,
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomLeft,
      width: 16,
      height: 16,
      tone: AppOrnamentTone.spark,
      offset: Offset(18, -10),
    ),
  ],
);

const AppOrnamentLayout kSectionOrbitLayout = AppOrnamentLayout(
  id: 'section-orbit',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topRight,
      width: 148,
      height: 148,
      tone: AppOrnamentTone.strong,
      offset: Offset(22, -44),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topCenter,
      width: 22,
      height: 22,
      tone: AppOrnamentTone.spark,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(42, 24),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomLeft,
      width: 164,
      height: 164,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-30, 70),
    ),
  ],
);

const AppOrnamentLayout kSectionCometLayout = AppOrnamentLayout(
  id: 'section-comet',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.topLeft,
      width: 168,
      height: 94,
      tone: AppOrnamentTone.strong,
      offset: Offset(-42, -30),
      rotation: -0.36,
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.centerRight,
      width: 18,
      height: 18,
      tone: AppOrnamentTone.spark,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(2, -14),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.bottomRight,
      width: 176,
      height: 100,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(38, 74),
      rotation: 0.42,
    ),
  ],
);

const AppOrnamentLayout kSectionPetalLayout = AppOrnamentLayout(
  id: 'section-petal',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topCenter,
      width: 114,
      height: 114,
      tone: AppOrnamentTone.strong,
      offset: Offset(-16, -40),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.centerLeft,
      width: 60,
      height: 60,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-10, -6),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.center,
      width: 16,
      height: 16,
      tone: AppOrnamentTone.spark,
      offset: Offset(44, -10),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomRight,
      width: 150,
      height: 150,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(28, 62),
    ),
  ],
);

const AppOrnamentLayout kSectionHaloLayout = AppOrnamentLayout(
  id: 'section-halo',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.ring,
      alignment: Alignment.topLeft,
      width: 132,
      height: 132,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-16, -44),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topRight,
      width: 34,
      height: 34,
      tone: AppOrnamentTone.strong,
      offset: Offset(2, 16),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.center,
      width: 14,
      height: 14,
      tone: AppOrnamentTone.spark,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(22, -10),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomLeft,
      width: 170,
      height: 170,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-28, 86),
    ),
  ],
);

const AppOrnamentLayout kSectionDriftLayout = AppOrnamentLayout(
  id: 'section-drift',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.centerLeft,
      width: 182,
      height: 96,
      tone: AppOrnamentTone.strong,
      offset: Offset(-82, -8),
      rotation: 0.26,
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topRight,
      width: 20,
      height: 20,
      tone: AppOrnamentTone.spark,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-4, 10),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomCenter,
      width: 108,
      height: 108,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(58, 56),
    ),
  ],
);

const AppOrnamentLayout kSectionCanopyLayout = AppOrnamentLayout(
  id: 'section-canopy',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.topCenter,
      width: 150,
      height: 80,
      tone: AppOrnamentTone.strong,
      offset: Offset(-18, -38),
      rotation: -0.14,
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topLeft,
      width: 52,
      height: 52,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-10, 12),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.centerRight,
      width: 16,
      height: 16,
      tone: AppOrnamentTone.spark,
      offset: Offset(-6, -4),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomLeft,
      width: 144,
      height: 144,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-16, 60),
    ),
  ],
);

const List<AppOrnamentLayout> kBannerSessionLayouts = [
  kBannerOrbitLayout,
  kBannerCometLayout,
  kBannerPetalLayout,
  kBannerHaloLayout,
  kBannerDriftLayout,
  kBannerCanopyLayout,
];

const List<AppOrnamentLayout> kSectionSessionLayouts = [
  kSectionOrbitLayout,
  kSectionCometLayout,
  kSectionPetalLayout,
  kSectionHaloLayout,
  kSectionDriftLayout,
  kSectionCanopyLayout,
];

const Map<AppOrnamentStyle, AppOrnamentLayout> kBannerFallbackLayouts = {
  AppOrnamentStyle.orbit: kBannerOrbitLayout,
  AppOrnamentStyle.comet: kBannerCometLayout,
  AppOrnamentStyle.petal: kBannerPetalLayout,
  AppOrnamentStyle.halo: kBannerHaloLayout,
};

const Map<AppOrnamentStyle, AppOrnamentLayout> kSectionFallbackLayouts = {
  AppOrnamentStyle.orbit: kSectionOrbitLayout,
  AppOrnamentStyle.comet: kSectionCometLayout,
  AppOrnamentStyle.petal: kSectionPetalLayout,
  AppOrnamentStyle.halo: kSectionHaloLayout,
};
