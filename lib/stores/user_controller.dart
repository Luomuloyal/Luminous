import 'dart:convert';

import 'package:get/get.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/stores/browse_history_store.dart';
import 'package:luminous/stores/token_manager.dart';
import 'package:luminous/stores/album_asset_store.dart';
import 'package:luminous/utils/notification_service.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局用户态控制器。
///
/// 使用 GetX 管理当前登录用户，并负责和本地持久化做同步。
class UserController extends GetxController {
  /// 当前登录用户的响应式容器。
  ///
  /// 未登录时值为 `null`，已登录时保存 `UserSafe`。
  final Rxn<UserSafe> user = Rxn<UserSafe>();
  final RxBool sessionReady = true.obs;
  Future<SharedPreferences>? _prefsFuture;
  final BrowseHistoryStore _browseHistoryStore = BrowseHistoryStore.instance;
  final AlbumAssetStore _albumAssetStore = AlbumAssetStore();

  /// 当前是否处于登录状态。
  ///
  /// 通过用户对象是否存在且有有效数据来判断。
  bool get isLoggedIn => user.value?.hasData ?? false;

  /// 标记当前会话仍在恢复中。
  void markSessionPending() {
    sessionReady.value = false;
  }

  Future<SharedPreferences> get _prefs async {
    return _prefsFuture ??= SharedPreferences.getInstance();
  }

  /// 从本地缓存恢复登录用户。
  ///
  /// 应用启动时由 `main()` 调用一次。
  Future<void> init() async {
    try {
      final prefs = await _prefs;

      /// 本地缓存的用户 JSON 字符串。
      final rawUser = prefs.getString(GlobalConstants.USER_KEY);

      if (rawUser == null || rawUser.trim().isEmpty) {
        if (user.value != null) {
          user.value = null;
        }
        return;
      }

      /// 从本地字符串反序列化得到的 JSON 对象。
      final decoded = jsonDecode(rawUser);
      if (decoded is Map<String, dynamic>) {
        user.value = UserSafe.fromJson(decoded);
        return;
      }
    } catch (_) {
      final prefs = await _prefs;
      await prefs.remove(GlobalConstants.USER_KEY);
    } finally {
      sessionReady.value = true;
    }

    if (user.value != null) {
      user.value = null;
    }
  }

  /// 更新当前用户并持久化到本地。
  ///
  /// 一般在登录成功后调用。
  Future<void> setUser(UserSafe nextUser) async {
    user.value = nextUser;
    final prefs = await _prefs;
    await prefs.setString(
      GlobalConstants.USER_KEY,
      jsonEncode(nextUser.toJson()),
    );
  }

  /// 清空当前用户状态并删除本地持久化数据。
  ///
  /// 一般在主动退出登录时调用。
  Future<void> logout() async {
    user.value = null;
    final prefs = await _prefs;
    await prefs.remove(GlobalConstants.USER_KEY);
    await tokenManager.deleteToken();
    await NotificationService.instance.cancelAll();
  }

  /// 当账户被真正注销时，清空当前用户相关的本地缓存与资产文件。
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
