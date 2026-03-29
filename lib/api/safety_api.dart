import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/viewmodels/safety.dart';

/// 安全辅助接口封装。
class SafetyApi {
  /// 私有构造函数，当前类只提供静态能力。
  SafetyApi._();

  /// 向安全辅助接口发起查询。
  ///
  /// - `userId`：当前用户 id，可选；
  /// - `mode`：查询模式，例如单药/多药；
  /// - `medicines`：参与分析的药品列表。
  static Future<ApiResult<MedicineAiSafetyResult>> query({
    String? userId,
    required String mode,
    required List<Map<String, String>> medicines,
  }) {
    return dioRequest.post<MedicineAiSafetyResult>(
      HttpConstants.MEDICINE_AI_SAFETY,
      data: <String, dynamic>{
        if (userId != null && userId.trim().isNotEmpty) 'userId': userId.trim(),
        'mode': mode,
        'medicines': medicines,
      },
      decoder: (json) => MedicineAiSafetyResult.fromJson(_asMap(json)),
      showLoading: true,
      loadingText: '查询中...',
    );
  }

  /// 把动态接口结果安全转换为 Map。
  static Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return json.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }
}
