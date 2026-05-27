import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/mine/presentation/models/mine.dart';
import 'package:luminous/utils/toast_utils.dart';

import '../providers/mine_provider.dart';
import '../widgets/mine_profile_card.dart';
import '../widgets/mine_page_widgets.dart';

/// 我的页。
class MinePage extends ConsumerWidget {
  const MinePage({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final preview = ref.watch(browseHistoryPreviewProvider);
    final l10n = AppLocalizations.of(context);
    final isLoggedIn = currentUser?.hasData ?? false;

    final historySubtitle = preview.latest?.displayTitle.trim();
    final historyText = (historySubtitle == null || historySubtitle.isEmpty)
        ? (l10n?.mineMenuHistorySubtitle ?? '你最近查看过的药品')
        : historySubtitle;
    final badgeText = preview.count > 0
        ? (l10n?.mineBrowseHistoryCountLabel(preview.count) ??
              '${preview.count} 条')
        : null;

    return MinePageLayout(
      headerPalette: SoftBannerPalettes.mineOf(context),
      profileCard: MineProfileCard(
        palette: SoftBannerPalettes.mineOf(context),
        user: currentUser,
        onTapProfile: () => _onTapProfile(context, isLoggedIn),
        onTapAction: () => _onTapProfile(context, isLoggedIn),
        loggedInActionLabel: l10n?.mineLoggedInActionLabel,
      ),
      quickActions: _quickActions(l10n),
      onTapQuickAction: (id) => _onTapQuickAction(context, id, l10n: l10n),
      onTapBrowseHistory: () => _openBrowseHistory(context, ref),
      browseHistorySubtitle: historyText,
      browseHistoryBadgeText: badgeText,
      onTapSecurity: () => context.push('/settings'),
      onTapAbout: () => _onTapAbout(context, l10n),
    );
  }

  void _onTapProfile(BuildContext context, bool isLoggedIn) {
    if (!isLoggedIn) {
      context.push('/login');
      return;
    }
    context.push('/settings');
  }

  void _onTapQuickAction(
    BuildContext context,
    String id, {
    AppLocalizations? l10n,
  }) {
    if (id == 'search') {
      context.push('/search');
      return;
    }
    if (id == 'reminders') {
      context.push('/reminders');
      return;
    }
    if (id == 'settings') {
      context.push('/settings');
      return;
    }
    ToastUtils.instance.show(context, l10n?.mineDevelopingToast ?? '功能开发中');
  }

  Future<void> _openBrowseHistory(BuildContext context, WidgetRef ref) async {
    await context.push('/browse-history');
    ref.invalidate(browseHistoryProvider);
  }

  void _onTapAbout(BuildContext context, AppLocalizations? l10n) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final dL10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: const Text('关于 Luminous'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppReleaseInfo.appName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                '版本 ${AppReleaseInfo.fullVersion}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.mineAboutLegalese ?? '健康助手与药品信息辅助应用',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push('/user-agreement');
              },
              child: Text(dL10n?.legalUserAgreementTitle ?? '用户协议'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push('/privacy-policy');
              },
              child: Text(dL10n?.legalPrivacyPolicyTitle ?? '隐私政策'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }
}
