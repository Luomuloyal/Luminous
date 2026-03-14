class MedicineItem {
  final String serialNo;
  final String approvalNo;
  final String productName;
  final String dosageForm;
  final String specification;
  final String marketingAuthorizationHolder;
  final String manufacturer;
  final String drugCode;
  final String drugCodeRemark;

  const MedicineItem({
    required this.serialNo,
    required this.approvalNo,
    required this.productName,
    required this.dosageForm,
    required this.specification,
    required this.marketingAuthorizationHolder,
    required this.manufacturer,
    required this.drugCode,
    required this.drugCodeRemark,
  });

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      serialNo: (json['serialNo'] ?? json['序号'] ?? '').toString(),
      approvalNo: (json['approvalNo'] ?? json['批准文号'] ?? '').toString(),
      productName: (json['productName'] ?? json['产品名称'] ?? '').toString(),
      dosageForm: (json['dosageForm'] ?? json['剂型'] ?? '').toString(),
      specification: (json['specification'] ?? json['规格'] ?? '').toString(),
      marketingAuthorizationHolder:
          (json['marketingAuthorizationHolder'] ?? json['上市许可持有人'] ?? '')
              .toString(),
      manufacturer: (json['manufacturer'] ?? json['生产单位'] ?? '').toString(),
      drugCode: (json['drugCode'] ?? json['药品编码'] ?? '').toString(),
      drugCodeRemark: (json['drugCodeRemark'] ?? json['药品编码备注'] ?? '')
          .toString(),
    );
  }

  bool get hasIdentity => drugCode.isNotEmpty || approvalNo.isNotEmpty;

  String get displayName => productName.isEmpty ? '未知药品' : productName;

  String get displaySubtitle {
    final parts = <String>[
      if (dosageForm.isNotEmpty) dosageForm,
      if (specification.isNotEmpty) specification,
    ];
    return parts.isEmpty ? '暂无规格信息' : parts.join(' · ');
  }

  String get displayTips {
    if (manufacturer.isNotEmpty) {
      return manufacturer;
    }
    if (marketingAuthorizationHolder.isNotEmpty) {
      return marketingAuthorizationHolder;
    }
    return '';
  }

  String get displayBadge {
    if (dosageForm.isNotEmpty) {
      return dosageForm;
    }
    return '药品';
  }
}

class MedicineSearchResult {
  final List<MedicineItem> items;
  final int total;
  final int page;
  final int pageSize;

  const MedicineSearchResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory MedicineSearchResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => MedicineItem.fromJson(e.cast<String, dynamic>()))
              .toList()
        : <MedicineItem>[];

    return MedicineSearchResult(
      items: items,
      total: int.tryParse((json['total'] ?? '').toString()) ?? items.length,
      page: int.tryParse((json['page'] ?? '').toString()) ?? 1,
      pageSize: _parsePageSize(json['pageSize'], fallback: 20),
    );
  }

  bool get hasMore => page * pageSize < total;
}

int _parsePageSize(dynamic value, {required int fallback}) {
  final parsed = int.tryParse((value ?? '').toString());
  if (parsed != null && parsed > 0) {
    return parsed;
  }
  return fallback;
}

class MedicineAiDetailResult {
  final String text;

  const MedicineAiDetailResult({required this.text});

  factory MedicineAiDetailResult.fromJson(Map<String, dynamic> json) {
    return MedicineAiDetailResult(text: (json['text'] ?? '').toString());
  }

  bool get hasText => text.trim().isNotEmpty;
}
