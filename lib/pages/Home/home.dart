import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/home.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/pages/Picker/medicine_picker.dart';
import 'package:luminous/pages/Scan/medicine_scan.dart';
import 'package:luminous/stores/reminder_local_gateway.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/home.dart';
import 'package:luminous/viewmodels/medicine.dart';

// 首页
//
// 设计要点：
// - 顶部色块展示健康提示（默认本地兜底，并随语言切换自动更新）
// - "常用功能"是本地静态入口（纯 UI）
// - "今日提醒"只读取本地 today snapshot
// - 远端只负责把数据同步回本地，再由本地回流驱动 UI
/// 首页。
///
/// 作为应用一级入口，负责把高频功能、今日提醒和健康提示组合在同一屏展示。
class HomeView extends StatefulWidget {
  /// 创建首页组件。
  const HomeView({super.key, this.reminderGateway});

  final ReminderLocalGateway? reminderGateway;

  /// 创建首页对应的状态对象，所有首页数据加载与交互都在状态类里完成。
  @override
  State<HomeView> createState() => _HomeViewState();
}

/// 首页状态对象。
///
/// 主要维护三类首页信息：
/// - 顶部温馨提示；
/// - 中部固定功能入口；
/// - 底部今日提醒及其本地回流逻辑。
class _HomeViewState extends State<HomeView> {
  List<String> get _defaultHealthTips => [
    '按时服药，别漏别补',
    '饭前饭后按说明来',
    '合并用药先问药师',
    '漏服勿加倍，咨询放在先',
    '出现不适，及时就医',
    '抗生素按疗程，不要擅停',
    '药品避光防潮，远离高温',
    '定期清理过期药品',
    '用药前看禁忌与相互作用',
    '规律作息，药效更稳',
  ];

  final UserController _userController = Get.find<UserController>();

  ReminderLocalGateway get _reminderGateway =>
      widget.reminderGateway ?? reminderLocalGateway;

  Worker? _userWorker;
  Worker? _sessionReadyWorker;
  StreamSubscription<int>? _revisionSubscription;

  late final ValueNotifier<String> _todayTipNotifier;
  String? _tipLocaleCode;

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  List<HomeFeatureItemData> get _entries {
    final l10n = _l10n;
    return [
      HomeFeatureItemData(
        id: 'drugScan',
        title: l10n?.homeFeatureDrugScanTitle ?? '药物识别',
        subtitle: l10n?.homeFeatureDrugScanSubtitle ?? '拍照识别药品',
        icon: Icons.camera_alt_outlined,
        color: const Color(0xFF0EA5E9),
      ),
      HomeFeatureItemData(
        id: 'manualSearch',
        title: l10n?.homeFeatureManualSearchTitle ?? '手动搜索',
        subtitle: l10n?.homeFeatureManualSearchSubtitle ?? '关键词查询',
        icon: Icons.search_outlined,
        color: const Color(0xFF06B6D4),
      ),
      HomeFeatureItemData(
        id: 'reminder',
        title: l10n?.homeFeatureReminderTitle ?? '用药提醒',
        subtitle: l10n?.homeFeatureReminderSubtitle ?? '按时通知',
        icon: Icons.alarm_outlined,
        color: const Color(0xFF10B981),
      ),
      HomeFeatureItemData(
        id: 'checkIn',
        title: l10n?.homeFeatureCheckInTitle ?? '用药打卡',
        subtitle: l10n?.homeFeatureCheckInSubtitle ?? '记录服药情况',
        icon: Icons.fact_check_outlined,
        color: const Color(0xFFF59E0B),
      ),
      HomeFeatureItemData(
        id: 'drugInfo',
        title: l10n?.homeFeatureDrugInfoTitle ?? '药物信息',
        subtitle: l10n?.homeFeatureDrugInfoSubtitle ?? '成分与禁忌',
        icon: Icons.medication_outlined,
        color: const Color(0xFF6366F1),
      ),
      HomeFeatureItemData(
        id: 'safety',
        title: l10n?.homeFeatureSafetyTitle ?? '安全辅助',
        subtitle: l10n?.homeFeatureSafetySubtitle ?? '风险提示',
        icon: Icons.health_and_safety_outlined,
        color: const Color(0xFFEC4899),
      ),
    ];
  }

