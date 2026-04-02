import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/medicine_api.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/search.dart';
import 'package:luminous/components/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/stores/local_medicine_store.dart';
import 'package:luminous/stores/my_medicine_repository.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/viewmodels/search.dart';

typedef MedicineSearchExecutor =
    Future<MedicineSearchResult> Function({
      required String keyword,
      required int page,
      required int pageSize,
    });

enum MedicineQueryMode { online, local }

enum MedicineDatabaseSource { nmpa, drugbank }

// 手动搜索页（对接 MySQL 药品库）
//
// 数据库字段说明：
//   productName         - 产品名称（主搜索字段）
//   approvalNo          - 批准文号（国药准字 HXXXXXXXX）
//   manufacturer        - 生产单位
//   marketingAuthorization - 上市许可持有人
//   dosageForm          - 剂型（片剂/胶囊/注射液等）
//   specification       - 规格（如 0.5g、10ml 等）
//   drugCode            - 药品编码（本位码）
//   serialNo            - 序号
//
// 搜索逻辑：
// - _draftKeyword：输入框实时内容（未提交）
// - _keyword：已提交的搜索关键词（触发请求）
// - 滚动到底部自动加载下一页
/// 手动搜索页。
///
/// 页面支持药品库关键词搜索、最近搜索、快捷标签，以及滚动分页加载。
class SearchView extends StatefulWidget {
  /// 创建手动搜索页组件。
  const SearchView({
    super.key,
    this.pickerMode = false,
    this.initialKeyword = '',
    this.autoSearchOnInit = false,
    this.searchExecutor,
  });

  /// 是否以“选择器模式”打开。
  ///
  /// - false：普通搜索页，点击结果进入详情页；
  /// - true：药品选择器模式，点击结果直接 `Navigator.pop(item)` 返回给上层。
  final bool pickerMode;

  /// 页面初始关键词。
  final String initialKeyword;

  /// 是否在首帧后自动执行一次搜索。
  final bool autoSearchOnInit;

  /// 搜索执行器（默认走 [MedicineApi.search]）。
  final MedicineSearchExecutor? searchExecutor;

  /// 创建搜索页对应的状态对象。
  @override
  State<SearchView> createState() => _SearchViewState();
}

/// 手动搜索页的状态对象。
///
/// 这个状态类同时维护三条主线：
/// - 搜索输入链路：`_draftKeyword -> _keyword -> _search(reset: true)`；
/// - 分页链路：`_hasMore/_page/_loadingMore` 控制滚动到底后的下一页请求；
/// - 本地联动链路：`_addedKeys` 用于把搜索结果和“我的药品”列表对齐。
class _SearchViewState extends State<SearchView> {
  /// 当前登录用户控制器。
  final UserController _userController = Get.find<UserController>();

  /// 搜索输入框控制器。
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _draftKeywordNotifier = ValueNotifier<String>('');

  /// 页面滚动控制器。
  ///
  /// 用于监听列表滚动位置，在接近底部时自动加载下一页。
  final ScrollController _scrollController = ScrollController();

  /// 搜索框下方的快捷搜索标签。
  List<String> get _quickTags {
    final l10n = _l10n;
    return [
      l10n?.searchQuickTagAmoxicillin ?? '阿莫西林',
      l10n?.searchQuickTagIbuprofen ?? '布洛芬',
      l10n?.searchQuickTagVitaminD ?? '维生素D',
      l10n?.searchQuickTagCephalosporin ?? '头孢',
      l10n?.searchQuickTagAntibiotic ?? '抗生素',
      l10n?.searchQuickTagGastroMedicine ?? '胃药',
    ];
  }

  /// 最近搜索关键词列表。
  ///
  /// 当前仅做内存态演示，未持久化到本地。
  final List<String> _recentKeywords = [];

  /// 最近搜索是否由当前语言的默认值自动填充。
  ///
  /// 仅当历史仍保持默认值时，语言切换才会替换为新语言默认词；
  /// 用户手动搜索或手动清空后不再自动覆盖。
  List<String>? _seededRecentKeywords;

  /// 标记是否由用户主动清空过历史，避免在同一会话内被默认词再次填充。
  bool _historyClearedByUser = false;

