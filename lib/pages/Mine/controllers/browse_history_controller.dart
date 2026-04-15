import 'dart:async';

import 'package:get/get.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/stores/browse_history_store.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/loading_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/browse_history.dart';

/// 浏览记录页控制器。
///
/// 负责从本地仓库读取、删除和清空浏览记录。
class BrowseHistoryController extends GetxController {
  BrowseHistoryController({
    UserController? userController,
    BrowseHistoryStore? historyStore,
  }) : _userController = userController ?? Get.find<UserController>(),
       _historyStore = historyStore ?? browseHistoryStore;

  final UserController _userController;
  final BrowseHistoryStore _historyStore;

  Worker? _userWorker;
  bool _loading = false;
  bool _busy = false;
  List<BrowseHistoryEntry> _items = const <BrowseHistoryEntry>[];

  bool get loading => _loading;
  bool get busy => _busy;
  List<BrowseHistoryEntry> get items => _items;
  int get count => _items.length;
  bool get isLoggedIn => _userController.isLoggedIn;
  String get userId => _userController.user.value?.id.trim() ?? '';

  @override
  void onInit() {
    super.onInit();
    _userWorker = ever<dynamic>(_userController.user, (_) {
      unawaited(load());
    });
    unawaited(load());
  }

  @override
  void onClose() {
    _userWorker?.dispose();
    super.onClose();
  }

  Future<void> load() async {
    if (_loading) {
      return;
    }

    _loading = true;
    update();
    try {
      _items = await _historyStore.loadEntries(userId: userId);
    } finally {
      if (!isClosed) {
        _loading = false;
        update();
      }
    }
  }

  Future<void> remove(BrowseHistoryEntry entry) async {
    if (_busy) {
      return;
    }
    _busy = true;
    update();
    try {
      await _historyStore.removeEntry(
        userId: userId,
        identityKey: entry.identityKey,
      );
      _items = await _historyStore.loadEntries(userId: userId);
      _showToast(_l10n?.mineBrowseHistoryDeleteToast ?? '已移除浏览记录');
    } finally {
      if (!isClosed) {
        _busy = false;
        update();
      }
    }
  }

  Future<void> clearAll() async {
    if (_busy) {
      return;
    }
    _busy = true;
    update();
    try {
      await _historyStore.clear(userId: userId);
      _items = const <BrowseHistoryEntry>[];
      _showToast(_l10n?.mineBrowseHistoryClearedToast ?? '浏览记录已清空');
    } finally {
      if (!isClosed) {
        _busy = false;
        update();
      }
    }
  }

  AppLocalizations? get _l10n {
    final context = LoadingUtils.navigatorKey.currentContext;
    if (context == null) {
      return null;
    }
    return AppLocalizations.of(context);
  }

  void _showToast(String message) {
    final context = LoadingUtils.navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    ToastUtils.instance.show(context, message);
  }
}
