import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/models/medicine.dart';

import 'medicine_support_cards.dart';

/// 详情页顶部基础信息卡片。
///
/// 展示药品名称、规格信息与关键身份字段（批准文号/药品编码），并提供"刷新"按钮。
class MedicineHeaderCard extends StatelessWidget {
  /// 创建详情页顶部基础信息卡片。
  const MedicineHeaderCard({
    super.key,
    required this.item,
    required this.loading,
    required this.onRefresh,
  });

  /// 当前药品对象。
  final MedicineItem item;

  /// 是否正在加载基础详情（用于禁用刷新并展示进度）。
  final bool loading;

  /// 点击刷新回调。
  final VoidCallback onRefresh;

  /// 构建顶部基础信息卡片 UI。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: scheme.primary,
      secondaryColor: Color.lerp(scheme.secondary, scheme.tertiary, 0.5)!,
      ornamentKey: 'medicine.header.compact',
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.tonalIcon(
              onPressed: loading ? null : onRefresh,
              icon: loading
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                loading
                    ? (l10n?.medicineDetailHeaderRefreshing ?? '更新中')
                    : (l10n?.medicineDetailHeaderRefresh ?? '刷新'),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(92, 38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 详情页"基础信息"卡片。
///
/// 展示药品的详细信息字段（产品名称、剂型、规格、批准文号、上市许可持有人、
/// 生产单位、药品编码、药品编码备注）。
class MedicineInfoCard extends StatelessWidget {
  /// 创建详情页"基础信息"卡片。
  const MedicineInfoCard({super.key, required this.item});

  /// 当前药品对象。
  final MedicineItem item;

  /// 构建基础信息卡片 UI。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MedicineSurfaceCard(
      title: l10n?.medicineDetailInfoTitle ?? '基础信息',
      accentColor: Theme.of(context).colorScheme.primary,
      secondaryColor: Theme.of(context).colorScheme.secondary,
      ornamentKey: 'medicine.info',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicineInfoRow(
            label: l10n?.medicineDetailLabelProductName ?? '产品名称',
            value: item.productName,
          ),
          MedicineInfoRow(
            label: l10n?.medicineDetailLabelDosageForm ?? '剂型',
            value: item.dosageForm,
          ),
          MedicineInfoRow(
            label: l10n?.medicineDetailLabelSpecification ?? '规格',
            value: item.specification,
          ),
          MedicineInfoRow(
            label: l10n?.medicineDetailLabelApprovalNo ?? '批准文号',
            value: item.approvalNo,
          ),
          MedicineInfoRow(
            label:
                l10n?.medicineDetailLabelMarketingAuthorizationHolder ??
                '上市许可持有人',
            value: item.marketingAuthorizationHolder,
          ),
          MedicineInfoRow(
            label: l10n?.medicineDetailLabelManufacturer ?? '生产单位',
            value: item.manufacturer,
          ),
          MedicineInfoRow(
            label: l10n?.medicineDetailLabelDrugCode ?? '药品编码',
            value: item.drugCode,
          ),
          MedicineInfoRow(
            label: l10n?.medicineDetailLabelDrugCodeRemark ?? '药品编码备注',
            value: item.drugCodeRemark,
          ),
        ],
      ),
    );
  }
}

/// "基础信息"卡片中的一行字段展示。
class MedicineInfoRow extends StatelessWidget {
  /// 创建"基础信息"卡片中的单行字段展示。
  const MedicineInfoRow({super.key, required this.label, required this.value});

  /// 字段名称。
  final String label;

  /// 字段值。
  final String value;

  /// 构建字段行 UI。
  @override
  Widget build(BuildContext context) {
    /// 经过兜底处理的展示文本。
    final text = value.trim().isEmpty ? '-' : value.trim();
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 320;
        if (compact) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.2,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
