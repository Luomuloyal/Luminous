import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:luminous/api/medicine_api.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/stores/local_medicine_store.dart';
import 'package:luminous/stores/my_medicine_repository.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/viewmodels/search.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef MedicineSearchExecutor =
    Future<MedicineSearchResult> Function({
      required String keyword,
      required int page,
      required int pageSize,
    });

enum MedicineQueryMode { online, local }

/// 手动搜索页页面级控制器。
///
/// 负责管理搜索输入、分页请求、最近搜索以及“我的药品”联动状态。
class SearchController extends GetxController {
  SearchController({
    required this.pickerMode,
    required this.initialKeyword,
    required this.autoSearchOnInit,
    this.searchExecutor,
  });

  final bool pickerMode;
  final String initialKeyword;
  final bool autoSearchOnInit;
  final MedicineSearchExecutor? searchExecutor;

  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<String> draftKeywordNotifier = ValueNotifier<String>('');
  final ScrollController scrollController = ScrollController();

  final List<String> _recentKeywords = <String>[];
  List<String>? _seededRecentKeywords;
  bool _historyClearedByUser = false;
  bool _hasPersistedRecentKeywords = false;
  bool _recentHistoryReady = false;

  static const int _maxRecentKeywordCount = 8;
  static const String _recentKeywordsStoragePrefix =
      'search_recent_keywords_v1';
  static const int _pageSize = 20;

  final List<MedicineItem> _results = <MedicineItem>[];
  final Set<String> _addedKeys = <String>{};
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = false;
  bool _showSlowSearchHint = false;
  String _keyword = '';
  String? _lastError;
  int _page = 1;
  int _searchRequestId = 0;
  Timer? _slowSearchHintTimer;
  ProviderSubscription? _userWorker;
  List<String> _localizedRecentDefaults = const <String>[];

  MedicineQueryMode _queryMode = MedicineQueryMode.online;

  List<String> get recentKeywords => List<String>.unmodifiable(_recentKeywords);
  List<MedicineItem> get results => List<MedicineItem>.unmodifiable(_results);
  Set<String> get addedKeys => Set<String>.unmodifiable(_addedKeys);
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  bool get showSlowSearchHint => _showSlowSearchHint;
  String get keyword => _keyword;
  String? get lastError => _lastError;
  MedicineQueryMode get queryMode => _queryMode;
  String get userId =>
      globalProviderContainer.read(currentUserProvider)?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    final normalizedInitialKeyword = initialKeyword.trim();
    if (normalizedInitialKeyword.isNotEmpty) {
      searchController.text = normalizedInitialKeyword;
      searchController.selection = TextSelection.collapsed(
        offset: normalizedInitialKeyword.length,
      );
      draftKeywordNotifier.value = normalizedInitialKeyword;
      if (autoSearchOnInit) {
        _keyword = normalizedInitialKeyword;
        _updateRecentKeywords(normalizedInitialKeyword);
      }
    }

    searchController.addListener(_syncDraftKeyword);
    scrollController.addListener(_handleScroll);
    unawaited(loadAddedKeys());
    unawaited(loadRecentKeywords());
    unawaited(detectInitialQueryMode());

    _userWorker = globalProviderContainer.listen(currentUserProvider, (
      previous,
      next,
    ) {
      unawaited(loadAddedKeys());
      unawaited(loadRecentKeywords());
    });

