import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/shared/widgets/responsive_quick_grid.dart';
import 'package:luminous/shared/widgets/shared_quick_entry_card.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'package:luminous/features/drug/presentation/models/drug_models.dart';

/// 药品页"快捷入口"区域 sliver。
class DrugQuickEntrySectionSliver extends StatelessWidget {
  const DrugQuickEntrySectionSliver({
    super.key,
    required this.entries,
    required this.onTapEntry,
  });

  /// 快捷入口数据列表。
  final List<DrugQuickEntry> entries;

  /// 点击快捷入口回调。
  final ValueChanged<DrugQuickEntry> onTapEntry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = SoftBannerPalettes.drugOf(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
            final metrics = ResponsiveQuickGridMetrics.fromWidth(
              constraints.maxWidth,
              textScaleFactor: textScaleFactor,
            );

            return SoftBannerCard(
              palette: palette,
              ornamentKey: 'drug.quick-banner',
              padding: EdgeInsets.all(metrics.sectionPadding),
              borderRadius: BorderRadius.circular(18),
              builder: (context, theme) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.drugQuickSectionTitle ?? '快捷入口',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textColor,
                      ),
                    ),
                    SizedBox(height: metrics.isCompact ? 2 : 3),
                    Text(
                      l10n?.drugQuickSectionSubtitle ?? '把高频操作收在一块，页面会更轻更顺手',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: theme.secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: metrics.isCompact ? 10 : 12),
                    ResponsiveQuickWrap(
                      metrics: metrics,
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final item = entries[index];
                        return SharedQuickEntryCard(
                          icon: item.icon,
                          title: item.title,
                          subtitle: item.subtitle,
                          color: item.color,
                          metrics: metrics,
                          onTap: () => onTapEntry(item),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
