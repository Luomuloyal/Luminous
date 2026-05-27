part of '../search.dart';

/// 手动搜索页。
///
/// 页面支持药品库关键词搜索、最近搜索、快捷标签，以及滚动分页加载。
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({
    super.key,
    this.pickerMode = false,
    this.initialKeyword = '',
    this.autoSearchOnInit = false,
    this.searchExecutor,
  });

  final bool pickerMode;
  final String initialKeyword;
  final bool autoSearchOnInit;
  final MedicineSearchExecutor? searchExecutor;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<String> _draftKeywordNotifier = ValueNotifier<String>('');
  bool _initialized = false;

  // ── 兼容 getter（供 support/*.dart extension 使用） ──

  TextEditingController get _searchController => _searchTextController;

  // 兼容 getter：support 文件通过 _SearchPageState extension 访问这些字段
  SearchState get _searchState => ref.read(searchProvider);
  bool get _loading => _searchState.loading;
  bool get _showSlowSearchHint => _searchState.showSlowSearchHint;
  List<String> get _recentKeywords => _searchState.recentKeywords;
  String get _keyword => _searchState.keyword;
  List<MedicineItem> get _results => _searchState.results;
  String? get _lastError => _searchState.lastError;
  Set<String> get _addedKeys => _searchState.addedKeys;
  MedicineQueryMode get _queryMode => _searchState.queryMode;

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

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  double get _pageOrnamentVisibilityScale => widget.pickerMode ? 1.0 : 0.2;

  @override
  void initState() {
    super.initState();
    _searchTextController.addListener(_syncDraftKeyword);
    _scrollController.addListener(_handleScroll);

    // 延迟初始化，避免在 build 期间修改 provider。
    Future(() {
      if (!mounted) return;
      _initialize();
    });
  }

  void _initialize() {
    if (_initialized) return;
    _initialized = true;

    final notifier = ref.read(searchProvider.notifier);
    notifier.initialize(
      pickerMode: widget.pickerMode,
      initialKeyword: widget.initialKeyword,
      autoSearchOnInit: widget.autoSearchOnInit,
    );

    final normalized = widget.initialKeyword.trim();
    if (normalized.isNotEmpty) {
      _searchTextController.text = normalized;
      _searchTextController.selection = TextSelection.collapsed(
        offset: normalized.length,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      if (mounted) {
        ref.read(searchProvider.notifier).applyLocalizedRecentDefaults(
          _defaultRecentKeywords(),
        );
      }
    });
  }

  List<String> _defaultRecentKeywords() {
    return _quickTags.take(3).toList();
  }

  @override
  void dispose() {
    _searchTextController.removeListener(_syncDraftKeyword);
    _searchTextController.dispose();
    _scrollController.dispose();
    _draftKeywordNotifier.dispose();
    super.dispose();
  }

  String _queryModeLabel(AppLocalizations? l10n) =>
      ref.read(searchProvider).queryMode == MedicineQueryMode.online
          ? (l10n?.searchQueryModeOnline ?? '联网查询')
          : (l10n?.searchQueryModeLocal ?? '本地查询');

  SearchSurfaceCard _buildSearchDecorCard({
    required String ornamentKey,
    required Widget child,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SearchSurfaceCard(
      decorated: true,
      accentColor: scheme.primary,
      secondaryColor: Color.lerp(scheme.secondary, scheme.tertiary, 0.45)!,
      ornamentKey: ornamentKey,
      ornamentVisibilityScale: _pageOrnamentVisibilityScale,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final scheme = Theme.of(context).colorScheme;
    final hasCommittedSearch = searchState.keyword.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
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
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                _buildHeaderSliver(),
                _buildSearchBarSliver(),
                if (!hasCommittedSearch) ...[
                  _buildQuickTagsSliver(),
                  _buildHistorySliver(),
                ],
                if (hasCommittedSearch) _buildResultTitleSliver(),
                _buildContentSliver(),
                if (hasCommittedSearch && searchState.loadingMore)
                  _buildLoadingMoreSliver(),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 事件转发 ──

  void _syncDraftKeyword() {
    final next = _searchTextController.text.trim();
    if (_draftKeywordNotifier.value != next) {
      _draftKeywordNotifier.value = next;
    }
    ref.read(searchProvider.notifier).syncDraftKeyword(
      _searchTextController.text,
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    ref.read(searchProvider.notifier).handleScroll(
      _scrollController.position.maxScrollExtent,
      _scrollController.offset,
    );
  }

  SearchResultItemData _toCardData(MedicineItem item) {
    final locale = (_l10n?.localeName ?? 'zh').toLowerCase();
    return ref.read(searchProvider.notifier).toCardData(
      item,
      isZh: locale.startsWith('zh'),
    );
  }

  void _applyQuickTag(String tag) {
    _searchTextController.text = tag;
    _searchTextController.selection = TextSelection.collapsed(
      offset: tag.length,
    );
    ref.read(searchProvider.notifier).applyQuickTag(tag);
  }

  void _commitSearch() {
    final text = _searchTextController.text.trim();
    if (text.isEmpty) {
      ToastUtils.instance.show(
        context,
        _l10n?.searchCommitEmptyToast ?? '请输入产品名称、批准文号或生产单位后再搜索',
      );
      return;
    }
    ref.read(searchProvider.notifier).commitSearch(text);
    FocusScope.of(context).unfocus();
  }

  void _clearKeyword() {
    _searchTextController.clear();
    ref.read(searchProvider.notifier).clearKeyword();
  }

  Future<void> _clearHistory() async {
    await ref.read(searchProvider.notifier).clearHistory();
    if (!mounted) return;
    ToastUtils.instance.show(
      context,
      _l10n?.searchHistoryClearedToast ?? '最近搜索已清空',
    );
  }

  String _buildIdentityKey(MedicineItem item) {
    return ref.read(searchProvider.notifier).buildIdentityKey(item);
  }

  Future<void> _addToMyMedicines(MedicineItem item) async {
    final result = await ref
        .read(searchProvider.notifier)
        .addToMyMedicines(item);
    if (!mounted) return;

    if (!result.added) {
      ToastUtils.instance.show(
        context,
        _l10n?.searchAlreadyAddedToast ?? '该药品已在我的药品列表中',
      );
      return;
    }
    ToastUtils.instance.show(
      context,
      ref.read(currentUserProvider)?.id != null &&
              !result.remoteSynced
          ? (_l10n?.searchAddedPendingSyncToast ?? '已添加到我的药品，待同步到云端')
          : (_l10n?.searchAddedToast ?? '已添加到我的药品'),
    );
  }

  Future<void> _search({required bool reset}) async {
    await ref.read(searchProvider.notifier).search(reset: reset);
  }

  Future<void> _refreshSearch() async {
    await ref.read(searchProvider.notifier).refreshSearch();
  }
}
