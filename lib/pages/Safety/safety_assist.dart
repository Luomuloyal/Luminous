import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/safety_api.dart';
import 'package:luminous/pages/Picker/medicine_picker.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/viewmodels/safety.dart';

/// 安全辅助页。
///
/// 页面允许用户选择一款或两款药品，并调用 AI 接口生成用药建议或相互作用提示。
class SafetyAssistPage extends StatefulWidget {
  /// 创建安全辅助页组件。
  const SafetyAssistPage({super.key});

  /// 创建安全辅助页对应的状态对象。
  @override
  State<SafetyAssistPage> createState() => _SafetyAssistPageState();
}

/// 安全辅助页状态对象。
///
/// 状态核心在于：
/// - 当前查询模式（单药 / 两药）；
/// - 已选择的药品；
/// - AI 返回的结果文本。
class _SafetyAssistPageState extends State<SafetyAssistPage> {
  /// 全局用户控制器，用于获取 userId（可选）与判断登录态。
  final UserController _userController = Get.find<UserController>();

  /// 当前查询模式：
  /// - single：单药建议
  /// - pair：两药相互作用
  ///
  /// 该状态决定页面要渲染几个药品选择入口，以及请求时要组装几条 medicine 数据。
  String _mode = 'single'; // single | pair

  /// 药品 A（单药模式仅使用 A）。
  MedicineItem? _a;

  /// 药品 B（两药模式使用 A + B）。
  MedicineItem? _b;

  /// 当前是否正在请求 AI 查询。
  bool _loading = false;

  /// AI 返回的查询结果。
  MedicineAiSafetyResult? _result;

  /// 当前登录用户 id（未登录时为空字符串）。
  String get _userId => _userController.user.value?.id ?? '';

