part of '../search.dart';

extension _SearchStateSlivers on _SearchPageState {
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
}
