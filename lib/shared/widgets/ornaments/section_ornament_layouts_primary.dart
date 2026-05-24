part of 'app_ornaments.dart';

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
