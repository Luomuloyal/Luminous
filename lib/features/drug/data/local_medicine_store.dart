import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:luminous/shared/models/medicine.dart';

class LocalMedicineStore {
  LocalMedicineStore._();

  static final LocalMedicineStore instance = LocalMedicineStore._();

  List<_IndexedMedicine>? _indexed;

  Future<void> _ensureLoaded() async {
    if (_indexed != null) {
      return;
    }

    final raw = await rootBundle.loadString('lib/assets/data.json');
    final decoded = jsonDecode(raw);
    final rows = _normalizeRows(decoded);

    final indexed = <_IndexedMedicine>[];
    for (final row in rows) {
      final item = _toMedicineItem(row);
      final indexText = _buildIndexText(item).toLowerCase();
      indexed.add(_IndexedMedicine(item: item, indexText: indexText));
    }

    _indexed = indexed;
  }

  Future<MedicineSearchResult> search({
    required String keyword,
    required int page,
    required int pageSize,
  }) async {
    final query = keyword.trim().toLowerCase();
    if (query.isEmpty) {
      return MedicineSearchResult(
        items: const <MedicineItem>[],
        total: 0,
        page: page <= 0 ? 1 : page,
        pageSize: pageSize <= 0 ? 20 : pageSize,
      );
    }

    final safePage = page <= 0 ? 1 : page;
    final safePageSize = pageSize <= 0 ? 20 : pageSize;
    final start = (safePage - 1) * safePageSize;
    final end = start + safePageSize;

    await _ensureLoaded();
    final indexed = _indexed ?? const <_IndexedMedicine>[];

    var matchedCount = 0;
    final pageItems = <MedicineItem>[];

    for (final entry in indexed) {
      if (!entry.indexText.contains(query)) {
        continue;
      }
      if (matchedCount >= start && matchedCount < end) {
        pageItems.add(entry.item);
      }
      matchedCount++;
    }

    return MedicineSearchResult(
      items: pageItems,
      total: matchedCount,
      page: safePage,
      pageSize: safePageSize,
    );
  }

  List<Map<String, dynamic>> _normalizeRows(dynamic decoded) {
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList(growable: false);
    }
    if (decoded is Map<String, dynamic>) {
      final items = decoded['items'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList(growable: false);
      }
      final data = decoded['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList(growable: false);
      }
    }
    return const <Map<String, dynamic>>[];
  }

  MedicineItem _toMedicineItem(Map<String, dynamic> row) {
    final serialNo = _readField(row, <String>['serialNo', '序号']);
    final approvalNo = _readField(row, <String>['approvalNo', '批准文号']);
    final productName = _readField(row, <String>['productName', '产品名称']);
    final dosageForm = _readField(row, <String>['dosageForm', '剂型']);
    final specification = _readField(row, <String>['specification', '规格']);
    final holder = _readField(row, <String>[
      'marketingAuthorizationHolder',
      '上市许可持有人',
    ]);
    final manufacturer = _readField(row, <String>['manufacturer', '生产单位']);
    final drugCode = _readField(row, <String>['drugCode', '药品编码']);
    final drugCodeRemark = _readField(row, <String>[
      'drugCodeRemark',
      '药品编码备注',
    ]);

    return MedicineItem(
      serialNo: serialNo,
      approvalNo: approvalNo,
      productName: productName,
      dosageForm: dosageForm,
      specification: specification,
      marketingAuthorizationHolder: holder,
      manufacturer: manufacturer,
      drugCode: drugCode,
      drugCodeRemark: drugCodeRemark,
    );
  }

  String _readField(Map<String, dynamic> row, List<String> candidates) {
    for (final key in candidates) {
      if (row.containsKey(key)) {
        return (row[key] ?? '').toString().trim();
      }
    }
    return '';
  }

  String _buildIndexText(MedicineItem item) {
    return <String>[
      item.productName,
      item.approvalNo,
      item.manufacturer,
      item.marketingAuthorizationHolder,
      item.drugCode,
      item.serialNo,
    ].join(' ');
  }
}

class _IndexedMedicine {
  const _IndexedMedicine({required this.item, required this.indexText});

  final MedicineItem item;
  final String indexText;
}

final localMedicineStore = LocalMedicineStore.instance;
