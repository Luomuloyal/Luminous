import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../pages/medicine_detail_page.dart';

/// 详情页底部免责声明卡片。
class MedicineDisclaimerCard extends StatelessWidget {
  /// 创建详情页底部免责声明卡片。
  const MedicineDisclaimerCard({super.key});

  /// 构建免责声明卡片 UI。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MedicineSurfaceCard(
      title: l10n?.medicineDetailSafetyTitle ?? '安全提示',
      accentColor: Theme.of(context).colorScheme.tertiary,
      secondaryColor: Theme.of(context).colorScheme.secondary,
      ornamentKey: 'medicine.disclaimer',
      child: Text(
        l10n?.medicineDetailSafetyDisclaimer ??
            pickDetailTextByLocale(
              context,
              zh: '本应用信息仅用于健康科普与辅助查询，不能替代医生诊断与处方。如有不适或正在用药，请遵医嘱并咨询专业人士。',
              en: 'This app provides health education and supportive lookup only, and does not replace diagnosis or prescriptions. If you feel unwell or are taking medication, follow medical advice and consult professionals.',
            ),
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

/// 详情页统一使用的白色表面卡片容器。
///
/// 用于保持"基础信息/AI 解读/免责声明"等区域的视觉一致性。
class MedicineSurfaceCard extends StatelessWidget {
  /// 创建详情页统一使用的白色表面卡片容器。
  const MedicineSurfaceCard({
    super.key,
    required this.title,
    required this.child,
    required this.accentColor,
    required this.secondaryColor,
    required this.ornamentKey,
    this.trailing,
    this.titleFontSize = 15.5,
  });

  /// 卡片标题。
  final String title;

  /// 卡片主体内容。
  final Widget child;

  final Color accentColor;
  final Color secondaryColor;
  final String ornamentKey;

  /// 右上角 trailing 区域（可选），例如按钮。
  final Widget? trailing;
  final double titleFontSize;

  /// 构建表面卡片 UI。
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: accentColor,
      secondaryColor: secondaryColor,
      ornamentKey: ornamentKey,
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactHeader =
                trailing != null && constraints.maxWidth < 420;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (compactHeader) ...[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  trailing!,
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 12),
                        trailing!,
                      ],
                    ],
                  ),
                const SizedBox(height: 10),
                child,
              ],
            );
          },
        ),
      ),
    );
  }
}
