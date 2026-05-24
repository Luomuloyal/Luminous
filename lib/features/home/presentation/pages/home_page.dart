part of '../home.dart';

/// 首页。
///
/// 作为应用一级入口，负责把高频功能、今日提醒和健康提示组合在同一屏展示。
class HomePage extends StatefulWidget {
  /// 创建首页组件。
  const HomePage({super.key, this.reminderGateway, this.controller});

  final ReminderLocalGateway? reminderGateway;
  final HomeController? controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller =
      widget.controller ??
      HomeController(reminderGateway: widget.reminderGateway);

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  List<HomeFeatureItemData> get _entries {
    final l10n = _l10n;
    return [
      HomeFeatureItemData(
        id: 'drugScan',
        title: l10n?.homeFeatureDrugScanTitle ?? '药物识别',
        subtitle: l10n?.homeFeatureDrugScanSubtitle ?? '拍照识别药品',
        icon: Icons.camera_alt_rounded,
        color: const Color(0xFF0EA5E9),
      ),
      HomeFeatureItemData(
        id: 'manualSearch',
        title: l10n?.homeFeatureManualSearchTitle ?? '手动搜索',
        subtitle: l10n?.homeFeatureManualSearchSubtitle ?? '关键词查询',
        icon: Icons.search_rounded,
        color: const Color(0xFF06B6D4),
      ),
      HomeFeatureItemData(
        id: 'reminder',
        title: l10n?.homeFeatureReminderTitle ?? '用药提醒',
        subtitle: l10n?.homeFeatureReminderSubtitle ?? '按时通知',
        icon: Icons.alarm_rounded,
        color: const Color(0xFF10B981),
      ),
      HomeFeatureItemData(
        id: 'checkIn',
        title: l10n?.homeFeatureCheckInTitle ?? '用药打卡',
        subtitle: l10n?.homeFeatureCheckInSubtitle ?? '记录服药情况',
        icon: Icons.fact_check_rounded,
        color: const Color(0xFFF59E0B),
      ),
      HomeFeatureItemData(
        id: 'drugInfo',
        title: l10n?.homeFeatureDrugInfoTitle ?? '药物信息',
        subtitle: l10n?.homeFeatureDrugInfoSubtitle ?? '成分与禁忌',
        icon: Icons.medication_rounded,
        color: const Color(0xFF6366F1),
      ),
      HomeFeatureItemData(
        id: 'safety',
        title: l10n?.homeFeatureSafetyTitle ?? '安全辅助',
        subtitle: l10n?.homeFeatureSafetySubtitle ?? '风险提示',
        icon: Icons.health_and_safety_rounded,
        color: const Color(0xFFEC4899),
      ),
    ];
  }

  ValueNotifier<String> get _todayTipNotifier => _controller.todayTipNotifier;
  List<HomeReminderItemData> get _reminders => _controller.reminders;
  List<HomeCheckInRecordData> get _checkInRecords => _controller.checkInRecords;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.applyLocalizedData(
      healthTips: _buildHomeHealthTips(_l10n),
      demoReminders: _buildHomeDemoReminders(_l10n),
      demoCheckInRecords: _buildHomeDemoCheckInRecords(_l10n),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: _controller,
      global: false,
      builder: (_) {
        final l10n = _l10n;
        final next = _reminders.cast<HomeReminderItemData?>().firstWhere(
          (item) => item != null && item.done == false,
          orElse: () => null,
        );
        final nextText = next == null
            ? (l10n?.homeNoReminder ?? '暂无提醒')
            : (l10n?.homeNextReminderPrefix(
                    next.title,
                    _composeReminderDetail(next),
                  ) ??
                  '${next.title} · ${_composeReminderDetail(next)}');

        return LayoutBuilder(
          builder: (context, constraints) {
            final windowClass = AppWindowClass.fromWidth(constraints.maxWidth);
            final maxWidth = AppContentWidths.fromWindowClass(windowClass);

            Widget content = SafeArea(
              child: RefreshIndicator(
                onRefresh: _refreshHomeData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: HomeTopSection(
                        palette: SoftBannerPalettes.homeOf(context),
                        todayTipListenable: _todayTipNotifier,
                        nextText: nextText,
                        loadingReminders: _controller.loadingReminders,
                        reminderCount: _reminders.length,
                        onTapTip: _cycleHealthTip,
                        onLongPressTip: _showAllHealthTips,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: HomeFeatureSection(
                        items: _entries,
                        onTap: _onEntryTap,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: HomeReminderSection(items: _reminders),
                    ),
                    SliverToBoxAdapter(
                      child: HomeCheckInRecordSection(items: _checkInRecords),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            );

            if (maxWidth != null) {
              content = Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: content,
                ),
              );
            }

            return content;
          },
        );
      },
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
        _loadCheckInRecords();
      });
      return;
    }

    if (item.id == 'checkIn') {
      Navigator.pushNamed(context, '/checkin').then((_) {
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

  Future<void> _loadCheckInRecords() async {
    await _controller.loadReminders();
    await _controller.loadCheckInRecords();
  }

  Future<void> _refreshHomeData() async {
    await _controller.refreshHomeData(context);
  }

  String _composeReminderDetail(HomeReminderItemData item) {
    final subtitle = item.subtitle.trim();
    if (subtitle.isNotEmpty) {
      return subtitle;
    }
    if (item.dosage.trim().isNotEmpty) {
      return _l10n?.reminderDosePrefix(item.dosage.trim()) ??
          '剂量: ${item.dosage.trim()}';
    }
    return _l10n?.homeNoReminder ?? '暂无提醒';
  }

  void _cycleHealthTip() {
    _controller.cycleHealthTip();
  }

  void _updateTodayTip(String nextTip) {
    _controller.updateTodayTip(nextTip);
  }

  Future<void> _showAllHealthTips() async {
    final l10n = _l10n;
    final selectedTip = await showHomeHealthTipsSheet(
      context: context,
      l10n: l10n,
      tips: _controller.healthTips.isEmpty
          ? _buildHomeHealthTips(l10n)
          : _controller.healthTips,
      currentTip: _todayTipNotifier.value,
    );

    if (selectedTip != null) {
      _updateTodayTip(selectedTip);
    }
  }
}
