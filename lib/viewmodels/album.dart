import 'dart:convert';
import 'dart:typed_data';

/// 相册（识别记录）相关的数据模型与列表卡片组件。
///
/// 该文件承载两类内容：
/// - 与识别记录接口/本地缓存相关的强类型模型（IdResult/ScanRecordItem/AlbumEntry...）；
/// - 相册页面网格中每一项的卡片组件（AlbumCard）。
class IdResult {
  /// 创建记录/资源后返回的 id。
  final String id;

  /// 创建一个 IdResult 对象。
  const IdResult({required this.id});

  /// 从后端 JSON 反序列化为 `IdResult`。
  factory IdResult.fromJson(Map<String, dynamic> json) {
    return IdResult(id: (json['id'] ?? json['_id'] ?? '').toString());
  }

  /// 是否包含有效 id。
  bool get hasId => id.trim().isNotEmpty;
}

/// 单条识别记录对象（后端返回结构）。
class ScanRecordItem {
  /// 记录 id。
  final String id;

  /// 缩略图 base64。
  final String thumbBase64;

  /// 药品编码。
  final String drugCode;

  /// 批准文号。
  final String approvalNo;

  /// 产品名称。
  final String productName;

  /// 拍摄/识别时间戳（毫秒）。
  final int takenAt;

  /// 创建一条识别记录对象。
  const ScanRecordItem({
    required this.id,
    required this.thumbBase64,
    required this.drugCode,
    required this.approvalNo,
    required this.productName,
    required this.takenAt,
  });

  /// 从后端 JSON 反序列化为 `ScanRecordItem`。
  factory ScanRecordItem.fromJson(Map<String, dynamic> json) {
    return ScanRecordItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      thumbBase64: (json['thumbBase64'] ?? '').toString(),
      drugCode: (json['drugCode'] ?? '').toString(),
      approvalNo: (json['approvalNo'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      takenAt: int.tryParse((json['takenAt'] ?? '').toString()) ?? 0,
    );
  }

  /// 页面展示用的名称（产品名为空时回退为“未知药品”）。
  String get displayName =>
      productName.trim().isEmpty ? '未知药品' : productName.trim();
}

/// 识别记录列表接口的分页结果。
class ScanRecordListResult {
  /// 记录列表。
  final List<ScanRecordItem> items;

  /// 总记录数。
  final int total;

  /// 当前页码。
  final int page;

  /// 每页大小。
  final int pageSize;

  /// 创建一个识别记录列表结果对象。
  const ScanRecordListResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  /// 从后端 JSON 反序列化为 `ScanRecordListResult`。
  factory ScanRecordListResult.fromJson(Map<String, dynamic> json) {
    /// 原始 items 字段。
    final rawItems = json['items'];

    /// 解析后的记录列表。
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => ScanRecordItem.fromJson(e.cast<String, dynamic>()))
              .toList()
        : <ScanRecordItem>[];

    return ScanRecordListResult(
      items: items,
      total: int.tryParse((json['total'] ?? '').toString()) ?? items.length,
      page: int.tryParse((json['page'] ?? '').toString()) ?? 1,
      pageSize: int.tryParse((json['pageSize'] ?? '').toString()) ?? 20,
    );
  }

  /// 是否还有下一页数据。
  bool get hasMore => page * pageSize < total;
}

/// 相册页使用的“统一入口记录模型”。
///
/// 它把：
/// - 本地 SQLite 行（album_items 表）；
/// - 远端 ScanRecordItem；
/// 都统一映射为一个结构，并把图片解码延后到展示组件中按需完成。
class AlbumEntry {
  /// 远端 id（如果是本地离线记录可能为空）。
  final String remoteId;

  /// 产品名称。
  final String productName;

  /// 药品编码。
  final String drugCode;

  /// 批准文号。
  final String approvalNo;

  /// 缩略图 base64 原始字符串。
  final String thumbBase64;

  /// 原图 base64（仅本地记录可能存在）。
  final String imageBase64;

  /// 原图 MIME 类型（仅本地记录可能存在）。
  final String imageMimeType;

  /// 拍摄/识别时间戳（毫秒）。
  final int takenAt;

  /// 创建一个相册条目对象。
  const AlbumEntry({
    required this.remoteId,
    required this.productName,
    required this.drugCode,
    required this.approvalNo,
    required this.thumbBase64,
    required this.imageBase64,
    required this.imageMimeType,
    required this.takenAt,
  });

  /// 从本地数据库行构建 `AlbumEntry`。
  ///
  /// 原图只保存在本地，因此会优先从本地行里读取 `imageBase64`。
  factory AlbumEntry.fromLocalRow(Map<String, dynamic> row) {
    final thumbBase64 = (row['thumbBase64'] ?? '').toString();
    return AlbumEntry(
      remoteId: (row['remoteId'] ?? '').toString(),
      productName: (row['productName'] ?? '').toString(),
      drugCode: (row['drugCode'] ?? '').toString(),
      approvalNo: (row['approvalNo'] ?? '').toString(),
      thumbBase64: thumbBase64,
      imageBase64: (row['imageBase64'] ?? '').toString(),
      imageMimeType: (row['imageMimeType'] ?? '').toString(),
      takenAt: (row['takenAt'] as int?) ?? (row['createdAt'] as int?) ?? 0,
    );
  }

  /// 从远端识别记录构建 `AlbumEntry`。
  ///
  /// 云端仅保存缩略图，不携带原图。
  factory AlbumEntry.fromScanRecord(ScanRecordItem record) {
    return AlbumEntry(
      remoteId: record.id,
      productName: record.productName,
      drugCode: record.drugCode,
      approvalNo: record.approvalNo,
      thumbBase64: record.thumbBase64,
      imageBase64: '',
      imageMimeType: '',
      takenAt: record.takenAt,
    );
  }

  /// 页面展示用名称。
  String get displayName =>
      productName.trim().isEmpty ? '未知药品' : productName.trim();

  /// 当前记录是否有本地原图。
  bool get hasOriginalImage => imageBase64.trim().isNotEmpty;

  /// 当前记录是否至少有可预览图片。
  bool get hasPreviewImage =>
      imageBase64.trim().isNotEmpty || thumbBase64.trim().isNotEmpty;

  /// 预览优先使用原图，没有原图时回退到缩略图。
  String get previewBase64 =>
      imageBase64.trim().isNotEmpty ? imageBase64.trim() : thumbBase64.trim();
}

/// 解码 base64 缩略图。
///
/// - 输入为空直接返回 null；
/// - 解码异常返回 null（容错）；
/// - 这样 UI 层可以统一按 null 显示占位图。
Uint8List? _decodeBase64(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  try {
    return base64Decode(trimmed);
  } catch (_) {
    return null;
  }
}

/// 对外暴露的安全 base64 解码方法。
Uint8List? decodeBase64Bytes(String raw) => _decodeBase64(raw);

/// 根据图片字节猜测 MIME 类型。
String guessImageMimeType(Uint8List bytes) {
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return 'image/webp';
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0D &&
      bytes[5] == 0x0A &&
      bytes[6] == 0x1A &&
      bytes[7] == 0x0A) {
    return 'image/png';
  }
  if (bytes.length >= 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF) {
    return 'image/jpeg';
  }
  return 'image/jpeg';
}
