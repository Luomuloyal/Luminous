import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/home_api.dart';
import 'package:luminous/components/home.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/pages/Picker/medicine_picker.dart';
import 'package:luminous/pages/Scan/medicine_scan.dart';
import 'package:luminous/stores/today_reminder_local_store.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/home.dart';
import 'package:luminous/viewmodels/medicine.dart';

typedef FetchTodayReminders =
    Future<ApiResult<TodayRemindersResult>> Function({String? userId});

// 首页
//
// 设计要点：
// - 顶部色块展示健康提示（默认本地兜底，并随语言切换自动更新）
// - "常用功能"是本地静态入口（纯 UI）
// - "今日提醒"来自后端接口 today-reminders
// - 请求成功后覆盖当天快照，失败时回退到当天快照或首页兜底数据
/// 首页。
///
/// 作为应用一级入口，负责把高频功能、今日提醒和健康提示组合在同一屏展示。
class HomeView extends StatefulWidget {
  /// 创建首页组件。
  const HomeView({
    super.key,
    this.fetchTodayReminders,
    this.todayReminderStore,
  });

  final FetchTodayReminders? fetchTodayReminders;
  final TodayReminderStore? todayReminderStore;

  /// 创建首页对应的状态对象，所有首页数据加载与交互都在状态类里完成。
  @override
  State<HomeView> createState() => _HomeViewState();
}

