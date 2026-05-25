import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/shared/design_tokens/design_tokens.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/reminders/data/reminder_local_gateway.dart';
import 'package:luminous/shared/models/home.dart';

import '../controllers/checkin_controller.dart';

/// 用药打卡页。
class CheckInPage extends StatelessWidget {
  const CheckInPage({super.key, this.reminderGateway});

  final ReminderLocalGateway? reminderGateway;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckInController>(
      init: CheckInController(reminderGateway: reminderGateway),
      global: false,
      builder: (controller) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(l10n?.checkInPageTitle ?? '用药打卡'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            foregroundColor: const Color(0xFF0F172A),
            actions: [
              IconButton(
                onPressed: controller.isLoggedIn && !controller.loading
                    ? controller.load
                    : null,
                icon: controller.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: AppCanvas(
            accentColor: const Color(0xFFF59E0B),
            secondaryAccentColor: const Color(0xFFBFD8FF),
            child: !controller.isLoggedIn
                ? _buildNeedLogin(context)
                : RefreshIndicator(
                    onRefresh: controller.load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
                      children: [
                        _buildHeroCard(context, controller),
                        const SizedBox(height: 8),
                        if (controller.error != null)
                          _buildErrorBanner(controller.error!),
                        if (controller.items.isEmpty &&
                            !controller.loading &&
                            controller.error == null)
                          _buildEmpty(context),
                        ...controller.items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == controller.items.length - 1
                                  ? 0
                                  : 6,
                            ),
                            child: _CheckInCard(
                              item: item,
                              onCheckIn: () =>
                                  _toggleCheckIn(context, controller, item),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(BuildContext context, CheckInController controller) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    final subtitleText = locale.startsWith('zh')
        ? '到点打卡，帮助你连续跟踪每日用药完成情况'
        : 'Check in on time to track your daily medication completion.';
    return AppSectionCard(
      accentColor: const Color(0xFFF59E0B),
      secondaryColor: const Color(0xFF38BDF8),
      ornamentKey: 'checkin.hero',
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.checkInPageTitle ?? '用药打卡',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitleText,
            style: TextStyle(
              fontSize: 12.8,
              height: 1.45,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              TintedStatusChip(
                icon: Icons.library_books_rounded,
                text: '${controller.items.length} 条',
                color: const Color(0xFF0EA5E9),
              ),
              TintedStatusChip(
                icon: Icons.check_circle_rounded,
                text: '${controller.doneCount} 已打卡',
                color: const Color(0xFF10B981),
              ),
              TintedStatusChip(
                icon: Icons.alarm_rounded,
                text: '${controller.pendingCount} 待完成',
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNeedLogin(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final iconAccent = Color.lerp(scheme.tertiary, scheme.primary, 0.32)!;
    final iconBackground = appTintedSurface(
      context,
      iconAccent,
      lightAlpha: 0.12,
      darkAlpha: 0.24,
      baseColor: theme.cardTheme.color ?? scheme.surface,
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: AppSectionCard(
          accentColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.35)!,
          secondaryColor: Color.lerp(scheme.primary, scheme.tertiary, 0.4)!,
          ornamentKey: 'checkin.need-login',
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          radius: 18,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appTintedBorder(
                      context,
                      iconAccent,
                      lightAlpha: 0.16,
                      darkAlpha: 0.26,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.fact_check_outlined,
                  color: iconAccent,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.checkInNeedLoginTitle ?? '请先登录',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.checkInNeedLoginSubtitle ??
                    '登录后可读取当前设备上的提醒计划，并在本机记录今日打卡状态。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                  ),
                  child: Text(l10n?.checkInNeedLoginAction ?? '去登录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: AppTypography.tab,
                height: 1.45,
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: AppSectionCard(
          accentColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.35)!,
          secondaryColor: Color.lerp(scheme.primary, scheme.tertiary, 0.4)!,
          ornamentKey: 'checkin.empty',
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          radius: 18,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_available_outlined,
                size: 42,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 10),
              Text(
                l10n?.checkInEmptyTitle ?? '今日暂无提醒',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.checkInEmptySubtitle ?? '可以先到"用药提醒"里新增计划',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleCheckIn(
    BuildContext context,
    CheckInController controller,
    ReminderItem item,
  ) async {
    if (item.done) {
      await _confirmAndMarkUndone(context, controller, item);
      return;
    }
    await controller.markDone(item);
  }

  Future<void> _confirmAndMarkUndone(
    BuildContext context,
    CheckInController controller,
    ReminderItem item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n?.checkInUndoDialogTitle ?? '撤销本地打卡'),
          content: Text(
            l10n?.checkInUndoDialogContent ??
                '当前用药打卡只保存在本机，撤销后会立即修改当前设备显示。确定继续吗？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n?.checkInUndoDialogCancel ?? '取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n?.checkInUndoDialogConfirm ?? '撤销本地打卡'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }
    await controller.markUndone(item);
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({required this.item, required this.onCheckIn});

  final ReminderItem item;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final done = item.done;
    final accent = done ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    return AppSectionCard(
      accentColor: accent,
      secondaryColor: Color.lerp(accent, scheme.primary, 0.35)!,
      ornamentKey: 'checkin.card.item',
      radius: 18,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    (done ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                        .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Icon(
                Icons.access_time_rounded,
                color: done ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _buildScheduleLine(item, l10n),
                    style: TextStyle(
                      fontSize: 12.1,
                      height: 1.35,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildExtraLine(item, l10n),
                    style: TextStyle(
                      fontSize: AppTypography.cardMeta,
                      height: 1.4,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onCheckIn,
              style: FilledButton.styleFrom(
                backgroundColor: done
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                minimumSize: const Size(84, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
              ),
              child: Text(
                done
                    ? (l10n?.checkInActionDone ?? '取消打卡')
                    : (l10n?.checkInActionUndone ?? '打卡'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildScheduleLine(ReminderItem item, AppLocalizations? l10n) {
    final parts = <String>[];
    if (item.time.trim().isNotEmpty) {
      parts.add(item.time.trim());
    }
    if (item.dosage.trim().isNotEmpty) {
      final locale = (l10n?.localeName ?? 'zh').toLowerCase();
      final doseLabel = locale.startsWith('zh') ? '剂量' : 'Dose';
      parts.add('$doseLabel: ${item.dosage.trim()}');
    }
    if (parts.isEmpty) {
      return l10n?.checkInCardDefaultSubtitle ?? '请按时完成';
    }
    return parts.join(' · ');
  }

  String _buildExtraLine(ReminderItem item, AppLocalizations? l10n) {
    final extra = item.subtitle.trim();
    if (extra.isNotEmpty) {
      return extra;
    }
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh') ? '无额外提醒内容' : 'No extra reminder';
  }
}