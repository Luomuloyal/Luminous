import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/viewmodels/album.dart';

/// 相册页（Album）的大块 UI 组件集合。
///
/// 页面层负责数据加载与合并（本地 + 远端），这里负责具体的 UI 结构与展示样式。
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
      child: Container(
        color: const Color(0xFFF3F7FB),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                    color: Colors.white.withValues(alpha: 0.86),
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
                        '同步缩略图与识别结果',
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
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 44),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Column(
            children: [
              Icon(Icons.photo_outlined, size: 44, color: Color(0xFF94A3B8)),
              SizedBox(height: 10),
              Text(
                '暂无记录',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6),
              Text(
                '去“药物识别”拍照后会自动同步到这里',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
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
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
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
              const Expanded(
                child: Text(
                  '登录后可同步识别记录并跨设备查看缩略图',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Color(0xFF475569),
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
    return RepaintBoundary(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
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
                  child: Base64MemoryImage(
                    base64: entry.thumbBase64,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    cacheWidth: 640,
                    placeholder: Container(
                      color: const Color(0xFFF1F5F9),
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
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.approvalNo.trim().isEmpty
                          ? '点击查看详情'
                          : '批准文号: ${entry.approvalNo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
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

/// 按需解码 base64 并以 `Image.memory` 展示。
class Base64MemoryImage extends StatefulWidget {
  const Base64MemoryImage({
    super.key,
    required this.base64,
    required this.fit,
    required this.placeholder,
    this.width,
    this.height,
    this.cacheWidth,
  });

  final String base64;
  final BoxFit fit;
  final Widget placeholder;
  final double? width;
  final double? height;
  final int? cacheWidth;

  @override
  State<Base64MemoryImage> createState() => _Base64MemoryImageState();
}

class _Base64MemoryImageState extends State<Base64MemoryImage> {
  Uint8List? _bytes;
  String _decodedSource = '';

  @override
  void initState() {
    super.initState();
    _refreshDecodedBytes();
  }

  @override
  void didUpdateWidget(covariant Base64MemoryImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.base64 != widget.base64) {
      _refreshDecodedBytes();
    }
  }

  void _refreshDecodedBytes() {
    final nextSource = widget.base64.trim();
    _decodedSource = nextSource;
    _bytes = decodeBase64Bytes(nextSource);
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes == null || _decodedSource.isEmpty) {
      return widget.placeholder;
    }
    return Image.memory(
      bytes,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      cacheWidth: widget.cacheWidth,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
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
                  child: Base64MemoryImage(
                    base64: entry.previewBase64,
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
                        '该旧记录仅有缩略图，无法高质量重识别。',
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
