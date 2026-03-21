import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/checkin_api.dart';
import 'package:luminous/api/home_api.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/home.dart';
import 'package:sqflite/sqflite.dart';

/// 用药打卡页。
///
/// 页面聚焦“今天要不要打卡、是否已完成”，数据来源是今日提醒接口。
class CheckInPage extends StatefulWidget {
  /// 创建用药打卡页组件。
  const CheckInPage({super.key});

  /// 创建用药打卡页对应的状态对象。
  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

/// 用药打卡页状态对象。
///
/// 会把 today-reminders 的结果渲染成可打卡列表，并在本地覆盖状态后同步刷新显示。
class _CheckInPageState extends State<CheckInPage> {
  /// 全局用户控制器，用于获取 userId 与判断登录态。
  final UserController _userController = Get.find<UserController>();

  /// 监听登录用户变化的 worker。
  Worker? _userWorker;

  /// 当前是否正在加载今日提醒列表。
  bool _loading = false;

  /// 当前错误提示文案。
  String? _error;

  /// 今日提醒条目列表（来自 today-reminders）。
  List<ReminderItem> _items = [];

  /// 当前登录用户 id（未登录时为空字符串）。
  String get _userId => _userController.user.value?.id ?? '';

  /// 页面初始化时加载今日提醒列表。
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