  /// 已提交并用于实际请求的搜索关键词。
  ///
  /// 之所以单独维护 `_keyword`，是为了把“输入态”和“请求态”解耦：
  /// 用户在输入框里继续编辑时（`_draftKeyword` 变化）不会立刻触发搜索，
  /// 只有点击“搜索/回车”后才会把输入提交到 `_keyword` 并发起请求。
  String _keyword = '';

  /// 最近一次搜索失败时的错误文案。
  String? _lastError;

  /// 当前已加载出来的搜索结果列表。
  ///
  /// - reset 搜索时会清空；
  /// - 分页加载时会在原列表尾部追加，保证滚动位置与已有内容不被打断。
  final List<MedicineItem> _results = [];

  /// 已经添加到“我的药品”的 identityKey 集合。
  ///
  /// 用 Set 的目的是：
  /// - O(1) 判断某条搜索结果是否已添加（用于禁用“添加”按钮/展示已添加状态）；
  /// - 避免重复插入本地数据库。
  final Set<String> _addedKeys = {};

  /// 是否正在执行“首屏/重置搜索”。
  ///
  /// 与 `_loadingMore` 分开是因为两者的 UI 与行为不同：
  /// - `_loading=true` 通常意味着清空结果并重新请求，需要展示首屏 loading；
  /// - `_loadingMore=true` 则保留现有结果，只在底部展示分页 loading。
  bool _loading = false;

  /// 当前活跃搜索请求的编号。
  int _searchRequestId = 0;

  /// 是否正在加载下一页。
  ///
  /// 该状态用于：
  /// - 防止滚动到底部时重复触发并发分页请求；
  /// - 控制底部“加载更多”进度条显示。
  bool _loadingMore = false;

  /// 当前是否还有下一页结果。
  ///
  /// 由后端分页结果返回，用于决定是否继续触发滚动加载。
  bool _hasMore = false;

  /// 下一次请求要使用的页码。
  ///
  /// 这里保存的是“下一页页码”（next page），而不是“当前页”：
  /// - reset 时回到 1；
  /// - 每次请求成功后会根据返回的 `result.page` 推进到 `result.page + 1`。
  int _page = 1;

  /// 每页大小常量。
  static const int _pageSize = 20;

  /// 当前查询模式：联网查询或本地 JSON 查询。
  MedicineQueryMode _queryMode = MedicineQueryMode.online;

  /// 是否已经完成首帧后的网络可达性探测。
  bool _queryModeResolved = false;

  /// 数据源选择（Drugbank 入口预留，尚未接入实际查询）。
  MedicineDatabaseSource _databaseSource = MedicineDatabaseSource.nmpa;

  /// 监听登录用户变化的 worker。
  Worker? _userWorker;

  /// 初始化时加载已添加药品集合，并注册滚动分页监听。
  @override
  void initState() {
    super.initState();
    final initialKeyword = widget.initialKeyword.trim();
    if (initialKeyword.isNotEmpty) {
      _searchController.text = initialKeyword;
      _searchController.selection = TextSelection.collapsed(
        offset: initialKeyword.length,
      );
      _draftKeywordNotifier.value = initialKeyword;
      if (widget.autoSearchOnInit) {
        _keyword = initialKeyword;
        _updateRecentKeywords(initialKeyword);
      }
    }
    _searchController.addListener(_syncDraftKeyword);
    _loadAddedKeys();
    _detectInitialQueryMode();
    _userWorker = ever<dynamic>(_userController.user, (_) {
      _loadAddedKeys();
    });
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) {
        return;
      }
      if (_keyword.isEmpty || !_hasMore || _loadingMore || _loading) {
        return;
      }

      /// 当前列表可滚动的最大偏移值。
      final maxScroll = _scrollController.position.maxScrollExtent;

