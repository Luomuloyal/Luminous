import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/reminders/data/reminder_local_gateway.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/utils/loading_utils.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/shared/models/home.dart';

@Deprecated('Use CheckInNotifier (Riverpod) instead') class CheckInController extends GetxController {
  CheckInController({ReminderLocalGateway? reminderGateway})
    : _reminderGateway = reminderGateway ?? reminderLocalGateway;

  final ReminderLocalGateway _reminderGateway;

  ProviderSubscription? _userWorker;
  StreamSubscription<int>? _revisionSubscription;
  bool _loading = false;
  String? _error;
  List<ReminderItem> _items = const <ReminderItem>[];
  bool _reloadQueued = false;
  int _loadRequestId = 0;

  bool get loading => _loading;
  String? get error => _error;
  List<ReminderItem> get items => _items;
  String get userId =>
      globalProviderContainer.read(currentUserProvider)?.id ?? '';
  bool get isLoggedIn =>
      (globalProviderContainer.read(currentUserProvider)?.hasData ?? false) &&
      userId.isNotEmpty;
  int get doneCount => _items.where((item) => item.done).length;
  int get pendingCount => _items.length - doneCount;

  @override
  void onInit() {
    super.onInit();
    _userWorker = globalProviderContainer.listen(currentUserProvider, (
      previous,
      next,
    ) {
      _handleUserChanged();
    });
    _handleUserChanged();
  }

  @override
  void onClose() {
    _userWorker?.close();
    _revisionSubscription?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) {
      _items = const <ReminderItem>[];
      _error = null;
      _loading = false;
      update();
      return;
    }
    if (_loading) {
      _reloadQueued = true;
      return;
    }

    final requestId = ++_loadRequestId;
    _loading = true;
    _error = null;
    update();

    try {
      final localItems = await _reminderGateway.loadTodayItems(scopedUserId);
      if (!_canApplyLoadResult(requestId, scopedUserId)) {
        return;
      }
      _items = localItems;
    } catch (error) {
      if (!_canApplyLoadResult(requestId, scopedUserId)) {
        return;
      }
      _error = MessageUtils.extractError(error);
      _items = const <ReminderItem>[];
    } finally {
      if (_isActiveLoadRequest(requestId) && !isClosed) {
        _loading = false;
        update();
      }
      if (_isActiveLoadRequest(requestId) && _reloadQueued && !isClosed) {
        _reloadQueued = false;
        unawaited(load());
      }
    }
  }

  Future<void> markDone(ReminderItem item) async {
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) {
      return;
    }
    if (item.id.trim().isEmpty) {
      _showToast(_l10n?.checkInMissingIdMarkDone ?? '该提醒缺少 id，无法打卡');
      return;
    }

    try {
      await _reminderGateway.markTodayDone(userId: scopedUserId, item: item);
      if (isClosed) {
        return;
      }
      _showToast(_l10n?.checkInMarkedDoneToast ?? '已记录到当前设备');
      await load();
    } catch (error) {
      if (!isClosed) {
        _showError(error);
      }
    }
  }

  Future<void> markUndone(ReminderItem item) async {
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) {
      return;
    }
    if (item.id.trim().isEmpty) {
      _showToast(_l10n?.checkInMissingIdMarkUndone ?? '该提醒缺少 id，无法切换状态');
      return;
    }

    try {
      await _reminderGateway.markTodayUndone(
        userId: scopedUserId,
        reminderId: item.id.trim(),
      );
      if (isClosed) {
        return;
      }
      _showToast(_l10n?.checkInMarkedUndoneToast ?? '已改为未打卡');
      await load();
    } catch (error) {
      if (!isClosed) {
        _showError(error);
      }
    }
  }

  void _handleUserChanged() {
    _bindRevision();
    unawaited(load());
  }

  void _bindRevision() {
    _revisionSubscription?.cancel();
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) {
      return;
    }
    _revisionSubscription = _reminderGateway.watchRevision(scopedUserId).listen(
      (_) {
        if (!isClosed) {
          unawaited(load());
        }
      },
    );
  }

  bool _canApplyLoadResult(int requestId, String scopedUserId) {
    return !isClosed &&
        _isActiveLoadRequest(requestId) &&
        scopedUserId == userId.trim();
  }

  bool _isActiveLoadRequest(int requestId) {
    return requestId == _loadRequestId;
  }

  AppLocalizations? get _l10n {
    final context = _context;
    if (context == null) {
      return null;
    }
    return AppLocalizations.of(context);
  }

  BuildContext? get _context => LoadingUtils.navigatorKey.currentContext;

  void _showToast(String message) {
    final context = _context;
    if (context == null) {
      return;
    }
    ToastUtils.instance.show(context, message);
  }

  void _showError(Object error, {String? fallback}) {
    final context = _context;
    if (context == null) {
      return;
    }
    ToastUtils.instance.showError(context, error, fallback: fallback);
  }
}
