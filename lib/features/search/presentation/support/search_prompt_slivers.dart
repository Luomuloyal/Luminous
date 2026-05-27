part of '../search.dart';

extension _SearchPromptSlivers on _SearchPageState {
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
                    padding: const EdgeInsets.only(bottom: 6),
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

  Widget _buildResultListSliver() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      sliver: SliverList.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final item = _results[index];
          final cardData = _toCardData(item);
          final identityKey = _buildIdentityKey(item);
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
                  context.push('/medicine-detail', extra: item);
                }
              },
              onAdd: isAdded ? null : () => _addToMyMedicines(item),
            ),
          );
        },
      ),
    );
  }
}
