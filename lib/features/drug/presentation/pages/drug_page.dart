import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/pages/Picker/medicine_picker.dart';
import 'package:luminous/features/scan/presentation/scan.dart';

import '../controllers/drug_controller.dart';
import '../models/drug_models.dart';
import '../widgets/drug_page_widgets.dart';
import 'medicine_detail_page.dart';

// 药品页
//
// 设计要点：
// - 无顶部色块，直接展示搜索入口 + 快捷入口
// - 下方为"我的药品"列表，使用 SliverList.builder 按需加载
// - 药品可通过手动搜索或拍照识别两种方式添加
/// 药品页。
///
/// 页面上半部分提供药品相关快捷入口，下半部分展示本地"我的药品"列表。
class DrugView extends StatelessWidget {
  /// 创建药品页组件。
  const DrugView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DrugController>(
      init: DrugController(),
      global: false,
      builder: (controller) {
        final l10n = AppLocalizations.of(context);
        return DrugPage(
          quickEntries: _quickEntries(l10n),
          myMedicines: controller.myMedicines,
          loadingMedicines: controller.loadingMedicines,
          onRefresh: controller.loadMyMedicines,
          onTapSearch: () async {
            await Navigator.pushNamed(context, '/search');
            if (context.mounted) {
              await controller.loadMyMedicines();
            }
          },
          onTapQuickEntry: (entry) => _onTapQuick(context, controller, entry),
          onTapMedicineRow: (row) =>
              _openMedicineDetail(context, controller, row),
          onDeleteMedicine: controller.deleteMedicine,
        );
      },
    );
  }

  /// 药品页顶部"快捷入口"的配置列表。
  List<DrugQuickEntry> _quickEntries(AppLocalizations? l10n) {
    return [
      DrugQuickEntry(
        entryKey: 'search',
        title: l10n?.drugQuickEntrySearchTitle ?? '手动搜索',
        subtitle: l10n?.drugQuickEntrySearchSubtitle ?? '名称/批准文号',
        icon: Icons.search_rounded,
        color: const Color(0xFF0EA5E9),
        routeName: '/search',
      ),
      DrugQuickEntry(
        entryKey: 'scan',
        title: l10n?.drugQuickEntryScanTitle ?? '药物识别',
        subtitle: l10n?.drugQuickEntryScanSubtitle ?? '拍照识别',
        icon: Icons.camera_alt_outlined,
        color: const Color(0xFF10B981),
        routeName: '',
      ),
      DrugQuickEntry(
        entryKey: 'ai',
        title: l10n?.drugQuickEntryAiTitle ?? 'AI 解读',
        subtitle: l10n?.drugQuickEntryAiSubtitle ?? '用法禁忌',
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFF6366F1),
        routeName: '',
      ),
    ];
  }

  /// 根据数据库行数据打开药品详情页。
  ///
  /// 这里会先把数据库行转换为 `MedicineItem`，作为详情页初始对象传入。
  void _openMedicineDetail(
    BuildContext context,
    DrugController controller,
    Map<String, dynamic> row,
  ) {
    final item = controller.toMedicineItem(row);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineDetailPage(initialItem: item),
      ),
    );
  }

  /// 处理顶部"快捷入口"点击。
  ///
  /// 有 routeName 的入口直接走命名路由；
  /// 没有 routeName 的入口根据 entryKey 走自定义逻辑。
  Future<void> _onTapQuick(
    BuildContext context,
    DrugController controller,
    DrugQuickEntry entry,
  ) async {
    if (entry.routeName.isNotEmpty) {
      await Navigator.pushNamed(context, entry.routeName);
      if (context.mounted) {
        await controller.loadMyMedicines();
      }
      return;
    }
    if (entry.entryKey == 'scan') {
      await openMedicineScanFlow(context, mode: ScanEntryMode.actions);
      if (context.mounted) {
        await controller.loadMyMedicines();
      }
      return;
    }
    if (entry.entryKey == 'ai') {
      await _pickAndOpenDetail(context);
      return;
    }
    ToastUtils.instance.show(
      context,
      AppLocalizations.of(context)?.homeFeatureDevelopingToast ?? '功能开发中',
    );
  }

  /// 先打开药品选择器，再进入对应药品的详情页。
  ///
  /// 这是"AI 解读"入口的第一步：先让用户选一款药。
  Future<void> _pickAndOpenDetail(BuildContext context) async {
    final item = await Navigator.of(context).push<MedicineItem>(
      MaterialPageRoute<MedicineItem>(
        builder: (_) => MedicinePickerPage(
          title: AppLocalizations.of(context)?.drugPickerTitle ?? '选择药品',
        ),
      ),
    );
    if (item == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineDetailPage(initialItem: item),
      ),
    );
  }
}
