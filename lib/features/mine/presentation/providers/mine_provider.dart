import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/mine/data/browse_history_store.dart';
import 'package:luminous/features/mine/presentation/models/browse_history.dart';

/// 浏览记录列表 provider。
final browseHistoryProvider =
    AsyncNotifierProvider<BrowseHistoryNotifier, List<BrowseHistoryEntry>>(
      BrowseHistoryNotifier.new,
    );

class BrowseHistoryNotifier extends AsyncNotifier<List<BrowseHistoryEntry>> {
  @override
  Future<List<BrowseHistoryEntry>> build() async {
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? '';
    if (userId.isEmpty) return const [];
    return browseHistoryStore.loadEntries(userId: userId);
  }

  Future<void> remove(BrowseHistoryEntry entry) async {
    final user = ref.read(currentUserProvider);
    final userId = user?.id ?? '';
    if (userId.isEmpty) return;
    await browseHistoryStore.removeEntry(
      userId: userId,
      identityKey: entry.identityKey,
    );
    ref.invalidateSelf();
  }

  Future<void> clearAll() async {
    final user = ref.read(currentUserProvider);
    final userId = user?.id ?? '';
    if (userId.isEmpty) return;
    await browseHistoryStore.clear(userId: userId);
    ref.invalidateSelf();
  }
}

/// 浏览记录预览 provider（供 Mine 页面使用：最新条目 + 总数）。
final browseHistoryPreviewProvider = Provider<BrowseHistoryPreview>((ref) {
  final entriesAsync = ref.watch(browseHistoryProvider);
  return entriesAsync.when(
    data: (entries) => BrowseHistoryPreview(
      latest: entries.isEmpty ? null : entries.first,
      count: entries.length,
    ),
    loading: () => const BrowseHistoryPreview(),
    error: (_, _) => const BrowseHistoryPreview(),
  );
});

class BrowseHistoryPreview {
  final BrowseHistoryEntry? latest;
  final int count;

  const BrowseHistoryPreview({this.latest, this.count = 0});
}
