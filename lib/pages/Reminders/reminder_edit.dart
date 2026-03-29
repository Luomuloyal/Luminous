import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/reminder_api.dart';
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

  /// 当前提醒是否启用。
  ///
  /// 之所以作为表单状态保存，是因为新增时就允许用户决定这条计划是否立即生效。
  bool _enabled = true;

  /// 当前是否正在保存。
  ///
  /// 用于避免重复点击“保存”导致重复 upsert。
  bool _saving = false;

  AppLocalizations? get _l10n => AppLocalizations.of(context);

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

    /// 当前是否为编辑模式。
    final isEdit = widget.initial != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: Text(
          isEdit
              ? (l10n?.reminderEditTitle ?? '编辑提醒')
              : (l10n?.reminderCreateTitle ?? '新增提醒'),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildSection(
            title: l10n?.reminderEditSectionDrugTime ?? '药品与时间',
            child: Column(
              children: [
                _tile(
                  icon: Icons.medication_outlined,
                  color: const Color(0xFF0EA5E9),
                  title: _nameController.text.trim().isEmpty
                      ? (l10n?.reminderEditSelectMedicine ?? '选择药品')
                      : _nameController.text.trim(),
                  subtitle:
                      _drugCode.trim().isNotEmpty ||
                          _approvalNo.trim().isNotEmpty
                      ? _buildSelectedIdentitySubtitle(l10n)
                      : (l10n?.reminderEditSelectMedicineHint ??
                            '可从“我的药品/搜索库”选择'),
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
          _buildSection(
            title: l10n?.reminderEditSectionContent ?? '提醒内容',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n?.reminderEditNameLabel ?? '药品名称(必填)',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final nextName = value.trim();
                    final shouldClearIdentity =
                        _selectedProductName.isNotEmpty &&
                        nextName != _selectedProductName;
                    setState(() {
                      if (shouldClearIdentity) {
                        _selectedProductName = '';
                        _drugCode = '';
                        _approvalNo = '';
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _subtitleController,
                  decoration: InputDecoration(
                    labelText: l10n?.reminderEditSubtitleLabel ?? '备注(可选)',
                    hintText: l10n?.reminderEditSubtitleHint ?? '例如 早餐后服用 1 粒',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSection(
            title: l10n?.reminderEditSectionSwitch ?? '开关',
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n?.reminderEditEnableSwitch ?? '启用提醒',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
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
          Text(
            l10n?.reminderEditTip ?? '提示：提醒信息仅用于辅助管理，不能替代医生处方。如有不适请及时就医。',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建一个统一风格的白色 section 卡片。
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  /// 构建可点击的选择 tile（药品 / 时间）。
  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
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
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
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
    setState(() {
      _nameController.text = item.productName;
      _subtitleController.text = _subtitleController.text.trim();
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
    final productName = _nameController.text.trim();
    if (productName.isEmpty) {
      ToastUtils.instance.show(
        context,
        _l10n?.reminderEditNameRequired ?? '药品名称不能为空',
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
