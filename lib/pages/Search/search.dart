import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/medicine_api.dart';
import 'package:luminous/components/search.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/stores/my_medicine_repository.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';

typedef MedicineSearchExecutor =
    Future<MedicineSearchResult> Function({
      required String keyword,
      required int page,
      required int pageSize,
    });

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
  final List<String> _quickTags = const [
    '阿莫西林',
    '布洛芬',
    '维生素D',
    '头孢',
    '抗生素',
    '胃药',
  ];

  /// 最近搜索关键词列表。
  ///
  /// 当前仅做内存态演示，未持久化到本地。
  final List<String> _recentKeywords = ['阿莫西林', '布洛芬', '维生素D'];

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

  void _syncDraftKeyword() {
    final next = _searchController.text.trim();
    if (_draftKeywordNotifier.value == next) {
      return;
    }
    _draftKeywordNotifier.value = next;
  }

  /// 当前登录用户 id（未登录时为空字符串）。
  String get _userId => _userController.user.value?.id ?? '';

  /// 构建搜索页整体 UI。
  ///
  /// 页面会根据 `_keyword/_draftKeyword/_loading/_lastError/_results`
  /// 的组合状态，在“提示态 / 待提交态 / 加载态 / 错误态 / 结果态”之间切换。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshSearch,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildHeaderSliver(),
              _buildSearchBarSliver(),
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
    );
  }

  /// 构建顶部标题区域。
  Widget _buildHeaderSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.pickerMode ? '选择药品' : '手动搜索',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.pickerMode ? '从后端药品库搜索并选择' : '支持按药品名称、批准文号、生产单位搜索',
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建搜索输入框区域。
  Widget _buildSearchBarSliver() {
    return ValueListenableBuilder<String>(
      valueListenable: _draftKeywordNotifier,
      builder: (context, draftKeyword, _) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchSurfaceCard(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _commitSearch(),
                        decoration: InputDecoration(
                          hintText: '产品名称 / 批准文号 / 生产单位',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF0EA5E9),
                          ),
                          suffixIcon: draftKeyword.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: _clearKeyword,
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
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
                        backgroundColor: const Color(0xFF0EA5E9),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(76, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('搜索'),
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
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: SearchSurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '常用搜索',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
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
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          backgroundColor: const Color(0xFFF8FAFC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          label: Text(
                            tag,
                            style: const TextStyle(
                              color: Color(0xFF334155),
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
                    const Text(
                      '最近搜索',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _recentKeywords.isEmpty ? null : _clearHistory,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: const Color(0xFF64748B),
                      ),
                      child: const Text('清空'),
                    ),
                  ],
                ),
                if (_recentKeywords.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      '暂无搜索历史',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
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
                                  const Icon(
                                    Icons.history_rounded,
                                    size: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      keyword,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.north_west_rounded,
                                    size: 16,
                                    color: Color(0xFF94A3B8),
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
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: Row(
          children: [
            const Text(
              '搜索结果',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${_keyword.isEmpty ? 0 : _results.length})',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
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
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 26, 16, 10),
        child: SearchSurfaceCard(
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_rounded,
                      color: Color(0xFF0EA5E9),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '搜索提示',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _TipRow(label: '产品名称', example: '阿莫西林胶囊、布洛芬片'),
                _TipRow(label: '批准文号', example: '国药准字 H20013191'),
                _TipRow(label: '生产单位', example: '石药集团、华润三九'),
                _TipRow(label: '药品编码', example: '86901000000000(本位码)'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建“输入了内容但还没真正搜索”时的引导区域。
  Widget _buildReadySliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: SearchSurfaceCard(
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Icon(Icons.keyboard_return_rounded, color: Color(0xFF0EA5E9)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '按下"搜索"或回车键开始查询药品数据库',
                    style: TextStyle(
                      color: Color(0xFF475569),
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
        padding: EdgeInsets.fromLTRB(16, 26, 16, 10),
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
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 30, 16, 12),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 38,
                color: Color(0xFF94A3B8),
              ),
              SizedBox(height: 8),
              Text(
                '暂无匹配结果',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '可尝试产品名称、批准文号或生产单位重新搜索',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建搜索失败时的错误区域。
  Widget _buildErrorSliver(String message) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 26, 16, 10),
        child: SearchSurfaceCard(
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
                      const Text(
                        '查询失败',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF475569),
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
                            foregroundColor: const Color(0xFF0F172A),
                            backgroundColor: const Color(0xFFF1F5F9),
                            minimumSize: const Size(88, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('重试'),
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
    /// 输入框中当前的关键词。
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      ToastUtils.instance.show(context, '请输入产品名称、批准文号或生产单位后再搜索');
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
    setState(() {
      _recentKeywords.clear();
    });
    ToastUtils.instance.show(context, '最近搜索已清空');
  }

  /// 更新最近搜索列表。
  ///
  /// 规则：
  /// - 相同关键词去重后移到最前；
  /// - 最多保留 8 条。
  void _updateRecentKeywords(String keyword) {
    _recentKeywords.remove(keyword);
    _recentKeywords.insert(0, keyword);
    if (_recentKeywords.length > 8) {
      _recentKeywords.removeLast();
    }
  }

  /// 将 `MedicineItem` 转为搜索结果卡片所需的数据对象。
  SearchResultItemData _toCardData(MedicineItem item) {
    /// 卡片下方的补充提示。
    final tips = item.approvalNo.isNotEmpty
        ? '批准文号: ${item.approvalNo}'
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
        ToastUtils.instance.show(context, '该药品已在我的药品列表中');
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
            ? '已添加到我的药品，待同步到云端'
            : '已添加到我的药品',
      );
    } catch (e) {
      if (!mounted) return;
      ToastUtils.instance.show(context, '添加失败，请重试');
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

    if (reset) {
      if (_loading) {
        return;
      }
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
      /// 调用药品搜索接口获取当前页结果。
      final result = widget.searchExecutor != null
          ? await widget.searchExecutor!(
              keyword: keyword,
              page: _page,
              pageSize: _pageSize,
            )
          : (await MedicineApi.search(
              keyword: keyword,
              page: _page,
              pageSize: _pageSize,
            )).result;

      if (!mounted) {
        return;
      }

      setState(() {
        _results.addAll(result.items);
        _hasMore = result.hasMore;
        _page = result.page + 1;
      });
    } catch (e) {
      if (!mounted) {
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
      if (mounted) {
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0369A1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              example,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
