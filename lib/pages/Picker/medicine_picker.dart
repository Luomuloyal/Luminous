import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/pages/Search/search.dart';
import 'package:luminous/stores/my_medicine_repository.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';

/// 药品选择器页面。
///
/// 统一承接“从我的药品选择”与“跳转搜索库选择”两种入口，并把结果返回给上层页面。
class MedicinePickerPage extends StatefulWidget {
  /// 创建药品选择器页面。
  const MedicinePickerPage({super.key, this.title = '选择药品'});

  /// 顶部 AppBar 标题。
  final String title;

  /// 创建药品选择页对应的状态对象。
  @override
  State<MedicinePickerPage> createState() => _MedicinePickerPageState();
}

/// 药品选择器状态对象。
///
/// 页面会先展示本地“我的药品”，必要时再跳到搜索页做更大范围的选择。
class _MedicinePickerPageState extends State<MedicinePickerPage> {
  /// 当前登录用户控制器。
  final UserController _userController = Get.find<UserController>();

  /// 当前是否正在加载“我的药品”列表。
  bool _loading = false;

  /// 从本地数据库读取到的“我的药品”行数据。
  List<Map<String, dynamic>> _rows = [];

  /// 页面初始化时立即加载本地药品列表。
  @override
  void initState() {
    super.initState();
    _load();
  }

  /// 从本地数据库加载“我的药品”。
  Future<void> _load() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final rows = await myMedicineRepository.loadLocalRows(userId: _userId);
      if (!mounted) return;
      setState(() => _rows = rows);