/// 首页状态对象。
///
/// 主要维护三类首页信息：
/// - 顶部温馨提示；
/// - 中部固定功能入口；
/// - 底部今日提醒及其本地/远端回退逻辑。
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

  List<HomeReminderItemData> _defaultFallbackReminders() => [
    HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: '08:30 维生素D',
      dosage: '1 粒',
      subtitle: '早餐后服用 1 粒',
      done: true,
    ),
    HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: '19:30 阿莫西林',
      dosage: '1 粒',
      subtitle: '晚餐后服用 1 粒',
      done: false,
    ),
    HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: '22:00 血压记录',
      dosage: '',
      subtitle: '睡前记录并上传',
      done: false,
    ),
  ];

  List<HomeReminderItemData> _buildGuestSampleRemindersFor(
    AppLocalizations? l10n,
  ) {
    final localeName = (l10n?.localeName ?? 'zh').toLowerCase();
    final prefix = localeName.startsWith('zh') ? '示例' : 'Sample';
    return _buildFallbackRemindersFor(l10n)
        .map(
          (item) => HomeReminderItemData(
            icon: item.icon,
            title: '$prefix ${item.title}',
            dosage: item.dosage,
            subtitle: item.subtitle,
            done: item.done,
          ),
        )
        .toList(growable: false);
  }

  /// 当前登录用户控制器。
  ///
  /// 用来读取用户 id，以便请求“今日提醒”接口和查询本地提醒/打卡数据。
  final UserController _userController = Get.find<UserController>();

  FetchTodayReminders get _fetchTodayRemindersApi =>
      widget.fetchTodayReminders ?? HomeApi.fetchTodayReminders;

  TodayReminderStore get _todayReminderStore =>
      widget.todayReminderStore ?? todayReminderLocalStore;

  /// 监听登录用户变化的 worker。
  Worker? _userWorker;
  Worker? _sessionReadyWorker;

  /// 当前首页顶部展示的小贴士文案监听器。
  late final ValueNotifier<String> _todayTipNotifier;

  String? _tipLocaleCode;

  bool _usingFallbackReminders = true;

  AppLocalizations? get _l10n => AppLocalizations.of(context);

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

  List<HomeReminderItemData> _buildFallbackRemindersFor(
    AppLocalizations? l10n,
  ) {
    if (l10n == null) {
      return _defaultFallbackReminders();
    }

    return [
      HomeReminderItemData(
        icon: Icons.access_time_rounded,
        title: l10n.homeFallbackReminder1Title,
        dosage: '1 粒',
        subtitle: l10n.homeFallbackReminder1Subtitle,
        done: true,
      ),
      HomeReminderItemData(
        icon: Icons.access_time_rounded,
        title: l10n.homeFallbackReminder2Title,
        dosage: '1 粒',
        subtitle: l10n.homeFallbackReminder2Subtitle,
        done: false,
      ),
      HomeReminderItemData(
        icon: Icons.access_time_rounded,
        title: l10n.homeFallbackReminder3Title,
        dosage: '',
        subtitle: l10n.homeFallbackReminder3Subtitle,
        done: false,
      ),
    ];
  }

  /// “常用功能”区域的静态入口列表。
  ///
  /// 每个元素描述一个功能卡片的 id、标题、副标题、图标和颜色，
  /// 页面点击后会根据 id 决定跳转到哪个功能页。
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

  /// 当前真正渲染到页面上的提醒列表。
  ///
  /// 初始值使用兜底提醒，后续会在 `_fetchTodayReminders` 中
  /// 被本地数据库数据或接口数据替换。
  late List<HomeReminderItemData> _reminders;

  /// 标记首页提醒区域是否正处于加载状态。
  ///
  /// 主要用于：
  /// 1. 防止重复触发提醒请求；
  /// 2. 顶部卡片展示“提醒加载中...”文案。
  bool _loadingReminders = false;

  /// 当前是否有新的提醒刷新请求在排队。
  bool _refreshQueued = false;

  /// 当前活跃提醒请求的编号。
  int _reminderRequestId = 0;

  /// 最近一次已经按当前用户态发起过的提醒请求 userId。
  String? _lastRequestedUserId;

  /// 页面初始化时完成一次性数据准备。
  ///
  /// 这里做两件事：
  /// 1. 绑定用户变化，确保提醒数据和登录态同步；
  /// 2. 拉取今日提醒，替换默认兜底数据。
  @override
  void initState() {
    super.initState();
    _todayTipNotifier = ValueNotifier<String>('');
    _reminders = <HomeReminderItemData>[];
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

    if (_usingFallbackReminders) {
      _reminders = _buildGuestSampleRemindersFor(_l10n);
    }
  }

  @override
  void dispose() {
    _userWorker?.dispose();
    _sessionReadyWorker?.dispose();
    _todayTipNotifier.dispose();
    super.dispose();
  }

  void _refreshRemindersIfReady({bool force = false}) {
    if (!_userController.sessionReady.value) {
      return;
    }
    final userId = (_userController.user.value?.id ?? '').trim();
    if (userId.isEmpty) {
      _lastRequestedUserId = userId;
      _refreshQueued = false;
      if (mounted) {
        setState(() {
          _loadingReminders = false;
          _usingFallbackReminders = true;
          _reminders = _buildGuestSampleRemindersFor(_l10n);
        });
      }
      return;
    }

    if (_lastRequestedUserId != null &&
        _lastRequestedUserId != userId &&
        mounted) {
      setState(() {
        _usingFallbackReminders = false;
        _reminders = <HomeReminderItemData>[];
      });
    }
    if (!force && _lastRequestedUserId == userId) {
      return;
    }
    _lastRequestedUserId = userId;
    unawaited(_fetchTodayReminders());
  }

  /// 构建首页整体 UI。
  ///
  /// 页面结构分为三块：
  /// 1. 顶部健康助手卡片；
  /// 2. 常用功能网格；
  /// 3. 今日提醒列表。
  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;

    /// 当前提醒列表里“下一条未完成提醒”。
    ///
    /// 顶部卡片会优先展示它，帮助用户快速知道最近一次该做什么。
    final next = _reminders.cast<HomeReminderItemData?>().firstWhere(
      (e) => e != null && e.done == false,
      orElse: () => null,
    );

    /// 顶部卡片中展示的“下一次提醒”文案。
    ///
    /// 如果今天没有待完成提醒，则显示“暂无提醒”。
    final nextText = next == null
        ? (l10n?.homeNoReminder ?? '暂无提醒')
        : (l10n?.homeNextReminderPrefix(
                next.title,
                _composeReminderDetail(next),
              ) ??
              '${next.title} · ${_composeReminderDetail(next)}');

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchTodayReminders,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: HomeTopSection(
                palette: SoftBannerPalettes.homeOf(context),
                todayTipListenable: _todayTipNotifier,
                nextText: nextText,
                loadingReminders: _loadingReminders,
                reminderCount: _reminders.length,
                onTapTip: _cycleHealthTip,
                onLongPressTip: _showAllHealthTips,
              ),
            ),
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

  /// 处理“常用功能”卡片的点击事件。
  ///
  /// 根据不同入口的 id 进行页面跳转；部分跳转完成后会刷新首页提醒，
  /// 保证提醒和打卡状态能及时同步回首页。
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
        _fetchTodayReminders();
      });
      return;
    }

    if (item.id == 'checkIn') {
      Navigator.pushNamed(context, '/checkin').then((_) {
        _fetchTodayReminders();
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

  /// 打开药品选择页，并在用户选中药品后进入药品详情页。
  ///
  /// 这是首页“药物信息”入口的行为：先选药，再看详情。
  Future<void> _pickAndOpenMedicineDetail() async {
    /// 从药品选择页返回的药品对象。
    ///
    /// 用户取消选择时会得到 `null`。
    final item = await Navigator.of(context).push<MedicineItem>(
      MaterialPageRoute<MedicineItem>(
        builder: (_) =>
            MedicinePickerPage(title: _l10n?.homeMedicinePickerTitle ?? '选择药品'),
      ),
    );
    if (!mounted) return;
    if (item == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineDetailPage(initialItem: item),
      ),
    );
  }

  /// 拉取首页“今日提醒”数据。
  ///
  /// 加载顺序是：
  /// 1. 先请求后端 today-reminders；
  /// 2. 请求成功后用完整远端结果覆盖当天快照；
  /// 3. 再统一从“当天快照 + 本地打卡 / override”组合出 UI；
  /// 4. 请求失败时回退到当天快照，没有快照再用首页兜底数据。
  Future<void> _fetchTodayReminders() async {
    if (_loadingReminders) {
      _refreshQueued = true;
      return;
    }

    final userId = (_userController.user.value?.id ?? '').trim();
    if (userId.isEmpty) {
      _refreshQueued = false;
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingReminders = false;
        _usingFallbackReminders = true;
        _reminders = _buildGuestSampleRemindersFor(_l10n);
      });
      return;
    }

    final requestId = ++_reminderRequestId;
    setState(() {
      _loadingReminders = true;
    });

    try {
      /// 后端返回的“今日提醒”结果。
      ///
      /// 作为网络数据来源，当本地没有可用数据时会回退使用这里的内容。
      final response = await _fetchTodayRemindersApi(
        userId: userId.isEmpty ? null : userId,
      );

      await _todayReminderStore.replaceTodaySnapshot(
        userId: userId,
        date: response.result.date,
        items: response.result.items,
      );

      final overrides = await _todayReminderStore.loadTodayOverrides(userId);

      /// 从“今日提醒快照 + 本地打卡状态”组合出来的 UI 数据。
      final snapshot = await _todayReminderStore.loadTodaySnapshotItems(
        userId,
        date: response.result.date,
        overrides: overrides,
      );

      final items = snapshot
          .map((item) => _toReminderUi(item, doneOverride: item.done))
          .toList();

      if (!_canApplyReminderResult(requestId, userId)) return;
      setState(() {
        _usingFallbackReminders = false;
        _reminders = items;
      });
    } catch (e) {
      if (!_canApplyReminderResult(requestId, userId)) {
        return;
      }
      final overrides = await _todayReminderStore.loadTodayOverrides(userId);
      final snapshot = await _todayReminderStore.loadTodaySnapshotItems(
        userId,
        overrides: overrides,
      );
      if (_canApplyReminderResult(requestId, userId) && snapshot.isNotEmpty) {
        setState(() {
          _usingFallbackReminders = false;
          _reminders = snapshot
              .map((item) => _toReminderUi(item, doneOverride: item.done))
              .toList();
        });
      } else if (_canApplyReminderResult(requestId, userId)) {
        setState(() {
          _usingFallbackReminders = false;
          _reminders = <HomeReminderItemData>[];
        });
      }
      if (!mounted) {
        return;
      }
      ToastUtils.instance.showError(context, e);
    } finally {
      if (_isActiveReminderRequest(requestId) && mounted) {
        setState(() {
          _loadingReminders = false;
        });
      }
      if (_isActiveReminderRequest(requestId) && _refreshQueued && mounted) {
        _refreshQueued = false;
        unawaited(_fetchTodayReminders());
      }
    }
  }

  /// 当前提醒请求结果是否仍然可以落到页面上。
  bool _canApplyReminderResult(int requestId, String userId) {
    return mounted &&
        _isActiveReminderRequest(requestId) &&
        userId == (_userController.user.value?.id ?? '').trim();
  }

  /// 当前请求是否仍然是活跃请求。
  bool _isActiveReminderRequest(int requestId) {
    return requestId == _reminderRequestId;
  }

  /// 把接口层的提醒对象转换为首页组件直接可用的 UI 数据。
  ///
  /// 这样页面不需要直接依赖接口返回结构的字段命名和组合规则。
  HomeReminderItemData _toReminderUi(ReminderItem item, {bool? doneOverride}) {
    /// 接口返回的提醒时间字符串。
    final time = item.time.trim();

    /// 接口返回的提醒标题。
    final title = item.title.trim();

    /// 首页主标题展示用的组合文案。
    final combinedTitle = time.isEmpty ? title : '$time $title';

    return HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: combinedTitle,
      dosage: item.dosage.trim(),
      subtitle: _composeReminderSubtitle(
        item.dosage.trim(),
        item.subtitle.trim(),
      ),
      done: doneOverride ?? item.done,
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

  /// 切换到下一条本地健康小贴士。
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
