import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 提醒列表页的辅助 UI 组件集合。
///
/// 从 `reminder_list.dart` 中提取出来的 hero 卡片、未登录引导、
/// 错误 banner 和空状态组件。

/// 顶部统计 hero 卡片。
class ReminderListHeroCard extends StatelessWidget {
  const ReminderListHeroCard({
    super.key,
    required this.itemCount,
    required this.enabledCount,
    required this.disabledCount,
  });

  final int itemCount;
  final int enabledCount;
  final int disabledCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: const Color(0xFF10B981),
      secondaryColor: const Color(0xFF38BDF8),
      ornamentKey: 'reminders.list.hero',
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.reminderListTitle ?? '用药提醒',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            l10n?.reminderEmptySubtitle ?? '点击右下角"新增提醒"开始设置',
            style: TextStyle(
              fontSize: 12.8,
              height: 1.45,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              TintedStatusChip(
                icon: Icons.library_books_rounded,
                text:
                    l10n?.reminderListCountLabel(itemCount) ?? '$itemCount 条提醒',
                color: const Color(0xFF0EA5E9),
              ),
              TintedStatusChip(
                icon: Icons.notifications_active_rounded,
                text:
                    l10n?.reminderListEnabledCountLabel(enabledCount) ??
                    '$enabledCount 启用',
                color: const Color(0xFF10B981),
              ),
              TintedStatusChip(
                icon: Icons.notifications_off_rounded,
                text:
                    l10n?.reminderListDisabledCountLabel(disabledCount) ??
                    '$disabledCount 关闭',
                color: const Color(0xFF64748B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 未登录引导卡片。
class ReminderNeedLoginCard extends StatelessWidget {
  const ReminderNeedLoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final iconAccent = Color.lerp(scheme.primary, scheme.tertiary, 0.4)!;
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
          accentColor: Color.lerp(scheme.primary, scheme.tertiary, 0.32)!,
          secondaryColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.4)!,
          ornamentKey: 'reminders.need-login',
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
                child: Icon(Icons.alarm_rounded, color: iconAccent, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.reminderNeedLoginTitle ?? '请先登录',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.reminderNeedLoginSubtitle ?? '登录后可同步提醒计划，并在到点收到系统通知。',
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
                  onPressed: () => context.push('/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(l10n?.reminderNeedLoginAction ?? '去登录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 错误提示 banner。
class ReminderErrorBanner extends StatelessWidget {
  const ReminderErrorBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: const Color(0xFFF59E0B),
      secondaryColor: Color.lerp(const Color(0xFFF59E0B), scheme.error, 0.25)!,
      ornamentKey: 'reminders.list.error',
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: scheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 空状态占位卡片。
class ReminderEmptyCard extends StatelessWidget {
  const ReminderEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: Color.lerp(scheme.primary, scheme.tertiary, 0.32)!,
      secondaryColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.4)!,
      ornamentKey: 'reminders.empty',
      padding: const EdgeInsets.symmetric(vertical: 42),
      radius: 18,
      child: Column(
        children: [
          const Icon(
            Icons.alarm_off_rounded,
            size: 42,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 10),
          Text(
            l10n?.reminderEmptyTitle ?? '暂无提醒',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.reminderEmptySubtitle ?? '点击右下角"新增提醒"开始设置',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
