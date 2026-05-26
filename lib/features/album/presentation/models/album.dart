import 'package:json_annotation/json_annotation.dart';
import 'package:luminous/utils/app_i18n_text.dart';

part 'album.g.dart';

/// 相册（识别记录）相关的数据模型。
@JsonSerializable(createFactory: false)
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
  @JsonKey(includeToJson: false)
  bool get hasId => id.trim().isNotEmpty;

  Map<String, dynamic> toJson() => _$IdResultToJson(this);
}

/// 相册页使用的本地记录模型。
///
/// 当前按“新应用”设计，相册只展示本地记录；
/// 云端仅做缩略图与识别结果的最佳努力上报，不再回拉历史列表。
class AlbumEntry {
  /// 远端 id（如果轻量上报失败或未登录可能为空）。
  final String remoteId;

  /// 产品名称。
  final String productName;

  /// 药品编码。
  final String drugCode;

  /// 批准文号。
  final String approvalNo;

  /// 缩略图本地路径。
  final String thumbPath;

  /// 原图本地路径。
  final String imagePath;

  /// 原图 MIME 类型。
  final String imageMimeType;

  /// 拍摄/识别时间戳（毫秒）。
  final int takenAt;

  /// 创建一个相册条目对象。
  const AlbumEntry({
    required this.remoteId,
    required this.productName,
    required this.drugCode,
    required this.approvalNo,
    required this.thumbPath,
    required this.imagePath,
    required this.imageMimeType,
    required this.takenAt,
  });

  /// 从本地数据库行构建 `AlbumEntry`。
  factory AlbumEntry.fromLocalRow(Map<String, dynamic> row) {
    return AlbumEntry(
      remoteId: (row['remoteId'] ?? '').toString(),
      productName: (row['productName'] ?? '').toString(),
      drugCode: (row['drugCode'] ?? '').toString(),
      approvalNo: (row['approvalNo'] ?? '').toString(),
      thumbPath: (row['thumbPath'] ?? '').toString(),
      imagePath: (row['imagePath'] ?? '').toString(),
      imageMimeType: (row['imageMimeType'] ?? '').toString(),
      takenAt: (row['takenAt'] as int?) ?? (row['createdAt'] as int?) ?? 0,
    );
  }

  /// 页面展示用名称。
  String get displayName => productName.trim().isEmpty
      ? AppI18nText.pick(zh: '未知药品', en: 'Unknown medicine')
      : productName.trim();

  /// 当前记录是否有本地原图。
  bool get hasOriginalImage => imagePath.trim().isNotEmpty;

  /// 当前记录是否至少有可预览图片。
  bool get hasPreviewImage => previewPath.isNotEmpty;

  /// 预览优先使用原图，没有原图时回退到缩略图。
  String get previewPath {
    final originalPath = imagePath.trim();
    if (originalPath.isNotEmpty) {
      return originalPath;
    }
    return thumbnailPath;
  }

  /// 网格卡片优先使用缩略图，没有缩略图时回退到原图。
  String get thumbnailPath {
    final thumb = thumbPath.trim();
    if (thumb.isNotEmpty) {
      return thumb;
    }
    return imagePath.trim();
  }
}
