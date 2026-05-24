part of 'app_ornaments.dart';

const AppOrnamentLayout kBannerRibbonLayout = AppOrnamentLayout(
  id: 'banner-ribbon',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.topLeft,
      width: 150,
      height: 82,
      tone: AppOrnamentTone.strong,
      offset: Offset(-44, -28),
      rotation: 0.18,
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.ring,
      alignment: Alignment.centerRight,
      width: 94,
      height: 94,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(34, -4),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.bottomRight,
      width: 102,
      height: 102,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(38, 46),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topCenter,
      width: 18,
      height: 18,
      tone: AppOrnamentTone.spark,
      offset: Offset(-6, 10),
    ),
  ],
);

const AppOrnamentLayout kBannerConstellationLayout = AppOrnamentLayout(
  id: 'banner-constellation',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topLeft,
      width: 78,
      height: 78,
      tone: AppOrnamentTone.medium,
      offset: Offset(-18, -20),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topCenter,
      width: 24,
      height: 24,
      tone: AppOrnamentTone.spark,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(20, 2),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.center,
      width: 16,
      height: 16,
      tone: AppOrnamentTone.spark,
      offset: Offset(-12, -12),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.centerRight,
      width: 42,
      height: 42,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(26, -18),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.bottomLeft,
      width: 142,
      height: 80,
      tone: AppOrnamentTone.light,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-48, 52),
      rotation: -0.24,
    ),
  ],
);

const AppOrnamentLayout kBannerHarborLayout = AppOrnamentLayout(
  id: 'banner-harbor',
  nodes: [
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.centerRight,
      width: 112,
      height: 112,
      tone: AppOrnamentTone.strong,
      offset: Offset(26, 4),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.pill,
      alignment: Alignment.bottomLeft,
      width: 118,
      height: 72,
      tone: AppOrnamentTone.medium,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(-28, 42),
      rotation: 0.26,
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.ring,
      alignment: Alignment.topLeft,
      width: 82,
      height: 82,
      tone: AppOrnamentTone.medium,
      offset: Offset(-10, -18),
    ),
    AppOrnamentNodeSpec(
      shape: AppOrnamentNodeShape.orb,
      alignment: Alignment.topCenter,
      width: 14,
      height: 14,
      tone: AppOrnamentTone.spark,
      colorRole: AppOrnamentColorRole.secondary,
      offset: Offset(48, 12),
    ),
  ],
);
