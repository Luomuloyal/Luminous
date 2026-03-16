import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

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
/// 都统一映射为一个结构，并提前把缩略图 base64 解码为 bytes，避免滚动时重复 decode。
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

  /// 预解码后的缩略图 bytes。
  ///
  /// 为空表示没有缩略图或解码失败。
  final Uint8List? thumbBytes;

  /// 拍摄/识别时间戳（毫秒）。
  final int takenAt;

  /// 创建一个相册条目对象。
  const AlbumEntry({
    required this.remoteId,
    required this.productName,
    required this.drugCode,
    required this.approvalNo,
    required this.thumbBase64,
    required this.thumbBytes,
    required this.takenAt,
  });

  /// 从本地数据库行构建 `AlbumEntry`。
  ///
  /// 同时会把 thumbBase64 解码为 bytes，缓存到 `thumbBytes`。
  factory AlbumEntry.fromLocalRow(Map<String, dynamic> row) {
    /// 本地缓存的缩略图 base64。
    final raw = (row['thumbBase64'] ?? '').toString();
    return AlbumEntry(
      remoteId: (row['remoteId'] ?? '').toString(),
      productName: (row['productName'] ?? '').toString(),
      drugCode: (row['drugCode'] ?? '').toString(),
      approvalNo: (row['approvalNo'] ?? '').toString(),
      thumbBase64: raw,
      thumbBytes: _decodeBase64(raw),
      takenAt: (row['takenAt'] as int?) ?? (row['createdAt'] as int?) ?? 0,
    );
  }

  /// 从远端识别记录构建 `AlbumEntry`。
  ///
  /// 同样会预解码缩略图，避免 UI build 时重复执行耗时操作。
  factory AlbumEntry.fromScanRecord(ScanRecordItem record) {
    /// 远端返回的缩略图 base64。
    final raw = record.thumbBase64;
    return AlbumEntry(
      remoteId: record.id,
      productName: record.productName,
      drugCode: record.drugCode,
      approvalNo: record.approvalNo,
      thumbBase64: raw,
      thumbBytes: _decodeBase64(raw),
      takenAt: record.takenAt,
    );
  }

  /// 页面展示用名称。
  String get displayName =>
      productName.trim().isEmpty ? '未知药品' : productName.trim();
}

/// 相册网格中单个条目的 UI 卡片。
///
/// 该组件是纯展示组件，点击事件通过 `onTap` 交由页面处理（例如跳转详情）。
class AlbumCard extends StatelessWidget {
  /// 创建一个相册卡片组件。
  const AlbumCard({super.key, required this.entry, required this.onTap});

  /// 当前卡片对应的数据条目。
  final AlbumEntry entry;

  /// 点击卡片回调。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    /// 缩略图 bytes（若为空则显示占位图标）。
    final bytes = entry.thumbBytes;
    return RepaintBoundary(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: bytes == null
                      ? Container(
                          color: const Color(0xFFF1F5F9),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.photo_outlined,
                            color: Color(0xFF94A3B8),
                            size: 34,
                          ),
                        )
                      : Image.memory(
                          bytes,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.approvalNo.trim().isEmpty
                          ? '点击查看详情'
                          : '批准文号: ${entry.approvalNo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
