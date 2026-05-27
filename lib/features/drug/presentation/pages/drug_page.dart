import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/medicine_picker/presentation/medicine_picker.dart';
import 'package:luminous/features/scan/presentation/scan.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/models/medicine.dart';
import 'package:luminous/utils/toast_utils.dart';

import '../models/drug_models.dart';
import '../providers/drug_provider.dart';
import '../widgets/drug_page_widgets.dart';
import 'medicine_detail_page.dart';

/// 药品页。
///
/// 页面上半部分提供药品相关快捷入口，下半部分展示本地"我的药品"列表。
class DrugPage extends ConsumerWidget {
  const DrugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(drugProvider);
    final l10n = AppLocalizations.of(context);

    return DrugPageLayout(
      quickEntries: _quickEntries(l10n),
      myMedicines: state.myMedicines,
      loadingMedicines: state.loadingMedicines,
      onRefresh: () => _loadMyMedicines(ref, context),
      onTapSearch: () => _onTapSearch(context, ref),
      onTapQuickEntry: (entry) => _onTapQuick(context, ref, entry),
      onTapMedicineRow: (row) => _openMedicineDetail(context, ref, row),
      onDeleteMedicine: (row) => _deleteMedicine(context, ref, row),
    );
  }

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

  Future<void> _loadMyMedicines(WidgetRef ref, BuildContext context) async {
    final error = await ref.read(drugProvider.notifier).loadMyMedicines();
    if (error != null && context.mounted) {
      _showError(context, error);
    }
  }

  Future<void> _onTapSearch(BuildContext context, WidgetRef ref) async {
    await context.push('/search');
    if (context.mounted) {
      final error = await ref.read(drugProvider.notifier).loadMyMedicines();
      if (error != null && context.mounted) {
        _showError(context, error);
      }
    }
  }

  void _openMedicineDetail(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> row,
  ) {
    final item = ref.read(drugProvider.notifier).toMedicineItem(row);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineDetailPage(initialItem: item),
      ),
    );
  }

  Future<void> _onTapQuick(
    BuildContext context,
    WidgetRef ref,
    DrugQuickEntry entry,
  ) async {
    if (entry.routeName.isNotEmpty) {
      await context.push(entry.routeName);
      if (context.mounted) {
        final error = await ref.read(drugProvider.notifier).loadMyMedicines();
        if (error != null && context.mounted) {
          _showError(context, error);
        }
      }
      return;
    }
    if (entry.entryKey == 'scan') {
      await openMedicineScanFlow(context, mode: ScanEntryMode.actions);
      if (context.mounted) {
        final error = await ref.read(drugProvider.notifier).loadMyMedicines();
        if (error != null && context.mounted) {
          _showError(context, error);
        }
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

  Future<void> _deleteMedicine(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> row,
  ) async {
    final error = await ref.read(drugProvider.notifier).deleteMedicine(row);
    if (!context.mounted) return;
    if (error != null) {
      ToastUtils.instance.show(
        context,
        AppLocalizations.of(context)?.drugDeleteFailedToast ?? '删除失败',
      );
    } else {
      ToastUtils.instance.show(
        context,
        AppLocalizations.of(context)?.drugDeletedToast ?? '已从我的药品中移除',
      );
    }
  }

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

  void _showError(BuildContext context, String error) {
    ToastUtils.instance.showError(context, error);
  }
}
