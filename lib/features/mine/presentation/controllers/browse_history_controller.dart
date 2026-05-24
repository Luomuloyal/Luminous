import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/stores/browse_history_store.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/utils/loading_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/browse_history.dart';

/// 浏览记录页控制器。
class BrowseHistoryController extends GetxController {
  BrowseHistoryController({BrowseHistoryStore? historyStore})
    : _historyStore = historyStore ?? browseHistoryStore;

  final BrowseHistoryStore _historyStore;

  ProviderSubscription? _userWorker;
  bool _loading = false;
  bool _busy = false;
  List<BrowseHistoryEntry> _items = const <BrowseHistoryEntry>[];

  bool get loading => _loading;
  bool get busy => _busy;
  List<BrowseHistoryEntry> get items => _items;
  int get count => _items.length;
  bool get isLoggedIn =>
      (globalProviderContainer.read(currentUserProvider)?.hasData ?? false);
  String get userId =>
      globalProviderContainer.read(currentUserProvider)?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    _userWorker = globalProviderContainer.listen(currentUserProvider, (
      previous,
      next,
    ) {
      unawaited(load());
    });
    unawaited(load());
  }

  @override
  void onClose() {
    _userWorker?.close();
    super.onClose();
  }

  Future<void> load() async {
    if (_loading) {
      return;
    }
    _loading = true;
    update();

    try {
      final entries = await _historyStore.loadEntries(userId: userId);
      if (isClosed) {
        return;
      }
      _items = entries;
    } catch (_) {
      if (!isClosed) {
        _items = const <BrowseHistoryEntry>[];
      }
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
