import 'dart:io';

import 'package:flutter/material.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/soft_banner.dart';
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
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            AlbumHeaderSliver(palette: headerPalette, loading: loading),
            if (!isLoggedIn) AlbumLoginBannerSliver(onTapLogin: onTapLogin),
            if (error != null) AlbumErrorBannerSliver(text: error!),
            if (entries.isEmpty && !loading)
              const AlbumEmptySliver()
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final e = entries[index];
                    return AlbumCard(entry: e, onTap: () => onTapEntry(e));
                  },
                ),
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
  });

  /// 顶部横幅配色。
  final SoftBannerPalette palette;

  /// 是否正在加载，用于显示右侧进度圈。
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: SoftBannerCard(
          palette: palette,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          builder: (context, theme) {
            return Row(
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
                        '识别相册',
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '本地保存原图，云端仅同步轻量结果',
                        style: TextStyle(
                          color: theme.secondaryTextColor,
                          fontSize: 13,
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
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w700,
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: AppSectionCard(
          accentColor: Color(0xFFF9E4AF),
          secondaryColor: Color(0xFFD9EAFF),
          padding: const EdgeInsets.fromLTRB(16, 44, 16, 44),
          radius: 18,
          child: Column(
            children: [
              const Icon(
                Icons.photo_outlined,
                size: 44,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 10),
              Text(
                '暂无记录',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '去“药物识别”拍照后会自动保存到这里',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: subtitleColor,
                  fontWeight: FontWeight.w600,
                ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF475569);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: AppSectionCard(
          accentColor: const Color(0xFFF9E4AF),
          secondaryColor: const Color(0xFFD9EAFF),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          radius: 16,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '登录后可把缩略图和识别结果同步到云端',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onTapLogin,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(78, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('登录'),
              ),
            ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF162033) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);
    final placeholderColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);
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
                      color: Color(0x0F000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
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
                  child: AlbumFileImage(
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.approvalNo.trim().isEmpty
                          ? '点击查看详情'
                          : '批准文号: ${entry.approvalNo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: subtitleColor,
                        fontWeight: FontWeight.w600,
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
    final hasOriginalImage = entry.hasOriginalImage;

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
              decoration: const BoxDecoration(
                color: Color(0xFFF3F7FB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    entry.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.approvalNo.trim().isEmpty
                        ? '暂无批准文号'
                        : '批准文号: ${entry.approvalNo}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!hasOriginalImage) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Text(
                        '当前记录仅保存缩略图，无法高质量重识别。',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: Color(0xFF92400E),
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
                      backgroundColor: const Color(0xFF0EA5E9),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('查看药品详情'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    key: const ValueKey('album_preview_rescan_button'),
                    onPressed: onRescan,
                    style: FilledButton.styleFrom(
                      foregroundColor: onRescan == null
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF0F172A),
                      backgroundColor: onRescan == null
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFFEAF6FF),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('再次识别'),
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
