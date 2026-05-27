import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/models/medicine.dart';
import 'package:luminous/features/medicine_picker/presentation/medicine_picker.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/utils/toast_utils.dart';

import '../providers/reminder_edit_provider.dart';
import '../widgets/reminder_edit_widgets.dart';

class ReminderEditPage extends ConsumerStatefulWidget {
  const ReminderEditPage({super.key, this.initial});

  final ReminderPlan? initial;

  @override
  ConsumerState<ReminderEditPage> createState() => _ReminderEditPageState();
}

class _ReminderEditPageState extends ConsumerState<ReminderEditPage> {
  late final TextEditingController _subtitleController;
  late final TextEditingController _dosageController;
  bool _initialized = false;

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _subtitleController = TextEditingController(text: initial?.subtitle ?? '');
    _dosageController = TextEditingController(text: initial?.dosage ?? '');

    Future.microtask(() {
      if (mounted) {
        _initialize();
      }
    });
  }

  void _initialize() {
    if (_initialized) return;
    _initialized = true;
    ref.read(reminderEditProvider.notifier).initialize(
      initial: widget.initial,
    );
  }

  @override
  void dispose() {
    _subtitleController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reminderEditProvider);
    final l10n = _l10n;
    final scheme = Theme.of(context).colorScheme;

    return AppCanvasPageScaffold(
      appBar: AppBar(
        title: Text(
          state.isEdit
              ? (l10n?.reminderEditTitle ?? '编辑提醒')
              : (l10n?.reminderCreateTitle ?? '新增提醒'),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
      ),
      appBarSpacing: 30,
      safeAreaBottom: true,
      accentColor: const Color(0xFF10B981),
      secondaryAccentColor: const Color(0xFF0EA5E9),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
        children: <Widget>[
          ReminderEditHeroCard(
            isEdit: state.isEdit,
            time: state.time,
            dosage: _dosageController.text.trim(),
            hasLinkedIdentity: state.hasLinkedIdentity,
            dateRangeChipText: _dateRangeChipText(l10n, state),
            enabled: state.enabled,
          ),
          const SizedBox(height: 10),
          ReminderEditSectionCard(
            title: l10n?.reminderEditSectionDrugTime ?? '药品与时间',
            accentColor: const Color(0xFF10B981),
            secondaryColor: const Color(0xFF06B6D4),
            ornamentKey: 'reminders.edit.drug-time',
            child: Column(
              children: <Widget>[
                ReminderEditTile(
                  icon: Icons.medication_outlined,
                  color: const Color(0xFF0EA5E9),
                  title: state.selectedMedicines.isEmpty
                      ? (l10n?.reminderEditSelectMedicine ?? '选择药品')
                      : state.normalizedProductName,
                  subtitle: _buildSelectedIdentitySubtitle(l10n, state),
                  badgeText: state.selectedMedicines.isEmpty
                      ? (l10n?.reminderEditStatusManualInput ?? '待选择')
                      : (state.selectedMedicines.length == 1
                            ? (l10n?.reminderEditStatusBoundMedicine ??
                                  '已绑定药品')
                            : '已绑定 ${state.selectedMedicines.length} 种'),
                  trailingIcon: Icons.add_circle_outline_rounded,
                  onTap: _pickMedicine,
                ),
                if (state.selectedMedicines.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  ReminderMedicineChips(
                    medicines: state.selectedMedicines,
                    onDeleted: (index) =>
                        ref.read(reminderEditProvider.notifier)
                            .removeSelectedMedicineAt(index),
                  ),
                ],
                const SizedBox(height: 8),
                ReminderEditTile(
                  icon: Icons.access_time_rounded,
                  color: const Color(0xFF10B981),
                  title: l10n?.reminderEditTimeTitle(state.time) ??
                      '提醒时间: ${state.time}',
                  subtitle: l10n?.reminderEditTimeSubtitle ??
                      '每天在该时间通过系统通知提醒',
                  onTap: _pickTime,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ReminderEditSectionCard(
            title: l10n?.reminderEditSectionEffectiveDate ?? '生效日期',
            accentColor: const Color(0xFF14B8A6),
            secondaryColor: const Color(0xFF0EA5E9),
            ornamentKey: 'reminders.edit.date-range',
            child: Column(
              children: <Widget>[
                ReminderEditTile(
                  icon: Icons.event_available_rounded,
                  color: const Color(0xFF14B8A6),
                  title: l10n?.reminderEditStartDateTitle(
                        state.startDate.isEmpty
                            ? l10n.reminderDateUnlimited
                            : state.startDate,
                      ) ??
                      (state.startDate.isEmpty
                          ? '开始日期: 不限制'
                          : '开始日期: ${state.startDate}'),
                  subtitle: l10n?.reminderEditStartDateSubtitle ??
                      '留空表示不限制开始日期',
                  badgeText: state.startDate.isEmpty
                      ? (l10n?.reminderEditDateBadgeUnset ?? '未设置')
                      : (l10n?.reminderEditDateBadgeSet ?? '已设置'),
                  onTap: _pickStartDate,
                ),
                const SizedBox(height: 8),
                ReminderEditTile(
                  icon: Icons.event_busy_rounded,
                  color: const Color(0xFF0EA5E9),
                  title: l10n?.reminderEditEndDateTitle(
                        state.endDate.isEmpty
                            ? l10n.reminderDateUnlimited
                            : state.endDate,
                      ) ??
                      (state.endDate.isEmpty
                          ? '结束日期: 不限制'
                          : '结束日期: ${state.endDate}'),
                  subtitle: l10n?.reminderEditEndDateSubtitle ??
                      '留空表示不限制结束日期',
                  badgeText: state.endDate.isEmpty
                      ? (l10n?.reminderEditDateBadgeUnset ?? '未设置')
                      : (l10n?.reminderEditDateBadgeSet ?? '已设置'),
                  onTap: _pickEndDate,
                ),
                if (state.startDate.isNotEmpty ||
                    state.endDate.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () =>
                          ref.read(reminderEditProvider.notifier)
                              .clearDateRange(),
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      label: Text(
                        l10n?.reminderEditClearDateLimit ?? '清空日期限制',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          ReminderEditSectionCard(
            title: l10n?.reminderEditSectionContent ?? '提醒内容',
            accentColor: const Color(0xFF3B82F6),
            secondaryColor: const Color(0xFF14B8A6),
            ornamentKey: 'reminders.edit.content',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ReminderEditInputField(
                  controller: _dosageController,
                  labelText: _doseLabel(l10n),
                  hintText: _doseHint(l10n),
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                ReminderEditInputField(
                  controller: _subtitleController,
                  labelText: _extraContentLabel(l10n),
                  hintText: _extraContentHint(l10n),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ReminderEditSectionCard(
            title: l10n?.reminderEditSectionSwitch ?? '开关',
            accentColor: const Color(0xFFF59E0B),
            secondaryColor: const Color(0xFF10B981),
            ornamentKey: 'reminders.edit.switch',
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n?.reminderEditEnableSwitch ?? '启用提醒',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Switch(
                  value: state.enabled,
                  onChanged: (v) =>
                      ref.read(reminderEditProvider.notifier).setEnabled(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.canSave ? _save : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: state.saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n?.reminderEditSave ?? '保存'),
            ),
          ),
          const SizedBox(height: 8),
          ReminderEditSectionCard(
            title: l10n?.safetyDisclaimerTitle ?? '提示',
            accentColor: const Color(0xFFF59E0B),
            secondaryColor: const Color(0xFF38BDF8),
            ornamentKey: 'reminders.edit.disclaimer',
            child: Text(
              '提醒功能仅作为辅助，具体用药请遵从医嘱。',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 业务方法 ──

  String _dateRangeChipText(AppLocalizations? l10n, ReminderEditState s) {
    if (s.startDate.isEmpty && s.endDate.isEmpty) {
      return l10n?.reminderDateRangeAllTime ?? '全时段';
    }
    if (s.startDate.isNotEmpty && s.endDate.isNotEmpty) {
      return l10n?.reminderDateRangeBetweenShort(
            _shortDate(s.startDate),
            _shortDate(s.endDate),
          ) ??
          '${_shortDate(s.startDate)}~${_shortDate(s.endDate)}';
    }
    if (s.startDate.isNotEmpty) {
      return l10n?.reminderDateRangeFromShort(_shortDate(s.startDate)) ??
          '${_shortDate(s.startDate)}起';
    }
    return l10n?.reminderDateRangeUntilShort(_shortDate(s.endDate)) ??
        '至${_shortDate(s.endDate)}';
  }

  String _shortDate(String value) {
    final text = value.trim();
    if (text.length >= 10) return text.substring(5, 10);
    return text;
  }

  String _buildSelectedIdentitySubtitle(
      AppLocalizations? l10n, ReminderEditState s) {
    if (s.selectedMedicines.isEmpty) {
      return l10n?.reminderEditSelectMedicineHint ?? '可从"我的药品/搜索库"选择';
    }
    if (s.selectedMedicines.length == 1) {
      final selected = s.selectedMedicines.first;
      final drugCode =
          selected.drugCode.trim().isEmpty ? '-' : selected.drugCode.trim();
      final approvalNo = selected.approvalNo.trim().isEmpty
          ? '-'
          : selected.approvalNo.trim();
      return l10n?.reminderEditSelectedIdentity(drugCode, approvalNo) ??
          'Drug Code: $drugCode  Approval No.: $approvalNo';
    }
    final first = s.selectedMedicines.first;
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    if (locale.startsWith('zh')) {
      return '已选择 ${s.selectedMedicines.length} 种药品，首项: ${first.productName}';
    }
    return '${s.selectedMedicines.length} medicines selected, first: ${first.productName}';
  }

  Future<void> _pickMedicine() async {
    final l10n = _l10n;
    final item = await Navigator.of(context).push<MedicineItem>(
      MaterialPageRoute<MedicineItem>(
        builder: (_) => MedicinePickerPage(
          title: l10n?.reminderEditSelectMedicine ?? '选择药品',
        ),
      ),
    );
    if (!mounted || item == null) return;
    final notifier = ref.read(reminderEditProvider.notifier);
    final identity = notifier.medicineIdentityKey(item);
    final state = ref.read(reminderEditProvider);
    if (state.selectedMedicines.any(
        (e) => notifier.medicineIdentityKey(e) == identity)) {
      ToastUtils.instance.show(
        context,
        '该药品已添加',
      );
      return;
    }
    notifier.addSelectedMedicine(item);
  }

  Future<void> _pickTime() async {
    final s = ref.read(reminderEditProvider);
    final parts = s.time.split(':');
    final h = parts.length == 2 ? int.tryParse(parts[0]) ?? 8 : 8;
    final m = parts.length == 2 ? int.tryParse(parts[1]) ?? 0 : 0;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: h, minute: m),
    );
    if (!mounted || picked == null) return;
    ref.read(reminderEditProvider.notifier).setTime(
      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
    );
  }

  Future<void> _pickStartDate() async {
    final s = ref.read(reminderEditProvider);
    final picked = await _pickDate(
      s.startDate.isEmpty ? s.endDate : s.startDate,
    );
    if (!mounted || picked == null) return;
    ref.read(reminderEditProvider.notifier).setStartDate(picked);
  }

  Future<void> _pickEndDate() async {
    final s = ref.read(reminderEditProvider);
    final picked = await _pickDate(
      s.endDate.isEmpty ? s.startDate : s.endDate,
    );
    if (!mounted || picked == null) return;
    ref.read(reminderEditProvider.notifier).setEndDate(picked);
  }

  Future<String?> _pickDate(String initialRaw) async {
    final now = DateTime.now();
    final parsed = DateTime.tryParse(initialRaw);
    final initialDate = parsed != null && parsed.isAfter(DateTime(2000, 1, 1))
        ? parsed
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(DateTime(now.year + 5))
          ? now
          : initialDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (picked == null) return null;
    return '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    final l10n = _l10n;
    final userId = ref.read(currentUserProvider)?.id ?? '';
    if (userId.trim().isEmpty) {
      ToastUtils.instance.show(
        context,
        l10n?.reminderEditNeedLogin ?? '请先登录',
      );
      Navigator.pushNamed(context, '/login');
      return;
    }

    final state = ref.read(reminderEditProvider);
    if (state.selectedMedicines.isEmpty) {
      ToastUtils.instance.show(
        context,
        l10n?.reminderEditNameRequired ?? '药品名称不能为空',
      );
      return;
    }

    if (state.startDate.isNotEmpty &&
        state.endDate.isNotEmpty &&
        state.startDate.compareTo(state.endDate) > 0) {
      ToastUtils.instance.show(
        context,
        l10n?.reminderEditDateRangeInvalidToast ?? '开始日期不能晚于结束日期',
      );
      return;
    }

    final plan = await ref.read(reminderEditProvider.notifier).save(
      scopedUserId: userId,
    );
    if (!mounted || plan == null) return;
    Navigator.of(context).pop<ReminderPlan>(plan);
  }

  String _doseLabel(AppLocalizations? l10n) {
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh') ? '服用剂量(可选)' : 'Dose (optional)';
  }

  String _doseHint(AppLocalizations? l10n) {
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh') ? '例如 1 粒 / 5 ml' : 'e.g. 1 tablet / 5 ml';
  }

  String _extraContentLabel(AppLocalizations? l10n) {
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh') ? '额外提醒内容(可选)' : 'Extra reminder content (optional)';
  }

  String _extraContentHint(AppLocalizations? l10n) {
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh')
        ? '例如 饭后服用，注意多喝水'
        : 'e.g. Take after meals and drink more water';
  }
}
