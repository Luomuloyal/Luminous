# 08 本地存储与同步

## 这一篇最重要的结论

这个项目真正容易出问题的地方，不是某一个页面，而是“不同数据到底谁算真相”。

当前本地层的核心规则可以概括成三句：

1. SharedPreferences 负责轻量状态，如用户、主题、token
2. SQLite 负责业务数据，如我的药品、提醒、打卡、相册、当天快照
3. 不同功能的“真相来源”并不一样，必须分开看

你以后只要遇到：

- 数据残留
- 用户切换后串数据
- 首页和打卡页状态不一致
- 相册本地和远端对不上

优先回到这一篇。

## 这一部分到底负责什么

这一部分主要负责：

- SQLite 表结构
- SharedPreferences 持久化
- 用户作用域隔离
- 本地缓存读写
- 登录后的会话同步
- 当天提醒与打卡状态的统一口径

## 建议你第一次怎么读

推荐顺序：

1. `lib/stores/app_database.dart`
2. `lib/stores/user_controller.dart`
3. `lib/stores/token_manager.dart`
4. `lib/stores/my_medicine_repository.dart`
5. `lib/stores/reminder_local_store.dart`
6. `lib/stores/today_reminder_local_store.dart`
7. `lib/stores/album_local_store.dart`
8. `lib/stores/session_sync_service.dart`
9. 相关测试

这样你会先知道“存在哪里”，再知道“谁负责把它们串起来”。

## 当前本地层可以分成两大类

### SharedPreferences

主要放轻量配置和会话信息：

- 当前用户 JSON
- 主题模式
- token

对应文件：

- `lib/stores/user_controller.dart`
- `lib/stores/theme_controller.dart`
- `lib/stores/token_manager.dart`

### SQLite

主要放业务数据和缓存：

- 我的药品
- 相册
- 提醒计划
- 打卡记录
- 打卡覆盖状态
- 当天提醒快照

对应总入口：

- `lib/stores/app_database.dart`

## AppDatabase 现在的核心结构

数据库入口在：

- `lib/stores/app_database.dart:12-58`

当前 schema 版本：

- `lib/stores/app_database.dart:27`
  `_version = 8`

建表逻辑在：

- `lib/stores/app_database.dart:62-197`

迁移逻辑在：

- `lib/stores/app_database.dart:202-275`

这意味着以后你要加表、加字段、改索引，不能只改 `CREATE TABLE`，还要同时考虑老用户升级路径。

## 当前主要表的职责边界

### `my_medicines`

用途：

- 保存用户手动加入或识别后加入的药品

位置：

- `lib/stores/app_database.dart:63-85`

对应仓库：

- `lib/stores/my_medicine_repository.dart`

### `album_items`

用途：

- 保存扫描相册记录
- 包括远端 id、缩略图、本地原图、identityKey 等

位置：

- `lib/stores/app_database.dart:87-119`

对应仓库：

- `lib/stores/album_local_store.dart`

### `reminders`

用途：

- 保存提醒计划缓存

位置：

- `lib/stores/app_database.dart:121-140`

对应仓库：

- `lib/stores/reminder_local_store.dart`

要特别记住：它现在只代表“提醒计划”，不是首页当天提醒真相。

### `checkins`

用途：

- 保存当天本地打卡记录

位置：

- `lib/stores/app_database.dart:142-156`

### `checkin_overrides`

用途：

- 保存当天本地覆盖状态
- 支持“明明今天本地打过卡，但我又想撤销成本地未打卡”

位置：

- `lib/stores/app_database.dart:157-172`

### `today_reminder_snapshots`

用途：

- 保存 `today-reminders` 当天接口快照

位置：

- `lib/stores/app_database.dart:174-197`

这张表是这轮架构调整后最关键的一张表之一。

## 现在不同功能的“真相来源”分别是什么

这是你以后最值得反复回看的部分。

### 我的药品

主真相：

- 本地 `my_medicines`

登录后：

- 会尝试同步远端
- 但页面本身还是本地优先读

### 提醒计划

主真相：

- 远端提醒接口

本地 `reminders` 的角色：

- 缓存
- 离线回退
- 通知调度输入

### 首页今日提醒

主真相：

- 远端成功后的 `today_reminder_snapshots`

最终 UI：

- `today_reminder_snapshots`
- `checkins`
- `checkin_overrides`

三者叠加

### 用药打卡

主真相：

