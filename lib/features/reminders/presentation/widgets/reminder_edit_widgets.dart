import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/models/medicine.dart';

/// 提醒编辑页的辅助 UI 组件。

/// 编辑页 hero 卡片。
class ReminderEditHeroCard extends StatelessWidget {
  const ReminderEditHeroCard({
    super.key,
    required this.isEdit,
    required this.time,
    required this.dosage,
    required this.hasLinkedIdentity,
    required this.dateRangeChipText,
    this.enabled = true,
  });

  final bool isEdit;
  final String time;
  final String dosage;
  final bool hasLinkedIdentity;
  final String dateRangeChipText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: const Color(0xFF10B981),
      secondaryColor: const Color(0xFF0EA5E9),
      ornamentKey: 'reminders.edit.hero',
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: appTintedSurface(
                context,
                const Color(0xFF10B981),
                lightAlpha: 0.13,
                darkAlpha: 0.22,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isEdit
                      ? (l10n?.reminderEditTitle ?? '编辑提醒')
                      : (l10n?.reminderCreateTitle ?? '新增提醒'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.reminderEditTimeSubtitle ?? '每天在该时间通过系统通知提醒',
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
                  children: <Widget>[
                    TintedStatusChip(
                      icon: Icons.schedule_rounded,
                      text: time,
                      color: const Color(0xFF10B981),
                      surfaceLightAlpha: 0.09,
                    ),
                    if (dosage.isNotEmpty)
                      TintedStatusChip(
                        icon: Icons.scale_rounded,
                        text: dosage,
                        color: const Color(0xFF0EA5E9),
                        surfaceLightAlpha: 0.09,
                      ),
                    TintedStatusChip(
                      icon: enabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_rounded,
                      text: enabled
                          ? (l10n?.reminderEditStatusEnabled ?? '启用')
                          : (l10n?.reminderEditStatusDisabled ?? '停用'),
                      color: enabled
                          ? const Color(0xFF0EA5E9)
                          : const Color(0xFF64748B),
                      surfaceLightAlpha: 0.09,
                    ),
                    TintedStatusChip(
                      icon: hasLinkedIdentity
                          ? Icons.verified_rounded
                          : Icons.edit_note_rounded,
                      text: hasLinkedIdentity
                          ? (l10n?.reminderEditStatusBoundMedicine ??
                              '已绑定药品')
                          : (l10n?.reminderEditStatusManualInput ?? '手动输入'),
                      color: hasLinkedIdentity
                          ? const Color(0xFF14B8A6)
                          : const Color(0xFFF59E0B),
                      surfaceLightAlpha: 0.09,
                    ),
                    TintedStatusChip(
                      icon: Icons.date_range_rounded,
                      text: dateRangeChipText,
                      color: const Color(0xFF0EA5E9),
                      surfaceLightAlpha: 0.09,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 编辑页统一使用的 section 卡片容器。
class ReminderEditSectionCard extends StatelessWidget {
  const ReminderEditSectionCard({
    super.key,
    required this.title,
    required this.child,
    required this.accentColor,
    required this.secondaryColor,
    required this.ornamentKey,
  });

  final String title;
  final Widget child;
  final Color accentColor;
  final Color secondaryColor;
  final String ornamentKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: accentColor,
      secondaryColor: secondaryColor,
      ornamentKey: ornamentKey,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// 编辑页输入字段。
class ReminderEditInputField extends StatelessWidget {
  const ReminderEditInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.78),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: appTintedSurface(
          context,
          const Color(0xFF0EA5E9),
          lightAlpha: 0.04,
          darkAlpha: 0.11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.4),
        ),
      ),
    );
  }
}

/// 编辑页可点击的选择 tile。
class ReminderEditTile extends StatelessWidget {
  const ReminderEditTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.trailingIcon,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? badgeText;
  final IconData? trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: appTintedSurface(
            context,
            color,
            lightAlpha: 0.05,
            darkAlpha: 0.12,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: appTintedBorder(
              context,
              color,
              lightAlpha: 0.12,
              darkAlpha: 0.22,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (badgeText != null && badgeText!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: appTintedSurface(
                          context,
                          color,
                          lightAlpha: 0.08,
                          darkAlpha: 0.16,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 6),
              Icon(trailingIcon, color: scheme.onSurfaceVariant, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

/// 已选药品 chips。
class ReminderMedicineChips extends StatelessWidget {
  const ReminderMedicineChips({
    super.key,
    required this.medicines,
    required this.onDeleted,
  });

  final List<MedicineItem> medicines;
  final ValueChanged<int> onDeleted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: medicines
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final medicine = entry.value;
            return InputChip(
              label: Text(
                medicine.productName.trim().isEmpty
                    ? '未知药品'
                    : medicine.productName.trim(),
              ),
              onDeleted: () => onDeleted(index),
              deleteIconColor: scheme.error,
              backgroundColor: appTintedSurface(
                context,
                const Color(0xFF0EA5E9),
                lightAlpha: 0.08,
                darkAlpha: 0.14,
              ),
              side: BorderSide(
                color: appTintedBorder(
                  context,
                  const Color(0xFF0EA5E9),
                  lightAlpha: 0.12,
                  darkAlpha: 0.2,
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
