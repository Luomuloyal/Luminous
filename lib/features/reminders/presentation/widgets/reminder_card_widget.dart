import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/viewmodels/reminder.dart';

/// 提醒计划列表中的单条卡片。
///
/// 负责展示时间、药品名、启用状态和删除入口，不直接访问接口。
class ReminderCard extends StatelessWidget {
  /// 创建提醒计划卡片。
  const ReminderCard({
    super.key,
    required this.item,
    required this.busy,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  /// 当前提醒计划条目。
  final ReminderPlan item;

  /// 当前条目是否正在执行变更操作。
  final bool busy;

  /// 点击卡片回调（进入编辑）。
  final VoidCallback onTap;

  /// 开关切换回调。
  final ValueChanged<bool> onToggle;

  /// 删除回调。
  final VoidCallback onDelete;

  /// 构建提醒计划卡片 UI。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final accent = item.enabled
        ? const Color(0xFF10B981)
        : const Color(0xFF64748B);
    final rangeText = _formatDateRange(
      item.startDate,
      item.endDate,
      l10n: l10n,
    );
    return AppSectionCard(
      accentColor: accent,
      secondaryColor: Color.lerp(accent, scheme.primary, 0.36)!,
      ornamentKey: 'reminders.list.item',
      radius: 18,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: busy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: appTintedSurface(
                        context,
                        accent,
                        lightAlpha: 0.12,
                        darkAlpha: 0.22,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.alarm_rounded, color: accent, size: 19),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.productName.trim().isEmpty
                          ? (l10n?.reminderListTitle ?? '用药提醒')
                          : item.productName.trim(),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 28,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Switch(
                        value: item.enabled,
                        onChanged: busy ? null : onToggle,
                      ),
                    ),
                  ),
                ],
              ),
              if (busy)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.primary,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                _buildScheduleLine(item, l10n),
                style: TextStyle(
                  fontSize: 12.2,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (rangeText.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  rangeText,
                  style: TextStyle(
                    fontSize: 11.8,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (item.dosage.trim().isNotEmpty)
                        TintedStatusChip(
                          icon: Icons.scale_rounded,
                          text: item.dosage.trim(),
                          color: const Color(0xFF0EA5E9),
                        ),
                      TintedStatusChip(
                        text: item.enabled ? '启用' : '已停用',
                        icon: item.enabled
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_rounded,
                        color: item.enabled
                            ? const Color(0xFF10B981)
                            : const Color(0xFF64748B),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: busy ? null : onDelete,
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Colors.red.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildScheduleLine(ReminderPlan item, AppLocalizations? l10n) {
    final time = item.time.trim();
    final subtitle = item.subtitle.trim();
    if (time.isEmpty && subtitle.isEmpty) {
      return '';
    }
    if (time.isNotEmpty && subtitle.isEmpty) {
      return time;
    }
    if (time.isEmpty) {
      return subtitle;
    }
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    if (locale.startsWith('zh')) {
      return '$time · $subtitle';
    }
    return '$time — $subtitle';
  }

  String _formatDateRange(
    String startDate,
    String endDate, {
    required AppLocalizations? l10n,
  }) {
    final s = startDate.trim();
    final e = endDate.trim();
    if (s.isEmpty && e.isEmpty) {
      return '';
    }
    final from = l10n?.reminderDateRangeFromShort(s) ?? '$s 起';
    final until = l10n?.reminderDateRangeUntilShort(e) ?? '至 $e';
    final between = l10n?.reminderDateRangeBetweenShort(s, e) ?? '$s ~ $e';

    if (s.isNotEmpty && e.isNotEmpty) {
      return between;
    }
    if (s.isNotEmpty) {
      return from;
    }
    return until;
  }
}
