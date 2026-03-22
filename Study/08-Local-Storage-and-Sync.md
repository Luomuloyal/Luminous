# 08 本地存储与同步

## 这个功能是干什么的

这部分负责 SQLite 表结构、本地缓存、游客与登录用户的数据隔离，以及登录后的远端同步。

## 用户从哪里进入 / 如何触发

- 应用启动 warmup 会预热数据库
- 登录成功后会话同步会触发远端同步
- 各功能页会在初始化或用户变化时读各自的本地仓库

## 关键页面、组件、API、store、backend、native 文件

- 数据库：`lib/stores/app_database.dart`
- 我的药品：`lib/stores/my_medicine_repository.dart`
- 提醒缓存：`lib/stores/reminder_local_store.dart`
- 今日提醒状态：`lib/stores/today_reminder_local_store.dart`
- 相册缓存：`lib/stores/album_local_store.dart`
- 会话同步：`lib/stores/session_sync_service.dart`
- token 持久化：`lib/stores/token_manager.dart`

## 核心实现路径

### UI 入口

- 页面层不会直接拼 SQL，都是通过 store / repository 访问数据

### 状态来源

- `luminous.db` 是统一 SQLite 文件
- `userId` 决定了本地数据作用域，游客一般用空字符串或 legacy 标记

### 网络 / 本地存储 / 后端流转

- 我的药品：本地先写，登录用户再尽量 upsert 到远端
- 提醒：登录后全量拉远端列表覆盖本地
- 相册：本地 pending 先补推远端，再拉远端记录回写本地
- 会话同步统一在 `SessionSyncService` 里串起来

### 结果如何回到 UI

- 页面重新读取本地仓库后重建 UI
- 用户态变化会触发很多页面的 `ever` 监听，自动切到对应作用域的数据

## 关键代码位置

- `lib/stores/app_database.dart:43`
  打开数据库。
- `lib/stores/app_database.dart:62`
  创建所有表结构。
- `lib/stores/app_database.dart:178`
  数据库升级迁移。
- `lib/stores/my_medicine_repository.dart:36`
  构建带用户作用域的 identityKey。
- `lib/stores/my_medicine_repository.dart:91`
  新增“我的药品”。
- `lib/stores/my_medicine_repository.dart:163`
  同步远端药品到本地。
- `lib/stores/my_medicine_repository.dart:244`
  游客药品迁移到登录用户作用域。
- `lib/stores/reminder_local_store.dart:19`
  读取提醒缓存。
- `lib/stores/reminder_local_store.dart:40`
  用完整列表覆盖提醒缓存。
- `lib/stores/today_reminder_local_store.dart:22`
  读取今日打卡 override。
- `lib/stores/today_reminder_local_store.dart:100`
  从本地 reminders/checkins 组装今日提醒。
- `lib/stores/album_local_store.dart:99`
  相册远端同步入口。
- `lib/stores/session_sync_service.dart:40`
  登录后的统一同步调度。

## 容易忽略的实现细节

- `identityKey` 都带了用户作用域，避免游客和登录用户数据混淆
- 相册同步会把游客 legacy 记录并入登录用户
- 提醒本地缓存采用“整表覆盖”的口径，不是增量 merge

## 如果以后要改，优先改哪里

- 改表结构：先看 `lib/stores/app_database.dart`
- 改同步顺序：看 `lib/stores/session_sync_service.dart`
- 改数据隔离规则：看 `my_medicine_repository.dart` 和 `album_local_store.dart`

## 相关测试在哪

- `test/album_local_store_test.dart:23`
  覆盖相册本地写入、远端回写、游客记录迁移
- 当前没有专门覆盖 reminders/checkins SQLite 组合读取的测试
