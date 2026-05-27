import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/models/medicine.dart';
import 'package:luminous/utils/toast_utils.dart';

import '../providers/medicine_detail_provider.dart';
import '../widgets/medicine_header_card.dart';
import '../widgets/medicine_ai_card.dart';
import '../widgets/medicine_support_cards.dart';

String pickDetailTextByLocale(
  BuildContext context, {
  required String zh,
  required String en,
}) {
  final languageCode = Localizations.localeOf(context).languageCode.toLowerCase();
  return languageCode.startsWith('zh') ? zh : en;
}

String formatAiTimestamp(BuildContext context, DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}

/// 药品详情页。
class MedicineDetailPage extends ConsumerStatefulWidget {
  const MedicineDetailPage({
    super.key,
    required this.initialItem,
  });

  final MedicineItem initialItem;

  @override
  ConsumerState<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends ConsumerState<MedicineDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(detailProvider.notifier).initialize(widget.initialItem);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(detailProvider);
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
      secondaryAccentColor: Color.lerp(scheme.secondary, scheme.tertiary, 0.55)!,
      child: RefreshIndicator(
        onRefresh: () => _loadDetail(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            MedicineHeaderCard(
              item: state.item,
              loading: state.loadingDetail,
              onRefresh: () => _loadDetail(),
            ),
            const SizedBox(height: 12),
            MedicineInfoCard(item: state.item),
            const SizedBox(height: 12),
            MedicineAiCard(
              hasIdentity: state.item.hasIdentity,
              loading: state.loadingAi,
              result: state.aiResult,
              onFetch: () => _loadAiDetail(),
              onCancel: _cancelAiDetail,
            ),
            const SizedBox(height: 12),
            const MedicineDisclaimerCard(),
          ],
        ),
      ),
    );
  }

  Future<void> _loadDetail() async {
    final error = await ref.read(detailProvider.notifier).loadDetail();
    if (error != null && mounted) {
      ToastUtils.instance.showError(context, error);
    }
  }

  Future<void> _loadAiDetail() async {
    final state = ref.read(detailProvider);
    final error = await ref.read(detailProvider.notifier).loadAiDetail(
      refresh: state.aiResult != null,
    );
    if (!mounted) return;
    if (error == 'aiNoContent') {
      ToastUtils.instance.show(
        context,
        AppLocalizations.of(context)?.medicineDetailAiNoContentToast ??
            'AI接口暂无返回内容',
      );
    } else if (error == 'aiNetworkError') {
      ToastUtils.instance.showError(
        context,
        'network',
        fallback: AppLocalizations.of(context)
                ?.medicineDetailAiNetworkErrorToast ??
            '网络访问失败，请检查网络后重试',
      );
    } else if (error != null) {
      ToastUtils.instance.showError(context, error);
    }
  }

  void _cancelAiDetail() {
    final msg = ref.read(detailProvider.notifier).cancelAiDetail();
    if (mounted) {
      ToastUtils.instance.show(context, msg);
    }
  }
}
