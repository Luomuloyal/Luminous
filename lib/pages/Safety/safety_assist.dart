import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/safety_api.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/auth.dart';
import 'package:luminous/components/soft_banner.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final secondaryAccent = Color.lerp(
      scheme.secondary,
      scheme.tertiary,
      0.52,
    )!;
    return AppCanvasPageScaffold(
      appBar: AppBar(
        title: const Text('安全辅助'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      appBarSpacing: 32,
      accentColor: scheme.primary,
      secondaryAccentColor: secondaryAccent,
      child: RefreshIndicator(
        onRefresh: _refreshResult,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            _buildHeroCard(),
            const SizedBox(height: 12),
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

  Widget _buildHeroCard() {
    final loggedIn = _userController.isLoggedIn;
    final selectedCount =
        1 + (_mode == 'pair' ? (_b == null ? 0 : 1) : 0) - (_a == null ? 1 : 0);

    return SoftBannerCard(
      palette: SoftBannerPalettes.drugOf(context),
      ornamentKey: 'safety.hero',
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      builder: (context, theme) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.surfaceColor,
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    color: theme.accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '安全辅助',
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '用更柔和的方式整理单药建议和两药相互作用提示',
                        style: TextStyle(
                          color: theme.secondaryTextColor,
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SafetyInfoChip(
                    icon: _mode == 'pair'
                        ? Icons.compare_arrows_rounded
                        : Icons.auto_awesome_rounded,
                    text: _mode == 'pair' ? '两药相互作用' : '单药建议',
                    backgroundColor: theme.surfaceColor,
                    foregroundColor: theme.surfaceTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SafetyInfoChip(
                    icon: Icons.medication_outlined,
                    text: selectedCount == 0
                        ? '等待选择药品'
                        : '已选择 $selectedCount 个药品',
                    backgroundColor: theme.surfaceColor,
                    foregroundColor: theme.surfaceTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SafetyInfoChip(
                    icon: loggedIn
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_outlined,
                    text: loggedIn ? '可附带账号上下文' : '云端AI查询',
                    backgroundColor: theme.surfaceColor,
                    foregroundColor: theme.surfaceTextColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// 构建“查询模式”卡片。
  Widget _buildModeCard() {
    final scheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: '查询模式',
      accentColor: scheme.secondary,
      secondaryColor: scheme.tertiary,
      ornamentKey: 'safety.mode',
      child: AuthMethodSwitcher(
        accentColor: scheme.secondary,
        items: [
          AuthMethodItem(
            label: '单药建议',
            selected: _mode == 'single',
            onTap: () => setState(() {
              _mode = 'single';
              _b = null;
              _result = null;
            }),
          ),
          AuthMethodItem(
            label: '两药相互作用',
            selected: _mode == 'pair',
            onTap: () => setState(() {
              _mode = 'pair';
              _result = null;
            }),
          ),
        ],
      ),
    );
  }

  /// 构建“选择药品”卡片。
  Widget _buildPickCard() {
    final scheme = Theme.of(context).colorScheme;
    final tileAColor = scheme.primary;
    final tileBColor = Color.lerp(scheme.secondary, scheme.tertiary, 0.35)!;
    return _SectionCard(
      title: '选择药品',
      accentColor: scheme.primary,
      secondaryColor: scheme.secondary,
      ornamentKey: 'safety.pick',
      child: Column(
        children: [
          _pickTile(
            label: _a?.displayName ?? '请选择药品 A',
            subtitle: _a?.displaySubtitle ?? '从我的药品/搜索库选择',
            color: tileAColor,
            onTap: () => _pickMedicine(slot: 0),
            badge: '药品 A',
            note: _a?.displayTips,
          ),
          if (_mode == 'pair') ...[
            const SizedBox(height: 10),
            _pickTile(
              label: _b?.displayName ?? '请选择药品 B',
              subtitle: _b?.displaySubtitle ?? '从我的药品/搜索库选择',
              color: tileBColor,
              onTap: () => _pickMedicine(slot: 1),
              badge: '药品 B',
              note: _b?.displayTips,
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
    required String badge,
    String? note,
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
            darkAlpha: 0.11,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: appTintedBorder(
              context,
              color,
              lightAlpha: 0.10,
              darkAlpha: 0.18,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
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
                          badge,
                          style: TextStyle(
                            fontSize: 10.8,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  if (note != null && note.trim().isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      note.trim(),
                      style: TextStyle(
                        fontSize: 11.8,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  /// 构建“开始查询”卡片。
  Widget _buildActionCard() {
    /// 当前是否已选择到足够的药品以开始查询。
    final ready = _a != null && (_mode == 'single' || _b != null);
    final scheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: '开始查询',
      accentColor: scheme.tertiary,
      secondaryColor: scheme.primary,
      ornamentKey: 'safety.action',
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _loading || !ready ? null : _query,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _loading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.onPrimary,
                  ),
                )
              : Text(_mode == 'pair' ? '查询两药相互作用' : '查询用药建议'),
        ),
      ),
    );
  }

  /// 构建“AI 结果”卡片。
  Widget _buildResultCard() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _SectionCard(
      title: 'AI 结果',
      accentColor: Color.lerp(scheme.secondary, scheme.primary, 0.5)!,
      secondaryColor: scheme.tertiary,
      ornamentKey: 'safety.result',
      child: _result == null || !_result!.hasText
          ? Text(
              '选择药品后点击“开始查询”，后端会调用 AI 模型返回用药建议或相互作用提示。',
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            )
          : Text(
              _result!.text,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: scheme.onSurface,
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
  const _SectionCard({
    required this.title,
    required this.child,
    required this.accentColor,
    required this.secondaryColor,
    required this.ornamentKey,
  });

  /// 卡片标题。
  final String title;

  /// 卡片主体内容。
  final Widget child;

  final Color accentColor;
  final Color secondaryColor;
  final String ornamentKey;

  /// 构建 section 卡片 UI。
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: accentColor,
      secondaryColor: secondaryColor,
      ornamentKey: ornamentKey,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      accentColor: Theme.of(context).colorScheme.tertiary,
      secondaryColor: Theme.of(context).colorScheme.secondary,
      ornamentKey: 'safety.disclaimer',
      child: Text(
        '本功能基于 AI 生成内容，仅用于健康科普与辅助查询，不能替代医生诊断与处方。'
        '如有不适或正在用药，请遵医嘱并咨询专业人士。',
        style: TextStyle(
          fontSize: 12.5,
          height: 1.55,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SafetyInfoChip extends StatelessWidget {
  const _SafetyInfoChip({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 16, color: foregroundColor),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 12.3,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
