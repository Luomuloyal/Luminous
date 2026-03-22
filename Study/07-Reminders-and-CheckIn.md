# 07 提醒与打卡

## 这个功能是干什么的

负责提醒计划的增删改查、系统通知调度、今日打卡以及打卡状态对首页的反映。

## 用户从哪里进入 / 如何触发

- 首页快捷入口“用药提醒”进入提醒列表
- 首页快捷入口“用药打卡”进入打卡页
- 提醒列表右下角新增、点击卡片编辑、开关启停、删除

## 关键页面、组件、API、store、backend、native 文件

- 提醒列表：`lib/pages/Reminders/reminder_list.dart`
- 提醒编辑：`lib/pages/Reminders/reminder_edit.dart`
- 打卡页：`lib/pages/CheckIn/checkin.dart`
- 提醒 API：`lib/api/reminder_api.dart`
- 打卡 API：`lib/api/checkin_api.dart`
- 本地提醒缓存：`lib/stores/reminder_local_store.dart`
- 今日提醒本地状态：`lib/stores/today_reminder_local_store.dart`
- 通知调度：`lib/utils/notification_service.dart`

## 核心实现路径

### UI 入口

- 列表页初始化时先拉提醒计划
- 编辑页既承担新增也承担编辑
- 打卡页展示“今天有哪些提醒、哪些已完成”

### 状态来源

- 提醒列表主状态是 `_items`
- 编辑页表单状态由 `_nameController`、`_time`、`_enabled` 等保存
- 打卡页主状态是 `_items` 和 `_error`

### 网络 / 本地存储 / 后端流转

- 列表页成功请求 `ReminderApi.list()` 后会回写 `reminders` 表，并重建通知
- 编辑页保存时调用 `ReminderApi.upsert()`，成功后把结果 `pop` 回列表页
- 打卡页通过 `HomeApi.fetchTodayReminders()` 取今天应做的提醒，再结合本地 `checkins/checkin_overrides`
- 打卡时调用 `CheckinApi.create()`，同时写本地 checkins 和 override

### 结果如何回到 UI

- 列表页收到编辑页返回值后更新 `_items` 并 `NotificationService.rescheduleAll()`
- 打卡页 `_setLocalDone()` 直接更新当前按钮状态
- 首页返回后会再次刷新今日提醒

## 关键代码位置

- `lib/pages/Reminders/reminder_list.dart:75`
  列表加载主流程。
- `lib/pages/Reminders/reminder_list.dart:153`
  把当前列表持久化到本地缓存。
- `lib/pages/Reminders/reminder_list.dart:364`
  新增提醒后的回写逻辑。
- `lib/pages/Reminders/reminder_list.dart:380`
  编辑提醒后的回写逻辑。
- `lib/pages/Reminders/reminder_list.dart:398`
  切换提醒启用状态。
- `lib/pages/Reminders/reminder_list.dart:427`
  删除提醒。
- `lib/pages/Reminders/reminder_edit.dart:80`
  编辑页初始化与回填。
- `lib/pages/Reminders/reminder_edit.dart:341`
  选药填表。
- `lib/pages/Reminders/reminder_edit.dart:382`
  保存提醒。
- `lib/pages/CheckIn/checkin.dart:50`
  打卡页加载今日提醒。
- `lib/pages/CheckIn/checkin.dart:319`
  打卡 / 取消打卡入口。
- `lib/pages/CheckIn/checkin.dart:327`
  标记已打卡。
- `lib/pages/CheckIn/checkin.dart:364`
  标记未打卡。
- `lib/api/reminder_api.dart:11`
  列表接口。
- `lib/api/reminder_api.dart:31`
  upsert 接口。
- `lib/api/reminder_api.dart:68`
  delete 接口。
- `lib/api/checkin_api.dart:15`
  创建打卡接口。
- `lib/stores/reminder_local_store.dart:19`
  读取本地提醒缓存。
- `lib/stores/reminder_local_store.dart:40`
  用远端完整结果覆盖本地提醒缓存。
- `lib/stores/today_reminder_local_store.dart:47`
  保存今日 override。
- `lib/stores/today_reminder_local_store.dart:63`
  写今日 checkin。
- `lib/stores/today_reminder_local_store.dart:86`
  删今日 checkin。
- `lib/utils/notification_service.dart:125`
  全量重建系统通知。

## 容易忽略的实现细节

- 编辑页如果用户手改药品名称，会自动清掉旧 `drugCode/approvalNo`，避免身份错配
- 通知层当前只真正调度 `daily + notification` 的计划
- 当前“取消打卡”只有本地撤销，没有远端撤销，这是本轮 review 的高优问题

## 如果以后要改，优先改哪里

- 改提醒列表或通知策略：`lib/pages/Reminders/reminder_list.dart` + `lib/utils/notification_service.dart`
- 改提醒表单：`lib/pages/Reminders/reminder_edit.dart`
- 改打卡一致性：`lib/pages/CheckIn/checkin.dart` + 后端对应接口

## 相关测试在哪

- `test/reminder_edit_page_test.dart:19`
  覆盖“手改药名后清掉旧 identity”这条编辑页关键规则
- 当前没有覆盖提醒列表加载、通知调度和取消打卡的测试
