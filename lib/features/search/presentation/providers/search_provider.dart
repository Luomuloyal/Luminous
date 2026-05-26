import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/api/medicine_api.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/drug/data/local_medicine_store.dart';
import 'package:luminous/features/drug/data/my_medicine_repository.dart';
import 'package:luminous/features/search/presentation/models/search.dart';
import 'package:luminous/shared/models/medicine.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Provider 注入 ──

final searchMyMedicineRepoProvider = Provider<MyMedicineRepository>(
  (ref) => myMedicineRepository,
);

final searchLocalStoreProvider = Provider<LocalMedicineStore>(
  (ref) => localMedicineStore,
);

typedef MedicineSearchExecutor = Future<MedicineSearchResult> Function({
  required String keyword,
  required int page,
  required int pageSize,
});

final searchExecutorProvider = Provider<MedicineSearchExecutor?>((ref) => null);

// ── 查询模式 ──

enum MedicineQueryMode { online, local }

// ── 状态模型 ──

class SearchState {
  const SearchState({
    this.recentKeywords = const [],
    this.results = const [],
    this.addedKeys = const {},
    this.loading = false,
    this.loadingMore = false,
    this.hasMore = false,
    this.showSlowSearchHint = false,
    this.keyword = '',
    this.lastError,
    this.queryMode = MedicineQueryMode.online,
    this.draftKeyword = '',
    this.recentHistoryReady = false,
    this.pickerMode = false,
    this.autoSearchOnInit = false,
    this.initialKeyword = '',
    this.page = 1,
    });

  final List<String> recentKeywords;
  final List<MedicineItem> results;
  final Set<String> addedKeys;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final bool showSlowSearchHint;
  final String keyword;
  final String? lastError;
  final MedicineQueryMode queryMode;
  final String draftKeyword;

  // 内部状态
  final bool recentHistoryReady;
  final bool pickerMode;
  final bool autoSearchOnInit;
  final String initialKeyword;
  final int page;
  SearchState copyWith({
    List<String>? recentKeywords,
    List<MedicineItem>? results,
    Set<String>? addedKeys,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    bool? showSlowSearchHint,
    String? keyword,
    String? lastError,
    MedicineQueryMode? queryMode,
    String? draftKeyword,
    bool? recentHistoryReady,
    bool? pickerMode,
    bool? autoSearchOnInit,
    String? initialKeyword,
    int? page,  }) {
    return SearchState(
      recentKeywords: recentKeywords ?? this.recentKeywords,
      results: results ?? this.results,
      addedKeys: addedKeys ?? this.addedKeys,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      showSlowSearchHint: showSlowSearchHint ?? this.showSlowSearchHint,
      keyword: keyword ?? this.keyword,
      lastError: lastError ?? this.lastError,
      queryMode: queryMode ?? this.queryMode,
      draftKeyword: draftKeyword ?? this.draftKeyword,
      recentHistoryReady: recentHistoryReady ?? this.recentHistoryReady,
      pickerMode: pickerMode ?? this.pickerMode,
      autoSearchOnInit: autoSearchOnInit ?? this.autoSearchOnInit,
      initialKeyword: initialKeyword ?? this.initialKeyword,
      page: page ?? this.page,    );
  }
}

// ── Notifier ──

class SearchNotifier extends Notifier<SearchState> {
  static const int _maxRecentKeywordCount = 8;
  static const String _recentKeywordsStoragePrefix =
      'search_recent_keywords_v1';
  static const int _pageSize = 20;

  MyMedicineRepository get _repo => ref.read(searchMyMedicineRepoProvider);
  LocalMedicineStore get _store => ref.read(searchLocalStoreProvider);

  int _searchRequestId = 0;
  Timer? _slowSearchHintTimer;
  List<String>? _seededRecentKeywords;
  bool _historyClearedByUser = false;
  bool _hasPersistedRecentKeywords = false;
  List<String> _localizedRecentDefaults = const <String>[];

  @override
  SearchState build() {
    ref.onDispose(() {
      _slowSearchHintTimer?.cancel();
    });

    ref.listen(currentUserProvider, (prev, next) {
      unawaited(_loadAddedKeys());
      unawaited(_loadRecentKeywords());
    });

    return const SearchState();
  }

  // ── 初始化 ──

  void initialize({
    required bool pickerMode,
    required String initialKeyword,
    required bool autoSearchOnInit,
  }) {
    state = state.copyWith(
      pickerMode: pickerMode,
      initialKeyword: initialKeyword,
      autoSearchOnInit: autoSearchOnInit,
    );

    final normalized = initialKeyword.trim();
    if (normalized.isNotEmpty) {
      state = state.copyWith(
        draftKeyword: normalized,
        keyword: autoSearchOnInit ? normalized : state.keyword,
      );
    }

    unawaited(_loadAddedKeys());
    unawaited(_loadRecentKeywords());
    unawaited(_detectInitialQueryMode());

    if (autoSearchOnInit && normalized.isNotEmpty) {
      Future.microtask(() => search(reset: true));
    }
  }

  // ── 我的药品 ──

