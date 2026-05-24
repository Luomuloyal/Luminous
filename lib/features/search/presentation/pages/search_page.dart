part of '../search.dart';

// 手动搜索页（当前在线查询走现有后端药品库，后端目标栈将迁往 NestJS + PostgreSQL）。
//
// 数据库字段说明：
//   productName            - 产品名称（主搜索字段）
//   approvalNo             - 批准文号（国药准字 HXXXXXXXX）
//   manufacturer           - 生产单位
//   marketingAuthorization - 上市许可持有人
//   dosageForm             - 剂型（片剂/胶囊/注射液等）
//   specification          - 规格（如 0.5g、10ml 等）
//   drugCode               - 药品编码（本位码）
//   serialNo               - 序号
//
// 搜索逻辑：
// - `_draftKeyword`：输入框实时内容（未提交）
// - `_keyword`：已提交的搜索关键词（触发请求）
// - 滚动到底部自动加载下一页
/// 手动搜索页。
///
/// 页面支持药品库关键词搜索、最近搜索、快捷标签，以及滚动分页加载。
class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.pickerMode = false,
    this.initialKeyword = '',
    this.autoSearchOnInit = false,
    this.searchExecutor,
    this.controller,
  });

  final bool pickerMode;
  final String initialKeyword;
  final bool autoSearchOnInit;
  final MedicineSearchExecutor? searchExecutor;
  final SearchController? controller;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final SearchController _controller =
      widget.controller ??
      SearchController(
        pickerMode: widget.pickerMode,
        initialKeyword: widget.initialKeyword,
        autoSearchOnInit: widget.autoSearchOnInit,
        searchExecutor: widget.searchExecutor,
      );

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

  TextEditingController get _searchController => _controller.searchController;
  ValueNotifier<String> get _draftKeywordNotifier =>
      _controller.draftKeywordNotifier;
  ScrollController get _scrollController => _controller.scrollController;
  List<String> get _recentKeywords => _controller.recentKeywords;
  String get _keyword => _controller.keyword;
  String? get _lastError => _controller.lastError;
  List<MedicineItem> get _results => _controller.results;
  Set<String> get _addedKeys => _controller.addedKeys;
  bool get _loading => _controller.loading;
  bool get _loadingMore => _controller.loadingMore;
  MedicineQueryMode get _queryMode => _controller.queryMode;
  bool get _showSlowSearchHint => _controller.showSlowSearchHint;

  AppLocalizations? get _l10n => AppLocalizations.of(context);
  double get _pageOrnamentVisibilityScale => widget.pickerMode ? 1.0 : 0.2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.applyLocalizedRecentDefaults(_defaultRecentKeywords());
  }

  List<String> _defaultRecentKeywords() {
    return _quickTags.take(3).toList();
  }

  String _queryModeLabel(AppLocalizations? l10n) =>
      _queryMode == MedicineQueryMode.online
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
    return GetBuilder<SearchController>(
      init: _controller,
      global: false,
      builder: (_) {
        final scheme = Theme.of(context).colorScheme;
        final hasCommittedSearch = _keyword.trim().isNotEmpty;
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
                    if (hasCommittedSearch && _loadingMore)
                      _buildLoadingMoreSliver(),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  SearchResultItemData _toCardData(MedicineItem item) {
    final locale = (_l10n?.localeName ?? 'zh').toLowerCase();
    return _controller.toCardData(item, isZh: locale.startsWith('zh'));
  }

  void _applyQuickTag(String tag) {
    _controller.applyQuickTag(tag);
  }

  void _commitSearch() {
    _controller.commitSearch(
      context,
      emptyToast: _l10n?.searchCommitEmptyToast ?? '请输入产品名称、批准文号或生产单位后再搜索',
    );
  }

  void _clearKeyword() {
    _controller.clearKeyword();
  }

  Future<void> _clearHistory() async {
    await _controller.clearHistory(
      context,
      clearedToast: _l10n?.searchHistoryClearedToast ?? '最近搜索已清空',
    );
  }

  String _buildIdentityKey(MedicineItem item) {
    return _controller.buildIdentityKey(item);
  }

  Future<void> _addToMyMedicines(MedicineItem item) async {
    await _controller.addToMyMedicines(
      context,
      item,
      alreadyAddedToast: _l10n?.searchAlreadyAddedToast ?? '该药品已在我的药品列表中',
      addedPendingSyncToast:
          _l10n?.searchAddedPendingSyncToast ?? '已添加到我的药品，待同步到云端',
      addedToast: _l10n?.searchAddedToast ?? '已添加到我的药品',
      addFailedToast: _l10n?.searchAddFailedToast ?? '添加失败，请重试',
    );
  }

  Future<void> _search({required bool reset}) async {
    await _controller.search(reset: reset);
  }

  Future<void> _refreshSearch() async {
    await _controller.refreshSearch();
  }
}