    if (autoSearchOnInit && normalizedInitialKeyword.isNotEmpty) {
      Future<void>.microtask(() => search(reset: true));
    }
  }

  @override
  void onClose() {
    _userWorker?.close();
    _slowSearchHintTimer?.cancel();
    searchController.removeListener(_syncDraftKeyword);
    searchController.dispose();
    scrollController.dispose();
    draftKeywordNotifier.dispose();
    super.onClose();
  }

  Future<void> loadAddedKeys() async {
    try {
      final keys = await myMedicineRepository.loadIdentityKeys(userId: userId);
      if (isClosed || _sameStringSet(_addedKeys, keys)) {
        return;
      }
      _addedKeys
        ..clear()
        ..addAll(keys);
      update();
    } catch (_) {
      // Keep the page usable even if local read fails.
    }
  }

  Future<void> loadRecentKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_recentKeywordsStorageKey);
    final sanitized = _sanitizeRecentKeywords(stored ?? const <String>[]);
    if (isClosed) {
      return;
    }
    _recentKeywords
      ..clear()
      ..addAll(sanitized);
    _hasPersistedRecentKeywords = stored != null;
    _recentHistoryReady = true;
    _historyClearedByUser = stored != null && sanitized.isEmpty;
    _seededRecentKeywords = null;
    _syncDefaultRecentKeywords();
    update();
  }

  void applyLocalizedRecentDefaults(List<String> defaults) {
    final sanitized = _sanitizeRecentKeywords(defaults);
    if (_sameStringList(_localizedRecentDefaults, sanitized)) {
      return;
    }
    _localizedRecentDefaults = sanitized;
    _syncDefaultRecentKeywords();
    if (!isClosed) {
      update();
    }
  }

  Future<void> detectInitialQueryMode() async {
    final reachable = await MedicineApi.isBackendReachable();
    if (isClosed || reachable) {
      return;
    }
    _queryMode = MedicineQueryMode.local;
    update();
  }

  void applyQuickTag(String tag) {
    final normalized = tag.trim();
    if (normalized.isEmpty) {
      return;
    }
    searchController.text = normalized;
    searchController.selection = TextSelection.collapsed(
      offset: normalized.length,
    );
    _lastError = null;
    _keyword = normalized;
    _updateRecentKeywords(normalized);
    update();
    unawaited(_persistRecentKeywords());
    unawaited(search(reset: true));
  }

  void commitSearch(BuildContext context, {String? emptyToast}) {
    final normalized = searchController.text.trim();
    if (normalized.isEmpty) {
      ToastUtils.instance.show(context, emptyToast ?? '请输入产品名称、批准文号或生产单位后再搜索');
      return;
    }
    _lastError = null;
    _keyword = normalized;
    _updateRecentKeywords(normalized);
    update();
    unawaited(_persistRecentKeywords());
    unawaited(search(reset: true));
    FocusScope.of(context).unfocus();
  }

  void clearKeyword() {
    searchController.clear();
    _keyword = '';
    _lastError = null;
    _results.clear();
    _hasMore = false;
    _page = 1;
    update();
  }

  Future<void> clearHistory(
    BuildContext context, {
    String? clearedToast,
  }) async {
    _recentKeywords.clear();
    _historyClearedByUser = true;
    _seededRecentKeywords = null;
    _hasPersistedRecentKeywords = true;
    update();
    await _persistRecentKeywords();
    if (isClosed || !context.mounted) {
      return;
    }
    ToastUtils.instance.show(context, clearedToast ?? '最近搜索已清空');
  }

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
    return myMedicineRepository.buildScopedIdentityKeyFromMedicine(
      item,
      userId: userId,
    );
  }

  Future<void> addToMyMedicines(
    BuildContext context,
    MedicineItem item, {
    required String alreadyAddedToast,
    required String addedPendingSyncToast,
    required String addedToast,
    required String addFailedToast,
  }) async {
    final identityKey = buildIdentityKey(item);
    try {
      final result = await myMedicineRepository.addMedicine(
        item: item,
        source: 'search',
        userId: userId,
      );
      if (isClosed || !context.mounted) {
        return;
      }
      if (!result.added) {
        ToastUtils.instance.show(context, alreadyAddedToast);
        _addedKeys.add(identityKey);
        update();
        return;
      }
      _addedKeys.add(identityKey);
      update();
      ToastUtils.instance.show(
        context,
        userId.isNotEmpty && !result.remoteSynced
            ? addedPendingSyncToast
            : addedToast,
      );
    } catch (_) {
      if (isClosed || !context.mounted) {
        return;
      }
      ToastUtils.instance.show(context, addFailedToast);
    }
  }

  Future<void> search({required bool reset}) async {
    final normalizedKeyword = _keyword.trim();
    if (normalizedKeyword.isEmpty) {
      return;
    }

    final requestId = ++_searchRequestId;
    final requestPage = reset ? 1 : _page;

    _slowSearchHintTimer?.cancel();
    if (_showSlowSearchHint) {
      _showSlowSearchHint = false;
      update();
    }

    if (reset) {
      _loading = true;
      _loadingMore = false;
      _lastError = null;
      _page = 1;
      _hasMore = false;
      _results.clear();
      update();
      _slowSearchHintTimer = Timer(const Duration(milliseconds: 300), () {
        if (isClosed || !_isActiveSearchRequest(requestId) || !_loading) {
          return;
        }
        _showSlowSearchHint = true;
        update();
      });
    } else {
      if (_loadingMore || _loading || !_hasMore) {
        return;
      }
      _loadingMore = true;
      update();
    }

    try {
      final result = _queryMode == MedicineQueryMode.local
          ? await localMedicineStore.search(
              keyword: normalizedKeyword,
              page: requestPage,
              pageSize: _pageSize,
            )
          : searchExecutor != null
          ? await searchExecutor!(
              keyword: normalizedKeyword,
              page: requestPage,
              pageSize: _pageSize,
            )
          : (await MedicineApi.search(
              keyword: normalizedKeyword,
              page: requestPage,
              pageSize: _pageSize,
            )).result;

      if (!_canApplySearchResult(requestId, normalizedKeyword)) {
        return;
      }

      _results.addAll(result.items);
      _hasMore = result.hasMore;
      _page = result.page + 1;
      update();
    } catch (error) {
      if (!_canApplySearchResult(requestId, normalizedKeyword)) {
        return;
      }

      if (_queryMode == MedicineQueryMode.online &&
          _isLikelyNetworkError(error.toString())) {
        _queryMode = MedicineQueryMode.local;
        update();
        await search(reset: true);
        return;
      }

      final message = MessageUtils.extractError(error);
      if (reset) {
        _lastError = message;
        update();
      }
    } finally {
      _slowSearchHintTimer?.cancel();
      if (_isActiveSearchRequest(requestId) && !isClosed) {
        _loading = false;
        _loadingMore = false;
        _showSlowSearchHint = false;
        update();
      }
    }
  }

  Future<void> refreshSearch() async {
    if (_keyword.trim().isEmpty) {
      await loadAddedKeys();
      return;
    }
    await search(reset: true);
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

  String get _recentKeywordsStorageKey {
    final scopedUserId = userId.trim();
    final scope = scopedUserId.isEmpty ? 'guest' : scopedUserId;
    return '$_recentKeywordsStoragePrefix:$scope';
  }

  List<String> _sanitizeRecentKeywords(Iterable<String> source) {
    final result = <String>[];
    for (final raw in source) {
      final keyword = raw.trim();
      if (keyword.isEmpty || result.contains(keyword)) {
        continue;
      }
      result.add(keyword);
      if (result.length >= _maxRecentKeywordCount) {
        break;
      }
    }
    return result;
  }

  Future<void> _persistRecentKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _recentKeywordsStorageKey,
      List<String>.from(_recentKeywords),
    );
  }

  void _syncDefaultRecentKeywords() {
    if (!_recentHistoryReady || _hasPersistedRecentKeywords) {
      return;
    }
    if (_localizedRecentDefaults.isEmpty) {
      return;
    }
    final defaults = List<String>.from(_localizedRecentDefaults);
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
    final next = searchController.text.trim();
    if (draftKeywordNotifier.value == next) {
      return;
    }
    draftKeywordNotifier.value = next;
  }

  void _handleScroll() {
    if (!scrollController.hasClients) {
      return;
    }
    if (_keyword.isEmpty || !_hasMore || _loadingMore || _loading) {
      return;
    }
    final maxScroll = scrollController.position.maxScrollExtent;
    final current = scrollController.offset;
    if (current >= maxScroll - 120) {
      unawaited(search(reset: false));
    }
  }

  void _updateRecentKeywords(String keyword) {
    final normalized = keyword.trim();
    if (normalized.isEmpty) {
      return;
    }
    _historyClearedByUser = false;
    _seededRecentKeywords = null;
    _hasPersistedRecentKeywords = true;
    _recentKeywords.remove(normalized);
    _recentKeywords.insert(0, normalized);
    if (_recentKeywords.length > _maxRecentKeywordCount) {
      _recentKeywords.removeLast();
    }
  }

  bool _canApplySearchResult(int requestId, String keyword) {
    return !isClosed &&
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
