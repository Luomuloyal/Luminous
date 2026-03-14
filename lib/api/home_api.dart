import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/DioRequest.dart';
import 'package:luminous/viewmodels/home.dart';

class HomeApi {
  HomeApi._();

  static Future<ApiResult<TodayRemindersResult>> fetchTodayReminders({
    String? userId,
  }) {
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
