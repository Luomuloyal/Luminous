import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:luminous/viewmodels/reminder.dart';

/// 统一封装本地通知能力的服务类。
///
/// 当前主要负责：
/// 1. 初始化通知插件与时区；
/// 2. 请求通知权限；
/// 3. 根据提醒计划重新调度本地通知；
/// 4. 取消所有已调度的通知。
class NotificationService {
  /// 私有构造函数，限制外部直接 new，只允许通过单例访问。
  NotificationService._();

  /// 全局单例实例。
  ///
  /// 这样全应用只维护一套通知插件状态，避免重复初始化和多实例带来的管理混乱。
  static final NotificationService instance = NotificationService._();

  /// `flutter_local_notifications` 插件实例。
  ///
  /// 所有真正和平台打交道的通知操作，最终都通过它完成。
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// 标记通知服务是否已经完成初始化。
  ///
  /// 用来保证 `init()` 是幂等的，避免反复初始化插件和渠道。
  bool _inited = false;

  /// Android 通知渠道 id。
  ///
  /// 系统会用它识别“这是一组什么类型的通知”。
  static const String _channelId = 'luminous_reminders';

  /// Android 通知渠道名称。
  ///
  /// 这是展示给用户看的渠道名。
  static const String _channelName = '用药提醒';

  /// Android 通知渠道描述。
  ///
  /// 这是展示在系统通知设置页中的说明文字。
  static const String _channelDescription = '按计划提醒你按时用药';

  /// 初始化通知服务。
  ///
  /// 初始化内容包括：
  /// 1. timezone 数据库初始化；
  /// 2. 尝试设置本地时区；
  /// 3. 初始化本地通知插件；
  /// 4. 预先创建 Android 通知渠道。
  Future<void> init() async {
    if (_inited) {
      return;
    }

    // 初始化 timezone 数据，`zonedSchedule` 依赖它来按本地时区调度。
    tz.initializeTimeZones();
    await _trySetLocalTimezone();

    /// Android 平台的初始化配置。
    ///
    /// 这里使用应用默认 launcher 图标作为通知小图标。
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    /// iOS/macOS 平台的初始化配置。
    ///
    /// 这里先不在初始化阶段直接请求权限，权限单独在 `_ensureNotificationPermission`
    /// 中按需请求。
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    /// 汇总后的跨平台初始化配置对象。
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    // 提前创建通知渠道，避免某些 Android 设备在首次调度时漏通知。
    /// Android 平台的用药提醒渠道定义。
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    _inited = true;
  }

