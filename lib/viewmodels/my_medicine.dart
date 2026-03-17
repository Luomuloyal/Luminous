/// “我的药品”记录对象。
///
/// 该对象同时用于：
/// - 前端和后端之间的同步协议；
/// - 本地 SQLite `my_medicines` 表的缓存落库。
class MyMedicineRecord {
  /// 远端记录 id。
  final String id;

  /// 所属用户 id。
  final String userId;

  /// 用户维度下的唯一 identityKey。
  final String identityKey;

  /// 药品编码。
  final String drugCode;

  /// 批准文号。
  final String approvalNo;

  /// 药品名称。
  final String productName;

  /// 剂型。
  final String dosageForm;

  /// 规格。
  final String specification;

  /// 生产厂家。
  final String manufacturer;

  /// 来源标记，例如 `search/scan`。
  final String source;

  /// 创建时间戳（毫秒）。
  final int createdAt;

  /// 创建一个“我的药品”记录对象。
  const MyMedicineRecord({
    required this.id,
    required this.userId,
    required this.identityKey,
    required this.drugCode,
    required this.approvalNo,
    required this.productName,
    required this.dosageForm,
    required this.specification,
    required this.manufacturer,
    required this.source,
    required this.createdAt,
  });

  /// 从接口 JSON 反序列化为 `MyMedicineRecord`。
  factory MyMedicineRecord.fromJson(Map<String, dynamic> json) {
    return MyMedicineRecord(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      identityKey: (json['identityKey'] ?? '').toString(),
      drugCode: (json['drugCode'] ?? '').toString(),
      approvalNo: (json['approvalNo'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      dosageForm: (json['dosageForm'] ?? '').toString(),
      specification: (json['specification'] ?? '').toString(),
      manufacturer: (json['manufacturer'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      createdAt: int.tryParse((json['createdAt'] ?? '').toString()) ?? 0,
    );
  }

  /// 序列化为本地数据库行数据。
  Map<String, dynamic> toLocalMap() {
    return {
      'identityKey': identityKey,
      'userId': userId,
      'remoteId': id,
      'drugCode': drugCode,
      'approvalNo': approvalNo,
      'productName': productName,
      'dosageForm': dosageForm,
      'specification': specification,
      'manufacturer': manufacturer,
      'source': source,
      'createdAt': createdAt,
    };
  }
}

/// “我的药品”列表接口返回对象。
class MyMedicineListResult {
  /// 记录列表。
  final List<MyMedicineRecord> items;

  /// 创建一个列表结果对象。
  const MyMedicineListResult({required this.items});

  /// 从接口 JSON 反序列化为 `MyMedicineListResult`。
  factory MyMedicineListResult.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = raw is List
        ? raw
              .whereType<Map>()
              .map(
                (entry) =>
                    MyMedicineRecord.fromJson(entry.cast<String, dynamic>()),
              )
              .toList()
        : <MyMedicineRecord>[];
    return MyMedicineListResult(items: items);
  }
}
