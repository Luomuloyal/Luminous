import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/search.dart';
import 'package:luminous/components/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/pages/Search/controllers/search_controller.dart'
    as search_page;
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/viewmodels/search.dart';

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
    this.controller,
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
  final search_page.MedicineSearchExecutor? searchExecutor;

  /// 可选外部 controller，便于测试或复用页面状态。
  final search_page.SearchController? controller;

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
  late final search_page.SearchController _controller =
      widget.controller ??
      search_page.SearchController(
        pickerMode: widget.pickerMode,
        initialKeyword: widget.initialKeyword,
        autoSearchOnInit: widget.autoSearchOnInit,
        searchExecutor: widget.searchExecutor,
      );

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.applyLocalizedRecentDefaults(_defaultRecentKeywords());
  }

  List<String> _defaultRecentKeywords() {
    return _quickTags.take(3).toList();
  }

  String _queryModeLabel(AppLocalizations? l10n) =>
      _queryMode == search_page.MedicineQueryMode.online
      ? (l10n?.searchQueryModeOnline ?? '联网查询')
      : (l10n?.searchQueryModeLocal ?? '本地查询');

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
  search_page.MedicineQueryMode get _queryMode => _controller.queryMode;
  bool get _showSlowSearchHint => _controller.showSlowSearchHint;

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  double get _pageOrnamentVisibilityScale => widget.pickerMode ? 1.0 : 0.2;

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

  /// 构建搜索页整体 UI。
  ///
  /// 页面会根据 `_keyword/_draftKeyword/_loading/_lastError/_results`
  /// 的组合状态，在“提示态 / 待提交态 / 加载态 / 错误态 / 结果态”之间切换。
  @override
  Widget build(BuildContext context) {
    return GetBuilder<search_page.SearchController>(
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
                  child: Row(
                    children: [
                      Flexible(
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
                      if (!widget.pickerMode) ...[
                        const SizedBox(width: 8),
                        Text(
                          _queryModeLabel(l10n),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (widget.pickerMode) ...[
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
                                '可按名称/文号/厂家搜索'),
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
            child: _buildSearchDecorCard(
              ornamentKey: widget.pickerMode
                  ? 'search.picker.searchBar'
                  : 'search.manual.searchBar',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
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
                            fontSize: 12,
                          ),
                          hintMaxLines: 1,
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: scheme.primary,
                            size: 20,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          suffixIcon: draftKeyword.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: _clearKeyword,
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                          suffixIconConstraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          filled: true,
                          fillColor: appTintedSurface(
                            context,
                            scheme.primary,
                            lightAlpha: 0.05,
                            darkAlpha: 0.11,
                            baseColor:
                                theme.inputDecorationTheme.fillColor ??
                                (theme.cardTheme.color ?? scheme.surface),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: appTintedBorder(
                                context,
                                scheme.primary,
                                lightAlpha: 0.14,
                                darkAlpha: 0.22,
                              ),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: appTintedBorder(
                                context,
                                scheme.primary,
                                lightAlpha: 0.14,
                                darkAlpha: 0.22,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: appTintedBorder(
                                context,
                                scheme.primary,
                                lightAlpha: 0.28,
                                darkAlpha: 0.34,
                              ),
                              width: 1.3,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton(
                          onPressed: _commitSearch,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(64, 38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n?.searchActionSearch ?? '搜索'),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          child: _loading && _showSlowSearchHint
                              ? Padding(
                                  key: const ValueKey<String>('searching-hint'),
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    '查询中...',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  key: ValueKey<String>('searching-hint-empty'),
                                  height: 0,
                                ),
                        ),
                      ],
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
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
        child: _buildSearchDecorCard(
          ornamentKey: widget.pickerMode
              ? 'search.picker.quickTags'
              : 'search.manual.quickTags',
          child: Padding(
            padding: const EdgeInsets.all(10),
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
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
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
        child: SearchSurfaceCard(
          ornamentVisibilityScale: _pageOrnamentVisibilityScale,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
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
                    padding: EdgeInsets.only(bottom: 6),
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
                                vertical: 6,
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
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
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
              text: _queryMode == search_page.MedicineQueryMode.online
                  ? (_l10n?.searchModeTagOnline ?? '联网')
                  : (_l10n?.searchModeTagLocal ?? '本地'),
              color: _queryMode == search_page.MedicineQueryMode.online
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
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
              bottom: index == _results.length - 1 ? 0 : 8,
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
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
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
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
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
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
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
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 8),
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
    _controller.applyQuickTag(tag);
  }

  /// 提交搜索。
  ///
  /// 该方法是“用户确认搜索”的入口，会把输入框内容从 `_draftKeyword`
  /// 提交到 `_keyword`，再触发一次重置搜索。
  void _commitSearch() {
    _controller.commitSearch(
      context,
      emptyToast: _l10n?.searchCommitEmptyToast ?? '请输入产品名称、批准文号或生产单位后再搜索',
    );
  }

  /// 清空当前搜索内容与结果列表。
  ///
  /// 这是一次完整的“回到初始搜索态”：
  /// - 输入态清空；
  /// - 请求态清空；
  /// - 错误态清空；
  /// - 分页态重置。
  void _clearKeyword() {
    _controller.clearKeyword();
  }

  /// 清空最近搜索历史。
  Future<void> _clearHistory() async {
    await _controller.clearHistory(
      context,
      clearedToast: _l10n?.searchHistoryClearedToast ?? '最近搜索已清空',
    );
  }

  /// 将 `MedicineItem` 转为搜索结果卡片所需的数据对象。
  SearchResultItemData _toCardData(MedicineItem item) {
    final locale = (_l10n?.localeName ?? 'zh').toLowerCase();
    return _controller.toCardData(item, isZh: locale.startsWith('zh'));
  }

  /// 生成药品的 identityKey。
  ///
  /// 优先级：drugCode > approvalNo > productName。
  String _buildIdentityKey(MedicineItem item) {
    return _controller.buildIdentityKey(item);
  }

  /// 将一条搜索结果加入“我的药品”。
  ///
  /// 成功后除了写库，还会立即把 identityKey 放进 `_addedKeys`，
  /// 这样当前页面不需要重新查库就能同步按钮状态。
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
    await _controller.search(reset: reset);
  }

  /// 下拉刷新时重新执行当前关键词搜索。
  Future<void> _refreshSearch() async {
    await _controller.refreshSearch();
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
