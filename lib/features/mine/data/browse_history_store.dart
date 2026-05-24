import 'dart:convert';

import 'package:luminous/features/mine/presentation/models/browse_history.dart';
import 'package:luminous/shared/models/medicine.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地浏览记录仓库。
///
/// 当前采用 SharedPreferences 按用户 scope 保存最近查看的药品详情记录。
class BrowseHistoryStore {
  BrowseHistoryStore._();

  static final BrowseHistoryStore instance = BrowseHistoryStore._();

  static const String _storageKeyPrefix = 'browse_history_v1';
  static const int _maxEntryCount = 60;

  Future<SharedPreferences>? _prefsFuture;

  Future<SharedPreferences> get _prefs async {
    return _prefsFuture ??= SharedPreferences.getInstance();
  }

  Future<List<BrowseHistoryEntry>> loadEntries({String? userId}) async {
    final prefs = await _prefs;
    final rawList = prefs.getStringList(_storageKey(userId));
    if (rawList == null || rawList.isEmpty) {
      return const <BrowseHistoryEntry>[];
    }

    final parsed = <BrowseHistoryEntry>[];
    for (final raw in rawList) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final entry = BrowseHistoryEntry.fromJson(decoded);
          if (entry.hasIdentity) {
            parsed.add(entry);
          }
        } else if (decoded is Map) {
          final entry = BrowseHistoryEntry.fromJson(
            decoded.cast<String, dynamic>(),
          );
          if (entry.hasIdentity) {
            parsed.add(entry);
          }
        }
      } catch (_) {
        // Ignore broken record and keep parsing the rest.
      }
    }

    final sanitized = _sanitizeEntries(parsed);
    if (!_sameEntries(parsed, sanitized)) {
      await _persistEntries(userId: userId, entries: sanitized);
    }
    return sanitized;
  }

  Future<void> recordMedicine({
    String? userId,
    required MedicineItem item,
  }) async {
    if (!item.hasIdentity) {
      return;
    }

    final entries = await loadEntries(userId: userId);
    final next = <BrowseHistoryEntry>[
      BrowseHistoryEntry.fromMedicineItem(
        item,
        viewedAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
      ...entries,
    ];
    await _persistEntries(userId: userId, entries: _sanitizeEntries(next));
  }

  Future<void> removeEntry({
    String? userId,
    required String identityKey,
  }) async {
    final normalizedKey = identityKey.trim();
    if (normalizedKey.isEmpty) {
      return;
    }
    final entries = await loadEntries(userId: userId);
    await _persistEntries(
      userId: userId,
      entries: entries
          .where((entry) => entry.identityKey != normalizedKey)
          .toList(growable: false),
    );
  }

  Future<void> clear({String? userId}) async {
    final prefs = await _prefs;
    await prefs.remove(_storageKey(userId));
  }

  String _storageKey(String? userId) {
    final scope = (userId ?? '').trim();
    if (scope.isEmpty) {
      return '$_storageKeyPrefix:guest';
    }
    return '$_storageKeyPrefix:user:$scope';
  }

  Future<void> _persistEntries({
    required String? userId,
    required List<BrowseHistoryEntry> entries,
  }) async {
    final prefs = await _prefs;
    if (entries.isEmpty) {
      await prefs.remove(_storageKey(userId));
      return;
    }
    await prefs.setStringList(
      _storageKey(userId),
      entries
          .map((entry) => jsonEncode(entry.toJson()))
          .toList(growable: false),
    );
  }

  List<BrowseHistoryEntry> _sanitizeEntries(List<BrowseHistoryEntry> items) {
    final latestByIdentity = <String, BrowseHistoryEntry>{};
    for (final item in items) {
      final identityKey = item.identityKey.trim();
      if (identityKey.isEmpty) {
        continue;
      }
      final existing = latestByIdentity[identityKey];
      if (existing == null || item.viewedAtMillis >= existing.viewedAtMillis) {
        latestByIdentity[identityKey] = item;
      }
    }

    final sanitized = latestByIdentity.values.toList(growable: false)
      ..sort((a, b) => b.viewedAtMillis.compareTo(a.viewedAtMillis));
    if (sanitized.length <= _maxEntryCount) {
      return sanitized;
    }
    return sanitized.take(_maxEntryCount).toList(growable: false);
  }

  bool _sameEntries(List<BrowseHistoryEntry> a, List<BrowseHistoryEntry> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (jsonEncode(a[i].toJson()) != jsonEncode(b[i].toJson())) {
        return false;
      }
    }
    return true;
  }
}

final browseHistoryStore = BrowseHistoryStore.instance;
