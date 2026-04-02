import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/stores/reminder_local_store.dart';
import 'package:luminous/stores/today_reminder_local_store.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/home.dart';
import 'package:luminous/viewmodels/reminder.dart';

typedef LoadLocalCheckInPlans =
    Future<List<ReminderPlan>> Function(String userId);

/// 用药打卡页。
///
/// 页面聚焦“今天要不要打卡、是否已完成”，数据来源是本地提醒计划和本地打卡状态。
class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key, this.todayReminderStore, this.loadLocalPlans});

  final TodayReminderStore? todayReminderStore;
  final LoadLocalCheckInPlans? loadLocalPlans;

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final UserController _userController = Get.find<UserController>();
  Worker? _userWorker;

  TodayReminderStore get _todayReminderStore =>
      widget.todayReminderStore ?? todayReminderLocalStore;

  LoadLocalCheckInPlans get _loadLocalPlans =>
      widget.loadLocalPlans ?? reminderLocalStore.loadForUser;

  bool _loading = false;
  String? _error;
  List<ReminderItem> _items = [];
  bool _reloadQueued = false;
  int _loadRequestId = 0;

  String get _userId => _userController.user.value?.id ?? '';

  AppLocalizations? get _l10n => AppLocalizations.of(context);

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

  Future<void> _load() async {
    final userId = _userId.trim();
    if (userId.isEmpty) {
      if (mounted) {
        setState(() {
          _items = [];
          _error = null;
          _loading = false;
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
      final plans = await _loadLocalPlans(userId);
      final overrides = await _todayReminderStore.loadTodayOverrides(userId);
      final localItems = await _todayReminderStore.applyTodayState(
        userId,
        items: _buildCheckInItems(plans),
        overrides: overrides,
      );
      if (!_canApplyLoadResult(requestId, userId)) return;

      setState(() {
        _items = localItems;
      });
    } catch (e) {
      if (!_canApplyLoadResult(requestId, userId)) return;
      setState(() {
        _error = MessageUtils.extractError(e);
        _items = const [];
      });
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

  bool _canApplyLoadResult(int requestId, String userId) {
    return mounted &&
        _isActiveLoadRequest(requestId) &&
        userId == _userId.trim();
  }

  bool _isActiveLoadRequest(int requestId) {
    return requestId == _loadRequestId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    final loggedIn = _userController.isLoggedIn && _userId.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n?.checkInPageTitle ?? '用药打卡'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: loggedIn && !_loading ? _load : null,
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
      body: AppCanvas(
        accentColor: const Color(0xFFF59E0B),
        secondaryAccentColor: const Color(0xFFBFD8FF),
        child: !loggedIn
            ? _buildNeedLogin()
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    if (_error != null) _buildErrorBanner(_error!),
                    if (_items.isEmpty && !_loading) _buildEmpty(),
                    ..._items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == _items.length - 1 ? 0 : 10,
                        ),
                        child: _CheckInCard(
                          item: item,
                          onCheckIn: () => _toggleCheckIn(item),
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNeedLogin() {
    final l10n = _l10n;
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final iconAccent = Color.lerp(scheme.tertiary, scheme.primary, 0.32)!;
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
          accentColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.35)!,
          secondaryColor: Color.lerp(scheme.primary, scheme.tertiary, 0.4)!,
          ornamentKey: 'checkin.need-login',
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
                child: Icon(
                  Icons.fact_check_outlined,
                  color: iconAccent,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.checkInNeedLoginTitle ?? '请先登录',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.checkInNeedLoginSubtitle ??
                    '登录后可读取当前设备上的提醒计划，并在本机记录今日打卡状态。',
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
                  child: Text(l10n?.checkInNeedLoginAction ?? '去登录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final l10n = _l10n;
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.35)!,
      secondaryColor: Color.lerp(scheme.primary, scheme.tertiary, 0.4)!,
      ornamentKey: 'checkin.empty',
      padding: const EdgeInsets.symmetric(vertical: 42),
      radius: 18,
      child: Column(
        children: [
          const Icon(
            Icons.event_available_outlined,
            size: 42,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 10),
          Text(
            l10n?.checkInEmptyTitle ?? '今日暂无提醒',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.checkInEmptySubtitle ?? '可以先到“用药提醒”里新增计划',
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

  Future<void> _toggleCheckIn(ReminderItem item) async {
    if (item.done) {
      await _markUndone(item);
      return;
    }
    await _markDone(item);
  }

  Future<void> _markDone(ReminderItem item) async {
    final l10n = _l10n;
    final userId = _userId.trim();
    if (userId.isEmpty) return;
    if (item.id.trim().isEmpty) {
      ToastUtils.instance.show(
        context,
        l10n?.checkInMissingIdMarkDone ?? '该提醒缺少 id，无法打卡',
      );
      return;
    }

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _todayReminderStore.replaceTodayCheckin(
        userId: userId,
        reminderId: item.id,
        takenAt: now,
      );
      await _todayReminderStore.saveTodayOverride(
        userId: userId,
        reminderId: item.id,
        done: true,
      );

      if (!mounted) return;
      ToastUtils.instance.show(
        context,
        l10n?.checkInMarkedDoneToast ?? '已记录到当前设备',
      );
      _setLocalDone(item.id, true);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.instance.showError(context, e);
    }
  }

  Future<void> _markUndone(ReminderItem item) async {
    final l10n = _l10n;
    final userId = _userId.trim();
    if (userId.isEmpty) {
      return;
    }
    if (item.id.trim().isEmpty) {
      ToastUtils.instance.show(
        context,
        l10n?.checkInMissingIdMarkUndone ?? '该提醒缺少 id，无法切换状态',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n?.checkInUndoDialogTitle ?? '撤销本地打卡'),
          content: Text(
            l10n?.checkInUndoDialogContent ??
                '当前用药打卡只保存在本机，撤销后会立即修改当前设备显示。确定继续吗？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n?.checkInUndoDialogCancel ?? '取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n?.checkInUndoDialogConfirm ?? '撤销本地打卡'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _todayReminderStore.deleteTodayCheckin(
        userId: userId,
        reminderId: item.id.trim(),
      );
      await _todayReminderStore.saveTodayOverride(
        userId: userId,
        reminderId: item.id,
        done: false,
      );

      if (!mounted) return;
      ToastUtils.instance.show(
        context,
        l10n?.checkInMarkedUndoneToast ?? '已改为未打卡',
      );
      _setLocalDone(item.id, false);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.instance.showError(context, e);
    }
  }

  void _setLocalDone(String reminderId, bool done) {
    setState(() {
      _items = _items
          .map(
            (item) => item.id == reminderId
                ? ReminderItem(
                    id: item.id,
                    time: item.time,
                    title: item.title,
                    subtitle: item.subtitle,
                    done: done,
                  )
                : item,
          )
          .toList();
    });
  }

  List<ReminderItem> _buildCheckInItems(List<ReminderPlan> plans) {
    final l10n = _l10n;
    return plans
        .where((plan) => plan.enabled)
        .where(_supportsLocalCheckIn)
        .map(
          (plan) => ReminderItem(
            id: plan.id.trim(),
            time: plan.time.trim(),
            title: plan.productName.trim().isEmpty
                ? (l10n?.checkInDefaultTitle ?? '用药提醒')
                : plan.productName.trim(),
            subtitle: plan.subtitle.trim(),
            done: false,
          ),
        )
        .toList(growable: false);
  }

  bool _supportsLocalCheckIn(ReminderPlan plan) {
    final repeatRule = plan.repeatRule.trim().toLowerCase();
    return repeatRule.isEmpty || repeatRule == 'daily';
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({required this.item, required this.onCheckIn});

  final ReminderItem item;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final done = item.done;
    return AppSurfaceCard(
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    (done ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                        .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.access_time_rounded,
                color: done ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.time.trim().isEmpty
                        ? item.title
                        : '${item.time} ${item.title}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle.trim().isEmpty
                        ? (l10n?.checkInCardDefaultSubtitle ?? '请按时完成')
                        : item.subtitle.trim(),
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: onCheckIn,
              style: FilledButton.styleFrom(
                backgroundColor: done
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                minimumSize: const Size(88, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                done
                    ? (l10n?.checkInActionDone ?? '取消打卡')
                    : (l10n?.checkInActionUndone ?? '打卡'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
