import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Picker/medicine_picker.dart';
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
  late final TextEditingController _nameController;

  /// 备注输入框控制器。
  late final TextEditingController _subtitleController;

  /// 当前选中药品的 drugCode。
  ///
  /// 单独保存它是因为药品名称输入框允许手动编辑，但接口提交和后续跳转更依赖稳定的身份字段。
  String _drugCode = '';

  /// 当前选中药品的 approvalNo。
  ///
  /// 与 `drugCode` 一起作为“这个提醒关联的是哪款药”的身份信息。
  String _approvalNo = '';

  /// 当前名称字段所对应的“已确认药品名”。
  ///
  /// 当用户手动改名后，如果名称和这个值不一致，就说明身份字段已经不再可信，
  /// 需要把 `drugCode/approvalNo` 一并清空，避免名称和身份错配。
  String _selectedProductName = '';

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

  String get _normalizedProductName => _nameController.text.trim();

  bool get _hasLinkedIdentity =>
      _drugCode.trim().isNotEmpty || _approvalNo.trim().isNotEmpty;

  bool get _canSave => !_saving && _normalizedProductName.isNotEmpty;

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
    final drugCode = _drugCode.trim().isEmpty ? '-' : _drugCode.trim();
    final approvalNo = _approvalNo.trim().isEmpty ? '-' : _approvalNo.trim();
    return l10n?.reminderEditSelectedIdentity(drugCode, approvalNo) ??
        'Drug Code: $drugCode  Approval No.: $approvalNo';
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
    _drugCode = init?.drugCode ?? '';
    _approvalNo = init?.approvalNo ?? '';
    _selectedProductName = init?.productName.trim() ?? '';
    _time = init?.time ?? '08:00';
    _enabled = init?.enabled ?? true;
    _startDate = init?.startDate ?? '';
    _endDate = init?.endDate ?? '';
  }

  /// 释放文本控制器资源。
  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    super.dispose();
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
      ),
      appBarSpacing: 30,
      safeAreaBottom: true,
      accentColor: const Color(0xFF10B981),
      secondaryAccentColor: const Color(0xFF0EA5E9),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 26),
        children: <Widget>[
          _buildHeroCard(),
          const SizedBox(height: 12),
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
                  title: _normalizedProductName.isEmpty
                      ? (l10n?.reminderEditSelectMedicine ?? '选择药品')
                      : _normalizedProductName,
                  subtitle: _hasLinkedIdentity
                      ? _buildSelectedIdentitySubtitle(l10n)
                      : (l10n?.reminderEditSelectMedicineHint ??
                            '可从“我的药品/搜索库”选择'),
                  badgeText: _hasLinkedIdentity
                      ? (l10n?.reminderEditStatusBoundMedicine ?? '已绑定药品')
                      : (l10n?.reminderEditStatusManualInput ?? '手动输入'),
                  onTap: _pickMedicine,
                ),
                const SizedBox(height: 10),
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
          const SizedBox(height: 12),
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
                            ? (l10n?.reminderDateUnlimited ?? '不限制')
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
                const SizedBox(height: 10),
                _tile(
                  icon: Icons.event_busy_rounded,
                  color: const Color(0xFF0EA5E9),
                  title:
                      l10n?.reminderEditEndDateTitle(
                        _endDate.isEmpty
                            ? (l10n?.reminderDateUnlimited ?? '不限制')
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
                  const SizedBox(height: 8),
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
          const SizedBox(height: 12),
          _buildSectionCard(
            title: l10n?.reminderEditSectionContent ?? '提醒内容',
            accentColor: const Color(0xFF3B82F6),
            secondaryColor: const Color(0xFF14B8A6),
            ornamentKey: 'reminders.edit.content',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildInputField(
                  controller: _nameController,
                  labelText: l10n?.reminderEditNameLabel ?? '药品名称(必填)',
                  maxLines: 1,
                  onChanged: _onNameChanged,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  controller: _subtitleController,
                  labelText: l10n?.reminderEditSubtitleLabel ?? '备注(可选)',
                  hintText: l10n?.reminderEditSubtitleHint ?? '例如 早餐后服用 1 粒',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 10),
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

  Widget _buildHeroCard() {
    final l10n = _l10n;
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: const Color(0xFF10B981),
      secondaryColor: const Color(0xFF0EA5E9),
      ornamentKey: 'reminders.edit.hero',
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
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
            ),
          ),
          const SizedBox(width: 12),
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
                  runSpacing: 8,
                  children: <Widget>[
                    TintedStatusChip(
                      icon: Icons.schedule_rounded,
                      text: _time,
                      color: const Color(0xFF10B981),
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
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
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
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
                    const SizedBox(height: 6),
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
          ],
        ),
      ),
    );
  }

  void _onNameChanged(String value) {
    final nextName = value.trim();
    final shouldClearIdentity =
        _selectedProductName.isNotEmpty && nextName != _selectedProductName;
    setState(() {
      if (shouldClearIdentity) {
        _selectedProductName = '';
        _drugCode = '';
        _approvalNo = '';
      }
    });
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
    setState(() {
      _nameController.text = item.productName;
      _drugCode = item.drugCode;
      _approvalNo = item.approvalNo;
      _selectedProductName = item.productName.trim();
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

    /// 表单中的药品名称。
    final productName = _normalizedProductName;
    if (productName.isEmpty) {
      ToastUtils.instance.show(
        context,
        _l10n?.reminderEditNameRequired ?? '药品名称不能为空',
      );
      return;
    }
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
        drugCode: _drugCode,
        approvalNo: _approvalNo,
        productName: productName,
        subtitle: _subtitleController.text.trim(),
        enabled: _enabled,
        repeatRule: 'daily',
        method: 'notification',
        startDate: _startDate,
        endDate: _endDate,
      );
      if (!mounted) return;
      Navigator.pop(context, response.result);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.instance.showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
