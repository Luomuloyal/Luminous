import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/DioRequest.dart';
import 'package:luminous/viewmodels/checkin.dart';

/// 用药打卡接口封装。
class CheckinApi {
  /// 私有构造函数，当前类只提供静态接口调用能力。
  CheckinApi._();

  /// 创建一条打卡记录。
  ///
  /// - `userId`：当前登录用户 id；
  /// - `reminderId`：对应提醒计划 id；
  /// - `takenAt`：可选的实际打卡时间戳，不传时由后端决定。
  static Future<ApiResult<CheckinCreateResult>> create({
    required String userId,
    required String reminderId,
    int? takenAt,
  }) {
    return dioRequest.post<CheckinCreateResult>(
      HttpConstants.CHECKIN_CREATE,
      data: <String, dynamic>{
        'userId': userId.trim(),
        'reminderId': reminderId.trim(),
        ...?(takenAt == null ? null : <String, dynamic>{'takenAt': takenAt}),
      },
      decoder: (json) => CheckinCreateResult.fromJson(_asMap(json)),
      showLoading: true,
      loadingText: '打卡中...',
    );
  }

  /// 把接口返回的动态对象安全转成 Map。
  static Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return json.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }
}
