import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/stores/browse_history_store.dart';
import 'package:luminous/stores/token_manager.dart';
import 'package:luminous/stores/album_asset_store.dart';
import 'package:luminous/utils/notification_service.dart';
import 'package:luminous/viewmodels/auth.dart';

class AuthService {
  AuthService(this._ref);

  final Ref _ref;
  final BrowseHistoryStore _browseHistoryStore = BrowseHistoryStore.instance;
  final AlbumAssetStore _albumAssetStore = AlbumAssetStore();

  Future<void> loginSuccess(UserSafe nextUser) async {
    await _ref.read(userSessionProvider.notifier).setUser(nextUser);
  }

  Future<void> logout() async {
    await _ref.read(userSessionProvider.notifier).clear();
    await tokenManager.deleteToken();
    await NotificationService.instance.cancelAll();
  }

  Future<void> purgeDeletedAccountData(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty) {
      return;
    }

    final db = await AppDatabase.instance.database;
    final albumRows = await db.query(
      'album_items',
      columns: ['imagePath', 'thumbPath'],
      where: 'userId = ?',
      whereArgs: [uid],
    );

    await _albumAssetStore.deletePaths(
      albumRows.expand((row) sync* {
        final imagePath = (row['imagePath'] ?? '').toString().trim();
        final thumbPath = (row['thumbPath'] ?? '').toString().trim();
        if (imagePath.isNotEmpty) {
          yield imagePath;
        }
        if (thumbPath.isNotEmpty) {
          yield thumbPath;
        }
      }),
    );

    await db.transaction((txn) async {
      await txn.delete('my_medicines', where: 'userId = ?', whereArgs: [uid]);
      await txn.delete('album_items', where: 'userId = ?', whereArgs: [uid]);
      await txn.delete('reminders', where: 'userId = ?', whereArgs: [uid]);
      await txn.delete('checkins', where: 'userId = ?', whereArgs: [uid]);
      await txn.delete(
        'checkin_overrides',
        where: 'userId = ?',
        whereArgs: [uid],
      );
      await txn.delete(
        'today_reminder_snapshots',
        where: 'userId = ?',
        whereArgs: [uid],
      );
    });

    await _browseHistoryStore.clear(userId: uid);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});
