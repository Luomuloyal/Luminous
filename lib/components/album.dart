import 'package:flutter/material.dart';
import 'package:luminous/viewmodels/album.dart';

/// 相册页（Album）的大块 UI 组件集合。
///
/// 页面层负责数据加载与合并（本地 + 远端），这里负责具体的 UI 结构与展示样式。
class AlbumPage extends StatelessWidget {
  const AlbumPage({
    super.key,
    required this.loading,
    required this.isLoggedIn,
    required this.error,
    required this.entries,
    required this.onRefresh,
    required this.onTapLogin,
    required this.onTapEntry,
  });

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
            slivers: [
              AlbumHeaderSliver(loading: loading),
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
  const AlbumHeaderSliver({super.key, required this.loading});

  /// 是否正在加载，用于显示右侧进度圈。
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF0EA5E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x28000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x28FFFFFF),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '识别相册',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '同步缩略图与识别结果',
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
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