      /// 当前滚动偏移值。
      final current = _scrollController.offset;
      if (current >= maxScroll - 120) {
        _search(reset: false);
      }
    });
    if (widget.autoSearchOnInit && initialKeyword.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _search(reset: true);
        }
      });
    }
  }

  /// 读取本地“我的药品”列表里的 identityKey，用于标记哪些搜索结果已添加。
  ///
  /// 这一步单独放在页面初始化时做，是为了让搜索结果一出现就知道哪些药
  /// 已经存在于本地列表里，避免用户重复点击“添加”。
  Future<void> _loadAddedKeys() async {
    try {
      /// 当前作用域下已经存在的 identityKey 集合。
      final keys = await myMedicineRepository.loadIdentityKeys(userId: _userId);
      if (!mounted) return;
      if (_sameStringSet(_addedKeys, keys)) {
        return;
      }
      setState(() {
        _addedKeys.clear();
        _addedKeys.addAll(keys);
      });
    } catch (_) {}
  }

  bool _sameStringSet(Set<String> current, Set<String> next) {
    if (current.length != next.length) {
      return false;
    }
    for (final key in next) {
      if (!current.contains(key)) {
        return false;
      }
    }
    return true;
  }

  bool _sameStringList(List<String> current, List<String> next) {
    if (current.length != next.length) {
      return false;
    }
    for (var i = 0; i < current.length; i++) {
      if (current[i] != next[i]) {
        return false;
      }
    }
    return true;
  }

  /// 页面销毁时释放控制器资源。
  @override
  void dispose() {
    _userWorker?.dispose();
    _searchController.removeListener(_syncDraftKeyword);
    _searchController.dispose();
    _scrollController.dispose();
    _draftKeywordNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDefaultRecentKeywordsForLocale();
  }

  List<String> _defaultRecentKeywords() {
    return _quickTags.take(3).toList();
  }

  void _syncDefaultRecentKeywordsForLocale() {
    final defaults = _defaultRecentKeywords();
    if (_recentKeywords.isEmpty) {
      if (_historyClearedByUser) {
        return;
      }
      _recentKeywords.addAll(defaults);
      _seededRecentKeywords = List<String>.from(defaults);
      return;
    }

    final seeded = _seededRecentKeywords;
    if (seeded == null || !_sameStringList(_recentKeywords, seeded)) {
      return;
    }
    if (_sameStringList(_recentKeywords, defaults)) {
      return;
    }

    _recentKeywords
      ..clear()
      ..addAll(defaults);
    _seededRecentKeywords = List<String>.from(defaults);
  }

  void _syncDraftKeyword() {
    final next = _searchController.text.trim();
    if (_draftKeywordNotifier.value == next) {
      return;
    }
    _draftKeywordNotifier.value = next;
  }

  String _queryModeLabel(AppLocalizations? l10n) =>
      _queryMode == MedicineQueryMode.online
      ? (l10n?.searchQueryModeOnline ?? '联网查询')
      : (l10n?.searchQueryModeLocal ?? '本地查询');

  String _databaseSourceLabel(AppLocalizations? l10n) =>
      _databaseSource == MedicineDatabaseSource.nmpa
      ? (l10n?.searchDatabaseSourceNmpa ?? 'NMPA')
      : (l10n?.searchDatabaseSourceDrugbank ?? 'Drugbank');

  Future<void> _detectInitialQueryMode() async {
    final reachable = await MedicineApi.isBackendReachable();
    if (!mounted) {
      return;
    }
    setState(() {
      _queryModeResolved = true;
      if (!reachable) {
        _queryMode = MedicineQueryMode.local;
      }
    });
  }

  void _switchQueryMode(MedicineQueryMode mode) {
    if (_queryMode == mode) {
      return;
    }
    setState(() {
      _queryMode = mode;
      _lastError = null;
      _results.clear();
      _hasMore = false;
      _page = 1;
    });

    if (_keyword.trim().isNotEmpty) {
      _search(reset: true);
    }
  }

  void _switchDatabaseSource(MedicineDatabaseSource source) {
    if (_databaseSource == source) {
      return;
    }
    setState(() {
      _databaseSource = source;
    });
    if (source == MedicineDatabaseSource.drugbank) {
      final l10n = _l10n;
      ToastUtils.instance.show(
        context,
        l10n?.searchDatabaseNotConnectedToast ??
            'Drugbank 暂未接入，当前仍使用 NMPA 数据源。',
      );
    }
  }

  Widget _buildDualOptionButton({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final borderColor = selected
        ? appTintedBorder(
            context,
            scheme.primary,
            lightAlpha: 0.16,
            darkAlpha: 0.24,
          )
        : scheme.outline;
    final foreground = selected ? scheme.primary : scheme.onSurface;
    final background = selected
        ? appTintedSurface(
            context,
            scheme.primary,
            lightAlpha: 0.12,
            darkAlpha: 0.22,
            baseColor: theme.cardTheme.color ?? scheme.surface,
          )
        : theme.cardTheme.color ?? scheme.surface;

    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor),
          backgroundColor: background,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  /// 当前登录用户 id（未登录时为空字符串）。
  String get _userId => _userController.user.value?.id ?? '';

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  Color _searchDecorAccent(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final base = theme.cardTheme.color ?? scheme.surface;
    return Color.alphaBlend(
      scheme.primary.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.22 : 0.12,
      ),
      base,
    );
  }

  Color _searchDecorSecondary(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final base = theme.cardTheme.color ?? scheme.surface;
    return Color.alphaBlend(
      Color.lerp(
        scheme.secondary,
        scheme.tertiary,
        0.65,
      )!.withValues(alpha: theme.brightness == Brightness.dark ? 0.18 : 0.10),
      base,
    );
  }

  SearchSurfaceCard _buildSearchDecorCard({
    required String ornamentKey,
    required Widget child,
  }) {
    return SearchSurfaceCard(
      decorated: true,
      ornamentKey: ornamentKey,
      accentColor: _searchDecorAccent(context),
      secondaryColor: _searchDecorSecondary(context),
      child: child,
    );
  }

  /// 构建搜索页整体 UI。
  ///
  /// 页面会根据 `_keyword/_draftKeyword/_loading/_lastError/_results`
  /// 的组合状态，在“提示态 / 待提交态 / 加载态 / 错误态 / 结果态”之间切换。
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppCanvas(
        accentColor: scheme.primary,
        secondaryAccentColor: Color.lerp(
          scheme.secondary,
          scheme.tertiary,
          0.5,
        )!,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshSearch,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildHeaderSliver(),
                _buildSearchBarSliver(),
                _buildQueryModeSliver(),
                _buildQuickTagsSliver(),
                _buildHistorySliver(),
                _buildResultTitleSliver(),
                _buildContentSliver(),
                if (_keyword.isNotEmpty && _loadingMore)
                  _buildLoadingMoreSliver(),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建顶部标题区域。
  Widget _buildHeaderSliver() {
    final l10n = _l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.maybePop(context),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color ?? theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: scheme.outline),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.pickerMode
                        ? (l10n?.searchTitlePicker ?? '选择药品')
                        : (l10n?.searchTitleManual ?? '手动搜索'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                TintedStatusChip(
                  text: widget.pickerMode
                      ? (l10n?.searchBadgePicker ?? '药品库选择')
                      : (l10n?.searchBadgeManual ?? '关键词检索'),
                  color: scheme.primary,
                  surfaceLightAlpha: 0.06,
                  surfaceDarkAlpha: 0.12,
                  borderLightAlpha: 0.08,
                  borderDarkAlpha: 0.16,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.pickerMode
                        ? (l10n?.searchHeaderSubtitlePicker ?? '从后端药品库搜索并选择')
                        : (l10n?.searchHeaderSubtitleManual ??
                              '支持按药品名称、批准文号、生产单位搜索'),
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建搜索输入框区域。
  Widget _buildSearchBarSliver() {
    final l10n = _l10n;
    return ValueListenableBuilder<String>(
      valueListenable: _draftKeywordNotifier,
      builder: (context, draftKeyword, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _buildSearchDecorCard(
              ornamentKey: widget.pickerMode
                  ? 'search.picker.searchBar'
                  : 'search.manual.searchBar',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _commitSearch(),
                        decoration: InputDecoration(
                          hintText:
                              l10n?.searchInputHint ?? '产品名称 / 批准文号 / 生产单位',
                          hintStyle: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: scheme.primary,
                          ),
                          suffixIcon: draftKeyword.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: _clearKeyword,
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                          filled: true,
                          fillColor: appTintedSurface(
                            context,
                            scheme.primary,
                            lightAlpha: 0.04,
                            darkAlpha: 0.10,
                            baseColor:
                                theme.inputDecorationTheme.fillColor ??
                                (theme.cardTheme.color ?? scheme.surface),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _commitSearch,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(76, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n?.searchActionSearch ?? '搜索'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQueryModeSliver() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = _l10n;
    final modeLabel = _queryModeLabel(l10n);
    final databaseLabel = _databaseSourceLabel(l10n);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: SearchSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n?.searchQueryModeTitle ?? '查询方式',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!_queryModeResolved)
                      Text(
                        l10n?.searchQueryModeDetecting ?? '检测网络中...',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      l10n?.searchQueryModeCurrent(modeLabel) ??
                          '当前: $modeLabel',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildDualOptionButton(
                        label: l10n?.searchQueryModeOnline ?? '联网查询',
                        selected: _queryMode == MedicineQueryMode.online,
                        onPressed: () =>
                            _switchQueryMode(MedicineQueryMode.online),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDualOptionButton(
                        label: l10n?.searchQueryModeLocal ?? '本地查询',
                        selected: _queryMode == MedicineQueryMode.local,
                        onPressed: () =>
                            _switchQueryMode(MedicineQueryMode.local),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.searchDatabaseTitle ?? '数据库',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDualOptionButton(
                        label: l10n?.searchDatabaseSourceNmpa ?? 'NMPA',
                        selected:
                            _databaseSource == MedicineDatabaseSource.nmpa,
                        onPressed: () =>
                            _switchDatabaseSource(MedicineDatabaseSource.nmpa),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDualOptionButton(
                        label: l10n?.searchDatabaseSourceDrugbank ?? 'Drugbank',
                        selected:
                            _databaseSource == MedicineDatabaseSource.drugbank,
                        onPressed: () => _switchDatabaseSource(
                          MedicineDatabaseSource.drugbank,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l10n?.searchDatabaseCurrentHint(databaseLabel) ??
                      '当前数据库: $databaseLabel。Drugbank 暂未接入，联网查询仍走 NMPA（MySQL）。',
                  style: TextStyle(
                    fontSize: 11.8,
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSliver() {
    return ValueListenableBuilder<String>(
      valueListenable: _draftKeywordNotifier,
      builder: (context, draftKeyword, _) {
        if (_keyword.isEmpty && draftKeyword.isEmpty) {
          return _buildGuideSliver();
        }
        if (_keyword.isEmpty && draftKeyword.isNotEmpty) {
          return _buildReadySliver();
        }
        if (_loading && _results.isEmpty) {
          return _buildLoadingSliver();
        }
        if (_lastError != null && _results.isEmpty) {
          return _buildErrorSliver(_lastError!);
        }
        if (_results.isEmpty) {
          return _buildEmptySliver();
        }
        return _buildResultListSliver();
      },
    );
  }

  /// 构建快捷搜索标签区域。
  Widget _buildQuickTagsSliver() {
    final l10n = _l10n;
    final scheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: _buildSearchDecorCard(
          ornamentKey: widget.pickerMode
              ? 'search.picker.quickTags'
              : 'search.manual.quickTags',
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.searchQuickTagsTitle ?? '常用搜索',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickTags
                      .map(
                        (tag) => ActionChip(
                          onPressed: () => _applyQuickTag(tag),
                          side: BorderSide(
                            color: appTintedBorder(
                              context,
                              scheme.primary,
                              lightAlpha: 0.10,
                              darkAlpha: 0.18,
                            ),
                          ),
                          backgroundColor: appTintedSurface(
                            context,
                            scheme.primary,
                            lightAlpha: 0.05,
                            darkAlpha: 0.11,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          label: Text(
                            tag,
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建最近搜索历史区域。
  Widget _buildHistorySliver() {
    final l10n = _l10n;
    final scheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
        child: SearchSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      l10n?.searchHistoryTitle ?? '最近搜索',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _recentKeywords.isEmpty ? null : _clearHistory,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: scheme.onSurfaceVariant,
                      ),
                      child: Text(l10n?.searchHistoryClearAction ?? '清空'),
                    ),
                  ],
                ),
                if (_recentKeywords.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      l10n?.searchHistoryEmpty ?? '暂无搜索历史',
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  Column(
                    children: _recentKeywords
                        .map(
                          (keyword) => InkWell(
                            onTap: () => _applyQuickTag(keyword),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    size: 16,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      keyword,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.north_west_rounded,
                                    size: 16,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建“搜索结果”标题行。
  Widget _buildResultTitleSliver() {
    final l10n = _l10n;
    final scheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: Row(
          children: [
            Text(
              l10n?.searchResultTitle ?? '搜索结果',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${_keyword.isEmpty ? 0 : _results.length})',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            TintedStatusChip(
              text: _queryMode == MedicineQueryMode.online
                  ? (_l10n?.searchModeTagOnline ?? '联网')
                  : (_l10n?.searchModeTagLocal ?? '本地'),
              color: _queryMode == MedicineQueryMode.online
                  ? scheme.primary
                  : scheme.tertiary,
              showBorder: false,
              surfaceLightAlpha: 0.08,
              surfaceDarkAlpha: 0.16,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建真正的搜索结果列表。
  Widget _buildResultListSliver() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final item = _results[index];

          /// 把药品对象转换成卡片展示数据。
          final cardData = _toCardData(item);

          /// 当前药品在本地列表中的 identityKey。
          final identityKey = _buildIdentityKey(item);

          /// 当前药品是否已在“我的药品”中。
          final isAdded = _addedKeys.contains(identityKey);
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == _results.length - 1 ? 0 : 10,
            ),
            child: SearchResultCard(
              item: cardData,
              isAdded: isAdded,
              onTap: () {
                if (widget.pickerMode) {
                  Navigator.pop(context, item);
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MedicineDetailPage(initialItem: item),
                    ),
                  );
                }
              },
              onAdd: isAdded ? null : () => _addToMyMedicines(item),
            ),
          );
        },
      ),
    );
  }

  /// 构建“还没输入也没搜索”时的搜索提示区域。
  Widget _buildGuideSliver() {
    final l10n = _l10n;
    final scheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: _buildSearchDecorCard(
          ornamentKey: widget.pickerMode
              ? 'search.picker.guide'
              : 'search.manual.guide',
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates_rounded, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n?.searchGuideTitle ?? '搜索提示',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _TipRow(
                  label: l10n?.searchGuideTipProductNameLabel ?? '产品名称',
                  example:
                      l10n?.searchGuideTipProductNameExample ?? '阿莫西林胶囊、布洛芬片',
                ),
                _TipRow(
                  label: l10n?.searchGuideTipApprovalNoLabel ?? '批准文号',
                  example:
                      l10n?.searchGuideTipApprovalNoExample ?? '国药准字 H20013191',
                ),
                _TipRow(
                  label: l10n?.searchGuideTipManufacturerLabel ?? '生产单位',
                  example:
                      l10n?.searchGuideTipManufacturerExample ?? '石药集团、华润三九',
                ),
                _TipRow(
                  label: l10n?.searchGuideTipDrugCodeLabel ?? '药品编码',
                  example:
                      l10n?.searchGuideTipDrugCodeExample ??
                      '86901000000000(本位码)',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建“输入了内容但还没真正搜索”时的引导区域。
  Widget _buildReadySliver() {
    final l10n = _l10n;
    final scheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: _buildSearchDecorCard(
          ornamentKey: widget.pickerMode
              ? 'search.picker.ready'
              : 'search.manual.ready',
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Icon(Icons.keyboard_return_rounded, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n?.searchReadyHint ?? '按下"搜索"或回车键开始查询药品数据库',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建首屏搜索中的 loading 区域。
  Widget _buildLoadingSliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  /// 构建分页加载中的 loading 区域。
  Widget _buildLoadingMoreSliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  /// 构建空结果占位区域。
  Widget _buildEmptySliver() {
    final l10n = _l10n;
    final scheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 38,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.searchEmptyTitle ?? '暂无匹配结果',
                style: TextStyle(
                  fontSize: 15,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n?.searchEmptySubtitle ?? '可尝试产品名称、批准文号或生产单位重新搜索',
                style: TextStyle(
                  fontSize: 12.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建搜索失败时的错误区域。
  Widget _buildErrorSliver(String message) {
    final l10n = _l10n;
    final scheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 26, 16, 10),
        child: _buildSearchDecorCard(
          ornamentKey: widget.pickerMode
              ? 'search.picker.error'
              : 'search.manual.error',
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.searchErrorTitle ?? '查询失败',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonal(
                          onPressed: () => _search(reset: true),
                          style: FilledButton.styleFrom(
                            foregroundColor: scheme.onSurface,
                            backgroundColor: appTintedSurface(
                              context,
                              scheme.primary,
                              lightAlpha: 0.06,
                              darkAlpha: 0.12,
                            ),
                            minimumSize: const Size(88, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n?.searchRetryAction ?? '重试'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 点击快捷标签/历史记录时直接应用关键词并触发搜索。
  ///
  /// 与手动输入再提交相比，这里会一步完成：
  /// 1. 回填输入框；
  /// 2. 同步 `_draftKeyword/_keyword`；
  /// 3. 更新最近搜索；
  /// 4. 直接发起 reset 搜索。
  void _applyQuickTag(String tag) {
    _searchController.text = tag;
    _searchController.selection = TextSelection.collapsed(offset: tag.length);
    setState(() {
      _lastError = null;
      _keyword = tag;
      _updateRecentKeywords(tag);
    });
    _search(reset: true);
  }

  /// 提交搜索。
  ///
  /// 该方法是“用户确认搜索”的入口，会把输入框内容从 `_draftKeyword`
  /// 提交到 `_keyword`，再触发一次重置搜索。
  void _commitSearch() {
    final l10n = _l10n;

    /// 输入框中当前的关键词。
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      ToastUtils.instance.show(
        context,
        l10n?.searchCommitEmptyToast ?? '请输入产品名称、批准文号或生产单位后再搜索',
      );
      return;
    }
    setState(() {
      _lastError = null;
      _keyword = keyword;
      _updateRecentKeywords(keyword);
    });
    _search(reset: true);
    FocusScope.of(context).unfocus();
  }

  /// 清空当前搜索内容与结果列表。
  ///
  /// 这是一次完整的“回到初始搜索态”：
  /// - 输入态清空；
  /// - 请求态清空；
  /// - 错误态清空；
  /// - 分页态重置。
  void _clearKeyword() {
    _searchController.clear();
    setState(() {
      _keyword = '';
      _lastError = null;
      _results.clear();
      _hasMore = false;
      _page = 1;
    });
  }

  /// 清空最近搜索历史。
  void _clearHistory() {
    final l10n = _l10n;
    setState(() {
      _recentKeywords.clear();
      _historyClearedByUser = true;
      _seededRecentKeywords = null;
    });
    ToastUtils.instance.show(
      context,
      l10n?.searchHistoryClearedToast ?? '最近搜索已清空',
    );
  }

  /// 更新最近搜索列表。
  ///
  /// 规则：
  /// - 相同关键词去重后移到最前；
  /// - 最多保留 8 条。
  void _updateRecentKeywords(String keyword) {
    _historyClearedByUser = false;
    _seededRecentKeywords = null;
    _recentKeywords.remove(keyword);
    _recentKeywords.insert(0, keyword);
    if (_recentKeywords.length > 8) {
      _recentKeywords.removeLast();
    }
  }

  /// 将 `MedicineItem` 转为搜索结果卡片所需的数据对象。
  SearchResultItemData _toCardData(MedicineItem item) {
    final l10n = _l10n;

    /// 卡片下方的补充提示。
    final tips = item.approvalNo.isNotEmpty
        ? (l10n?.searchApprovalNoPrefix(item.approvalNo) ??
              '批准文号: ${item.approvalNo}')
        : item.displayTips;
    return SearchResultItemData(
      name: item.displayName,
      subtitle: item.displaySubtitle,
      tips: tips,
      badge: item.displayBadge,
    );
  }

  /// 生成药品的 identityKey。
  ///
  /// 优先级：drugCode > approvalNo > productName。
  String _buildIdentityKey(MedicineItem item) {
    return myMedicineRepository.buildScopedIdentityKeyFromMedicine(
      item,
      userId: _userId,
    );
  }

  /// 将一条搜索结果加入“我的药品”。
  ///
  /// 成功后除了写库，还会立即把 identityKey 放进 `_addedKeys`，
  /// 这样当前页面不需要重新查库就能同步按钮状态。
  Future<void> _addToMyMedicines(MedicineItem item) async {
    final l10n = _l10n;

    /// 当前药品的唯一 identityKey。
    final identityKey = _buildIdentityKey(item);
    try {
      final result = await myMedicineRepository.addMedicine(
        item: item,
        source: 'search',
        userId: _userId,
      );
      if (!mounted) return;
      if (!result.added) {
        ToastUtils.instance.show(
          context,
          l10n?.searchAlreadyAddedToast ?? '该药品已在我的药品列表中',
        );
        setState(() {
          _addedKeys.add(identityKey);
        });
        return;
      }
      setState(() {
        _addedKeys.add(identityKey);
      });
      ToastUtils.instance.show(
        context,
        _userId.isNotEmpty && !result.remoteSynced
            ? (l10n?.searchAddedPendingSyncToast ?? '已添加到我的药品，待同步到云端')
            : (l10n?.searchAddedToast ?? '已添加到我的药品'),
      );
    } catch (e) {
      if (!mounted) return;
      ToastUtils.instance.show(
        context,
        l10n?.searchAddFailedToast ?? '添加失败，请重试',
      );
    }
  }

  /// 执行搜索请求。
  ///
  /// - `reset=true`：重置结果并从第一页开始搜；
  /// - `reset=false`：在已有结果后继续加载下一页。
  ///
  /// 这里把“首屏搜索”和“分页搜索”合并在一个方法里，核心原因是它们共用：
  /// - 同一组接口参数；
  /// - 同一套结果合并逻辑；
  /// - 同一套异常处理。
  ///
  /// 区别主要体现在进入方法前如何准备状态：
  /// - reset：清空旧结果、页码回到 1、展示首屏 loading；
  /// - load more：保留旧结果、只打开底部 loading。
  Future<void> _search({required bool reset}) async {
    /// 真正用于请求的关键词。
    final keyword = _keyword.trim();
    if (keyword.isEmpty) {
      return;
    }

    final requestId = ++_searchRequestId;
    final requestPage = reset ? 1 : _page;

    if (reset) {
      setState(() {
        _loading = true;
        _loadingMore = false;
        _lastError = null;
        _page = 1;
        _hasMore = false;
        _results.clear();
      });
    } else {
      if (_loadingMore || _loading || !_hasMore) {
        return;
      }
      setState(() {
        _loadingMore = true;
      });
    }

    try {
      /// 根据查询模式执行联网或本地查询。
      final result = _queryMode == MedicineQueryMode.local
          ? await localMedicineStore.search(
              keyword: keyword,
              page: requestPage,
              pageSize: _pageSize,
            )
          : widget.searchExecutor != null
          ? await widget.searchExecutor!(
              keyword: keyword,
              page: requestPage,
              pageSize: _pageSize,
            )
          : (await MedicineApi.search(
              keyword: keyword,
              page: requestPage,
              pageSize: _pageSize,
            )).result;

      if (!_canApplySearchResult(requestId, keyword)) {
        return;
      }

      setState(() {
        _results.addAll(result.items);
        _hasMore = result.hasMore;
        _page = result.page + 1;
      });
    } catch (e) {
      if (!_canApplySearchResult(requestId, keyword)) {
        return;
      }
      if (!mounted) {
        return;
      }

      if (_queryMode == MedicineQueryMode.online &&
          _isLikelyNetworkError(e.toString())) {
        setState(() {
          _queryMode = MedicineQueryMode.local;
        });
        await _search(reset: true);
        return;
      }

      final msg = MessageUtils.extractError(e);
      ToastUtils.instance.show(context, msg);
      if (reset) {
        setState(() {
          _lastError = msg;
        });
      }
    } finally {
      if (_isActiveSearchRequest(requestId) && mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  /// 下拉刷新时重新执行当前关键词搜索。
  Future<void> _refreshSearch() async {
    if (_keyword.trim().isEmpty) {
      await _loadAddedKeys();
      return;
    }
    await _search(reset: true);
  }

  bool _canApplySearchResult(int requestId, String keyword) {
    return mounted &&
        _isActiveSearchRequest(requestId) &&
        keyword == _keyword.trim();
  }

  bool _isActiveSearchRequest(int requestId) {
    return requestId == _searchRequestId;
  }

  bool _isLikelyNetworkError(String message) {
    final text = message.toLowerCase();
    return text.contains('socket') ||
        text.contains('network') ||
        text.contains('connection') ||
        text.contains('xmlhttprequest') ||
        text.contains('timeout') ||
        text.contains('failed host lookup');
  }
}

/// 搜索提示卡片中的单行说明。
///
/// 用于统一渲染“字段名 + 示例值”的展示样式，避免在页面主体里重复写布局。
class _TipRow extends StatelessWidget {
  /// 创建搜索提示行（字段标签 + 示例值）。
  const _TipRow({required this.label, required this.example});

  /// 左侧字段标签文案（例如“产品名称”）。
  final String label;

  /// 右侧示例文案（例如“阿莫西林胶囊、布洛芬片”）。
  final String example;

  /// 构建单行“字段标签 + 示例值”说明。
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: appTintedSurface(
                context,
                scheme.primary,
                lightAlpha: 0.10,
                darkAlpha: 0.18,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              example,
              style: TextStyle(
                fontSize: 12.5,
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
