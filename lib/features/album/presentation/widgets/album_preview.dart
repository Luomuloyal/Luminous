import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/viewmodels/album.dart';

import 'album_page_widgets.dart';
import 'album_card.dart';

/// 相册预览页。
class AlbumPreviewPage extends StatelessWidget {
  const AlbumPreviewPage({
    super.key,
    required this.entry,
    required this.onOpenDetail,
    required this.onRescan,
  });

  final AlbumEntry entry;
  final VoidCallback onOpenDetail;
  final VoidCallback? onRescan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasOriginalImage = entry.hasOriginalImage;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final panelColor = theme.cardTheme.color ?? scheme.surface;
    final titleColor = scheme.onSurface;
    final subtitleColor = scheme.onSurfaceVariant;
    final primaryActionColor = scheme.primary;
    final tonalColor = Color.lerp(scheme.secondary, scheme.tertiary, 0.28)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(entry.displayName),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: AlbumFileImage(
                    path: entry.previewPath,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    placeholder: const Icon(
                      Icons.photo_outlined,
                      size: 72,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: BoxDecoration(
                color: panelColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    entry.displayName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.approvalNo.trim().isEmpty
                        ? (l10n?.albumPreviewNoApprovalNo ?? '暂无批准文号')
                        : (l10n?.albumApprovalNoPrefix(entry.approvalNo) ??
                              '批准文号: ${entry.approvalNo}'),
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AlbumInfoChip(
                        icon: hasOriginalImage
                            ? Icons.hd_rounded
                            : Icons.photo_size_select_small_rounded,
                        text: hasOriginalImage
                            ? (l10n?.albumPreviewTagOriginalRescannable ??
                                  '本地原图可重识别')
                            : (l10n?.albumPreviewTagThumbnailOnly ??
                                  '当前仅保存缩略图'),
                        backgroundColor: themeChipColor(
                          context,
                          hasOriginalImage ? tonalColor : scheme.secondary,
                        ),
                        foregroundColor: hasOriginalImage
                            ? tonalColor
                            : scheme.secondary,
                      ),
                      if (entry.takenAt > 0)
                        AlbumInfoChip(
                          icon: Icons.schedule_rounded,
                          text:
                              l10n?.albumPreviewTagRecordedAt(
                                formatAlbumDate(entry.takenAt),
                              ) ??
                              pickByCurrentLocale(
                                context,
                                zh: '记录于 ${formatAlbumDate(entry.takenAt)}',
                                en: 'Recorded at ${formatAlbumDate(entry.takenAt)}',
                              ),
                          backgroundColor: themeChipColor(
                            context,
                            scheme.primary,
                          ),
                          foregroundColor: scheme.primary,
                        ),
                    ],
                  ),
                  if (!hasOriginalImage) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color: appTintedSurface(
                          context,
                          scheme.secondary,
                          lightAlpha: 0.06,
                          darkAlpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: appTintedBorder(
                            context,
                            scheme.secondary,
                            lightAlpha: 0.14,
                            darkAlpha: 0.24,
                          ),
                        ),
                      ),
                      child: Text(
                        l10n?.albumPreviewLowQualityNotice ?? '当前记录仅保存缩略图，无法高质量重识别。',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: onOpenDetail,
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryActionColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            l10n?.albumPreviewOpenDetailAction ?? '查看药品详情',
                          ),
                        ),
                      ),
                      if (onRescan != null) ...[
                        const SizedBox(width: 10),
                        FilledButton.tonal(
                          onPressed: onRescan,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(120, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            l10n?.albumPreviewRescanAction ?? '再次识别',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
