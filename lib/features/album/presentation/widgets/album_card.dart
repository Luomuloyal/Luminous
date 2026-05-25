import 'dart:io';

import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/album/presentation/models/album.dart';
import 'package:luminous/shared/design_tokens/design_tokens.dart';

import 'album_page_widgets.dart';

/// 相册网格中单个条目的 UI 卡片。
class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.entry, required this.onTap});

  final AlbumEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = entry.hasOriginalImage ? scheme.tertiary : scheme.secondary;
    final background = theme.cardTheme.color ?? theme.colorScheme.surface;
    final border = appTintedBorder(
      context,
      accent,
      lightAlpha: 0.12,
      darkAlpha: 0.20,
    );
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);
    final placeholderColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);
    final statusText = entry.hasOriginalImage
        ? (l10n?.albumCardStatusLocalOriginal ?? '本地原图')
        : (l10n?.albumCardStatusThumbnailOnly ?? '仅缩略图');

    return RepaintBoundary(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: isDark
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x120F172A),
                      blurRadius: 14,
                      offset: Offset(0, 7),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.08,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AlbumFileImage(
                        path: entry.thumbnailPath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        cacheWidth: 640,
                        placeholder: Container(
                          color: placeholderColor,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.photo_outlined,
                            color: Color(0xFF94A3B8),
                            size: 34,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0, 0.52, 1],
                                colors: [
                                  Colors.black.withValues(alpha: 0.05),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: AlbumOverlayBadge(
                          icon: entry.hasOriginalImage
                              ? Icons.hd_rounded
                              : Icons.photo_size_select_small_rounded,
                          text: statusText,
                        ),
                      ),
                      if (entry.takenAt > 0)
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: AlbumOverlayBadge(
                            icon: Icons.schedule_rounded,
                            text: formatAlbumDate(entry.takenAt),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.displayName,
                      maxLines: 3,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: AppTypography.cardTitle,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        height: 1.24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.approvalNo.trim().isEmpty
                          ? (l10n?.albumCardSubtitleTapForDetail ??
                                '点击查看识别结果与药品详情')
                          : (l10n?.albumApprovalNoPrefix(entry.approvalNo) ??
                                '批准文号: ${entry.approvalNo}'),
                      maxLines: 3,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 11.8,
                        color: subtitleColor,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.hasOriginalImage
                          ? (l10n?.albumCardTagRescannable ?? '可再次识别')
                          : (l10n?.albumCardTagLightRecord ?? '当前为轻量记录'),
                      maxLines: 2,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 11.8,
                        color: accent,
                        fontWeight: FontWeight.w800,
                        height: 1.24,
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

/// 以本地文件路径展示图片。
class AlbumFileImage extends StatelessWidget {
  const AlbumFileImage({
    super.key,
    required this.path,
    required this.fit,
    required this.placeholder,
    this.width,
    this.height,
    this.cacheWidth,
  });

  final String path;
  final BoxFit fit;
  final Widget placeholder;
  final double? width;
  final double? height;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final normalizedPath = path.trim();
    if (normalizedPath.isEmpty) {
      return placeholder;
    }

    return Image.file(
      File(normalizedPath),
      fit: fit,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
