import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/DioRequest.dart';
import 'package:luminous/viewmodels/album.dart';
import 'package:luminous/viewmodels/scan.dart';

/// 药品识别与识别记录相关接口封装。
class ScanApi {
  /// 私有构造函数，防止外部实例化。
  ScanApi._();

  /// 上传图片并请求药品识别。
  ///
  /// - `userId`：当前用户 id，可选；
  /// - `imageBase64`：待识别图片的 base64；
  /// - `mimeType`：图片 MIME 类型，默认 jpeg。
  static Future<ApiResult<MedicineScanResult>> scanMedicine({
    String? userId,
    required String imageBase64,
    String mimeType = 'image/jpeg',
  }) {
    return dioRequest.post<MedicineScanResult>(
      HttpConstants.MEDICINE_SCAN,
      data: <String, dynamic>{
        if (userId != null && userId.trim().isNotEmpty) 'userId': userId.trim(),
        'imageBase64': imageBase64,
        'mimeType': mimeType,
      },
      decoder: (json) {
        if (json is Map<String, dynamic>) {
          return MedicineScanResult.fromJson(json);
        }
        if (json is Map) {
          return MedicineScanResult.fromJson(json.cast<String, dynamic>());
        }
        return const MedicineScanResult(candidates: [], thumbBase64: '');
      },
      showLoading: false,
    );
  }

  /// 创建一条识别记录。
  ///
  /// 该接口用于把拍照识别结果同步到服务端，便于后续跨设备查看。
  static Future<ApiResult<IdResult>> createScanRecord({
    required String userId,
    required String thumbBase64,
    String? drugCode,
    String? approvalNo,
    String? productName,
    int? takenAt,
  }) {
    return dioRequest.post<IdResult>(
      HttpConstants.SCAN_RECORD_CREATE,
      data: <String, dynamic>{
        'userId': userId.trim(),
        'thumbBase64': thumbBase64,
        if (drugCode != null && drugCode.trim().isNotEmpty)
          'drugCode': drugCode.trim(),
        if (approvalNo != null && approvalNo.trim().isNotEmpty)
          'approvalNo': approvalNo.trim(),
        if (productName != null && productName.trim().isNotEmpty)
          'productName': productName.trim(),
        ...?(takenAt == null ? null : <String, dynamic>{'takenAt': takenAt}),
      },
      decoder: (json) => IdResult.fromJson(_asMap(json)),
      showLoading: false,
    );
  }

  /// 获取识别记录列表。
  ///
  /// 支持按用户分页拉取，供相册页展示使用。
  static Future<ApiResult<ScanRecordListResult>> listScanRecords({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) {
    return dioRequest.post<ScanRecordListResult>(
      HttpConstants.SCAN_RECORD_LIST,
      data: <String, dynamic>{
        'userId': userId.trim(),
        'page': page,
        'pageSize': pageSize,
      },
      decoder: (json) {
        if (json is Map<String, dynamic>) {
          return ScanRecordListResult.fromJson(json);
        }
        if (json is Map) {
          return ScanRecordListResult.fromJson(json.cast<String, dynamic>());
        }
        return const ScanRecordListResult(
          items: [],
          total: 0,
          page: 1,
          pageSize: 20,
        );
      },
      showLoading: false,
    );
  }

  /// 把动态接口返回值安全转换为 Map。
  static Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return json.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }
}
