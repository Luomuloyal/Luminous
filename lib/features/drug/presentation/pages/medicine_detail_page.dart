import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/viewmodels/medicine.dart';

import '../controllers/medicine_detail_controller.dart';
import '../widgets/medicine_header_card.dart';
import '../widgets/medicine_ai_card.dart';
import '../widgets/medicine_support_cards.dart';

String pickDetailTextByLocale(
  BuildContext context, {
  required String zh,
  required String en,
}) {
  final languageCode = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase();
  return languageCode.startsWith('zh') ? zh : en;
}

String formatAiTimestamp(BuildContext context, DateTime? value) {
  if (value == null) {
    return '';
  }
  final local = value.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}

// 药品详情页
//
// 页面职责：
// - 展示基础信息（来自 MySQL 查询）
// - 按需获取 AI 详细信息：点击"获取更详细信息"调用后端 /medicine-ai-detail
//
// 设计注意：
// - 详情与 AI 是两个请求：detail 用于补齐基础信息，ai-detail 用于后续扩展
// - AI 内容是高风险区域：后续接入时应加免责声明、过滤与超时策略（后端更关键）
/// 药品详情页。
///
/// 用于展示基础药品信息，并在用户需要时进一步拉取 AI 解读内容。
class MedicineDetailPage extends StatelessWidget {
  /// 创建药品详情页，并指定初始药品对象。
  ///
  /// 初始对象可能来自列表点击，字段不一定完整，页面会在 `initState` 再拉取一次详情补齐。
  const MedicineDetailPage({
    super.key,
    required this.initialItem,
    this.controller,
  });

  /// 详情页的初始药品对象。
  ///
  /// 通常来自列表页/搜索页的点击结果，字段可能不完整，页面会再调用详情接口补齐。
  final MedicineItem initialItem;
  final MedicineDetailController? controller;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MedicineDetailController>(
      init: controller ?? MedicineDetailController(initialItem: initialItem),
      global: false,
      builder: (controller) {
        final l10n = AppLocalizations.of(context);
        final scheme = Theme.of(context).colorScheme;

        return AppCanvasPageScaffold(
          appBar: AppBar(
            toolbarHeight: 44,
            title: Text(
              l10n?.medicineDetailPageTitle ?? '药品详情',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            foregroundColor: const Color(0xFF0F172A),
          ),
          appBarSpacing: 30,
          accentColor: scheme.primary,
          secondaryAccentColor: Color.lerp(
            scheme.secondary,
            scheme.tertiary,
            0.55,
          )!,
          child: RefreshIndicator(
            onRefresh: controller.loadDetail,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                MedicineHeaderCard(
                  item: controller.item,
                  loading: controller.loadingDetail,
                  onRefresh: controller.loadDetail,
                ),
                const SizedBox(height: 12),
                MedicineInfoCard(item: controller.item),
                const SizedBox(height: 12),
                MedicineAiCard(
                  hasIdentity: controller.item.hasIdentity,
                  loading: controller.loadingAi,
                  result: controller.aiResult,
                  onFetch: () => controller.loadAiDetail(
                    refresh: controller.aiResult != null,
                  ),
                  onCancel: controller.cancelAiDetail,
                ),
                const SizedBox(height: 12),
                const MedicineDisclaimerCard(),
              ],
            ),
          ),
        );
      },
    );
  }
}