- 本地提醒计划 `reminders`
- 本地 `checkins`
- 本地 `checkin_overrides`

当前不依赖打卡后端。

### 相册

主真相：

- 本地 `album_items`

登录后：

- 远端记录会被 merge / upsert 回本地

## 各个本地仓库分别负责什么

### `MyMedicineRepository`

关键位置：

- `lib/stores/my_medicine_repository.dart:35-64`
  identityKey 与用户作用域
- `lib/stores/my_medicine_repository.dart:91-155`
  本地先写、登录后尽量同步
- `lib/stores/my_medicine_repository.dart:163-177`
  同步远端药品
- `lib/stores/my_medicine_repository.dart:244-290`
  游客数据迁移到登录用户作用域

它最值得学的点是“作用域 identityKey”，比如：

- 游客：`guest|...`
- 登录用户：`user:{id}|...`

这样能避免游客和登录用户本地数据串在一起。

### `ReminderLocalStore`

关键位置：

- `lib/stores/reminder_local_store.dart:19-33`
  读取提醒计划缓存
- `lib/stores/reminder_local_store.dart:40-61`
  用完整远端结果覆盖本地提醒缓存

它的重点是“全量覆盖”，不是增量 merge。

### `TodayReminderLocalStore`

这是当前最关键的状态整合层之一。

关键位置：

- `lib/stores/today_reminder_local_store.dart:81-127`
  覆盖当天快照
- `lib/stores/today_reminder_local_store.dart:130-159`
  读取今日 override
- `lib/stores/today_reminder_local_store.dart:162-189`
  保存今日 override
- `lib/stores/today_reminder_local_store.dart:192-228`
  写入今日 checkin
- `lib/stores/today_reminder_local_store.dart:231-252`
  删除今日 checkin
- `lib/stores/today_reminder_local_store.dart:255-315`
  从快照 / 本地状态生成最终提醒
- `lib/stores/today_reminder_local_store.dart:317-338`
  从提醒计划构建今日打卡条目
- `lib/stores/today_reminder_local_store.dart:389-404`
  `done` 判定优先级

它的职责不是“再存一份页面状态”，而是把多来源状态合成出当天真实表现。

### `AlbumLocalStore`

关键位置：

- `lib/stores/album_local_store.dart:36-60`
  读列表
- `lib/stores/album_local_store.dart:62-96`
  存本地扫描记录
- `lib/stores/album_local_store.dart:98-123`
  登录后同步远端
- `lib/stores/album_local_store.dart:125-210`
  远端回写本地并保留原图
- `lib/stores/album_local_store.dart:373-442`
  补推 pending 本地记录

## 会话同步服务到底做了什么

`SessionSyncService` 在：

- `lib/stores/session_sync_service.dart:29-71`

当前登录后同步顺序是：

1. 我的药品
2. 用药提醒
3. 相册

提醒同步细节在：

- `lib/stores/session_sync_service.dart:75-84`

它会先拉远端列表，再写 `reminders` 本地缓存，再重建通知。

另外它还有一个很重要的保护：

- `_shouldApplySync()`

对应：

- `lib/stores/session_sync_service.dart:86-92`

这能避免 A 用户发起的同步结果落到 B 用户界面上。

## token 和用户为什么不放到 SQLite

当前设计里：

- 用户 JSON 走 `UserController + SharedPreferences`
- token 走 `TokenManager + SharedPreferences`

对应位置：

- `lib/stores/user_controller.dart:38-91`
- `lib/stores/token_manager.dart:20-44`

这样做的原因是：

- 结构更轻
- 启动恢复更直接
- 不需要为会话轻量数据额外走 SQLite

## Web 和原生端有什么本地差异

这个点也很值得你记住。

`TodayReminderLocalStore` 在 Web 端有内存兜底分支：

- `lib/stores/today_reminder_local_store.dart:56-60`
- `lib/stores/today_reminder_local_store.dart:86-99`
- `lib/stores/today_reminder_local_store.dart:167-179`
- `lib/stores/today_reminder_local_store.dart:198-211`

也就是说，Web 端这块不完全依赖 SQLite。

所以以后你如果看到：

- Web 表现和 Android 不完全一样
- Web 测试里没走真实数据库

先想想是不是这里的分支导致的。

## 一条最短的读码路径

如果你以后只想最快重温本地层结构，推荐顺序：