  late List<HomeReminderItemData> _reminders;
  late List<HomeCheckInRecordData> _checkInRecords;
  bool _loadingReminders = false;
  bool _loadingCheckInRecords = false;
  bool _syncingReminders = false;
  bool _reloadQueued = false;
  bool _checkInReloadQueued = false;
  bool _syncQueued = false;
  int _reminderRequestId = 0;
  int _checkInRequestId = 0;
  String? _lastRequestedUserId;

  List<String> _healthTipsFor(AppLocalizations? l10n) {
    if (l10n == null) {
      return _defaultHealthTips;
    }
    return <String>[
      l10n.homeTip1,
      l10n.homeTip2,
      l10n.homeTip3,
      l10n.homeTip4,
      l10n.homeTip5,
      l10n.homeTip6,
      l10n.homeTip7,
      l10n.homeTip8,
      l10n.homeTip9,
      l10n.homeTip10,
    ];
  }

  @override
  void initState() {
    super.initState();
    _todayTipNotifier = ValueNotifier<String>('');
    _reminders = _buildDemoReminders(_l10n);
    _checkInRecords = _buildDemoCheckInRecords(_l10n);
    _userWorker = ever<dynamic>(_userController.user, (_) {
      _refreshRemindersIfReady();
    });
    _sessionReadyWorker = ever<bool>(_userController.sessionReady, (ready) {
      if (ready) {
        _lastRequestedUserId = null;
        _refreshRemindersIfReady();
      }
    });
    _refreshRemindersIfReady();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCode = Localizations.localeOf(context).languageCode;
    if (_tipLocaleCode == localeCode) {
      return;
    }
    _tipLocaleCode = localeCode;

    final tips = _healthTipsFor(_l10n);
    if (tips.isNotEmpty) {
      if (_todayTipNotifier.value.isEmpty ||
          !tips.contains(_todayTipNotifier.value)) {
        _todayTipNotifier.value = tips[Random().nextInt(tips.length)];
      }
    }

    final userId = (_userController.user.value?.id ?? '').trim();
    if (userId.isEmpty && mounted) {
      setState(() {
        _reminders = _buildDemoReminders(_l10n);
        _checkInRecords = _buildDemoCheckInRecords(_l10n);
      });
    }
  }

  @override
  void dispose() {
    _userWorker?.dispose();
    _sessionReadyWorker?.dispose();
    _revisionSubscription?.cancel();
    _todayTipNotifier.dispose();
    super.dispose();
  }

  void _refreshRemindersIfReady({bool force = false}) {
    if (!_userController.sessionReady.value) {
      return;
    }

    final userId = (_userController.user.value?.id ?? '').trim();
    _bindRevision(userId);

    if (userId.isEmpty) {
      _lastRequestedUserId = userId;
      _reloadQueued = false;
      _checkInReloadQueued = false;
      _syncQueued = false;
      if (mounted) {
        setState(() {
          _loadingReminders = false;
          _loadingCheckInRecords = false;
          _syncingReminders = false;
          _reminders = _buildDemoReminders(_l10n);
          _checkInRecords = _buildDemoCheckInRecords(_l10n);
        });
      }
      return;
    }

    if (_lastRequestedUserId != null &&
        _lastRequestedUserId != userId &&
        mounted) {
      setState(() {
        _reminders = <HomeReminderItemData>[];
        _checkInRecords = <HomeCheckInRecordData>[];
      });
    }

    if (!force && _lastRequestedUserId == userId) {
      return;
    }

    _lastRequestedUserId = userId;
    unawaited(_loadTodayReminders());
    unawaited(_loadCheckInRecords());
    unawaited(_syncTodayReminders());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    final next = _reminders.cast<HomeReminderItemData?>().firstWhere(
      (e) => e != null && e.done == false,
      orElse: () => null,
    );
    final nextText = next == null
        ? (l10n?.homeNoReminder ?? '暂无提醒')
        : (l10n?.homeNextReminderPrefix(
                next.title,
                _composeReminderDetail(next),
              ) ??
              '${next.title} · ${_composeReminderDetail(next)}');

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _syncTodayReminders(showError: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: HomeTopSection(
                palette: SoftBannerPalettes.homeOf(context),
                todayTipListenable: _todayTipNotifier,
                nextText: nextText,
                loadingReminders: _loadingReminders || _syncingReminders,
                reminderCount: _reminders.length,
                onTapTip: _cycleHealthTip,
                onLongPressTip: _showAllHealthTips,
              ),
            ),
            SliverToBoxAdapter(
              child: HomeFeatureSection(items: _entries, onTap: _onEntryTap),
            ),
            SliverToBoxAdapter(child: HomeReminderSection(items: _reminders)),
            SliverToBoxAdapter(
              child: HomeCheckInRecordSection(items: _checkInRecords),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  void _onEntryTap(HomeFeatureItemData item) {
    if (item.id == 'manualSearch') {
      Navigator.pushNamed(context, '/search');
      return;
    }

    if (item.id == 'drugScan') {
      unawaited(openMedicineScanFlow(context, mode: ScanEntryMode.result));
      return;
    }

    if (item.id == 'reminder') {
      Navigator.pushNamed(context, '/reminders').then((_) {
        _loadTodayReminders();
        _loadCheckInRecords();
      });
      return;
    }

    if (item.id == 'checkIn') {
      Navigator.pushNamed(context, '/checkin').then((_) {
        _loadTodayReminders();
        _loadCheckInRecords();
      });
      return;
    }

    if (item.id == 'safety') {
      Navigator.pushNamed(context, '/safety');
      return;
    }

    if (item.id == 'drugInfo') {
      _pickAndOpenMedicineDetail();
      return;
    }

    ToastUtils.instance.show(
      context,
      _l10n?.homeFeatureDevelopingToast ?? '功能开发中',
    );
  }

  Future<void> _pickAndOpenMedicineDetail() async {
    final item = await Navigator.of(context).push<MedicineItem>(
      MaterialPageRoute<MedicineItem>(
        builder: (_) =>
            MedicinePickerPage(title: _l10n?.homeMedicinePickerTitle ?? '选择药品'),
      ),
    );
    if (!mounted || item == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineDetailPage(initialItem: item),
      ),
    );
  }

  Future<void> _loadTodayReminders() async {
    if (_loadingReminders) {
      _reloadQueued = true;
      return;
    }

    final userId = (_userController.user.value?.id ?? '').trim();
    if (userId.isEmpty) {
      _reloadQueued = false;
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingReminders = false;
        _reminders = _buildDemoReminders(_l10n);
      });
      return;
    }

