import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/album/data/album_local_store.dart';
import 'package:luminous/features/album/presentation/models/album.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';

/// 相册条目列表的 Riverpod provider。
///
/// 替代旧 GetX `AlbumController` 的 loading / error / entries 状态。
/// 当 `currentUserProvider` 变化时自动重新加载条目。
final albumEntriesProvider =
    AsyncNotifierProvider<AlbumEntriesNotifier, List<AlbumEntry>>(
      AlbumEntriesNotifier.new,
    );

/// 管理相册条目列表的异步加载。
///
/// - `build()` 中通过 `ref.watch(currentUserProvider)` 感知用户变化，
///   自动触发重新加载，替代旧 `_userWorker` 手动监听。
/// - 调用方通过 `ref.invalidate(albumEntriesProvider)` 触发手动刷新。
class AlbumEntriesNotifier extends AsyncNotifier<List<AlbumEntry>> {
  @override
  Future<List<AlbumEntry>> build() async {
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? '';
    return albumLocalStore.loadEntries(userId: userId);
  }
}