  /// 构建安全辅助页 UI。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('安全辅助'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshResult,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _buildModeCard(),
            const SizedBox(height: 12),
            _buildPickCard(),
            const SizedBox(height: 12),
            _buildActionCard(),
            const SizedBox(height: 12),
            _buildResultCard(),
            const SizedBox(height: 12),
            const _DisclaimerCard(),
          ],
        ),
      ),
    );
  }

  /// 构建“查询模式”卡片。
  Widget _buildModeCard() {
    return _SectionCard(
      title: '查询模式',
      child: Row(
        children: [
          Expanded(
            child: _modeChip(
              label: '单药建议',
              selected: _mode == 'single',
              onTap: () => setState(() {
                _mode = 'single';
                _b = null;
                _result = null;
              }),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _modeChip(
              label: '两药相互作用',
              selected: _mode == 'pair',
              onTap: () => setState(() {
                _mode = 'pair';
                _result = null;
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个模式选择 chip。
  Widget _modeChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = selected ? const Color(0xFFEC4899) : const Color(0xFF64748B);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFFDA4AF) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? const Color(0xFF9F1239)
                      : const Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建“选择药品”卡片。
  Widget _buildPickCard() {
    return _SectionCard(
      title: '选择药品',
      child: Column(
        children: [
          _pickTile(
            label: _a?.displayName ?? '请选择药品 A',
            subtitle: _a?.displaySubtitle ?? '从我的药品/搜索库选择',
            color: const Color(0xFF0EA5E9),
            onTap: () => _pickMedicine(slot: 0),
          ),
          if (_mode == 'pair') ...[
            const SizedBox(height: 10),
            _pickTile(
              label: _b?.displayName ?? '请选择药品 B',
              subtitle: _b?.displaySubtitle ?? '从我的药品/搜索库选择',
              color: const Color(0xFF10B981),
              onTap: () => _pickMedicine(slot: 1),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建药品选择 tile（A 或 B）。
  Widget _pickTile({
    required String label,
    required String subtitle,
    required Color color,
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
              child: Icon(Icons.medication_outlined, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
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

  /// 构建“开始查询”卡片。
  Widget _buildActionCard() {
    /// 当前是否已选择到足够的药品以开始查询。
    final ready = _a != null && (_mode == 'single' || _b != null);
    return _SectionCard(
      title: '开始查询',
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _loading || !ready ? null : _query,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFEC4899),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_mode == 'pair' ? '查询两药相互作用' : '查询用药建议'),
        ),
      ),
    );
  }

  /// 构建“AI 结果”卡片。
  Widget _buildResultCard() {
    return _SectionCard(
      title: 'AI 结果',
      child: _result == null || !_result!.hasText
          ? const Text(
              '选择药品后点击“开始查询”，后端会调用腾讯云智能问药能力返回相关建议/相互作用提示。',
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            )
          : Text(
              _result!.text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  /// 打开药品选择器并把结果写入 A 或 B。
  ///
  /// - slot=0：设置 A
  /// - slot=1：设置 B
  Future<void> _pickMedicine({required int slot}) async {
    final item = await Navigator.of(context).push<MedicineItem>(
      MaterialPageRoute<MedicineItem>(
        builder: (_) =>
            MedicinePickerPage(title: slot == 0 ? '选择药品 A' : '选择药品 B'),
      ),
    );
    if (!mounted) return;
    if (item == null) return;
    setState(() {
      if (slot == 0) {
        _a = item;
      } else {
        _b = item;
      }
      _result = null;
    });
  }

  /// 发起安全辅助查询。
  ///
  /// 会根据模式组装 medicines 数组，然后调用后端 `medicine-ai-safety` 接口。
  Future<void> _query() async {
    /// 当前选择的药品 A。
    final a = _a;

    /// 当前选择的药品 B（两药模式才需要）。
    final b = _b;
    if (a == null) {
      ToastUtils.instance.show(context, '请先选择药品');
      return;
    }
    if (_mode == 'pair' && b == null) {
      ToastUtils.instance.show(context, '请再选择一个药品');
      return;
    }

    setState(() => _loading = true);
    try {
      /// 发送给后端的药品列表（Map 结构由接口契约约定）。
      final medicines = <Map<String, String>>[
        {
          'drugCode': a.drugCode,
          'approvalNo': a.approvalNo,
          'productName': a.productName,
        },
        if (_mode == 'pair' && b != null)
          {
            'drugCode': b.drugCode,
            'approvalNo': b.approvalNo,
            'productName': b.productName,
          },
      ];

      /// 调用安全辅助接口。
      final response = await SafetyApi.query(
        userId: _userId.isEmpty ? null : _userId,
        mode: _mode,
        medicines: medicines,
      );
      if (!mounted) return;
      setState(() => _result = response.result);
      if (!_result!.hasText) {
        ToastUtils.instance.show(context, 'AI暂无返回内容');
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtils.instance.showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 下拉刷新时按当前已选药品重新发起一次查询。
  Future<void> _refreshResult() async {
    final ready = _a != null && (_mode == 'single' || _b != null);
    if (!ready || _loading) {
      return;
    }
    await _query();
  }
}

/// 安全辅助页统一使用的白色 section 卡片。
///
/// 通过统一容器包裹不同区域，保持“模式/选药/结果/免责声明”视觉一致。
class _SectionCard extends StatelessWidget {
  /// 创建统一风格的白色 section 卡片。
  const _SectionCard({required this.title, required this.child});

  /// 卡片标题。
  final String title;

  /// 卡片主体内容。
  final Widget child;

  /// 构建 section 卡片 UI。
  @override
  Widget build(BuildContext context) {
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
}

/// 安全辅助页底部免责声明卡片。
class _DisclaimerCard extends StatelessWidget {
  /// 创建安全辅助页免责声明卡片。
  const _DisclaimerCard();

  /// 构建免责声明卡片 UI。
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '安全提示',
      child: const Text(
        '本功能基于 AI 生成内容，仅用于健康科普与辅助查询，不能替代医生诊断与处方。'
        '如有不适或正在用药，请遵医嘱并咨询专业人士。',
        style: TextStyle(
          fontSize: 12.5,
          height: 1.55,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
