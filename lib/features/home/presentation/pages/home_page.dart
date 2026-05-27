part of '../home.dart';

/// 首页。
///
/// 作为应用一级入口，负责把高频功能、今日提醒和健康提示组合在同一屏展示。
class HomePage extends ConsumerStatefulWidget {
  /// 创建首页组件。
  ///
  /// [reminderGateway] 仅用于测试注入，新代码应通过 ProviderScope override。
  const HomePage({super.key, this.reminderGateway});

  /// 测试用 gateway 注入，新代码应使用 ProviderScope override
  /// `homeReminderGatewayProvider.overrideWithValue(gateway)`。
  final ReminderLocalGateway? reminderGateway;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // 使用 Future 延迟：在 build 完成后（而非期间）修改 provider。
    Future(() {
      if (mounted) {
        _initLocalizedData();
        ref.read(homeProvider.notifier).start();
      }
    });
  }

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // applyLocalizedData 在 initState 的 post-frame callback 中调用，
    // 以避免在 widget 构建期间修改 provider。
  }

  void _initLocalizedData() {
    ref.read(homeProvider.notifier).applyLocalizedData(
      healthTips: _buildHomeHealthTips(_l10n),
      demoReminders: _buildHomeDemoReminders(_l10n),
      demoCheckInRecords: _buildHomeDemoCheckInRecords(_l10n),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    final l10n = _l10n;
    final reminders = homeState.reminders;
    final next = reminders.cast<HomeReminderItemData?>().firstWhere(
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

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final windowClass = AppWindowClass.fromWidth(constraints.maxWidth);
        final maxWidth = AppContentWidths.fromWindowClass(windowClass);

        Widget inner = SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshHomeData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: HomeTopSection(
                    palette: SoftBannerPalettes.homeOf(context),
                    todayTipListenable: _todayTipListenable(homeState.todayTip),
                    nextText: nextText,
                    loadingReminders: homeState.loadingReminders,
                    reminderCount: reminders.length,
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
                  child: HomeReminderSection(items: reminders),
                ),
                SliverToBoxAdapter(
                  child: HomeCheckInRecordSection(
                    items: homeState.checkInRecords,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );

        if (maxWidth != null) {
          inner = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: inner,
            ),
          );
        }

        return inner;
      },
    );

    // If a test gateway was injected, override the provider for this subtree.
    if (widget.reminderGateway != null) {
      content = ProviderScope(
        overrides: [
          homeReminderGatewayProvider.overrideWithValue(
            widget.reminderGateway!,
          ),
        ],
        child: content,
      );
    }

    return content;
  }

  /// 返回健康提示 Notifier 适配器，兼容 `HomeTopSection` 的 `ValueListenable` 接口。
  ValueNotifier<String> _todayTipListenable(String tip) {
    // 使用 _HomeTipNotifier 作为适配桥接。
    return _HomeTipNotifier(tip);
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
    await ref.read(homeProvider.notifier).loadReminders();
    await ref.read(homeProvider.notifier).loadCheckInRecords();
  }

  Future<void> _refreshHomeData() async {
    final notifier = ref.read(homeProvider.notifier);
    final userId = (ref.read(currentUserProvider)?.id ?? '').trim();
    if (userId.isEmpty) {
      notifier.refreshIfReady(force: true);
      return;
    }

    try {
      await ref.read(homeReminderGatewayProvider).syncRemoteToLocal(userId);
      if (!mounted ||
          userId != (ref.read(currentUserProvider)?.id ?? '').trim()) {
        return;
      }
      unawaited(notifier.loadReminders());
      unawaited(notifier.loadCheckInRecords());
    } catch (error) {
      if (!mounted) return;
      ToastUtils.instance.showError(context, error);
    }
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
    ref.read(homeProvider.notifier).cycleHealthTip();
  }

  void _updateTodayTip(String nextTip) {
    ref.read(homeProvider.notifier).updateTodayTip(nextTip);
  }

  Future<void> _showAllHealthTips() async {
    final l10n = _l10n;
    final homeState = ref.read(homeProvider);

    final selectedTip = await showHomeHealthTipsSheet(
      context: context,
      l10n: l10n,
      tips: homeState.healthTips.isEmpty
          ? _buildHomeHealthTips(l10n)
          : homeState.healthTips,
      currentTip: homeState.todayTip,
    );

    if (selectedTip != null) {
      _updateTodayTip(selectedTip);
    }
  }
}

/// 将 String 值适配为 `ValueNotifier<String>`，供 `HomeTopSection` 的
/// `todayTipListenable` 参数使用。
///
/// 旧实现依赖 `HomeController.todayTipNotifier` (ValueNotifier)，
/// 新实现改用 `todayTipProvider` (StateProvider)。此适配器在每次
/// build 时创建新实例，使 `HomeTopSection` 能通过 `ValueListenableBuilder`
/// 感知健康提示变化。
class _HomeTipNotifier extends ValueNotifier<String> {
  _HomeTipNotifier(super.value);
}