    final requestId = ++_reminderRequestId;
    setState(() {
      _loadingReminders = true;
    });

    try {
      final snapshot = await _reminderGateway.loadTodayItems(userId);
      final items = snapshot.map(_toReminderUi).toList(growable: false);

      if (!_canApplyReminderResult(requestId, userId)) {
        return;
      }
      setState(() {
        _reminders = items;
      });
    } catch (_) {
      if (_canApplyReminderResult(requestId, userId)) {
        setState(() {
          _reminders = <HomeReminderItemData>[];
        });
      }
    } finally {
      if (_isActiveReminderRequest(requestId) && mounted) {
        setState(() {
          _loadingReminders = false;
        });
      }
      if (_isActiveReminderRequest(requestId) && _reloadQueued && mounted) {
        _reloadQueued = false;
        unawaited(_loadTodayReminders());
      }
    }
  }

  Future<void> _loadCheckInRecords() async {
    if (_loadingCheckInRecords) {
      _checkInReloadQueued = true;
      return;
    }

    final userId = (_userController.user.value?.id ?? '').trim();
    if (userId.isEmpty) {
      _checkInReloadQueued = false;
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingCheckInRecords = false;
        _checkInRecords = _buildDemoCheckInRecords(_l10n);
      });
      return;
    }

    final requestId = ++_checkInRequestId;
    if (mounted) {
      setState(() {
        _loadingCheckInRecords = true;
      });
    }

    try {
      final records = await _reminderGateway.loadCheckInRecords(
        userId,
        maxDays: 7,
        maxItems: 160,
      );
      if (!_canApplyCheckInResult(requestId, userId)) {
        return;
      }
      setState(() {
        _checkInRecords = records;
      });
    } catch (_) {
      if (_canApplyCheckInResult(requestId, userId)) {
        setState(() {
          _checkInRecords = <HomeCheckInRecordData>[];
        });
      }
    } finally {
      if (_isActiveCheckInRequest(requestId) && mounted) {
        setState(() {
          _loadingCheckInRecords = false;
        });
      }
      if (_isActiveCheckInRequest(requestId) &&
          _checkInReloadQueued &&
          mounted) {
        _checkInReloadQueued = false;
        unawaited(_loadCheckInRecords());
      }
    }
  }

  Future<void> _syncTodayReminders({bool showError = false}) async {
    final userId = (_userController.user.value?.id ?? '').trim();
    if (userId.isEmpty) {
      return;
    }

    if (_syncingReminders) {
      _syncQueued = true;
      return;
    }

    if (mounted) {
      setState(() {
        _syncingReminders = true;
      });
    }

    try {
      await _reminderGateway.syncRemoteToLocal(userId);
      if (mounted && userId == (_userController.user.value?.id ?? '').trim()) {
        await _loadTodayReminders();
        await _loadCheckInRecords();
      }
    } catch (error) {
      if (showError && mounted) {
        ToastUtils.instance.showError(context, error);
      }
    } finally {
      if (mounted && userId == (_userController.user.value?.id ?? '').trim()) {
        setState(() {
          _syncingReminders = false;
        });
      }
      if (_syncQueued &&
          mounted &&
          userId == (_userController.user.value?.id ?? '').trim()) {
        _syncQueued = false;
        unawaited(_syncTodayReminders(showError: showError));
      }
    }
  }

  bool _canApplyReminderResult(int requestId, String userId) {
    return mounted &&
        _isActiveReminderRequest(requestId) &&
        userId == (_userController.user.value?.id ?? '').trim();
  }

  bool _isActiveReminderRequest(int requestId) {
    return requestId == _reminderRequestId;
  }

  bool _canApplyCheckInResult(int requestId, String userId) {
    return mounted &&
        _isActiveCheckInRequest(requestId) &&
        userId == (_userController.user.value?.id ?? '').trim();
  }

  bool _isActiveCheckInRequest(int requestId) {
    return requestId == _checkInRequestId;
  }

  HomeReminderItemData _toReminderUi(ReminderItem item) {
    final time = item.time.trim();
    final title = item.title.trim();
    final combinedTitle = time.isEmpty ? title : '$time $title';

    return HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: combinedTitle,
      dosage: item.dosage.trim(),
      subtitle: _composeReminderSubtitle(
        item.dosage.trim(),
        item.subtitle.trim(),
      ),
      done: item.done,
    );
  }

  String _composeReminderSubtitle(String dosage, String extra) {
    final dose = dosage.trim();
    final note = extra.trim();
    if (dose.isNotEmpty && note.isNotEmpty) {
      return '剂量: $dose · $note';
    }
    if (dose.isNotEmpty) {
      return '剂量: $dose';
    }
    return note;
  }

  String _composeReminderDetail(HomeReminderItemData item) {
    final subtitle = item.subtitle.trim();
    if (subtitle.isNotEmpty) {
      return subtitle;
    }
    if (item.dosage.trim().isNotEmpty) {
      return '剂量: ${item.dosage.trim()}';
    }
    return _l10n?.homeNoReminder ?? '暂无提醒';
  }

  List<HomeReminderItemData> _buildDemoReminders(AppLocalizations? l10n) {
    final reminder1Title =
        l10n?.homeFallbackReminder1Title ??
        AppI18nText.pick(zh: '08:30 维生素D', en: '08:30 Vitamin D');
    final reminder1Subtitle =
        l10n?.homeFallbackReminder1Subtitle ??
        AppI18nText.pick(zh: '早餐后服用 1 粒', en: 'Take 1 capsule after breakfast');
    final reminder2Title =
        l10n?.homeFallbackReminder2Title ??
        AppI18nText.pick(zh: '19:30 阿莫西林', en: '19:30 Amoxicillin');
    final reminder2Subtitle =
        l10n?.homeFallbackReminder2Subtitle ??
        AppI18nText.pick(zh: '晚餐后服用 1 粒', en: 'Take 1 capsule after dinner');
    final reminder3Title =
        l10n?.homeFallbackReminder3Title ??
        AppI18nText.pick(zh: '22:00 血压记录', en: '22:00 Blood Pressure Log');
    final reminder3Subtitle =
        l10n?.homeFallbackReminder3Subtitle ??
        AppI18nText.pick(zh: '睡前记录并上传', en: 'Record and upload before sleep');

    return <HomeReminderItemData>[
      HomeReminderItemData(
        icon: Icons.access_time_rounded,
        title: reminder1Title,
        subtitle: reminder1Subtitle,
        done: true,
      ),
      HomeReminderItemData(
        icon: Icons.access_time_rounded,
        title: reminder2Title,
        subtitle: reminder2Subtitle,
        done: false,
      ),
      HomeReminderItemData(
        icon: Icons.access_time_rounded,
        title: reminder3Title,
        subtitle: reminder3Subtitle,
        done: false,
      ),
    ];
  }

  List<HomeCheckInRecordData> _buildDemoCheckInRecords(AppLocalizations? l10n) {
    final demoReminders = _buildDemoReminders(l10n);
    final reminder1 = _splitDemoReminderTitle(demoReminders[0].title);
    final reminder2 = _splitDemoReminderTitle(demoReminders[1].title);
    final reminder3 = _splitDemoReminderTitle(demoReminders[2].title);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    return <HomeCheckInRecordData>[
      HomeCheckInRecordData(
        dateKey: _dateKey(today),
        reminderId: 'demo-amoxicillin',
        title: reminder1.title,
        reminderTime: reminder1.time,
        done: true,
        takenAt: today
            .add(const Duration(hours: 8, minutes: 34))
            .millisecondsSinceEpoch,
      ),
      HomeCheckInRecordData(
        dateKey: _dateKey(today),
        reminderId: 'demo-vitamin-d',
        title: reminder2.title,
        reminderTime: reminder2.time,
        done: false,
      ),
      HomeCheckInRecordData(
        dateKey: _dateKey(today),
        reminderId: 'demo-valsartan',
        title: reminder3.title,
        reminderTime: reminder3.time,
        done: false,
      ),
      HomeCheckInRecordData(
        dateKey: _dateKey(yesterday),
        reminderId: 'demo-valsartan',
        title: reminder3.title,
        reminderTime: reminder3.time,
        done: true,
        takenAt: yesterday
            .add(const Duration(hours: 20, minutes: 41))
            .millisecondsSinceEpoch,
      ),
      HomeCheckInRecordData(
        dateKey: _dateKey(twoDaysAgo),
        reminderId: 'demo-vitamin-d',
        title: reminder2.title,
        reminderTime: reminder2.time,
        done: true,
        takenAt: twoDaysAgo
            .add(const Duration(hours: 12, minutes: 5))
            .millisecondsSinceEpoch,
      ),
    ];
  }

  ({String time, String title}) _splitDemoReminderTitle(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return (time: '', title: '');
    }
    final firstSpace = text.indexOf(' ');
    if (firstSpace <= 0) {
      return (time: '', title: text);
    }
    final maybeTime = text.substring(0, firstSpace).trim();
    if (!RegExp(r'^\d{1,2}:\d{2}$').hasMatch(maybeTime)) {
      return (time: '', title: text);
    }
    final title = text.substring(firstSpace + 1).trim();
    return (time: maybeTime, title: title.isEmpty ? text : title);
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _bindRevision(String userId) {
    _revisionSubscription?.cancel();
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) {
      return;
    }
    _revisionSubscription = _reminderGateway.watchRevision(scopedUserId).listen(
      (_) {
        if (mounted) {
          unawaited(_loadTodayReminders());
          unawaited(_loadCheckInRecords());
        }
      },
    );
  }

  void _cycleHealthTip() {
    final tips = _healthTipsFor(_l10n);
    if (tips.length <= 1) {
      return;
    }

    final currentTip = _todayTipNotifier.value;
    final nextTips = tips.where((tip) => tip != currentTip).toList();
    if (nextTips.isEmpty) {
      return;
    }

    _updateTodayTip(nextTips[Random().nextInt(nextTips.length)]);
  }

  void _updateTodayTip(String nextTip) {
    if (nextTip == _todayTipNotifier.value || !mounted) {
      return;
    }
    _todayTipNotifier.value = nextTip;
  }

  Future<void> _showAllHealthTips() async {
    final l10n = _l10n;
    final tips = _healthTipsFor(l10n);
    final currentTip = _todayTipNotifier.value;
    final selectedTip = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.72,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.homeTipsSheetTitle ?? '全部健康小贴士',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n?.homeTipsSheetSubtitle ?? '点击任意一条即可替换首页提示语',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                  itemCount: tips.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tip = tips[index];
                    final isCurrent = tip == currentTip;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.of(context).pop(tip),
                        child: Ink(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color(0xFFEAF6FF)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCurrent
                                  ? const Color(0xFFBFDBFE)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? const Color(0xFFDBEAFE)
                                      : const Color(0xFFE2E8F0),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCurrent
                                      ? Icons.favorite_rounded
                                      : Icons.lightbulb_outline_rounded,
                                  size: 14,
                                  color: isCurrent
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedTip != null) {
      _updateTodayTip(selectedTip);
    }
  }
}
