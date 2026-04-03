import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Picker/medicine_picker.dart';
import 'package:luminous/stores/my_medicine_repository.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/viewmodels/reminder.dart';

/// 提醒编辑页。
///
/// 同时承载“新增提醒”和“编辑提醒”两种场景，是否编辑由 `initial` 是否为空决定。
class ReminderEditPage extends StatefulWidget {
  /// 创建提醒编辑页。
  const ReminderEditPage({super.key, this.initial});

  /// 编辑时传入的初始提醒计划。
  ///
  /// - null：新增提醒
  /// - 非 null：编辑已有提醒
  final ReminderPlan? initial;

  /// 创建提醒编辑页对应的状态对象。
  @override
  State<ReminderEditPage> createState() => _ReminderEditPageState();
}

/// 提醒编辑页状态对象。
///
/// 这里把“表单显示值”和“接口提交所需身份字段”一起维护，避免只靠药品名称提交导致
/// 后续无法和详情、提醒、打卡等功能对齐。
class _ReminderEditPageState extends State<ReminderEditPage> {
  /// 全局用户控制器，用于读取当前 userId。
  final UserController _userController = Get.find<UserController>();

  /// 药品名称输入框控制器。
  ///
  /// 当前仅用于持有已选药品名称，不再直接暴露可编辑输入框。
  late final TextEditingController _nameController;

  /// 额外提醒内容输入框控制器。
  late final TextEditingController _subtitleController;

  /// 剂量输入框控制器。
  late final TextEditingController _dosageController;

  /// 当前提醒已选择的药品列表（支持一条提醒绑定多个药品）。
  final List<MedicineItem> _selectedMedicines = <MedicineItem>[];

  /// 当前选择的提醒时间（HH:mm）。
  ///
  /// 页面内部统一保留为字符串，便于直接回填 UI、写入接口和本地缓存。
  String _time = '08:00';

  /// 生效开始日期（yyyy-MM-dd，留空表示不限制）。
  String _startDate = '';

  /// 生效结束日期（yyyy-MM-dd，留空表示不限制）。
  String _endDate = '';

  /// 当前提醒是否启用。
  ///
  /// 之所以作为表单状态保存，是因为新增时就允许用户决定这条计划是否立即生效。
  bool _enabled = true;

  /// 当前是否正在保存。
  ///
  /// 用于避免重复点击“保存”导致重复 upsert。
  bool _saving = false;

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  bool get _isEdit => widget.initial != null;

  String get _normalizedProductName => _composeSelectedMedicineNames();

  String get _normalizedDosage => _dosageController.text.trim();

  String get _normalizedExtraContent => _subtitleController.text.trim();

  bool get _hasLinkedIdentity => _selectedMedicines.isNotEmpty;

  bool get _canSave => !_saving && _selectedMedicines.isNotEmpty;

  String _shortDate(String value) {
    final text = value.trim();
    if (text.length >= 10) {
      return text.substring(5, 10);
    }
    return text;
  }

  String get _dateRangeChipText {
    final l10n = _l10n;
    if (_startDate.isEmpty && _endDate.isEmpty) {
      return l10n?.reminderDateRangeAllTime ?? '全时段';
    }
    if (_startDate.isNotEmpty && _endDate.isNotEmpty) {
      return l10n?.reminderDateRangeBetweenShort(
            _shortDate(_startDate),
            _shortDate(_endDate),
          ) ??
          '${_shortDate(_startDate)}~${_shortDate(_endDate)}';
    }
    if (_startDate.isNotEmpty) {
      return l10n?.reminderDateRangeFromShort(_shortDate(_startDate)) ??
          '${_shortDate(_startDate)}起';
    }
    return l10n?.reminderDateRangeUntilShort(_shortDate(_endDate)) ??
        '至${_shortDate(_endDate)}';
  }

  /// 生成已选药品身份信息的副标题文本。
  ///
  /// 当选中了药品后，优先展示本地化标签（药品编码/批准文号），
  /// 便于用户确认当前提醒绑定的是哪条药品记录。
  String _buildSelectedIdentitySubtitle(AppLocalizations? l10n) {
    if (_selectedMedicines.isEmpty) {
      return l10n?.reminderEditSelectMedicineHint ?? '可从“我的药品/搜索库”选择';
    }
    if (_selectedMedicines.length == 1) {
      final selected = _selectedMedicines.first;
      final drugCode = selected.drugCode.trim().isEmpty
          ? '-'
          : selected.drugCode.trim();
      final approvalNo = selected.approvalNo.trim().isEmpty
          ? '-'
          : selected.approvalNo.trim();
      return l10n?.reminderEditSelectedIdentity(drugCode, approvalNo) ??
          'Drug Code: $drugCode  Approval No.: $approvalNo';
    }
    final first = _selectedMedicines.first;
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    if (locale.startsWith('zh')) {
      return '已选择 ${_selectedMedicines.length} 种药品，首项: ${first.productName}';
    }
    return '${_selectedMedicines.length} medicines selected, first: ${first.productName}';
  }