  Future<void> _loadAddedKeys() async {
    try {
      final userId = _userId;
      final keys = await _repo.loadIdentityKeys(userId: userId);
      if ( _sameStringSet(state.addedKeys, keys)) return;
      state = state.copyWith(addedKeys: keys);
    } catch (e) {
      debugPrint('[search] _loadAddedKeys failed: $e');
    }
  }

  // ── 最近搜索 ──

  Future<void> _loadRecentKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storageKey);
    final sanitized = _sanitizeRecentKeywords(stored ?? const <String>[]);
    _hasPersistedRecentKeywords = stored != null;
    _historyClearedByUser = stored != null && sanitized.isEmpty;
    _seededRecentKeywords = null;
    _syncDefaultRecentKeywords(sanitized);
    state = state.copyWith(
      recentKeywords: sanitized,
      recentHistoryReady: true,
    );
  }

  void applyLocalizedRecentDefaults(List<String> defaults) {
    final sanitized = _sanitizeRecentKeywords(defaults);
    if (_sameStringList(_localizedRecentDefaults, sanitized)) return;
    _localizedRecentDefaults = sanitized;
    final updated = _buildSyncedKeywords(state.recentKeywords);
    {
      state = state.copyWith(recentKeywords: updated);
    }
  }

  List<String> _buildSyncedKeywords(List<String> current) {
    if (!state.recentHistoryReady || _hasPersistedRecentKeywords) {
      return current;
    }
    if (_localizedRecentDefaults.isEmpty) return current;

    final defaults = List<String>.from(_localizedRecentDefaults);
    if (current.isEmpty) {
      if (_historyClearedByUser) return current;
      _seededRecentKeywords = List<String>.from(defaults);
      return defaults;
    }

    final seeded = _seededRecentKeywords;
    if (seeded == null || !_sameStringList(current, seeded)) return current;
    if (_sameStringList(current, defaults)) return current;

    _seededRecentKeywords = List<String>.from(defaults);
    return defaults;
  }

  void _syncDefaultRecentKeywords(List<String> current) {
    final updated = _buildSyncedKeywords(current);
    if (!_sameStringList(state.recentKeywords, updated)) {
      state = state.copyWith(recentKeywords: updated);
    }
  }

  // ── 查询模式 ──

  Future<void> _detectInitialQueryMode() async {
    final reachable = await MedicineApi.isBackendReachable();
    if ( reachable) return;
    state = state.copyWith(queryMode: MedicineQueryMode.local);
  }

  // ── 快捷标签 ──

  void applyQuickTag(String tag) {
    final normalized = tag.trim();
    if (normalized.isEmpty) return;

    _updateRecentKeywords(normalized);
    state = state.copyWith(
      draftKeyword: normalized,
      keyword: normalized,
      lastError: null,
    );
    unawaited(_persistRecentKeywords());
    unawaited(search(reset: true));
  }

  // ── 提交搜索 ──

  void commitSearch(String keyword) {
    final normalized = keyword.trim();
    if (normalized.isEmpty) return;

    _updateRecentKeywords(normalized);
    state = state.copyWith(
      keyword: normalized,
      lastError: null,
    );
    unawaited(_persistRecentKeywords());
    unawaited(search(reset: true));
  }

  void clearKeyword() {
    state = state.copyWith(
      keyword: '',
      draftKeyword: '',
      lastError: null,
      results: const [],
      hasMore: false,
      page: 1,
    );
  }

  Future<void> clearHistory() async {
    _historyClearedByUser = true;
    _seededRecentKeywords = null;
    _hasPersistedRecentKeywords = true;
    state = state.copyWith(recentKeywords: const []);
    await _persistRecentKeywords();
  }

  // ── 药品操作 ──

  SearchResultItemData toCardData(MedicineItem item, {required bool isZh}) {
    final manufacturer = item.manufacturer.trim().isNotEmpty
        ? item.manufacturer.trim()
        : item.marketingAuthorizationHolder.trim();
    final tips = manufacturer.isNotEmpty
        ? (isZh ? '生产单位: $manufacturer' : 'Manufacturer: $manufacturer')
        : item.displayTips;
    return SearchResultItemData(
      name: item.displayName,
      subtitle: item.displaySubtitle,
      tips: tips,
      badge: item.displayBadge,
    );
  }

  String buildIdentityKey(MedicineItem item) {
    return _repo.buildScopedIdentityKeyFromMedicine(
      item,
      userId: _userId,
    );
  }

  Future<SaveMedicineResult> addToMyMedicines(MedicineItem item) async {
    final identityKey = buildIdentityKey(item);
    try {
      final result = await _repo.addMedicine(
        item: item,
        source: 'search',
        userId: _userId,
      );
      if (!result.added) {
        state = state.copyWith(
          addedKeys: {...state.addedKeys, identityKey},
        );
        return result;
      }
      state = state.copyWith(
        addedKeys: {...state.addedKeys, identityKey},
      );
      return result;
    } catch (_) {
      rethrow;
    }
  }

  // ── 搜索 ──

  Future<void> search({required bool reset}) async {
    final normalizedKeyword = state.keyword.trim();
    if (normalizedKeyword.isEmpty) return;

    final requestId = ++_searchRequestId;
    final requestPage = reset ? 1 : state.page;

    _slowSearchHintTimer?.cancel();
    if (state.showSlowSearchHint) {
      state = state.copyWith(showSlowSearchHint: false);
    }

    if (reset) {
      state = state.copyWith(
        loading: true,
        loadingMore: false,
        lastError: null,
        page: 1,
        hasMore: false,
        results: const [],
      );
      _slowSearchHintTimer = Timer(const Duration(milliseconds: 300), () {
        if (
            !_isActiveSearchRequest(requestId) ||
            !state.loading) {
          return;
        }
        state = state.copyWith(showSlowSearchHint: true);
      });
    } else {
      if (state.loadingMore || state.loading || !state.hasMore) return;
      state = state.copyWith(loadingMore: true);
    }

    try {
      final result = state.queryMode == MedicineQueryMode.local
          ? await _store.search(
              keyword: normalizedKeyword,
              page: requestPage,
              pageSize: _pageSize,
            )
          : await _executeSearch(
              keyword: normalizedKeyword,
              page: requestPage,
              pageSize: _pageSize,
            );

      if (!_canApplySearchResult(requestId, normalizedKeyword)) return;

      state = state.copyWith(
        results: [...state.results, ...result.items],
        hasMore: result.hasMore,
        page: result.page + 1,
      );
    } catch (error) {
      if (!_canApplySearchResult(requestId, normalizedKeyword)) return;

      if (state.queryMode == MedicineQueryMode.online &&
          _isLikelyNetworkError(error.toString())) {
        state = state.copyWith(queryMode: MedicineQueryMode.local);
        await search(reset: true);
        return;
      }

      final message = MessageUtils.extractError(error);
      if (reset) {
        state = state.copyWith(lastError: message);
      }
    } finally {
      _slowSearchHintTimer?.cancel();
      if (_isActiveSearchRequest(requestId)) {
        state = state.copyWith(
          loading: false,
          loadingMore: false,
          showSlowSearchHint: false,
        );
      }
    }
  }

  Future<MedicineSearchResult> _executeSearch({
    required String keyword,
    required int page,
    required int pageSize,
  }) async {
    final executor = ref.read(searchExecutorProvider);
    if (executor != null) {
      return executor(keyword: keyword, page: page, pageSize: pageSize);
    }
    return (await MedicineApi.search(
      keyword: keyword,
      page: page,
      pageSize: pageSize,
    )).result;
  }

  Future<void> refreshSearch() async {
    if (state.keyword.trim().isEmpty) {
      await _loadAddedKeys();
      return;
    }
    await search(reset: true);
  }

  // ── 滚动分页 ──

  void handleScroll(double maxScrollExtent, double currentOffset) {
    if (state.keyword.isEmpty ||
        !state.hasMore ||
        state.loadingMore ||
        state.loading) {
      return;
    }
    if (currentOffset >= maxScrollExtent - 120) {
      unawaited(search(reset: false));
    }
  }

  // ── 草稿关键词 ──

  void syncDraftKeyword(String next) {
    if (state.draftKeyword == next) return;
    state = state.copyWith(draftKeyword: next);
  }

  // ── 内部辅助 ──

  String get _userId {
    return ref.read(currentUserProvider)?.id ?? '';
  }

  String get _storageKey {
    final scopedUserId = _userId.trim();
    final scope = scopedUserId.isEmpty ? 'guest' : scopedUserId;
    return '$_recentKeywordsStoragePrefix:$scope';
  }

  void _updateRecentKeywords(String keyword) {
    final normalized = keyword.trim();
    if (normalized.isEmpty) return;
    _historyClearedByUser = false;
    _seededRecentKeywords = null;
    _hasPersistedRecentKeywords = true;

    final updated = List<String>.from(state.recentKeywords);
    updated.remove(normalized);
    updated.insert(0, normalized);
    if (updated.length > _maxRecentKeywordCount) {
      updated.removeLast();
    }
    state = state.copyWith(recentKeywords: updated);
  }

  Future<void> _persistRecentKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, state.recentKeywords);
  }

  List<String> _sanitizeRecentKeywords(Iterable<String> source) {
    final result = <String>[];
    for (final raw in source) {
      final keyword = raw.trim();
      if (keyword.isEmpty || result.contains(keyword)) continue;
      result.add(keyword);
      if (result.length >= _maxRecentKeywordCount) break;
    }
    return result;
  }

  bool _canApplySearchResult(int requestId, String keyword) {
    return _isActiveSearchRequest(requestId) &&
        keyword == state.keyword.trim();
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

  static bool _sameStringSet(Set<String> current, Set<String> next) {
    if (current.length != next.length) return false;
    for (final key in next) {
      if (!current.contains(key)) return false;
    }
    return true;
  }

  static bool _sameStringList(List<String> current, List<String> next) {
    if (current.length != next.length) return false;
    for (var i = 0; i < current.length; i++) {
      if (current[i] != next[i]) return false;
    }
    return true;
  }
}

// ── Provider ──

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});
