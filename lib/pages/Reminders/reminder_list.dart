import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Reminders/reminder_edit.dart';
import 'package:luminous/stores/reminder_local_store.dart';
import 'package:luminous/stores/today_reminder_local_store.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/notification_service.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/reminder.dart';

/// 用药提醒列表页。
///
/// 页面负责展示提醒计划、进入新增/编辑页，并把结果同步到本地缓存与系统通知。
class ReminderListPage extends StatefulWidget {
  /// 创建用药提醒列表页组件。
  const ReminderListPage({super.key});

  /// 创建提醒列表页对应的状态对象。
  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

/// 提醒列表页状态对象。
///
/// 这里维护的是“提醒计划清单”本身，任何对计划的新增、编辑、启停、删除
/// 都会在这里更新 `_items`，并重新调度系统通知。
class _ReminderListPageState extends State<ReminderListPage> {
  /// 全局用户控制器，用于判断登录态与获取 userId。
  final UserController _userController = Get.find<UserController>();

  /// 监听登录用户变化的 worker。
  Worker? _userWorker;

  /// 当前是否正在加载提醒列表。
  bool _loading = false;

  /// 当前错误提示文案（非空时会在页面顶部展示错误 banner）。
  String? _error;

  /// 当前提醒计划列表。
  List<ReminderPlan> _items = [];

  /// 当前是否有一次新的刷新请求在排队。
  bool _reloadQueued = false;

  /// 当前活跃加载请求的编号。
  int _loadRequestId = 0;

  /// 正在执行启用/删除等变更操作的提醒 id。
  final Set<String> _busyReminderIds = <String>{};

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  /// 页面初始化时先拉取一次提醒列表。
  @override
  void initState() {
    super.initState();
    _userWorker = ever<dynamic>(_userController.user, (_) {
      _load();
    });
    _load();
  }

  @override
  void dispose() {
    _userWorker?.dispose();
    super.dispose();
  }

  /// 当前登录用户 id（未登录时为空字符串）。
  String get _userId => _userController.user.value?.id ?? '';

  bool get _loggedIn => _userController.isLoggedIn && _userId.trim().isNotEmpty;

  int get _enabledCount => _items.where((item) => item.enabled).length;

  int get _disabledCount => _items.length - _enabledCount;

  String _itemsCountLabel(AppLocalizations? l10n) =>
      l10n?.reminderListCountLabel(_items.length) ?? '${_items.length} 条提醒';

