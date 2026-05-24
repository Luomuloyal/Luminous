import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/shared/models/home.dart';

/// 首页相关接口封装。
class HomeApi {
  /// 私有构造函数，当前类作为静态方法集合使用。
  HomeApi._();

  /// 获取今天的提醒数据。
  ///
  /// 会自动带上当天日期；如果传入 `userId`，则同时按用户维度请求。
  static Future<ApiResult<TodayRemindersResult>> fetchTodayReminders({
    String? userId,
  }) {
    /// 当前日期字符串，格式为 `yyyy-MM-dd`。
    final date = DateTime.now().toIso8601String().substring(0, 10);
    return dioRequest.post<TodayRemindersResult>(
      HttpConstants.TODAY_REMINDERS,
      data: <String, dynamic>{
        'date': date,
        if (userId != null && userId.trim().isNotEmpty) 'userId': userId.trim(),
      },
      decoder: (json) {
        if (json is Map<String, dynamic>) {
          return TodayRemindersResult.fromJson(json);
        }
        if (json is Map) {
          return TodayRemindersResult.fromJson(json.cast<String, dynamic>());
        }
        return TodayRemindersResult(date: date, items: const []);
      },
    );
  }
}
