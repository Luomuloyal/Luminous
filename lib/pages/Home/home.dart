import 'package:flutter/material.dart';
import 'package:luminous/api/home_api.dart';
import 'package:luminous/components/home.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/home.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final List<HomeFeatureItemData> _entries = const [
    HomeFeatureItemData(
      id: 'drugScan',
      title: '药物识别',
      subtitle: '拍照识别药品',
      icon: Icons.camera_alt_outlined,
      color: Color(0xFF0EA5E9),
    ),
    HomeFeatureItemData(
      id: 'manualSearch',
      title: '手动搜索',
      subtitle: '关键词查询',
      icon: Icons.search_outlined,
      color: Color(0xFF06B6D4),
    ),
    HomeFeatureItemData(
      id: 'reminder',
      title: '用药提醒',
      subtitle: '按时通知',
      icon: Icons.alarm_outlined,
      color: Color(0xFF10B981),
    ),
    HomeFeatureItemData(
      id: 'checkIn',
      title: '用药打卡',
      subtitle: '记录服药情况',
      icon: Icons.fact_check_outlined,
      color: Color(0xFFF59E0B),
    ),
    HomeFeatureItemData(
      id: 'drugInfo',
      title: '药物信息',
      subtitle: '成分与禁忌',
      icon: Icons.medication_outlined,
      color: Color(0xFF6366F1),
    ),
    HomeFeatureItemData(
      id: 'safety',
      title: '安全辅助',
      subtitle: '风险提示',
      icon: Icons.health_and_safety_outlined,
      color: Color(0xFFEC4899),
    ),
  ];

  static const List<HomeReminderItemData> _fallbackReminders = [
    HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: '08:30 维生素D',
      subtitle: '早餐后服用 1 粒',
      done: true,
    ),
    HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: '19:30 阿莫西林',
      subtitle: '晚餐后服用 1 粒',
      done: false,
    ),
    HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: '22:00 血压记录',
      subtitle: '睡前记录并上传',
      done: false,
    ),
  ];

  late List<HomeReminderItemData> _reminders = List<HomeReminderItemData>.from(
    _fallbackReminders,
  );
  bool _loadingReminders = false;

  @override
  void initState() {
    super.initState();
    _fetchTodayReminders();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFF3F7FB),
        child: CustomScrollView(
          slivers: [
            _buildTopSliver(),
            SliverToBoxAdapter(
              child: HomeFeatureSection(items: _entries, onTap: _onEntryTap),
            ),
            SliverToBoxAdapter(child: HomeReminderSection(items: _reminders)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSliver() {
    final next = _reminders.cast<HomeReminderItemData?>().firstWhere(
      (e) => e != null && e.done == false,
      orElse: () => null,
    );
    final nextText = next == null
        ? '暂无提醒'
        : '下一次提醒: ${next.title} · ${next.subtitle}';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x30000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x28FFFFFF),
                    ),
                    child: const Icon(
                      Icons.favorite_outline,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      '健康助手',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _buildStatusChip('已同步'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '今天也要按时用药',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nextText,
                style: TextStyle(color: Color(0xE6FFFFFF), fontSize: 14),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildInfoPill(
                    _loadingReminders
                        ? '提醒加载中...'
                        : '今日提醒 ${_reminders.length} 条',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoPill('功能持续完善中'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onEntryTap(HomeFeatureItemData item) {
    if (item.id == 'manualSearch') {
      Navigator.pushNamed(context, '/search');
      return;
    }
    ToastUtils.instance.show(context, '功能开发中');
  }

  Widget _buildStatusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0x33FFFFFF),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0x29FFFFFF),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _fetchTodayReminders() async {
    if (_loadingReminders) {
      return;
    }
    setState(() {
      _loadingReminders = true;
    });

    try {
      final response = await HomeApi.fetchTodayReminders();
      if (!mounted) {
        return;
      }
      final items = response.result.items;
      if (items.isEmpty) {
        return;
      }
      setState(() {
        _reminders = items.map(_toReminderUi).toList();
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.show(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingReminders = false;
        });
      }
    }
  }

  HomeReminderItemData _toReminderUi(ReminderItem item) {
    final time = item.time.trim();
    final title = item.title.trim();
    final combinedTitle = time.isEmpty ? title : '$time $title';

    return HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: combinedTitle,
      subtitle: item.subtitle.trim(),
      done: item.done,
    );
  }
}
