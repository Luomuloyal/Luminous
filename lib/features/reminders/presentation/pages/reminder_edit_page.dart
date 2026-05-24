import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/viewmodels/reminder.dart';

import '../controllers/reminder_edit_controller.dart';
import '../widgets/reminder_edit_widgets.dart';

/// 提醒编辑页。
///
/// 同时承载"新增提醒"和"编辑提醒"两种场景，是否编辑由 `initial` 是否为空决定。
class ReminderEditPage extends StatefulWidget {
  /// 创建提醒编辑页。
  const ReminderEditPage({super.key, this.initial, this.controller});

  /// 编辑时传入的初始提醒计划。
  ///
  /// - null：新增提醒
  /// - 非 null：编辑已有提醒
  final ReminderPlan? initial;
  final ReminderEditController? controller;

  /// 创建提醒编辑页对应的状态对象。
  @override
  State<ReminderEditPage> createState() => _ReminderEditPageState();
}

/// 提醒编辑页状态对象。
///
/// 这里把"表单显示值"和"接口提交所需身份字段"一起维护，避免只靠药品名称提交导致
/// 后续无法和详情、提醒、打卡等功能对齐。
class _ReminderEditPageState extends State<ReminderEditPage> {
  late final ReminderEditController _controller =
      widget.controller ?? ReminderEditController(initial: widget.initial);

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  bool get _isEdit => _controller.isEdit;
  TextEditingController get _subtitleController =>
      _controller.subtitleController;
  TextEditingController get _dosageController => _controller.dosageController;
  List<MedicineItem> get _selectedMedicines => _controller.selectedMedicines;
  String get _time => _controller.time;
  String get _startDate => _controller.startDate;
  String get _endDate => _controller.endDate;
  bool get _enabled => _controller.enabled;
  bool get _saving => _controller.saving;
  String get _normalizedProductName => _controller.normalizedProductName;
  String get _normalizedDosage => _controller.normalizedDosage;
  bool get _hasLinkedIdentity => _controller.hasLinkedIdentity;
  bool get _canSave => _controller.canSave;
  String get _dateRangeChipText => _controller.dateRangeChipText(_l10n);

  /// 生成已选药品身份信息的副标题文本。
  String _buildSelectedIdentitySubtitle(AppLocalizations? l10n) {
    return _controller.buildSelectedIdentitySubtitle(l10n);
  }

  /// 构建提醒编辑页 UI。
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReminderEditController>(
      init: _controller,
      global: false,
      builder: (_) {
        final l10n = _l10n;
        final scheme = Theme.of(context).colorScheme;
        return AppCanvasPageScaffold(
          appBar: AppBar(
            title: Text(
              _isEdit
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
                isEdit: _isEdit,
                time: _time,
                dosage: _normalizedDosage,
                hasLinkedIdentity: _hasLinkedIdentity,
                dateRangeChipText: _dateRangeChipText,
                enabled: _enabled,
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
                      title: _selectedMedicines.isEmpty
                          ? (l10n?.reminderEditSelectMedicine ?? '选择药品')
                          : _normalizedProductName,
                      subtitle: _buildSelectedIdentitySubtitle(l10n),
                      badgeText: _selectedMedicines.isEmpty
                          ? (l10n?.reminderEditStatusManualInput ?? '待选择')
                          : (_selectedMedicines.length == 1
                                ? (l10n?.reminderEditStatusBoundMedicine ??
                                      '已绑定药品')
                                : '已绑定 ${_selectedMedicines.length} 种'),
                      trailingIcon: Icons.add_circle_outline_rounded,
                      onTap: _pickMedicine,
                    ),
                    if (_selectedMedicines.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 8),
                      ReminderMedicineChips(
                        medicines: _selectedMedicines,
                        onDeleted: _controller.removeSelectedMedicineAt,
                      ),
                    ],
                    const SizedBox(height: 8),
                    ReminderEditTile(
                      icon: Icons.access_time_rounded,
                      color: const Color(0xFF10B981),
                      title: l10n?.reminderEditTimeTitle(_time) ??
                          '提醒时间: $_time',
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
                            _startDate.isEmpty
                                ? l10n.reminderDateUnlimited
                                : _startDate,
                          ) ??
                          (_startDate.isEmpty
                              ? '开始日期: 不限制'
                              : '开始日期: $_startDate'),
                      subtitle: l10n?.reminderEditStartDateSubtitle ??
                          '留空表示不限制开始日期',
                      badgeText: _startDate.isEmpty
                          ? (l10n?.reminderEditDateBadgeUnset ?? '未设置')
                          : (l10n?.reminderEditDateBadgeSet ?? '已设置'),
                      onTap: _pickStartDate,
                    ),
                    const SizedBox(height: 8),
                    ReminderEditTile(
                      icon: Icons.event_busy_rounded,
                      color: const Color(0xFF0EA5E9),
                      title: l10n?.reminderEditEndDateTitle(
                            _endDate.isEmpty
                                ? l10n.reminderDateUnlimited
                                : _endDate,
                          ) ??
                          (_endDate.isEmpty
                              ? '结束日期: 不限制'
                              : '结束日期: $_endDate'),
                      subtitle: l10n?.reminderEditEndDateSubtitle ??
                          '留空表示不限制结束日期',
                      badgeText: _endDate.isEmpty
                          ? (l10n?.reminderEditDateBadgeUnset ?? '未设置')
                          : (l10n?.reminderEditDateBadgeSet ?? '已设置'),
                      onTap: _pickEndDate,
                    ),
                    if (_startDate.isNotEmpty || _endDate.isNotEmpty) ...<
                      Widget>[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _controller.clearDateRange,
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
                      labelText: _controller.doseLabel(l10n),
                      hintText: _controller.doseHint(l10n),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    ReminderEditInputField(
                      controller: _subtitleController,
                      labelText: _controller.extraContentLabel(l10n),
                      hintText: _controller.extraContentHint(l10n),
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
                      value: _enabled,
                      onChanged: _controller.setEnabled,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _canSave ? _save : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
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
                ornamentKey: 'reminders.edit.tip',
                child: Text(
                  l10n?.reminderEditTip ??
                      '提示：提醒信息仅用于辅助管理，不能替代医生处方。如有不适请及时就医。',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMedicine() async {
    final l10n = _l10n;
    await _controller.pickMedicine(
      context,
      pickerTitle: l10n?.drugPickerTitle ?? '选择药品',
      duplicateToast: l10n?.searchAlreadyAddedToast ?? '该药品已选择，请勿重复添加',
    );
  }

  Future<void> _pickTime() async {
    await _controller.pickTime(context);
  }

  Future<void> _pickStartDate() async {
    await _controller.pickStartDate(context);
  }

  Future<void> _pickEndDate() async {
    await _controller.pickEndDate(context);
  }

  Future<void> _save() async {
    final l10n = _l10n;
    final plan = await _controller.save(
      context,
      needLoginToast: l10n?.reminderEditNeedLogin ?? '请先登录',
      nameRequiredToast:
          l10n?.reminderEditNameRequired ?? '请至少选择一种药品',
      invalidDateRangeToast: l10n?.reminderEditDateRangeInvalidToast ??
          '开始日期不能晚于结束日期',
    );
    if (!mounted || plan == null) {
      return;
    }
    Navigator.of(context).pop(plan);
  }
}
