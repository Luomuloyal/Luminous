import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/viewmodels/mine.dart';

import '../controllers/mine_controller.dart';
import '../widgets/mine_profile_card.dart';
import '../widgets/mine_page_widgets.dart';

// 我的页
//
// 设计要点：
// - 页面只负责组合 UI；
// - 登录态、浏览记录预览与入口交互交给页面级 MineController；
// - 具体卡片/布局仍由 widgets 负责。
/// 我的页。
///
/// 负责承载个人中心 UI，并通过页面级 GetX controller 接管页面状态。
class MinePage extends ConsumerWidget {
  /// 创建我的页组件。
  const MinePage({super.key, this.controller});

  final MineController? controller;

  List<MineQuickActionData> _quickActions(AppLocalizations? l10n) {
    return [
      MineQuickActionData(
        icon: Icons.alarm_rounded,
        title: l10n?.mineQuickReminderTitle ?? '今日提醒',
        subtitle: l10n?.mineQuickReminderSubtitle ?? '查看计划',
        color: const Color(0xFF10B981),
        id: 'reminders',
      ),
      MineQuickActionData(
        icon: Icons.search_rounded,
        title: l10n?.mineQuickSearchTitle ?? '手动搜索',
        subtitle: l10n?.mineQuickSearchSubtitle ?? '药品信息',
        color: const Color(0xFF0EA5E9),
        id: 'search',
      ),
      MineQuickActionData(
        icon: Icons.settings_rounded,
        title: l10n?.mineQuickSettingsTitle ?? '设置',
        subtitle: l10n?.mineQuickSettingsSubtitle ?? '偏好选项',
        color: const Color(0xFF6366F1),
        id: 'settings',
      ),
    ];
  }

  String? _browseHistorySubtitle(
    AppLocalizations? l10n,
    MineController controller,
  ) {
    final latest = controller.latestBrowseEntry;
    if (latest == null) {
      return l10n?.mineMenuHistorySubtitle ?? '你最近查看过的药品';
    }
    final title = latest.displayTitle.trim();
    if (title.isEmpty) {
      return l10n?.mineMenuHistorySubtitle ?? '你最近查看过的药品';
    }
    return title;
  }

  String? _browseHistoryBadgeText(
    AppLocalizations? l10n,
    MineController controller,
  ) {
    final count = controller.browseHistoryCount;
    if (count <= 0) {
      return null;
    }
    return l10n?.mineBrowseHistoryCountLabel(count) ?? '$count 条';
  }

  /// 构建我的页 UI。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    return GetBuilder<MineController>(
      init: controller ?? MineController(),
      global: false,
      builder: (controller) {
        final l10n = AppLocalizations.of(context);
        return MinePageLayout(
          headerPalette: SoftBannerPalettes.mineOf(context),
          profileCard: MineProfileCard(
            palette: SoftBannerPalettes.mineOf(context),
            user: currentUser ?? controller.currentUser,
            onTapProfile: () => controller.onTapProfile(context),
            onTapAction: () => controller.onTapAction(context),
            loggedInActionLabel: l10n?.mineLoggedInActionLabel,
          ),
          quickActions: _quickActions(l10n),
          onTapQuickAction: (id) =>
              controller.onTapQuickAction(context, id, l10n: l10n),
          onTapBrowseHistory: () => controller.openBrowseHistory(context),
          browseHistorySubtitle: _browseHistorySubtitle(l10n, controller),
          browseHistoryBadgeText: _browseHistoryBadgeText(l10n, controller),
          onTapSecurity: () => Navigator.pushNamed(context, '/settings'),
          onTapAbout: () => controller.onTapAbout(
            context,
            legalese: l10n?.mineAboutLegalese ?? '健康助手与药品信息辅助应用',
          ),
        );
      },
    );
  }
}
