import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/features/drug/presentation/drug.dart';
import 'package:luminous/features/home/presentation/home.dart';
import 'package:luminous/features/mine/presentation/mine.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:luminous/shared/models/home.dart';
import 'package:luminous/features/mine/presentation/models/mine.dart';

void main() {
  Future<void> pumpAtSize(
    WidgetTester tester, {
    required Size size,
    required Widget child,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(width: size.width, height: size.height, child: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const homeItems = <HomeFeatureItemData>[
    HomeFeatureItemData(
      id: 'drugScan',
      title: '药物识别',
      subtitle: '拍照识别药品',
      icon: Icons.camera_alt_outlined,
      color: Color(0xFF0EA5E9),
    ),
    HomeFeatureItemData(
      id: 'manualSearch',
      title: '手动搜索',
      subtitle: '关键词查询',
      icon: Icons.search_outlined,
      color: Color(0xFF06B6D4),
    ),
    HomeFeatureItemData(
      id: 'reminder',
      title: '用药提醒',
      subtitle: '按时通知',
      icon: Icons.alarm_outlined,
      color: Color(0xFF10B981),
    ),
    HomeFeatureItemData(
      id: 'checkIn',
      title: '用药打卡',
      subtitle: '记录服药情况',
      icon: Icons.fact_check_outlined,
      color: Color(0xFFF59E0B),
    ),
    HomeFeatureItemData(
      id: 'drugInfo',
      title: '药物信息',
      subtitle: '成分与禁忌',
      icon: Icons.medication_outlined,
      color: Color(0xFF6366F1),
    ),
    HomeFeatureItemData(
      id: 'safety',
      title: '安全辅助',
      subtitle: '风险提示',
      icon: Icons.health_and_safety_outlined,
      color: Color(0xFFEC4899),
    ),
  ];

  const drugEntries = <DrugQuickEntry>[
    DrugQuickEntry(
      entryKey: 'search',
      title: '手动搜索',
      subtitle: '名称/批准文号',
      icon: Icons.search_rounded,
      color: Color(0xFF0EA5E9),
      routeName: '/search',
    ),
    DrugQuickEntry(
      entryKey: 'scan',
      title: '药物识别',
      subtitle: '拍照识别',
      icon: Icons.camera_alt_outlined,
      color: Color(0xFF10B981),
      routeName: '',
    ),
    DrugQuickEntry(
      entryKey: 'ai',
      title: 'AI 解读',
      subtitle: '用法禁忌',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF6366F1),
      routeName: '',
    ),
  ];

  const mineActions = <MineQuickActionData>[
    MineQuickActionData(
      icon: Icons.alarm_rounded,
      title: '今日提醒',
      subtitle: '查看计划',
      color: Color(0xFF10B981),
      id: 'reminders',
    ),
    MineQuickActionData(
      icon: Icons.search_rounded,
      title: '手动搜索',
      subtitle: '药品信息',
      color: Color(0xFF0EA5E9),
      id: 'search',
    ),
    MineQuickActionData(
      icon: Icons.settings_rounded,
      title: '设置',
      subtitle: '偏好选项',
      color: Color(0xFF6366F1),
      id: 'settings',
    ),
  ];

  testWidgets(
    'responsive quick entry sections avoid overflow on narrow screens',
    (tester) async {
      const sizes = <Size>[Size(360, 800), Size(393, 873)];

      for (final size in sizes) {
        await pumpAtSize(
          tester,
          size: size,
          child: HomeFeatureSection(items: homeItems, onTap: (_) {}),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'home section overflowed at $size',
        );

        await pumpAtSize(
          tester,
          size: size,
          child: CustomScrollView(
            slivers: [
              DrugQuickEntrySectionSliver(
                entries: drugEntries,
                onTapEntry: (_) {},
              ),
            ],
          ),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'drug section overflowed at $size',
        );

        await pumpAtSize(
          tester,
          size: size,
          child: MineQuickActionsSection(items: mineActions, onTap: (_) {}),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'mine section overflowed at $size',
        );
      }
    },
  );

  testWidgets('mine profile card keeps action button visible with long email', (
    tester,
  ) async {
    const user = UserSafe(
      id: 'user-1',
      username: 'luo*****0',
      email:
          'luo2508015296_super_long_alias_for_mobile_layout_test@outlook.com',
      phone: '',
      name: '',
      type: 0,
    );

    await pumpAtSize(
      tester,
      size: const Size(360, 800),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MineProfileCard(
          palette: SoftBannerPalettes.mine,
          user: user,
          onTapProfile: () {},
          onTapAction: () {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(FilledButton, '设置'), findsOneWidget);
  });
}
