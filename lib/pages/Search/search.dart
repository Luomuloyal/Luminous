import 'package:flutter/material.dart';
import 'package:luminous/api/medicine_api.dart';
import 'package:luminous/components/search.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickTags = const ['退烧', '抗生素', '止咳', '过敏', '胃药', '维生素'];

  final List<String> _recentKeywords = ['阿莫西林', '布洛芬', '维生素D'];

  String _keyword = '';
  String _draftKeyword = '';

  final List<MedicineItem> _results = [];
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) {
        return;
      }
      if (_keyword.isEmpty || !_hasMore || _loadingMore || _loading) {
        return;
      }
      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      if (current >= maxScroll - 120) {
        _search(reset: false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildHeaderSliver(),
            _buildSearchBarSliver(),
            _buildQuickTagsSliver(),
            _buildHistorySliver(),
            _buildResultTitleSliver(),
            if (_keyword.isEmpty && _draftKeyword.isEmpty)
              _buildGuideSliver()
            else if (_keyword.isEmpty && _draftKeyword.isNotEmpty)
              _buildReadySliver()
            else if (_loading && _results.isEmpty)
              _buildLoadingSliver()
            else if (_results.isEmpty)
              _buildEmptySliver()
            else
              _buildResultListSliver(),
            if (_keyword.isNotEmpty && _loadingMore) _buildLoadingMoreSliver(),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

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
                const Expanded(
                  child: Text(
                    '手动搜索',
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
            const Text(
              '输入药名、成分或症状快速查找',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarSliver() {
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
                    onChanged: (value) {
                      setState(() {
                        _draftKeyword = value.trim();
                      });
                    },
                    onSubmitted: (_) => _commitSearch(),
                    decoration: InputDecoration(
                      hintText: '请输入药名/症状/成分',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF0EA5E9),
                      ),
                      suffixIcon: _draftKeyword.isEmpty
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
  }

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
                  '快捷搜索',
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

  Widget _buildResultListSliver() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final item = _results[index];
          final cardData = _toCardData(item);
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == _results.length - 1 ? 0 : 10,
            ),
            child: SearchResultCard(
              item: cardData,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MedicineDetailPage(initialItem: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuideSliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 26, 16, 10),
        child: SearchSurfaceCard(
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_rounded, color: Color(0xFF0EA5E9)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '输入药品名称、批准文号或生产单位后点击搜索，即可从药品数据库查询信息。',
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
                    '按下“搜索”开始查询药品数据库。',
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
                '可尝试更换关键词重新搜索',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyQuickTag(String tag) {
    _searchController.text = tag;
    _searchController.selection = TextSelection.collapsed(offset: tag.length);
    setState(() {
      _draftKeyword = tag;
      _keyword = tag;
      _updateRecentKeywords(tag);
    });
    _search(reset: true);
  }

  void _commitSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      ToastUtils.instance.show(context, '请输入药名、成分或症状后再搜索');
      return;
    }
    setState(() {
      _draftKeyword = keyword;
      _keyword = keyword;
      _updateRecentKeywords(keyword);
    });
    _search(reset: true);
    FocusScope.of(context).unfocus();
  }

  void _clearKeyword() {
    _searchController.clear();
    setState(() {
      _keyword = '';
      _draftKeyword = '';
      _results.clear();
      _hasMore = false;
      _page = 1;
    });
  }

  void _clearHistory() {
    setState(() {
      _recentKeywords.clear();
    });
    ToastUtils.instance.show(context, '最近搜索已清空');
  }

  void _updateRecentKeywords(String keyword) {
    _recentKeywords.remove(keyword);
    _recentKeywords.insert(0, keyword);
    if (_recentKeywords.length > 8) {
      _recentKeywords.removeLast();
    }
  }

  SearchResultItemData _toCardData(MedicineItem item) {
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

  Future<void> _search({required bool reset}) async {
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
      final response = await MedicineApi.search(
        keyword: keyword,
        page: _page,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      final result = response.result;
      setState(() {
        _results.addAll(result.items);
        _hasMore = result.hasMore;
        _page = result.page + 1;
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
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }
}