  /// 加载今日提醒列表（用于打卡页面展示）。
  ///
  /// 注意：打卡页依赖登录态，没有 userId 时直接返回。
  Future<void> _load() async {
    /// 当前 userId（提前取出来避免重复读取）。
    final userId = _userId.trim();
    if (userId.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _items = [];
          _error = null;
          _loading = false;
        });
      }
      return;
    }
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      /// 调用首页同款接口获取今日提醒。
      final response = await HomeApi.fetchTodayReminders(userId: userId);
      final overrides = await _loadTodayCheckinOverrides(userId);
      final local = await _loadLocalTodayReminders(
        userId,
        overrides: overrides,
      );
      if (!mounted) return;
      setState(() {
        _items = local.isNotEmpty
            ? local
            : response.result.items
                  .map(
                    (item) => ReminderItem(
                      id: item.id,
                      time: item.time,
                      title: item.title,
                      subtitle: item.subtitle,
                      done: overrides[item.id.trim()] ?? item.done,
                    ),
                  )
                  .toList();
      });
    } catch (e) {
      if (!mounted) return;
      final local = await _loadLocalTodayReminders(userId);
      if (!mounted) return;
      setState(() {
        _error = MessageUtils.extractError(e);
        _items = local;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 构建打卡页面 UI。
  @override
  Widget build(BuildContext context) {
    /// 当前是否处于可用的登录状态。
    final loggedIn = _userController.isLoggedIn && _userId.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('用药打卡'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
      body: !loggedIn
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
    );
  }

  /// 构建未登录时的引导视图。
  Widget _buildNeedLogin() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: Color(0xFFF59E0B),
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '请先登录',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '登录后可同步打卡记录，并自动影响首页今日提醒状态。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('去登录'),
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

  /// 构建空状态占位（今日暂无提醒）。
  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 42,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 10),
          Text(
            '今日暂无提醒',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 6),
          Text(
            '可以先到“用药提醒”里新增计划',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 对某条提醒执行打卡状态切换。
  ///
  /// - 未打卡 -> 已打卡：请求创建打卡，并写入本地覆盖状态；
  /// - 已打卡 -> 未打卡：只更新本地覆盖状态，等待后端后续补齐对应接口。
  Future<void> _toggleCheckIn(ReminderItem item) async {
    if (item.done) {
      await _markUndone(item);
      return;
    }
    await _markDone(item);
  }

  Future<void> _markDone(ReminderItem item) async {
    /// 当前 userId。
    final userId = _userId;
    if (userId.trim().isEmpty) return;
    if (item.id.trim().isEmpty) {
      ToastUtils.instance.show(context, '该提醒缺少 id，无法打卡');
      return;
    }
    try {
      /// 当前打卡时间戳（毫秒）。
      final now = DateTime.now().millisecondsSinceEpoch;

      /// 调用后端创建打卡记录。
      final response = await CheckinApi.create(
        userId: userId,
        reminderId: item.id,
        takenAt: now,
      );

      try {
        /// 本地数据库实例。
        final db = await AppDatabase.instance.database;
        final range = _todayRange();
        await db.delete(
          'checkins',
          where:
              'userId = ? AND reminderRemoteId = ? AND takenAt >= ? AND takenAt < ?',
          whereArgs: [userId, item.id, range.start, range.end],
        );
        await db.insert('checkins', {
          'remoteId': response.result.id,
          'userId': userId,
          'reminderRemoteId': item.id,
          'takenAt': now,
          'createdAt': now,
        });
        await _saveTodayCheckinOverride(
          userId: userId,
          reminderId: item.id,
          done: true,
        );
      } catch (_) {}

      if (!mounted) return;
      ToastUtils.instance.show(context, '打卡成功');
      _setLocalDone(item.id, true);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.instance.showError(context, e);
    }
  }

  Future<void> _markUndone(ReminderItem item) async {
    final userId = _userId.trim();
    if (userId.isEmpty) {
      return;
    }
    if (item.id.trim().isEmpty) {
      ToastUtils.instance.show(context, '该提醒缺少 id，无法切换状态');
      return;
    }

    try {
      final db = await AppDatabase.instance.database;
      final range = _todayRange();
      await db.delete(
        'checkins',
        where:
            'userId = ? AND reminderRemoteId = ? AND takenAt >= ? AND takenAt < ?',
        whereArgs: [userId, item.id.trim(), range.start, range.end],
      );
      await _saveTodayCheckinOverride(
        userId: userId,
        reminderId: item.id,
        done: false,
      );
      if (!mounted) return;
      ToastUtils.instance.show(context, '已改为未打卡');
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

  ({int start, int end, String dateKey}) _todayRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end = start + const Duration(days: 1).inMilliseconds;
    final dateKey =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return (start: start, end: end, dateKey: dateKey);
  }

  Future<void> _saveTodayCheckinOverride({
    required String userId,
    required String reminderId,
    required bool done,
  }) async {
    final db = await AppDatabase.instance.database;
    final range = _todayRange();
    await db.insert('checkin_overrides', {
      'userId': userId.trim(),
      'reminderRemoteId': reminderId.trim(),
      'dateKey': range.dateKey,
      'done': done ? 1 : 0,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, bool>> _loadTodayCheckinOverrides(String? userId) async {
    final uid = (userId ?? '').trim();
    if (uid.isEmpty) {
      return const {};
    }

    try {
      final db = await AppDatabase.instance.database;
      final range = _todayRange();
      final rows = await db.query(
        'checkin_overrides',
        columns: ['reminderRemoteId', 'done'],
        where: 'userId = ? AND dateKey = ?',
        whereArgs: [uid, range.dateKey],
      );
      return {
        for (final row in rows)
          (row['reminderRemoteId'] ?? '').toString().trim():
              (row['done'] as int? ?? 0) == 1,
      }..removeWhere((key, value) => key.isEmpty);
    } catch (_) {
      return const {};
    }
  }

  Future<List<ReminderItem>> _loadLocalTodayReminders(
    String? userId, {
    Map<String, bool>? overrides,
  }) async {
    final uid = (userId ?? '').trim();
    if (uid.isEmpty) {
      return const [];
    }

    try {
      final db = await AppDatabase.instance.database;
      final range = _todayRange();
      final checkinRows = await db.query(
        'checkins',
        columns: ['reminderRemoteId'],
        where: 'userId = ? AND takenAt >= ? AND takenAt < ?',
        whereArgs: [uid, range.start, range.end],
      );

      final doneSet = <String>{};
      for (final row in checkinRows) {
        final id = (row['reminderRemoteId'] ?? '').toString().trim();
        if (id.isNotEmpty) {
          doneSet.add(id);
        }
      }

      final reminderRows = await db.query(
        'reminders',
        where: 'userId = ? AND enabled = 1',
        whereArgs: [uid],
        orderBy: 'time ASC',
      );
      if (reminderRows.isEmpty) {
        return const [];
      }

      return reminderRows.map((row) {
        final remoteId = (row['remoteId'] ?? '').toString().trim();
        final time = (row['time'] ?? '').toString().trim();
        final title = (row['productName'] ?? '').toString().trim();
        final subtitle = (row['subtitle'] ?? '').toString().trim();
        final done = overrides?[remoteId] ?? doneSet.contains(remoteId);

        return ReminderItem(
          id: remoteId,
          time: time,
          title: title.isEmpty ? '用药提醒' : title,
          subtitle: subtitle.isEmpty ? '系统通知提醒' : subtitle,
          done: done,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }
}

/// 单条打卡提醒卡片。
///
/// 负责展示提醒时间、说明文案和“打卡/已完成”按钮，不参与任何数据请求。
class _CheckInCard extends StatelessWidget {
  /// 创建单条打卡提醒卡片。
  const _CheckInCard({required this.item, required this.onCheckIn});

  /// 当前提醒条目。
  final ReminderItem item;

  /// 点击“打卡/取消打卡”按钮回调。
  final VoidCallback onCheckIn;

  /// 构建单条打卡提醒卡片 UI。
  @override
  Widget build(BuildContext context) {
    /// 当前是否已完成。
    final done = item.done;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
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
                        ? '请按时完成'
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
              child: Text(done ? '取消打卡' : '打卡'),
            ),
          ],
        ),
      ),
    );
  }
}