  /// 加载提醒计划列表。
  ///
  /// - 成功：写入本地缓存，并重新调度系统通知；
  /// - 失败：回退读取本地缓存。
  Future<void> _load() async {
    final userId = _userId.trim();
    if (userId.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _items = [];
          _error = null;
          _loading = false;
          _busyReminderIds.clear();
        });
      }
      return;
    }
    if (_loading) {
      _reloadQueued = true;
      return;
    }

    final requestId = ++_loadRequestId;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ReminderApi.list(userId: userId);
      final items = _sortedPlans(response.result.items);
      if (!_canApplyLoadResult(requestId, userId)) return;
      setState(() {
        _items = items;
      });
      await reminderLocalStore.replaceForUser(userId, items);
      await _syncTodaySnapshotForUser(userId);
      if (!_canApplyLoadResult(requestId, userId)) return;
      await NotificationService.instance.rescheduleAll(items);
    } catch (e) {
      if (!_canApplyLoadResult(requestId, userId)) return;
      setState(() => _error = MessageUtils.extractError(e));
      await _loadLocal(userId, requestId: requestId);
    } finally {
      if (_isActiveLoadRequest(requestId) && mounted) {
        setState(() => _loading = false);
      }
      if (_isActiveLoadRequest(requestId) && _reloadQueued && mounted) {
        _reloadQueued = false;
        unawaited(_load());
      }
    }
  }

  /// 从本地缓存读取提醒计划列表（网络失败时回退使用）。
  Future<void> _loadLocal(String userId, {required int requestId}) async {
    final items = await reminderLocalStore.loadForUser(userId);
    if (!_canApplyLoadResult(requestId, userId)) {
      return;
    }
    setState(() {
      _items = items;
    });
    await _syncTodaySnapshotForUser(userId);
  }

  /// 当前请求结果是否仍然可以安全落到界面上。
  bool _canApplyLoadResult(int requestId, String userId) {
    return mounted &&
        _isActiveLoadRequest(requestId) &&
        userId == _userId.trim();
  }

  /// 当前请求是否仍然是活跃请求。
  bool _isActiveLoadRequest(int requestId) {
    return requestId == _loadRequestId;
  }

  /// 对提醒计划列表做稳定排序。
  List<ReminderPlan> _sortedPlans(Iterable<ReminderPlan> items) {
    return List<ReminderPlan>.from(items)
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  /// 把当前页面上的提醒列表持久化到本地缓存。
  Future<void> _persistCurrentItems({String? userId}) async {
    final provided = (userId ?? '').trim();
    final uid = provided.isNotEmpty ? provided : _userId.trim();
    if (uid.isEmpty) {
      return;
    }
    await reminderLocalStore.replaceForUser(uid, _sortedPlans(_items));
  }

  Future<void> _syncTodaySnapshotForUser(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty) {
      return;
    }
    final items = await todayReminderLocalStore.buildTodayItemsFromPlans(
      uid,
      _items,
    );
    await todayReminderLocalStore.replaceTodaySnapshot(
      userId: uid,
      items: items,
    );
  }

  /// 构建提醒列表页 UI。
  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    return AppCanvasPageScaffold(
      appBar: AppBar(
        title: Text(l10n?.reminderListTitle ?? '用药提醒'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _loggedIn && !_loading ? _load : null,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      appBarSpacing: 30,
      accentColor: const Color(0xFF10B981),
      secondaryAccentColor: const Color(0xFF0EA5E9),
      floatingActionButton: _loggedIn
          ? FloatingActionButton.extended(
              onPressed: _loading ? null : _openCreate,
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n?.reminderAddButton ?? '新增提醒'),
            )
          : null,
      child: !_loggedIn
          ? _buildNeedLogin()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 12),
                  if (_error != null) _buildErrorBanner(_error!),
                  if (_items.isEmpty && !_loading) _buildEmpty(),
                  ..._items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _items.length - 1 ? 0 : 10,
                      ),
                      child: _ReminderCard(
                        item: item,
                        busy: _busyReminderIds.contains(item.id.trim()),
                        onTap: () => _openEdit(item),
                        onToggle: (value) => _toggleEnabled(item, value),
                        onDelete: () => _delete(item),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroCard() {
    final l10n = _l10n;
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: const Color(0xFF10B981),
      secondaryColor: const Color(0xFF38BDF8),
      ornamentKey: 'reminders.list.hero',
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.reminderListTitle ?? '用药提醒',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            l10n?.reminderEmptySubtitle ?? '点击右下角“新增提醒”开始设置',
            style: TextStyle(
              fontSize: 12.8,
              height: 1.45,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TintedStatusChip(
                icon: Icons.library_books_rounded,
                text: _itemsCountLabel(l10n),
                color: const Color(0xFF0EA5E9),
              ),
              TintedStatusChip(
                icon: Icons.notifications_active_rounded,
                text:
                    l10n?.reminderListEnabledCountLabel(_enabledCount) ??
                    '$_enabledCount 启用',
                color: const Color(0xFF10B981),
              ),
              TintedStatusChip(
                icon: Icons.notifications_off_rounded,
                text:
                    l10n?.reminderListDisabledCountLabel(_disabledCount) ??
                    '$_disabledCount 关闭',
                color: const Color(0xFF64748B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建未登录时的引导视图。
  Widget _buildNeedLogin() {
    final l10n = _l10n;
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final iconAccent = Color.lerp(scheme.primary, scheme.tertiary, 0.4)!;
    final iconBackground = appTintedSurface(
      context,
      iconAccent,
      lightAlpha: 0.12,
      darkAlpha: 0.24,
      baseColor: theme.cardTheme.color ?? scheme.surface,
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: AppSectionCard(
          accentColor: Color.lerp(scheme.primary, scheme.tertiary, 0.32)!,
          secondaryColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.4)!,
          ornamentKey: 'reminders.need-login',
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          radius: 18,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appTintedBorder(
                      context,
                      iconAccent,
                      lightAlpha: 0.16,
                      darkAlpha: 0.26,
                    ),
                  ),
                ),
                child: Icon(Icons.alarm_rounded, color: iconAccent, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.reminderNeedLoginTitle ?? '请先登录',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.reminderNeedLoginSubtitle ?? '登录后可同步提醒计划，并在到点收到系统通知。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(l10n?.reminderNeedLoginAction ?? '去登录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建错误提示 banner。
  Widget _buildErrorBanner(String text) {
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: const Color(0xFFF59E0B),
      secondaryColor: Color.lerp(const Color(0xFFF59E0B), scheme.error, 0.25)!,
      ornamentKey: 'reminders.list.error',
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: scheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态占位视图。
  Widget _buildEmpty() {
    final l10n = _l10n;
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: Color.lerp(scheme.primary, scheme.tertiary, 0.32)!,
      secondaryColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.4)!,
      ornamentKey: 'reminders.empty',
      padding: const EdgeInsets.symmetric(vertical: 42),
      radius: 18,
      child: Column(
        children: [
          const Icon(
            Icons.alarm_off_rounded,
            size: 42,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 10),
          Text(
            l10n?.reminderEmptyTitle ?? '暂无提醒',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.reminderEmptySubtitle ?? '点击右下角“新增提醒”开始设置',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 打开“新增提醒”页面并在保存成功后更新列表与通知调度。
  Future<void> _openCreate() async {
    final plan = await Navigator.of(context).push<ReminderPlan>(
      MaterialPageRoute<ReminderPlan>(builder: (_) => const ReminderEditPage()),
    );
    if (!mounted) return;
    if (plan == null) return;
    await _upsertPlanAndReschedule(plan);
  }

  /// 打开“编辑提醒”页面并在保存成功后更新列表与通知调度。
  Future<void> _openEdit(ReminderPlan plan) async {
    final next = await Navigator.of(context).push<ReminderPlan>(
      MaterialPageRoute<ReminderPlan>(
        builder: (_) => ReminderEditPage(initial: plan),
      ),
    );
    if (!mounted) return;
    if (next == null) return;
    await _upsertPlanAndReschedule(next);
  }

  Future<void> _upsertPlanAndReschedule(ReminderPlan plan) async {
    setState(() {
      _items.removeWhere((e) => e.id == plan.id);
      _items.add(plan);
      _items = _sortedPlans(_items);
    });
    await _persistCurrentItems(userId: plan.userId);
    await _syncTodaySnapshotForUser(plan.userId);
    await NotificationService.instance.rescheduleAll(_items);
  }

  Future<void> _runWithBusyReminder(
    String reminderId,
    Future<void> Function() task,
  ) async {
    final id = reminderId.trim();
    if (id.isEmpty) {
      await task();
      return;
    }
    if (_busyReminderIds.contains(id)) {
      return;
    }

    if (mounted) {
      setState(() => _busyReminderIds.add(id));
    }
    try {
      await task();
    } finally {
      if (mounted) {
        setState(() => _busyReminderIds.remove(id));
      }
    }
  }

  /// 切换某条提醒的启用状态，并同步到后端/本地/系统通知。
  Future<void> _toggleEnabled(ReminderPlan plan, bool enabled) async {
    await _runWithBusyReminder(plan.id, () async {
      try {
        final next = await ReminderApi.upsert(
          userId: _userId,
          id: plan.id,
          time: plan.time,
          drugCode: plan.drugCode,
          approvalNo: plan.approvalNo,
          productName: plan.productName,
          subtitle: plan.subtitle,
          enabled: enabled,
          repeatRule: plan.repeatRule,
          method: plan.method,
          startDate: plan.startDate,
          endDate: plan.endDate,
        );
        if (!mounted) return;
        await _upsertPlanAndReschedule(next.result);
      } catch (e) {
        if (mounted) {
          ToastUtils.instance.showError(context, e);
        }
      }
    });
  }

  /// 删除一条提醒计划，并同步到后端/本地/系统通知。
  Future<void> _delete(ReminderPlan plan) async {
    final l10n = _l10n;
    final confirmed = await _confirmDeletePlan(plan);
    if (!confirmed) return;

    await _runWithBusyReminder(plan.id, () async {
      try {
        await ReminderApi.delete(userId: _userId, id: plan.id);
        if (!mounted) return;
        setState(() {
          _items.removeWhere((e) => e.id == plan.id);
          _items = _sortedPlans(_items);
        });
        await _persistCurrentItems(userId: plan.userId);
        await _syncTodaySnapshotForUser(plan.userId);
        await NotificationService.instance.rescheduleAll(_items);
        if (mounted) {
          ToastUtils.instance.show(
            context,
            l10n?.reminderDeletedToast ?? '已删除',
          );
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.instance.showError(context, e);
        }
      }
    });
  }

  Future<bool> _confirmDeletePlan(ReminderPlan plan) async {
    final l10n = _l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: AppSectionCard(
            accentColor: const Color(0xFFF59E0B),
            secondaryColor: const Color(0xFFEF4444),
            ornamentKey: 'reminders.list.delete-dialog',
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: appTintedSurface(
                          dialogContext,
                          scheme.error,
                          lightAlpha: 0.12,
                          darkAlpha: 0.22,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: scheme.error,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n?.reminderDeleteDialogTitle ?? '删除提醒',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.reminderDeleteDialogContent(
                        plan.productName,
                        plan.time,
                      ) ??
                      '确定要删除“${plan.productName} ${plan.time}”吗？',
                  style: TextStyle(
                    fontSize: 13.2,
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          side: BorderSide(
                            color: scheme.outline.withValues(alpha: 0.7),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n?.reminderDeleteCancel ?? '取消'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n?.reminderDeleteConfirm ?? '删除'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result == true;
  }
}

/// 提醒计划列表中的单条卡片。
///
/// 负责展示时间、药品名、启用状态和删除入口，不直接访问接口。
class _ReminderCard extends StatelessWidget {
  /// 创建提醒计划卡片。
  const _ReminderCard({
    required this.item,
    required this.busy,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  /// 当前提醒计划条目。
  final ReminderPlan item;

  /// 当前条目是否正在执行变更操作。
  final bool busy;

  /// 点击卡片回调（进入编辑）。
  final VoidCallback onTap;

  /// 开关切换回调。
  final ValueChanged<bool> onToggle;

  /// 删除回调。
  final VoidCallback onDelete;

  /// 构建提醒计划卡片 UI。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final accent = item.enabled
        ? const Color(0xFF10B981)
        : const Color(0xFF64748B);
    final rangeText = _formatDateRange(
      item.startDate,
      item.endDate,
      l10n: l10n,
    );
    return AppSurfaceCard(
      radius: 18,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: busy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: appTintedSurface(
                    context,
                    accent,
                    lightAlpha: 0.12,
                    darkAlpha: 0.22,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.alarm_rounded, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: appTintedSurface(
                              context,
                              accent,
                              lightAlpha: 0.1,
                              darkAlpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: appTintedBorder(
                                context,
                                accent,
                                lightAlpha: 0.12,
                                darkAlpha: 0.22,
                              ),
                            ),
                          ),
                          child: Text(
                            item.time,
                            style: TextStyle(
                              fontSize: 11.6,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (busy)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.displayTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle.trim().isEmpty
                          ? (l10n?.reminderSystemNotificationSubtitle ??
                                '系统通知提醒')
                          : item.subtitle.trim(),
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n?.reminderRangeLabel(rangeText) ?? '生效区间: $rangeText',
                      style: TextStyle(
                        fontSize: 11.8,
                        height: 1.35,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Switch(
                          value: item.enabled,
                          onChanged: busy ? null : onToggle,
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: appTintedSurface(
                              context,
                              scheme.error,
                              lightAlpha: 0.06,
                              darkAlpha: 0.14,
                            ),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: appTintedBorder(
                                context,
                                scheme.error,
                                lightAlpha: 0.11,
                                darkAlpha: 0.2,
                              ),
                            ),
                          ),
                          child: IconButton(
                            onPressed: busy ? null : onDelete,
                            constraints: const BoxConstraints.tightFor(
                              width: 38,
                              height: 38,
                            ),
                            padding: EdgeInsets.zero,
                            splashRadius: 18,
                            tooltip: l10n?.reminderDeleteConfirm ?? '删除',
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 19,
                              color: busy
                                  ? scheme.error.withValues(alpha: 0.34)
                                  : scheme.error.withValues(alpha: 0.78),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateRange(
    String startDate,
    String endDate, {
    AppLocalizations? l10n,
  }) {
    final start = startDate.trim();
    final end = endDate.trim();
    if (start.isEmpty && end.isEmpty) {
      return l10n?.reminderRangeUnlimited ?? '不限制';
    }
    if (start.isNotEmpty && end.isNotEmpty) {
      return l10n?.reminderRangeBetween(start, end) ?? '$start 至 $end';
    }
    if (start.isNotEmpty) {
      return l10n?.reminderRangeFrom(start) ?? '$start 起';
    }
    return l10n?.reminderRangeUntil(end) ?? '截止 $end';
  }
}