  /// 当前登录用户 id（未登录时为空字符串）。
  String get _userId => _userController.user.value?.id ?? '';

  /// 初始化编辑页状态。
  ///
  /// 如果是编辑模式，会把 `widget.initial` 的数据回填到表单。
  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _nameController = TextEditingController(text: init?.productName ?? '');
    _subtitleController = TextEditingController(text: init?.subtitle ?? '');
    _dosageController = TextEditingController(text: init?.dosage ?? '');
    _time = init?.time ?? '08:00';
    _enabled = init?.enabled ?? true;
    _startDate = init?.startDate ?? '';
    _endDate = init?.endDate ?? '';
    _hydrateInitialMedicines(init);
  }

  /// 释放文本控制器资源。
  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _hydrateInitialMedicines(ReminderPlan? init) {
    final refs = init?.medicines ?? const <ReminderMedicineRef>[];
    if (refs.isNotEmpty) {
      _selectedMedicines.addAll(
        refs
            .where((item) => item.productName.trim().isNotEmpty)
            .map(_toMedicineItem)
            .toList(growable: false),
      );
    } else if ((init?.productName ?? '').trim().isNotEmpty) {
      _selectedMedicines.add(
        MedicineItem(
          serialNo: '',
          approvalNo: init?.approvalNo ?? '',
          productName: init?.productName ?? '',
          dosageForm: '',
          specification: init?.dosage ?? '',
          marketingAuthorizationHolder: '',
          manufacturer: '',
          drugCode: init?.drugCode ?? '',
          drugCodeRemark: '',
        ),
      );
    }
    _nameController.text = _normalizedProductName;
  }

  MedicineItem _toMedicineItem(ReminderMedicineRef ref) {
    return MedicineItem(
      serialNo: '',
      approvalNo: ref.approvalNo,
      productName: ref.productName,
      dosageForm: '',
      specification: _normalizedDosage,
      marketingAuthorizationHolder: '',
      manufacturer: '',
      drugCode: ref.drugCode,
      drugCodeRemark: '',
    );
  }

  String _composeSelectedMedicineNames() {
    final names = _selectedMedicines
        .map((item) => item.productName.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    if (names.isEmpty) {
      return _nameController.text.trim();
    }
    return names.toSet().join('、');
  }

  String _medicineIdentityKey(MedicineItem item) {
    final drugCode = item.drugCode.trim();
    if (drugCode.isNotEmpty) {
      return 'drug:$drugCode';
    }
    final approvalNo = item.approvalNo.trim();
    if (approvalNo.isNotEmpty) {
      return 'approval:$approvalNo';
    }
    return 'name:${item.productName.trim()}';
  }

  /// 构建提醒编辑页 UI。
  @override
  Widget build(BuildContext context) {
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
                            ? (l10n?.reminderEditStatusBoundMedicine ?? '已绑定药品')
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
                  title: l10n?.reminderEditTimeTitle(_time) ?? '提醒时间: $_time',
                  subtitle: l10n?.reminderEditTimeSubtitle ?? '每天在该时间通过系统通知提醒',
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
                      (_startDate.isEmpty ? '开始日期: 不限制' : '开始日期: $_startDate'),
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
                  subtitle: l10n?.reminderEditEndDateSubtitle ?? '留空表示不限制结束日期',
                  badgeText: _endDate.isEmpty
                      ? (l10n?.reminderEditDateBadgeUnset ?? '未设置')
                      : (l10n?.reminderEditDateBadgeSet ?? '已设置'),
                  onTap: _pickEndDate,
                ),
                if (_startDate.isNotEmpty || _endDate.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _startDate = '';
                          _endDate = '';
                        });
                      },
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      label: Text(l10n?.reminderEditClearDateLimit ?? '清空日期限制'),
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
                Switch(
                  value: _enabled,
                  onChanged: (v) => setState(() => _enabled = v),
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
              onDeleted: () {
                setState(() {
                  _selectedMedicines.removeAt(index);
                  _nameController.text = _normalizedProductName;
                });
              },
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
    final item = await Navigator.of(context).push<MedicineItem>(
      MaterialPageRoute<MedicineItem>(
        builder: (_) => MedicinePickerPage(
          title: _l10n?.reminderEditPickerTitle ?? '选择提醒药品',
        ),
      ),
    );
    if (!mounted) return;
    if (item == null) return;
    final identity = _medicineIdentityKey(item);
    if (_selectedMedicines.any((e) => _medicineIdentityKey(e) == identity)) {
      ToastUtils.instance.show(
        context,
        _l10n?.searchAlreadyAddedToast ?? '该药品已选择',
      );
      return;
    }

    setState(() {
      _selectedMedicines.add(item);
      _nameController.text = _normalizedProductName;
    });
  }

  /// 打开时间选择器并更新提醒时间。
  Future<void> _pickTime() async {
    /// 当前时间字符串按冒号拆分后的部分。
    final parts = _time.split(':');

    /// 当前时间的小时值。
    final h = parts.length == 2 ? int.tryParse(parts[0]) ?? 8 : 8;

    /// 当前时间的分钟值。
    final m = parts.length == 2 ? int.tryParse(parts[1]) ?? 0 : 0;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: h, minute: m),
    );
    if (picked == null) return;
    setState(() {
      _time =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  DateTime _resolvePickerInitial(String raw) {
    final now = DateTime.now();
    final minDate = DateTime(2000, 1, 1);
    final maxDate = DateTime(now.year + 5, 12, 31);
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return now;
    }
    if (parsed.isBefore(minDate)) {
      return minDate;
    }
    if (parsed.isAfter(maxDate)) {
      return maxDate;
    }
    return parsed;
  }

  Future<String?> _pickDate(String initialRaw) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _resolvePickerInitial(initialRaw),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (picked == null) {
      return null;
    }
    return '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickStartDate() async {
    final picked = await _pickDate(_startDate.isEmpty ? _endDate : _startDate);
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await _pickDate(_endDate.isEmpty ? _startDate : _endDate);
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _endDate = picked);
  }

  /// 保存提醒计划。
  ///
  /// 会先做前端校验，再调用 `ReminderApi.upsert`，成功后把结果返回上一页。
  Future<void> _save() async {
    /// 当前 userId。
    final userId = _userId;
    if (userId.trim().isEmpty) {
      ToastUtils.instance.show(context, _l10n?.reminderEditNeedLogin ?? '请先登录');
      Navigator.pushNamed(context, '/login');
      return;
    }

    if (_selectedMedicines.isEmpty) {
      ToastUtils.instance.show(
        context,
        _l10n?.reminderEditNameRequired ?? '请至少选择一种药品',
      );
      return;
    }
    final productName = _normalizedProductName;
    final medicines = _selectedMedicines
        .where((item) => item.productName.trim().isNotEmpty)
        .map(
          (item) => ReminderMedicineRef(
            drugCode: item.drugCode.trim(),
            approvalNo: item.approvalNo.trim(),
            productName: item.productName.trim(),
          ),
        )
        .toList(growable: false);

    if (medicines.isEmpty) {
      ToastUtils.instance.show(
        context,
        _l10n?.reminderEditNameRequired ?? '请至少选择一种药品',
      );
      return;
    }

    final primaryMedicine = medicines.first;
    if (_startDate.isNotEmpty &&
        _endDate.isNotEmpty &&
        _startDate.compareTo(_endDate) > 0) {
      ToastUtils.instance.show(
        context,
        _l10n?.reminderEditDateRangeInvalidToast ?? '开始日期不能晚于结束日期',
      );
      return;
    }

    setState(() => _saving = true);
    try {
      /// 调用新增/更新提醒接口。
      final response = await ReminderApi.upsert(
        userId: userId,
        id: widget.initial?.id,
        time: _time,
        drugCode: primaryMedicine.drugCode,
        approvalNo: primaryMedicine.approvalNo,
        productName: productName,
        medicines: medicines,
        dosage: _normalizedDosage,
        subtitle: _normalizedExtraContent,
        enabled: _enabled,
        repeatRule: 'daily',
        method: 'notification',
        startDate: _startDate,
        endDate: _endDate,
      );
      await _syncReminderMedicinesToLocal(userId);
      if (!mounted) return;
      Navigator.pop(context, response.result);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.instance.showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _syncReminderMedicinesToLocal(String userId) async {
    if (userId.trim().isEmpty || _selectedMedicines.isEmpty) {
      return;
    }
    for (final item in _selectedMedicines) {
      final normalized = MedicineItem(
        serialNo: item.serialNo,
        approvalNo: item.approvalNo,
        productName: item.productName,
        dosageForm: item.dosageForm,
        specification: item.specification.isNotEmpty
            ? item.specification
            : _normalizedDosage,
        marketingAuthorizationHolder: item.marketingAuthorizationHolder,
        manufacturer: item.manufacturer,
        drugCode: item.drugCode,
        drugCodeRemark: item.drugCodeRemark,
      );
      try {
        await myMedicineRepository.addMedicine(
          item: normalized,
          source: 'reminder',
          userId: userId,
        );
      } catch (_) {}
    }
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
    return locale.startsWith('zh')
        ? '额外提醒内容(可选)'
        : 'Extra reminder content (optional)';
  }

  String _extraContentHint(AppLocalizations? l10n) {
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    return locale.startsWith('zh')
        ? '例如 饭后服用，注意多喝水'
        : 'e.g. Take after meals and drink more water';
  }
}
