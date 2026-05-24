part of 'app_ornaments.dart';

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
