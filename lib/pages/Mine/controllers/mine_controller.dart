import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/stores/browse_history_store.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:luminous/viewmodels/browse_history.dart';

/// 我的页页面级控制器。
///
/// 负责：
/// - 监听登录态变化；
/// - 加载浏览记录预览；
/// - 处理页面上的主要路由与交互。
class MineController extends GetxController {
  MineController({
    UserController? userController,
    BrowseHistoryStore? historyStore,
  }) : _userController = userController ?? Get.find<UserController>(),
       _historyStore = historyStore ?? browseHistoryStore;

  final UserController _userController;
  final BrowseHistoryStore _historyStore;

  Worker? _userWorker;
  BrowseHistoryEntry? _latestBrowseEntry;
  int _browseHistoryCount = 0;

  BrowseHistoryEntry? get latestBrowseEntry => _latestBrowseEntry;
  int get browseHistoryCount => _browseHistoryCount;
  bool get isLoggedIn => _userController.isLoggedIn;

  @override
  void onInit() {
    super.onInit();
    _userWorker = ever<dynamic>(_userController.user, (_) {
      unawaited(loadBrowseHistoryPreview());
      update();
    });
    unawaited(loadBrowseHistoryPreview());
  }

  @override
  void onClose() {
    _userWorker?.dispose();
    super.onClose();
  }

  UserSafe? get currentUser => _userController.user.value;

  Future<void> loadBrowseHistoryPreview() async {
    try {
      final entries = await _historyStore.loadEntries(
        userId: _userController.user.value?.id,
      );
      if (isClosed) {
        return;
      }
      _latestBrowseEntry = entries.isEmpty ? null : entries.first;
      _browseHistoryCount = entries.length;
      update();
    } catch (_) {
      if (isClosed) {
        return;
      }
      _latestBrowseEntry = null;
      _browseHistoryCount = 0;
      update();
    }
  }

  Future<void> onTapProfile(BuildContext context) async {
    if (!_userController.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    Navigator.pushNamed(context, '/settings');
  }

  Future<void> onTapAction(BuildContext context) async {
    if (!_userController.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    Navigator.pushNamed(context, '/settings');
  }

  void onTapQuickAction(
    BuildContext context,
    String id, {
    AppLocalizations? l10n,
  }) {
    if (id == 'search') {
      Navigator.pushNamed(context, '/search');
      return;
    }
    if (id == 'reminders') {
      Navigator.pushNamed(context, '/reminders');
      return;
    }
    if (id == 'settings') {
      Navigator.pushNamed(context, '/settings');
      return;
    }
    ToastUtils.instance.show(context, l10n?.mineDevelopingToast ?? '功能开发中');
  }

  Future<void> openBrowseHistory(BuildContext context) async {
    await Navigator.pushNamed(context, '/browse-history');
    if (isClosed) {
      return;
    }
    await loadBrowseHistoryPreview();
  }

  void onTapAbout(BuildContext context, {required String legalese}) {
    showAboutDialog(
      context: context,
      applicationName: 'Luminous Alpha',
      applicationVersion: '3.1.0-alpha.1+35',
      applicationLegalese: legalese,
    );
  }
}
