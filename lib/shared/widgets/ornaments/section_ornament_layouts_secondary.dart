part of 'app_ornaments.dart';

const AppOrnamentLayout kSectionSplitLayout = AppOrnamentLayout(
  id: 'section-split',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.centerLeft,
      width: 176,
      height: 176,
      tone: AppOrnamentTone.strong,
      offset: Offset(-66, 4),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.ring,
      alignment: Alignment.topRight,
      width: 96,
      height: 96,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(18, -18),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.bottomRight,
      width: 146,
      height: 76,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(44, 42),
      rotation: -0.22,
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomCenter,
      width: 16,
      height: 16,
      tone: AppOrnamentTone.spark,
      offset: Offset(-30, -4),
    ),
  ],
);

const AppOrnamentLayout kSectionRidgeLayout = AppOrnamentLayout(
  id: 'section-ridge',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.topCenter,
      width: 170,
      height: 86,
      tone: AppOrnamentTone.strong,
      offset: Offset(20, -36),
      rotation: 0.12,
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topLeft,
      width: 46,
      height: 46,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(10, 12),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomRight,
      width: 160,
      height: 160,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(30, 64),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.ring,
      alignment: Alignment.centerLeft,
      width: 86,
      height: 86,
      tone: AppOrnamentTone.medium,
      offset: Offset(-18, 26),
    ),
  ],
);

const AppOrnamentLayout kSectionTideLayout = AppOrnamentLayout(
  id: 'section-tide',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.bottomCenter,
      width: 206,
      height: 102,
      tone: AppOrnamentTone.strong,
      offset: Offset(16, 46),
      rotation: -0.10,
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topLeft,
      width: 74,
      height: 74,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-16, -10),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.ring,
      alignment: Alignment.centerRight,
      width: 88,
      height: 88,
      tone: AppOrnamentTone.medium,
      offset: Offset(16, 6),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topRight,
      width: 16,
      height: 16,
      tone: AppOrnamentTone.spark,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-12, 18),
    ),
  ],
);

const AppOrnamentLayout kSectionClusterLayout = AppOrnamentLayout(
  id: 'section-cluster',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topLeft,
      width: 82,
      height: 82,
      tone: AppOrnamentTone.medium,
      offset: Offset(-8, -18),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topCenter,
      width: 34,
      height: 34,
      tone: AppOrnamentTone.spark,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(10, 10),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topRight,
      width: 58,
      height: 58,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(18, -4),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.ring,
      alignment: Alignment.bottomRight,
      width: 118,
      height: 118,
      tone: AppOrnamentTone.medium,
      offset: Offset(20, 36),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomLeft,
      width: 146,
      height: 146,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-26, 76),
    ),
  ],
);

const AppOrnamentLayout kSectionBeaconLayout = AppOrnamentLayout(
  id: 'section-beacon',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.centerRight,
      width: 120,
      height: 178,
      tone: AppOrnamentTone.strong,
      offset: Offset(64, -4),
      rotation: 0.24,
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topLeft,
      width: 62,
      height: 62,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-4, -8),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomLeft,
      width: 92,
      height: 92,
      tone: AppOrnamentTone.light,
      offset: Offset(-18, 28),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.center,
      width: 16,
      height: 16,
      tone: AppOrnamentTone.spark,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(24, -18),
    ),
  ],
);
