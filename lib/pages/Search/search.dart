import 'package:flutter/material.dart';
import 'package:luminous/components/search.dart';
import 'package:luminous/utils/toast_utils.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _quickTags = const ['退烧', '抗生素', '止咳', '过敏', '胃药', '维生素'];

  final List<SearchResultItemData> _allResults = const [
    SearchResultItemData(
      name: '阿莫西林胶囊',
      subtitle: '抗感染类 · 0.25g*24粒',
      tips: '青霉素过敏者禁用',
      badge: '抗生素',
    ),
    SearchResultItemData(
      name: '布洛芬缓释胶囊',
      subtitle: '解热镇痛类 · 0.3g*20粒',
      tips: '饭后服用，避免空腹',
      badge: '退烧止痛',
    ),
    SearchResultItemData(
      name: '氯雷他定片',
      subtitle: '抗过敏类 · 10mg*12片',
      tips: '服药后避免饮酒',
      badge: '过敏',
    ),
    SearchResultItemData(
      name: '奥美拉唑肠溶胶囊',
      subtitle: '胃药类 · 20mg*14粒',
      tips: '建议早餐前服用',
      badge: '胃药',
    ),
    SearchResultItemData(
      name: '维生素C片',
      subtitle: '维矿补充类 · 100mg*60片',
      tips: '长期补充请遵医嘱',
      badge: '维生素',
    ),
  ];

  final List<String> _recentKeywords = ['阿莫西林', '布洛芬', '维生素D'];

  String _keyword = '';

  List<SearchResultItemData> get _filteredResults {
    if (_keyword.isEmpty) {
      return _allResults.take(3).toList();
    }
    return _allResults.where((item) {
      return item.name.contains(_keyword) ||
          item.subtitle.contains(_keyword) ||
          item.badge.contains(_keyword);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeaderSliver(),
            _buildSearchBarSliver(),
            _buildQuickTagsSliver(),
            _buildHistorySliver(),
            _buildResultTitleSliver(),
            if (_filteredResults.isEmpty)
              _buildEmptySliver()
            else
              _buildResultListSliver(),
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
                        _keyword = value.trim();
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
                      suffixIcon: _keyword.isEmpty
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
              '(${_filteredResults.length})',
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
        itemCount: _filteredResults.length,
        itemBuilder: (context, index) {
          final item = _filteredResults[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == _filteredResults.length - 1 ? 0 : 10,
            ),
            child: SearchResultCard(
              item: item,
              onTap: () {
                ToastUtils.instance.show(context, '${item.name} 详情功能开发中');
              },
            ),
          );
        },
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
      _keyword = tag;
      _updateRecentKeywords(tag);
    });
  }

  void _commitSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      ToastUtils.instance.show(context, '请输入药名、成分或症状后再搜索');
      return;
    }
    setState(() {
      _keyword = keyword;
      _updateRecentKeywords(keyword);
    });
    FocusScope.of(context).unfocus();
  }

  void _clearKeyword() {
    _searchController.clear();
    setState(() {
      _keyword = '';
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
}