1. `lib/stores/app_database.dart:21-58`
2. `lib/stores/app_database.dart:62-197`
3. `lib/stores/user_controller.dart:38-91`
4. `lib/stores/token_manager.dart:20-44`
5. `lib/stores/reminder_local_store.dart:19-61`
6. `lib/stores/today_reminder_local_store.dart:81-127`
7. `lib/stores/today_reminder_local_store.dart:255-315`
8. `lib/stores/my_medicine_repository.dart:35-64`
9. `lib/stores/my_medicine_repository.dart:91-177`
10. `lib/stores/album_local_store.dart:36-123`
11. `lib/stores/session_sync_service.dart:29-92`

## 关键代码位置

- `lib/stores/app_database.dart:27`
  当前数据库 schema 版本。
- `lib/stores/app_database.dart:35-58`
  打开数据库。
- `lib/stores/app_database.dart:62-197`
  创建全部表结构。
- `lib/stores/app_database.dart:202-275`
  数据库升级迁移。
- `lib/stores/my_medicine_repository.dart:35-64`
  用户作用域 identityKey。
- `lib/stores/my_medicine_repository.dart:91-155`
  本地新增“我的药品”。
- `lib/stores/my_medicine_repository.dart:163-177`
  登录后同步远端药品。
- `lib/stores/my_medicine_repository.dart:244-290`
  游客药品迁移。
- `lib/stores/reminder_local_store.dart:19-61`
  提醒计划本地缓存。
- `lib/stores/today_reminder_local_store.dart:81-127`
  用远端结果覆盖当天快照。
- `lib/stores/today_reminder_local_store.dart:162-228`
  写入本地 override 和本地 checkin。
- `lib/stores/today_reminder_local_store.dart:255-315`
  组装首页 / 打卡页最终提醒。
- `lib/stores/today_reminder_local_store.dart:389-404`
  `done` 状态优先级。
- `lib/stores/album_local_store.dart:36-60`
  相册本地读取。
- `lib/stores/album_local_store.dart:98-123`
  相册远端同步入口。
- `lib/stores/album_local_store.dart:125-210`
  远端回写本地。
- `lib/stores/album_local_store.dart:373-442`
  pending 相册记录上传。
- `lib/stores/session_sync_service.dart:29-71`
  登录后的统一同步入口。
- `lib/stores/session_sync_service.dart:75-84`
  提醒计划同步。
- `lib/stores/token_manager.dart:20-44`
  token 预热、写入和删除。

## 容易忽略的实现细节

- `today_reminder_snapshots` 是按天全量覆盖，不是增量 merge。
- `checkin_overrides` 的优先级高于 `checkins` 和 `serverDone`。
- 我的药品和相册都做了用户作用域隔离，不是简单共享同一份本地数据。
- Web 端在今日提醒本地状态这块有内存兜底实现，不完全等同于原生端。

## 如果以后要改，优先改哪里

### 想改数据库结构

先看：

1. `lib/stores/app_database.dart`

并且一定同时考虑：

1. 新建表
2. 升级迁移
3. 老数据兼容

### 想改某个功能的数据真相来源

先确认你改的是：

1. 提醒计划
2. 当天提醒
3. 打卡状态
4. 相册
5. 我的药品

然后再去看对应 store，不要直接在页面里改。

### 想改登录后同步顺序或范围

先看：

1. `lib/stores/session_sync_service.dart`

### 想改 token / 用户持久化方式

先看：

1. `lib/stores/user_controller.dart`
2. `lib/stores/token_manager.dart`

## 初学时最容易卡住的点

- 误以为所有本地数据都在 SQLite。实际上用户、主题、token 不在。
- 误以为 `reminders` 表就是首页当天提醒来源。现在已经不是。
- 误以为会话同步只是“顺手拉数据”。实际上它还会影响本地通知和多个页面的本地视图。

## 相关测试在哪

- `test/today_reminder_local_store_test.dart:6-58`
  覆盖日期处理和 `done` 状态优先级。
- `test/home_today_reminders_test.dart:37-154`
  覆盖首页当天提醒快照覆盖与回退。
- `test/checkin_page_test.dart:37-154`
  覆盖打卡页本地状态叠加和撤销逻辑。
- `test/album_local_store_test.dart:23-205`
  覆盖相册本地写入、用户作用域、远端回写和 pending 上传。

如果以后要继续加强这一层的质量，最值得优先补的是：

1. `AppDatabase` 升级迁移测试
2. `SessionSyncService` 串用户保护测试
3. `MyMedicineRepository` 游客迁移到登录用户作用域测试
