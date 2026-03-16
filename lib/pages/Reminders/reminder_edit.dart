import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/pages/Picker/medicine_picker.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/viewmodels/reminder.dart';

class ReminderEditPage extends StatefulWidget {
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

class _ReminderEditPageState extends State<ReminderEditPage> {
  /// 全局用户控制器，用于读取当前 userId。
  final UserController _userController = Get.find<UserController>();

  /// 药品名称输入框控制器。
  late final TextEditingController _nameController;

  /// 备注输入框控制器。
  late final TextEditingController _subtitleController;

  /// 当前选中药品的 drugCode。
  String _drugCode = '';

  /// 当前选中药品的 approvalNo。
  String _approvalNo = '';

  /// 当前选择的提醒时间（HH:mm）。
  String _time = '08:00';

  /// 当前提醒是否启用。
  bool _enabled = true;

  /// 当前是否正在保存。
  bool _saving = false;

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
    /// 当前是否为编辑模式。
    final isEdit = widget.initial != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: Text(isEdit ? '编辑提醒' : '新增提醒'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildSection(
            title: '药品与时间',
            child: Column(
              children: [
                _tile(
                  icon: Icons.medication_outlined,
                  color: const Color(0xFF0EA5E9),
                  title: _nameController.text.trim().isEmpty
                      ? '选择药品'
                      : _nameController.text.trim(),
                  subtitle:
                      _drugCode.trim().isNotEmpty ||
                          _approvalNo.trim().isNotEmpty
                      ? 'drugCode: ${_drugCode.isEmpty ? '-' : _drugCode}  approvalNo: ${_approvalNo.isEmpty ? '-' : _approvalNo}'
                      : '可从“我的药品/搜索库”选择',
                  onTap: _pickMedicine,
                ),
                const SizedBox(height: 10),
                _tile(
                  icon: Icons.access_time_rounded,
                  color: const Color(0xFF10B981),
                  title: '提醒时间: $_time',
                  subtitle: '每天在该时间通过系统通知提醒',
                  onTap: _pickTime,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSection(
            title: '提醒内容',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '药品名称(必填)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(
                    labelText: '备注(可选)',
                    hintText: '例如 早餐后服用 1 粒',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSection(
            title: '开关',
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '启用提醒',
                    style: TextStyle(
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
                  : const Text('保存'),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '提示：提醒信息仅用于辅助管理，不能替代医生处方。如有不适请及时就医。',
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
        builder: (_) => const MedicinePickerPage(title: '选择提醒药品'),
      ),
    );
    if (!mounted) return;
    if (item == null) return;
    setState(() {
      _nameController.text = item.productName;
      _subtitleController.text = _subtitleController.text.trim();
      _drugCode = item.drugCode;
      _approvalNo = item.approvalNo;
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
      ToastUtils.instance.show(context, '请先登录');
      Navigator.pushNamed(context, '/login');
      return;
    }

    /// 表单中的药品名称。
    final productName = _nameController.text.trim();
    if (productName.isEmpty) {
      ToastUtils.instance.show(context, '药品名称不能为空');
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
      ToastUtils.instance.show(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
