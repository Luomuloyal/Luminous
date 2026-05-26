import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/reminders/data/reminder_local_gateway.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/utils/loading_utils.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';

@Deprecated('Use ReminderListNotifier (Riverpod) instead')
class ReminderListController extends GetxController {
  ReminderListController({ReminderLocalGateway? reminderGateway})
    : _reminderGateway = reminderGateway ?? reminderLocalGateway;

  final ReminderLocalGateway _reminderGateway;

  ProviderSubscription? _userWorker;
  StreamSubscription<int>? _revisionSubscription;
  bool _loading = false;
  bool _syncing = false;
  String? _error;
  List<ReminderPlan> _items = const <ReminderPlan>[];
  bool _reloadQueued = false;
  bool _syncQueued = false;
  int _loadRequestId = 0;
  final Set<String> _busyReminderIds = <String>{};

  bool get loading => _loading || _syncing;
  String? get error => _error;
  List<ReminderPlan> get items => _items;
  String get userId =>
      globalProviderContainer.read(currentUserProvider)?.id ?? '';
  bool get isLoggedIn =>
      (globalProviderContainer.read(currentUserProvider)?.hasData ?? false) &&
      userId.trim().isNotEmpty;
  int get enabledCount => _items.where((item) => item.enabled).length;
  int get disabledCount => _items.length - enabledCount;

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
      _items = const <ReminderPlan>[];
      _error = null;
      _loading = false;
      _reloadQueued = false;
      _busyReminderIds.clear();
      update();
      return;
    }
    if (_loading) { _reloadQueued = true; return; }
    final requestId = ++_loadRequestId;
    _loading = true;
    update();
    try {
      final items = await _reminderGateway.loadPlans(scopedUserId);
      if (!_canApplyLoadResult(requestId, scopedUserId)) return;
      _items = _sortedPlans(items);
      _error = null;
    } catch (error) {
      if (!_canApplyLoadResult(requestId, scopedUserId)) return;
      _error = MessageUtils.extractError(error);
      _items = const <ReminderPlan>[];
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

  Future<void> sync() async {
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) return;
    if (_syncing) { _syncQueued = true; return; }
    _syncing = true; _error = null; update();
    try {
      await _reminderGateway.syncRemoteToLocal(scopedUserId);
      if (!isClosed && scopedUserId == userId.trim()) await load();
    } catch (error) {
      if (!isClosed && scopedUserId == userId.trim()) {
        _error = MessageUtils.extractError(error);
        update();
      }
    } finally {
      if (!isClosed && scopedUserId == userId.trim()) {
        _syncing = false; update();
      }
      if (_syncQueued && !isClosed && scopedUserId == userId.trim()) {
        _syncQueued = false;
        unawaited(sync());
      }
    }
  }

  Future<void> applySavedPlan(ReminderPlan plan) async {
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) return;
    final planUserId = plan.userId.trim();
    if (planUserId.isNotEmpty && planUserId != scopedUserId) {
      await sync(); return;
    }
    await _reminderGateway.upsertLocalPlan(scopedUserId, plan);
    if (!isClosed) await load();
  }

  Future<void> toggleEnabled(ReminderPlan plan, bool enabled) async {
    await _runWithBusyReminder(plan.id, () async {
      final scopedUserId = userId.trim();
      if (scopedUserId.isEmpty) return;
      try {
        final next = await ReminderApi.upsert(
          userId: scopedUserId, id: plan.id, time: plan.time,
          drugCode: plan.drugCode, approvalNo: plan.approvalNo,
          productName: plan.productName, medicines: plan.medicines,
          dosage: plan.dosage, subtitle: plan.subtitle,
          enabled: enabled, repeatRule: plan.repeatRule,
          method: plan.method, startDate: plan.startDate,
          endDate: plan.endDate,
        );
        if (isClosed) return;
        await _reminderGateway.upsertLocalPlan(scopedUserId, next.result);
        if (!isClosed) await load();
      } catch (error) {
        if (!isClosed) _showError(error);
      }
    });
  }

  Future<void> deletePlan(ReminderPlan plan) async {
    await _runWithBusyReminder(plan.id, () async {
      final scopedUserId = userId.trim();
      if (scopedUserId.isEmpty) return;
      try {
        await ReminderApi.delete(userId: scopedUserId, id: plan.id);
        if (isClosed) return;
        await _reminderGateway.deleteLocalPlan(scopedUserId, plan.id);
        if (!isClosed) {
          await load();
          _showToast(_l10n?.reminderDeletedToast ?? '已删除');
        }
      } catch (error) { if (!isClosed) _showError(error); }
    });
  }

  bool isBusy(String reminderId) => _busyReminderIds.contains(reminderId.trim());

  void _handleUserChanged() {
    _bindRevision();
    if (isLoggedIn) { unawaited(_loadThenSync()); return; }
    unawaited(load());
  }

  Future<void> _loadThenSync() async {
    await load();
    if (!isClosed && isLoggedIn) await sync();
  }

  void _bindRevision() {
    _revisionSubscription?.cancel();
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) return;
    _revisionSubscription = _reminderGateway.watchRevision(scopedUserId).listen(
      (_) { if (!isClosed) unawaited(load()); },
    );
  }

  Future<void> _runWithBusyReminder(String reminderId, Future<void> Function() task) async {
    final normalizedId = reminderId.trim();
    if (normalizedId.isEmpty) { await task(); return; }
    if (_busyReminderIds.contains(normalizedId)) return;
    _busyReminderIds.add(normalizedId);
    if (!isClosed) update();
    try { await task(); }
    finally { _busyReminderIds.remove(normalizedId); if (!isClosed) update(); }
  }

  List<ReminderPlan> _sortedPlans(Iterable<ReminderPlan> items) =>
      List<ReminderPlan>.from(items)..sort((a, b) => a.time.compareTo(b.time));

  bool _canApplyLoadResult(int requestId, String scopedUserId) =>
      !isClosed && _isActiveLoadRequest(requestId) && scopedUserId == userId.trim();
  bool _isActiveLoadRequest(int requestId) => requestId == _loadRequestId;

  AppLocalizations? get _l10n {
    final context = _context;
    if (context == null) return null;
    return AppLocalizations.of(context);
  }
  BuildContext? get _context => LoadingUtils.navigatorKey.currentContext;
  void _showToast(String message) {
    final context = _context; if (context == null) return;
    ToastUtils.instance.show(context, message);
  }
  void _showError(Object error, {String? fallback}) {
    final context = _context; if (context == null) return;
    ToastUtils.instance.showError(context, error, fallback: fallback);
  }
}
