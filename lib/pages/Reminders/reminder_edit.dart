import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Reminders/controllers/reminder_edit_controller.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/viewmodels/reminder.dart';

/// 提醒编辑页。
///
/// 同时承载“新增提醒”和“编辑提醒”两种场景，是否编辑由 `initial` 是否为空决定。
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
/// 这里把“表单显示值”和“接口提交所需身份字段”一起维护，避免只靠药品名称提交导致
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
  ///
  /// 当选中了药品后，优先展示本地化标签（药品编码/批准文号），
  /// 便于用户确认当前提醒绑定的是哪条药品记录。
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
              _buildHeroCard(),
              const SizedBox(height: 10),
              _buildSectionCard(
                title: l10n?.reminderEditSectionDrugTime ?? '药品与时间',
                accentColor: const Color(0xFF10B981),
                secondaryColor: const Color(0xFF06B6D4),
                ornamentKey: 'reminders.edit.drug-time',
                child: Column(
                  children: <Widget>[
                    _tile(
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
                      _buildSelectedMedicineChips(),
                    ],
                    const SizedBox(height: 8),
                    _tile(
                      icon: Icons.access_time_rounded,
                      color: const Color(0xFF10B981),
                      title:
                          l10n?.reminderEditTimeTitle(_time) ?? '提醒时间: $_time',
                      subtitle:
                          l10n?.reminderEditTimeSubtitle ?? '每天在该时间通过系统通知提醒',
                      onTap: _pickTime,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildSectionCard(
                title: l10n?.reminderEditSectionEffectiveDate ?? '生效日期',
                accentColor: const Color(0xFF14B8A6),
                secondaryColor: const Color(0xFF0EA5E9),
                ornamentKey: 'reminders.edit.date-range',
                child: Column(
                  children: <Widget>[
                    _tile(
                      icon: Icons.event_available_rounded,
                      color: const Color(0xFF14B8A6),
                      title:
                          l10n?.reminderEditStartDateTitle(
                            _startDate.isEmpty
                                ? l10n.reminderDateUnlimited
                                : _startDate,
                          ) ??
                          (_startDate.isEmpty
                              ? '开始日期: 不限制'
                              : '开始日期: $_startDate'),
                      subtitle:
                          l10n?.reminderEditStartDateSubtitle ?? '留空表示不限制开始日期',
                      badgeText: _startDate.isEmpty
                          ? (l10n?.reminderEditDateBadgeUnset ?? '未设置')
                          : (l10n?.reminderEditDateBadgeSet ?? '已设置'),
                      onTap: _pickStartDate,
                    ),
                    const SizedBox(height: 8),
                    _tile(
                      icon: Icons.event_busy_rounded,
                      color: const Color(0xFF0EA5E9),
                      title:
                          l10n?.reminderEditEndDateTitle(
                            _endDate.isEmpty
                                ? l10n.reminderDateUnlimited
                                : _endDate,
                          ) ??
                          (_endDate.isEmpty ? '结束日期: 不限制' : '结束日期: $_endDate'),
                      subtitle:
                          l10n?.reminderEditEndDateSubtitle ?? '留空表示不限制结束日期',
                      badgeText: _endDate.isEmpty
                          ? (l10n?.reminderEditDateBadgeUnset ?? '未设置')
                          : (l10n?.reminderEditDateBadgeSet ?? '已设置'),
                      onTap: _pickEndDate,
                    ),
                    if (_startDate.isNotEmpty ||
                        _endDate.isNotEmpty) ...<Widget>[
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
              _buildSectionCard(
                title: l10n?.reminderEditSectionContent ?? '提醒内容',
                accentColor: const Color(0xFF3B82F6),
                secondaryColor: const Color(0xFF14B8A6),
                ornamentKey: 'reminders.edit.content',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildInputField(
                      controller: _dosageController,
                      labelText: _doseLabel(l10n),
                      hintText: _doseHint(l10n),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _subtitleController,
                      labelText: _extraContentLabel(l10n),
                      hintText: _extraContentHint(l10n),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildSectionCard(
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
                    Switch(value: _enabled, onChanged: _controller.setEnabled),
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
              _buildSectionCard(
                title: l10n?.safetyDisclaimerTitle ?? '提示',
                accentColor: const Color(0xFFF59E0B),
                secondaryColor: const Color(0xFF38BDF8),
                ornamentKey: 'reminders.edit.tip',
                child: Text(
                  l10n?.reminderEditTip ?? '提示：提醒信息仅用于辅助管理，不能替代医生处方。如有不适请及时就医。',
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

  Widget _buildSelectedMedicineChips() {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _selectedMedicines
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
              onDeleted: () => _controller.removeSelectedMedicineAt(index),
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

  Widget _buildHeroCard() {
    final l10n = _l10n;
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
                  _isEdit
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
                      text: _time,
                      color: const Color(0xFF10B981),
                      surfaceLightAlpha: 0.09,
                    ),
                    if (_normalizedDosage.isNotEmpty)
                      TintedStatusChip(
                        icon: Icons.scale_rounded,
                        text: _normalizedDosage,
                        color: const Color(0xFF0EA5E9),
                        surfaceLightAlpha: 0.09,
                      ),
                    TintedStatusChip(
                      icon: _enabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_rounded,
                      text: _enabled
                          ? (l10n?.reminderEditStatusEnabled ?? '启用')
                          : (l10n?.reminderEditStatusDisabled ?? '停用'),
                      color: _enabled
                          ? const Color(0xFF0EA5E9)
                          : const Color(0xFF64748B),
                      surfaceLightAlpha: 0.09,
                    ),
                    TintedStatusChip(
                      icon: _hasLinkedIdentity
                          ? Icons.verified_rounded
                          : Icons.edit_note_rounded,
                      text: _hasLinkedIdentity
                          ? (l10n?.reminderEditStatusBoundMedicine ?? '已绑定药品')
                          : (l10n?.reminderEditStatusManualInput ?? '手动输入'),
                      color: _hasLinkedIdentity
                          ? const Color(0xFF14B8A6)
                          : const Color(0xFFF59E0B),
                      surfaceLightAlpha: 0.09,
                    ),
                    TintedStatusChip(
                      icon: Icons.date_range_rounded,
                      text: _dateRangeChipText,
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

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    required Color accentColor,
    required Color secondaryColor,
    required String ornamentKey,
  }) {
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
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

  /// 构建可点击的选择 tile（药品 / 时间）。
  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    String? badgeText,
    IconData? trailingIcon,
    required VoidCallback onTap,
  }) {
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
                  if (badgeText != null && badgeText.trim().isNotEmpty) ...[
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
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10.8,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            if (trailingIcon != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(trailingIcon, color: color, size: 19),
              ),
          ],
        ),
      ),
    );
  }

  /// 打开药品选择器并把结果回填到表单。
  Future<void> _pickMedicine() async {
    await _controller.pickMedicine(
      context,
      pickerTitle: _l10n?.reminderEditPickerTitle ?? '选择提醒药品',
      duplicateToast: _l10n?.searchAlreadyAddedToast ?? '该药品已选择',
    );
  }

  /// 打开时间选择器并更新提醒时间。
  Future<void> _pickTime() async {
    await _controller.pickTime(context);
  }

  Future<void> _pickStartDate() async {
    await _controller.pickStartDate(context);
  }

  Future<void> _pickEndDate() async {
    await _controller.pickEndDate(context);
  }

  /// 保存提醒计划。
  ///
  /// 会先做前端校验，再调用 `ReminderApi.upsert`，成功后把结果返回上一页。
  Future<void> _save() async {
    try {
      final plan = await _controller.save(
        context,
        needLoginToast: _l10n?.reminderEditNeedLogin ?? '请先登录',
        nameRequiredToast: _l10n?.reminderEditNameRequired ?? '请至少选择一种药品',
        invalidDateRangeToast:
            _l10n?.reminderEditDateRangeInvalidToast ?? '开始日期不能晚于结束日期',
      );
      if (!mounted || plan == null) {
        return;
      }
      Navigator.pop(context, plan);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.instance.showError(context, e);
    }
  }

  String _doseLabel(AppLocalizations? l10n) {
    return _controller.doseLabel(l10n);
  }

  String _doseHint(AppLocalizations? l10n) {
    return _controller.doseHint(l10n);
  }

  String _extraContentLabel(AppLocalizations? l10n) {
    return _controller.extraContentLabel(l10n);
  }

  String _extraContentHint(AppLocalizations? l10n) {
    return _controller.extraContentHint(l10n);
  }
}