  /// 取消当前应用已调度的所有本地通知。
  ///
  /// 一般在“重新调度所有提醒”之前调用，确保旧计划不会残留。
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// 按当前提醒计划重新调度所有通知。
  ///
  /// 逻辑是全量重建：
  /// 1. 初始化通知服务；
  /// 2. 确保有通知权限；
  /// 3. 取消旧通知；
  /// 4. 遍历 reminders，把满足条件的提醒重新 schedule。
  Future<void> rescheduleAll(List<ReminderPlan> reminders) async {
    await init();

    /// 当前设备/平台是否已经拿到通知权限。
    ///
    /// 如果没有权限，提醒数据仍然保留，但不会真的调度到系统。
    final granted = await _ensureNotificationPermission();
    if (!granted) {
      return;
    }

    await cancelAll();

    /// Android 平台采用的调度模式。
    ///
    /// 优先尝试精确调度，失败后回退为非精确调度。
    final scheduleMode = await _chooseAndroidScheduleMode();

    /// 逐条遍历提醒计划，只为当前实现支持的提醒类型创建通知。
    for (final r in reminders) {
      if (!r.enabled) continue;
      if (r.repeatRule.trim().toLowerCase() != 'daily') continue;
      if (r.method.trim().toLowerCase() != 'notification') continue;
      if (r.id.trim().isEmpty) continue;

      /// 从 `HH:mm` 字符串中解析出的时和分。
      ///
      /// 若解析失败，说明当前提醒时间格式非法，直接跳过。
      final hm = _parseHourMinute(r.time);
      if (hm == null) continue;

      /// 当前提醒对应的稳定通知 id。
      ///
      /// 使用提醒 id 做稳定 hash，保证相同提醒每次生成的通知 id 一致。
      final notificationId = _stableHash32('reminder:${r.id}');

      /// 这条提醒下一次应该触发的具体时间。
      final scheduled = _nextInstanceOfTime(hm.$1, hm.$2);

      /// 通知标题。
      ///
      /// 优先显示药品名称，没有药品名称时回退为通用标题。
      final title = r.productName.trim().isEmpty
          ? '用药提醒'
          : r.productName.trim();

      /// 通知正文。
      ///
      /// 优先显示提醒副标题，没有副标题时回退为通用提示语。
      final body = r.subtitle.trim().isEmpty ? '请按时用药' : r.subtitle.trim();

      await _plugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// 尝试把 timezone 包的本地时区设置为设备真实时区。
  ///
  /// 这是 best-effort 操作：
  /// - Web 平台直接跳过；
  /// - 获取失败时不抛错，回退使用 `tz.local` 默认行为。
  Future<void> _trySetLocalTimezone() async {
    if (kIsWeb) {
      return;
    }
    try {
      /// 设备当前时区名称，例如 `Asia/Shanghai`。
      final String timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      // 获取失败时保持默认时区配置，不阻塞通知初始化流程。
    }
  }

  /// 确保应用具备发送通知的权限。
  ///
  /// - Web 平台当前直接返回 false；
  /// - 已授权则直接返回 true；
  /// - 未授权则向系统发起权限申请。
  Future<bool> _ensureNotificationPermission() async {
    if (kIsWeb) {
      return false;
    }

    /// 当前通知权限状态。
    final status = await Permission.notification.status;
    if (status.isGranted) {
      return true;
    }

    /// 请求通知权限后的最新状态。
    final next = await Permission.notification.request();
    return next.isGranted;
  }

  /// 计算某个“时:分”在本地时区下的下一次触发时间。
  ///
  /// 如果今天这个时间还没到，就返回今天；
  /// 如果今天这个时间已经过了，就顺延到明天。
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    /// 当前本地时区下的时间。
    final now = tz.TZDateTime.now(tz.local);

    /// 先按“今天的 hour:minute”构造一个候选触发时间。
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// 选择 Android 调度模式。
  ///
  /// Android 12+ 以后，精确闹钟可能需要额外权限。
  /// 因此这里会：
  /// 1. 优先检查是否已经允许精确调度；
  /// 2. 若未允许，尝试向系统申请；
  /// 3. 若仍不可用，则回退为非精确调度。
  Future<AndroidScheduleMode> _chooseAndroidScheduleMode() async {
    if (kIsWeb) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }

    /// Android 平台特定的通知插件实现。
    ///
    /// 用它来检查/申请精确闹钟能力。
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }

    try {
      /// 当前是否已经具备精确通知调度能力。
      final can = await android.canScheduleExactNotifications();
      if (can == true) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }

      /// 如果没有精确调度能力，则尝试向系统申请。
      final granted = await android.requestExactAlarmsPermission();
      if (granted == true) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
    } catch (_) {
      // 查询或申请失败时，统一回退到非精确调度。
    }

    return AndroidScheduleMode.inexactAllowWhileIdle;
  }
}

/// 解析 `HH:mm` 形式的时间字符串。
///
/// 解析成功时返回 `(hour, minute)`；
/// 解析失败时返回 `null`。
(int, int)? _parseHourMinute(String time) {
  /// 去除前后空白后的时间字符串。
  final t = time.trim();
  if (t.length != 5 || !t.contains(':')) {
    return null;
  }

  /// 通过冒号分隔出的小时和分钟字符串。
  final parts = t.split(':');
  if (parts.length != 2) return null;

  /// 解析后的小时值。
  final h = int.tryParse(parts[0]);

  /// 解析后的分钟值。
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  if (h < 0 || h > 23) return null;
  if (m < 0 || m > 59) return null;
  return (h, m);
}

/// 基于字符串生成稳定的 32 位正整数 hash。
///
/// 这里用于把 reminder id 映射成通知 id，保证：
/// 1. 同一 reminder 每次调度出来的 id 一样；
/// 2. 不需要依赖数据库自增整型 id；
/// 3. 尽量减少不同 reminder 之间的冲突。
int _stableHash32(String input) {
  // FNV-1a 32-bit

  /// FNV-1a 算法使用的乘子常量。
  const int fnvPrime = 0x01000193;

  /// FNV-1a 算法的初始偏移基。
  int hash = 0x811c9dc5;

  /// 遍历输入字符串的 UTF-16 code units，逐步累计 hash。
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * fnvPrime) & 0xFFFFFFFF;
  }

  /// 最终转成非负 31 位整数，便于作为通知 id 使用。
  return hash & 0x7FFFFFFF;
}
