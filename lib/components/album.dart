import 'dart:io';

import 'package:flutter/material.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/viewmodels/album.dart';

/// 相册页（Album）的大块 UI 组件集合。
///
/// 页面层负责本地数据加载，这里负责具体的 UI 结构与展示样式。
class AlbumPage extends StatelessWidget {
  const AlbumPage({
    super.key,
    required this.headerPalette,
    required this.loading,
    required this.isLoggedIn,
    required this.error,
    required this.entries,
    required this.onRefresh,
    required this.onTapLogin,
    required this.onTapEntry,
  });

  /// 顶部横幅配色。
  final SoftBannerPalette headerPalette;

  /// 是否正在加载数据。
  final bool loading;

  /// 当前是否已登录（用于决定是否展示登录引导 banner）。
  final bool isLoggedIn;

  /// 当前错误信息（非空时展示错误 banner）。
  final String? error;

  /// 要展示的相册条目列表。
  final List<AlbumEntry> entries;

  /// 下拉刷新回调。
  final Future<void> Function() onRefresh;

  /// 点击“登录”按钮回调。
  final VoidCallback onTapLogin;

  /// 点击某个条目回调。
  final ValueChanged<AlbumEntry> onTapEntry;

  @override
  Widget build(BuildContext context) {
    final originalCount = entries
        .where((entry) => entry.hasOriginalImage)
        .length;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            AlbumHeaderSliver(
              palette: headerPalette,
              loading: loading,
              entryCount: entries.length,
              originalCount: originalCount,
              isLoggedIn: isLoggedIn,
            ),
            if (!isLoggedIn) AlbumLoginBannerSliver(onTapLogin: onTapLogin),
            if (error != null) AlbumErrorBannerSliver(text: error!),
            if (entries.isEmpty && !loading)
              const AlbumEmptySliver()
            else
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final crossAxisCount = width >= 1100
                      ? 4
                      : (width >= 760 ? 3 : 2);
                  final spacing = width >= 760 ? 12.0 : 10.0;
                  final aspectRatio = width >= 760 ? 0.96 : 0.90;

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return AlbumCard(
                          entry: entry,
                          onTap: () => onTapEntry(entry),
                        );
                      },
                    ),
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        ),
      ),
    );
  }
}

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

  /// 顶部横幅配色。
  final SoftBannerPalette palette;

  /// 是否正在加载，用于显示右侧进度圈。
  final bool loading;

  /// 当前记录总数。
  final int entryCount;

  /// 当前保留了本地原图的记录数。
  final int originalCount;

  /// 当前是否已登录。
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
                    _AlbumInfoChip(
                      icon: Icons.grid_view_rounded,
                      text: entryCount == 0
                          ? (l10n?.albumHeaderChipWaitingFirstRecord ??
                                '等待第一条记录')
                          : (l10n?.albumHeaderChipRecordCount(entryCount) ??
                                '$entryCount 条记录'),
                      backgroundColor: theme.surfaceColor,
                      foregroundColor: theme.surfaceTextColor,
                    ),
                    _AlbumInfoChip(
                      icon: Icons.hd_rounded,
                      text: originalCount == 0
                          ? (l10n?.albumHeaderChipNoOriginal ?? '暂无原图归档')
                          : (l10n?.albumHeaderChipOriginalCount(
                                  originalCount,
                                ) ??
                                AppI18nText.pick(
                                  zh: '原图 $originalCount 条',
                                  en: '$originalCount originals',
                                )),
                      backgroundColor: theme.surfaceColor,
                      foregroundColor: theme.surfaceTextColor,
                    ),
                    _AlbumInfoChip(
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

  /// 要展示的错误文本。
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
                  borderRadius: BorderRadius.circular(12),
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
                        fontSize: 12.5,
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
                l10n?.albumEmptySubtitle ?? '去“药物识别”拍照后会自动保存到这里',
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
                  _AlbumInfoChip(
                    icon: Icons.photo_camera_back_outlined,
                    text: l10n?.albumEmptyChipAutoArchive ?? '拍照后自动归档',
                    backgroundColor: themeChipColor(context, scheme.primary),
                    foregroundColor: scheme.primary,
                  ),
                  _AlbumInfoChip(
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

  /// 点击登录按钮回调。
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
                      _AlbumInfoChip(
                        icon: Icons.image_not_supported_outlined,
                        text: l10n?.albumLoginChipNoUpload ?? '原图不上传',
                        backgroundColor: themeChipColor(context, accent),
                        foregroundColor: accent,
                      ),
                      _AlbumInfoChip(
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
                            borderRadius: BorderRadius.circular(12),
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
                          borderRadius: BorderRadius.circular(14),
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
                      borderRadius: BorderRadius.circular(12),
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
                        borderRadius: BorderRadius.circular(14),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
                        child: _AlbumOverlayBadge(
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
                          child: _AlbumOverlayBadge(
                            icon: Icons.schedule_rounded,
                            text: _formatAlbumDate(entry.takenAt),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.8,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      entry.approvalNo.trim().isEmpty
                          ? (l10n?.albumCardSubtitleTapForDetail ??
                                '点击查看识别结果与药品详情')
                          : (l10n?.albumApprovalNoPrefix(entry.approvalNo) ??
                                '批准文号: ${entry.approvalNo}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.8,
                        color: subtitleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.hasOriginalImage
                          ? (l10n?.albumCardTagRescannable ?? '可再次识别')
                          : (l10n?.albumCardTagLightRecord ?? '当前为轻量记录'),
                      style: TextStyle(
                        fontSize: 11.8,
                        color: accent,
                        fontWeight: FontWeight.w800,
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

class _AlbumInfoChip extends StatelessWidget {
  const _AlbumInfoChip({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 12.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumOverlayBadge extends StatelessWidget {
  const _AlbumOverlayBadge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

Color themeChipColor(BuildContext context, Color accent) {
  final theme = Theme.of(context);
  return Color.alphaBlend(
    accent.withValues(alpha: theme.brightness == Brightness.dark ? 0.16 : 0.10),
    theme.cardTheme.color ?? theme.colorScheme.surface,
  );
}

String _formatAlbumDate(int takenAt) {
  final date = DateTime.fromMillisecondsSinceEpoch(takenAt);
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month/$day';
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
    final isDark = theme.brightness == Brightness.dark;
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
                      _AlbumInfoChip(
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
                        _AlbumInfoChip(
                          icon: Icons.schedule_rounded,
                          text:
                              l10n?.albumPreviewTagRecordedAt(
                                _formatAlbumDate(entry.takenAt),
                              ) ??
                              AppI18nText.pick(
                                zh: '记录于 ${_formatAlbumDate(entry.takenAt)}',
                                en: 'Recorded at ${_formatAlbumDate(entry.takenAt)}',
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
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      decoration: BoxDecoration(
                        color: appTintedSurface(
                          context,
                          scheme.secondary,
                          lightAlpha: 0.12,
                          darkAlpha: 0.20,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: appTintedBorder(
                            context,
                            scheme.secondary,
                            lightAlpha: 0.18,
                            darkAlpha: 0.24,
                          ),
                        ),
                      ),
                      child: Text(
                        l10n?.albumPreviewLowQualityNotice ??
                            '当前记录仅保存缩略图，无法高质量重识别。',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: isDark
                              ? scheme.onSurface
                              : const Color(0xFF7C5A19),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton(
                    key: const ValueKey('album_preview_detail_button'),
                    onPressed: onOpenDetail,
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryActionColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n?.albumPreviewOpenDetailAction ?? '查看药品详情'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    key: const ValueKey('album_preview_rescan_button'),
                    onPressed: onRescan,
                    style: FilledButton.styleFrom(
                      foregroundColor: onRescan == null
                          ? scheme.onSurfaceVariant.withValues(alpha: 0.76)
                          : tonalColor,
                      backgroundColor: onRescan == null
                          ? theme.cardTheme.color?.withValues(alpha: 0.82) ??
                                scheme.surfaceContainerHighest
                          : themeChipColor(context, tonalColor),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n?.albumPreviewRescanAction ?? '再次识别'),
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
