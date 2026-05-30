import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

/// 今日页。
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < 600
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);
    final layout = AppLayoutTokens.resolve(width);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvasSoft,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColorTokens.canvas,
            AppColorTokens.canvasSoft,
          ],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: layout.pageHorizontalPadding,
                vertical: width < 600
                    ? AppSpacingTokens.x4l
                    : AppSpacingTokens.x5l,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight -
                      ((width < 600
                              ? AppSpacingTokens.x4l
                              : AppSpacingTokens.x5l) *
                          2),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          layout.maxContentWidth * (width < 600 ? 1 : 0.54),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: surface.canvas,
                        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
                        border: Border.all(color: surface.hairline),
                        boxShadow: AppShadowTokens.level4,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(layout.cardPaddingLarge),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: width < 600 ? 72 : 84,
                              height: width < 600 ? 72 : 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                    AppColorTokens.gradientDevelopStart,
                                    AppColorTokens.gradientDevelopEnd,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.wb_sunny_rounded,
                                size: width < 600 ? 34 : 38,
                                color: AppColorTokens.onPrimary,
                              ),
                            ),
                            SizedBox(height: layout.componentGap),
                            Text(
                              '今日',
                              style: typography.displayLg.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacingTokens.xs),
                            Text(
                              '新的首页将从这里开始重建：先完成响应式视觉系统，再逐步接入喝水、提醒、健康快照和 Lumi 建议。',
                              style: typography.bodyMd.copyWith(
                                color: surface.body,
                              ),
                            ),
                            const SizedBox(height: AppSpacingTokens.lg),
                            Wrap(
                              spacing: AppSpacingTokens.sm,
                              runSpacing: AppSpacingTokens.sm,
                              children: const <Widget>[
                                _TodayPreviewChip(label: '喝水追踪'),
                                _TodayPreviewChip(label: '用药提醒'),
                                _TodayPreviewChip(label: '健康快照'),
                                _TodayPreviewChip(label: '饮食建议'),
                                _TodayPreviewChip(label: '环境提醒'),
                                _TodayPreviewChip(label: 'Lumi 建议'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TodayPreviewChip extends StatelessWidget {
  const _TodayPreviewChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < 600
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.sm,
        vertical: AppSpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: surface.canvasSoft,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pillSm),
        border: Border.all(color: surface.hairline),
      ),
      child: Text(
        label,
        style: typography.bodySm.copyWith(color: scheme.onSurface),
      ),
    );
  }
}
