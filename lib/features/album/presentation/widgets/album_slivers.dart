import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/design_tokens/design_tokens.dart';

import 'album_page_widgets.dart';

/// 相册页顶部 header sliver。
class AlbumHeaderSliver extends StatelessWidget {
  const AlbumHeaderSliver({
    super.key,
    required this.palette,
    required this.loading,
    required this.entryCount,
    required this.originalCount,
    required this.isLoggedIn,
  });

  final SoftBannerPalette palette;
  final bool loading;
  final int entryCount;
  final int originalCount;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: SoftBannerCard(
          palette: palette,
          ornamentKey: 'album.banner',
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
                        Icons.photo_library_outlined,
                        color: theme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.albumHeaderTitle ?? '识别相册',
                            style: TextStyle(
                              color: theme.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entryCount == 0
                                ? (l10n?.albumHeaderSubtitleEmpty ??
                                      '新的识别记录会自动归档到这里')
                                : (l10n?.albumHeaderSubtitleNonEmpty ??
                                      '本地保存原图，云端仅同步缩略图和识别结果'),
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
                    if (loading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.accentColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AlbumInfoChip(
                      icon: Icons.grid_view_rounded,
                      text: entryCount == 0
                          ? (l10n?.albumHeaderChipWaitingFirstRecord ??
                                '等待第一条记录')
                          : (l10n?.albumHeaderChipRecordCount(entryCount) ??
                                '$entryCount 条记录'),
                      backgroundColor: theme.surfaceColor,
                      foregroundColor: theme.surfaceTextColor,
                    ),
                    AlbumInfoChip(
                      icon: Icons.hd_rounded,
                      text: originalCount == 0
                          ? (l10n?.albumHeaderChipNoOriginal ?? '暂无原图归档')
                          : (l10n?.albumHeaderChipOriginalCount(
                                  originalCount,
                                ) ??
                                pickByCurrentLocale(
                                  context,
                                  zh: '原图 $originalCount 条',
                                  en: '$originalCount originals',
                                )),
                      backgroundColor: theme.surfaceColor,
                      foregroundColor: theme.surfaceTextColor,
                    ),
                    AlbumInfoChip(
                      icon: isLoggedIn
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_off_rounded,
                      text: isLoggedIn
                          ? (l10n?.albumHeaderChipCloudSync ?? '云端轻同步')
                          : (l10n?.albumHeaderChipLocalOnly ?? '当前仅本地保存'),
                      backgroundColor: theme.surfaceColor,
                      foregroundColor: theme.surfaceTextColor,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 相册页错误提示 banner sliver。
class AlbumErrorBannerSliver extends StatelessWidget {
  const AlbumErrorBannerSliver({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: AppSectionCard(
          accentColor: scheme.error,
          secondaryColor: Color.lerp(scheme.error, scheme.secondary, 0.24)!,
          ornamentKey: 'album.error',
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          radius: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Icon(Icons.warning_amber_rounded, color: scheme.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.albumErrorTitle ?? '相册同步出了点问题',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: AppTypography.tab,
                        height: 1.45,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.albumErrorHint ?? '下拉刷新后会再次尝试读取本地记录',
                      style: TextStyle(
                        fontSize: 11.8,
                        color: scheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 相册页空状态占位 sliver。
class AlbumEmptySliver extends StatelessWidget {
  const AlbumEmptySliver({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: AppSectionCard(
          accentColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.35)!,
          secondaryColor: Color.lerp(scheme.primary, scheme.tertiary, 0.35)!,
          ornamentKey: 'album.empty',
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 36),
          radius: 18,
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_outlined,
                  size: 28,
                  color: scheme.secondary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n?.albumEmptyTitle ?? '暂无记录',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.albumEmptySubtitle ?? '去"药物识别"拍照后会自动保存到这里',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: subtitleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  AlbumInfoChip(
                    icon: Icons.photo_camera_back_outlined,
                    text: l10n?.albumEmptyChipAutoArchive ?? '拍照后自动归档',
                    backgroundColor: themeChipColor(context, scheme.primary),
                    foregroundColor: scheme.primary,
                  ),
                  AlbumInfoChip(
                    icon: Icons.lock_outline_rounded,
                    text: l10n?.albumEmptyChipLocalOnly ?? '原图仅保存在本机',
                    backgroundColor: themeChipColor(context, scheme.secondary),
                    foregroundColor: scheme.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 相册页未登录提示 banner sliver。
class AlbumLoginBannerSliver extends StatelessWidget {
  const AlbumLoginBannerSliver({super.key, required this.onTapLogin});

  final VoidCallback onTapLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = Color.lerp(scheme.secondary, scheme.primary, 0.3)!;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: AppSectionCard(
          accentColor: accent,
          secondaryColor: scheme.tertiary,
          ornamentKey: 'album.login',
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          radius: 16,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 430;
              final info = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.albumLoginTitle ?? '开启轻量同步',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n?.albumLoginSubtitle ?? '登录后可把缩略图和识别结果同步到云端，原图继续留在本机',
                    style: TextStyle(
                      fontSize: 12.8,
                      height: 1.45,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AlbumInfoChip(
                        icon: Icons.image_not_supported_outlined,
                        text: l10n?.albumLoginChipNoUpload ?? '原图不上传',
                        backgroundColor: themeChipColor(context, accent),
                        foregroundColor: accent,
                      ),
                      AlbumInfoChip(
                        icon: Icons.cloud_upload_outlined,
                        text: l10n?.albumLoginChipLightweightSync ?? '只同步轻量结果',
                        backgroundColor: themeChipColor(
                          context,
                          scheme.primary,
                        ),
                        foregroundColor: scheme.primary,
                      ),
                    ],
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: info),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: onTapLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                      ),
                      child: Text(
                        l10n?.albumLoginActionSyncAfterLogin ?? '登录后同步',
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Icon(Icons.lock_outline_rounded, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: info),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: onTapLogin,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(96, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                    ),
                    child: Text(l10n?.albumLoginActionLogin ?? '登录'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