      if (_userId.isNotEmpty) {
        await myMedicineRepository.syncRemote(_userId);
        final syncedRows = await myMedicineRepository.loadLocalRows(
          userId: _userId,
        );
        if (!mounted) return;
        setState(() => _rows = syncedRows);
      }
    } catch (_) {
      if (mounted) {
        ToastUtils.instance.show(context, '加载我的药品失败');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 当前登录用户 id（未登录时为空字符串）。
  String get _userId => _userController.user.value?.id ?? '';

  /// 构建药品选择页 UI。
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCanvasPageScaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      appBarSpacing: 32,
      accentColor: scheme.primary,
      secondaryAccentColor: Color.lerp(scheme.secondary, scheme.tertiary, 0.5)!,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            _buildFlowHints(),
            const SizedBox(height: 12),
            _buildSearchEntry(),
            const SizedBox(height: 12),
            _buildMyMedicinesCard(),
          ],
        ),
      ),
    );
  }

  /// 构建顶部流程提示，让选择策略更直观。
  Widget _buildFlowHints() {
    final scheme = Theme.of(context).colorScheme;
    final itemCountText = _rows.isEmpty
        ? '本地药品库暂时为空'
        : '本地已收录 ${_rows.length} 项';
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _PickerHintChip(
          icon: Icons.offline_bolt_rounded,
          label: '本地优先选择',
          accent: scheme.primary,
        ),
        _PickerHintChip(
          icon: Icons.cloud_sync_outlined,
          label: '需要时再补查云端',
          accent: scheme.secondary,
        ),
        _PickerHintChip(
          icon: Icons.inventory_2_outlined,
          label: itemCountText,
          accent: scheme.tertiary,
        ),
      ],
    );
  }

  /// 构建顶部“手动搜索药品库”入口。
  Widget _buildSearchEntry() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppSectionCard(
      accentColor: scheme.primary,
      secondaryColor: scheme.secondary,
      ornamentKey: 'picker.search-entry',
      padding: EdgeInsets.zero,
      radius: 18,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _openSearchPicker,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: appTintedSurface(
                      context,
                      scheme.primary,
                      lightAlpha: 0.10,
                      darkAlpha: 0.18,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.search_rounded, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: appTintedSurface(
                            context,
                            scheme.secondary,
                            lightAlpha: 0.09,
                            darkAlpha: 0.16,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '云端药品库',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: scheme.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '手动搜索药品库',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '从云端搜索后直接带回当前流程，适合本地还没保存时快速补查。',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建“我的药品”选择卡片区域。
  ///
  /// 用户可以直接从本地已添加的药品里点选，也可以跳到搜索页重新选择。
  Widget _buildMyMedicinesCard() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppSectionCard(
      accentColor: scheme.tertiary,
      secondaryColor: scheme.secondary,
      ornamentKey: 'picker.my-medicines',
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '我的药品',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(width: 10),
              if (_rows.isNotEmpty)
                _PickerCountChip(
                  label: '共 ${_rows.length} 项',
                  accent: scheme.tertiary,
                ),
              const Spacer(),
              if (_loading) ...[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 6),
                Text(
                  '同步中',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (_rows.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              decoration: BoxDecoration(
                color: appTintedSurface(
                  context,
                  scheme.tertiary,
                  lightAlpha: 0.045,
                  darkAlpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: appTintedBorder(
                    context,
                    scheme.tertiary,
                    lightAlpha: 0.08,
                    darkAlpha: 0.18,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: appTintedSurface(
                        context,
                        scheme.tertiary,
                        lightAlpha: 0.09,
                        darkAlpha: 0.16,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.medication_liquid_rounded,
                      color: scheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '还没有本地药品记录',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '你可以先去云端药品库补查，或者稍后再把常用药保存到这里。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              final item = _rowToItem(row);
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _rows.length - 1 ? 0 : 10,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.pop(context, item),
                  child: Ink(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: appTintedSurface(
                        context,
                        scheme.primary,
                        lightAlpha: 0.04,
                        darkAlpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: appTintedBorder(
                          context,
                          scheme.primary,
                          lightAlpha: 0.08,
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
                            color: appTintedSurface(
                              context,
                              scheme.primary,
                              lightAlpha: 0.10,
                              darkAlpha: 0.18,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.medication_rounded,
                            color: scheme.primary,
                          ),
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
                                      item.displayName,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _MedicineBadge(
                                    label: item.displayBadge,
                                    accent: scheme.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.displaySubtitle,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                              if (item.displayTips.isNotEmpty) ...[
                                const SizedBox(height: 7),
                                Text(
                                  item.displayTips,
                                  style: TextStyle(
                                    fontSize: 11.8,
                                    color: scheme.onSurfaceVariant.withValues(
                                      alpha: 0.88,
                                    ),
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
                        Icon(
                          Icons.chevron_right_rounded,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  /// 把数据库行数据转换为 `MedicineItem`。
  ///
  /// 这样选择页返回给上层的是统一的强类型对象，而不是原始 Map。
  MedicineItem _rowToItem(Map<String, dynamic> row) {
    return MedicineItem(
      serialNo: '',
      approvalNo: (row['approvalNo'] ?? '').toString(),
      productName: (row['productName'] ?? '').toString(),
      dosageForm: (row['dosageForm'] ?? '').toString(),
      specification: (row['specification'] ?? '').toString(),
      marketingAuthorizationHolder: '',
      manufacturer: (row['manufacturer'] ?? '').toString(),
      drugCode: (row['drugCode'] ?? '').toString(),
      drugCodeRemark: '',
    );
  }

  /// 打开搜索页进行药品选择。
  ///
  /// 搜索页会以 `pickerMode=true` 打开，选中后直接返回 `MedicineItem`。
  Future<void> _openSearchPicker() async {
    /// 从搜索页返回的药品对象。
    final result = await Navigator.of(context).push<MedicineItem>(
      MaterialPageRoute<MedicineItem>(
        builder: (_) => const SearchView(pickerMode: true),
      ),
    );
    if (!mounted) return;
    if (result == null) return;
    Navigator.pop(context, result);
  }
}

class _PickerHintChip extends StatelessWidget {
  const _PickerHintChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final background = appTintedSurface(
      context,
      accent,
      lightAlpha: 0.06,
      darkAlpha: 0.11,
    );
    final border = appTintedBorder(
      context,
      accent,
      lightAlpha: 0.08,
      darkAlpha: 0.16,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerCountChip extends StatelessWidget {
  const _PickerCountChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: appTintedSurface(
          context,
          accent,
          lightAlpha: 0.08,
          darkAlpha: 0.16,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.3,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }
}

class _MedicineBadge extends StatelessWidget {
  const _MedicineBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: appTintedSurface(
          context,
          accent,
          lightAlpha: 0.08,
          darkAlpha: 0.16,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.8,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }
}
