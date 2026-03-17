import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/pages/Reminders/reminder_edit.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/notification_service.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/reminder.dart';
import 'package:sqflite/sqflite.dart';

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

  /// 加载提醒计划列表。
  ///
  /// - 成功：写入本地缓存，并重新调度系统通知；
  /// - 失败：回退读取本地缓存。
  Future<void> _load() async {
    final userId = _userId;
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
      // 1) 从后端拉取提醒计划列表。
      final response = await ReminderApi.list(userId: userId);
      if (!mounted) return;
      // 2) 拿到提醒计划列表并按时间排序，便于页面展示。
      final items = response.result.items;
      setState(() {
        _items = List<ReminderPlan>.from(items)
          ..sort((a, b) => a.time.compareTo(b.time));
      });
      // 3) 写入本地缓存，便于离线展示与首页拼装“今日提醒”。
      await _cacheToLocal(userId, _items);
      // 4) 根据最新计划重新调度系统通知。
      await NotificationService.instance.rescheduleAll(_items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      // fallback: load local cache
      await _loadLocal(userId);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 从本地缓存读取提醒计划列表（网络失败时回退使用）。
  Future<void> _loadLocal(String userId) async {
    try {
      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        'reminders',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'time ASC',
      );
      final items = rows.map(_rowToPlan).toList();
      if (!mounted) return;
      setState(() {
        _items = items;
      });
    } catch (_) {}
  }

  /// 把 reminders 表的一行记录转换为 `ReminderPlan`。
  ReminderPlan _rowToPlan(Map<String, dynamic> row) {
    return ReminderPlan(
      id: (row['remoteId'] ?? '').toString(),
      userId: (row['userId'] ?? '').toString(),
      time: (row['time'] ?? '').toString(),
      drugCode: (row['drugCode'] ?? '').toString(),
      approvalNo: (row['approvalNo'] ?? '').toString(),
      productName: (row['productName'] ?? '').toString(),
      subtitle: (row['subtitle'] ?? '').toString(),
      enabled: (row['enabled'] ?? 1) == 1,
      repeatRule: (row['repeatRule'] ?? 'daily').toString(),
      method: (row['method'] ?? 'notification').toString(),
    );
  }

  /// 将提醒计划列表写入本地 reminders 表缓存。
  ///
  /// 使用 replace 覆盖写入，保证本地缓存与远端结果一致。
  Future<void> _cacheToLocal(String userId, List<ReminderPlan> items) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final r in items) {
      if (r.id.trim().isEmpty) continue;
      await db.insert('reminders', {
        'remoteId': r.id,
        'userId': userId,
        'time': r.time,
        'drugCode': r.drugCode,
        'approvalNo': r.approvalNo,
        'productName': r.productName,
        'subtitle': r.subtitle,
        'enabled': r.enabled ? 1 : 0,
        'repeatRule': r.repeatRule,
        'method': r.method,
        'updatedAt': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// 构建提醒列表页 UI。
  @override
  Widget build(BuildContext context) {
    final loggedIn = _userController.isLoggedIn && _userId.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('用药提醒'),
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
      floatingActionButton: loggedIn
          ? FloatingActionButton.extended(
              onPressed: _openCreate,
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('新增提醒'),
            )
          : null,
      body: !loggedIn
          ? _buildNeedLogin()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
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
                      child: _ReminderCard(
                        item: item,
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.alarm_rounded,
                  color: Color(0xFF10B981),
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
                '登录后可同步提醒计划，并在到点收到系统通知。',
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

  /// 构建空状态占位视图。
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
          Icon(Icons.alarm_off_rounded, size: 42, color: Color(0xFF94A3B8)),
          SizedBox(height: 10),
          Text(
            '暂无提醒',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 6),
          Text(
            '点击右下角“新增提醒”开始设置',
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

  /// 打开“新增提醒”页面并在保存成功后更新列表与通知调度。
  Future<void> _openCreate() async {
    final plan = await Navigator.of(context).push<ReminderPlan>(
      MaterialPageRoute<ReminderPlan>(builder: (_) => const ReminderEditPage()),
    );
    if (!mounted) return;
    if (plan == null) return;
    setState(() {
      _items.removeWhere((e) => e.id == plan.id);
      _items.add(plan);
      _items.sort((a, b) => a.time.compareTo(b.time));
    });
    await _cacheToLocal(_userId, _items);
    await NotificationService.instance.rescheduleAll(_items);
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
    setState(() {
      _items.removeWhere((e) => e.id == next.id);
      _items.add(next);
      _items.sort((a, b) => a.time.compareTo(b.time));
    });
    await _cacheToLocal(_userId, _items);
    await NotificationService.instance.rescheduleAll(_items);
  }

  /// 切换某条提醒的启用状态，并同步到后端/本地/系统通知。
  Future<void> _toggleEnabled(ReminderPlan plan, bool enabled) async {
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
      );
      if (!mounted) return;
      setState(() {
        _items = _items.map((e) => e.id == plan.id ? next.result : e).toList()
          ..sort((a, b) => a.time.compareTo(b.time));
      });
      await _cacheToLocal(_userId, _items);
      await NotificationService.instance.rescheduleAll(_items);
    } catch (e) {
      if (mounted) {
        ToastUtils.instance.show(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  /// 删除一条提醒计划，并同步到后端/本地/系统通知。
  Future<void> _delete(ReminderPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除提醒'),
          content: Text('确定要删除“${plan.productName} ${plan.time}”吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    try {
      await ReminderApi.delete(userId: _userId, id: plan.id);
      if (!mounted) return;
      setState(() {
        _items.removeWhere((e) => e.id == plan.id);
      });
      final db = await AppDatabase.instance.database;
      await db.delete('reminders', where: 'remoteId = ?', whereArgs: [plan.id]);
      await NotificationService.instance.rescheduleAll(_items);
      if (mounted) ToastUtils.instance.show(context, '已删除');
    } catch (e) {
      if (mounted) {
        ToastUtils.instance.show(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }
}

/// 提醒计划列表中的单条卡片。
///
/// 负责展示时间、药品名、启用状态和删除入口，不直接访问接口。
class _ReminderCard extends StatelessWidget {
  /// 创建提醒计划卡片。
  const _ReminderCard({
    required this.item,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  /// 当前提醒计划条目。
  final ReminderPlan item;

  /// 点击卡片回调（进入编辑）。
  final VoidCallback onTap;

  /// 开关切换回调。
  final ValueChanged<bool> onToggle;

  /// 删除回调。
  final VoidCallback onDelete;

  /// 构建提醒计划卡片 UI。
  @override
  Widget build(BuildContext context) {
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
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      (item.enabled
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8))
                          .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.alarm_rounded,
                  color: item.enabled
                      ? const Color(0xFF10B981)
                      : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle.trim().isEmpty
                          ? '系统通知提醒'
                          : item.subtitle.trim(),
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Switch(value: item.enabled, onChanged: onToggle),
                        const Spacer(),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: Colors.red.shade300,
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
}
