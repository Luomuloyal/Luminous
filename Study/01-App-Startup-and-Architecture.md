# 01 应用启动与架构

## 这个功能是干什么的

这一部分负责把应用启动起来，并把“必须首帧前完成的事”和“可以首帧后预热的事”拆开。

## 用户从哪里进入 / 如何触发

- Android 冷启动后先进入原生启动屏
- Flutter 入口从 `main()` 开始
- 根路由默认进入底部 Tab 容器

## 关键页面、组件、API、store、backend、native 文件

- Flutter 入口：`lib/main.dart`
- 启动预热：`lib/startup/app_startup_warmup.dart`
- 根路由：`lib/routes/routes.dart`
- 主容器：`lib/pages/Main/main.dart`
- 用户态：`lib/stores/user_controller.dart`
- 会话同步：`lib/stores/session_sync_service.dart`
- 原生启动：`android/app/src/main/AndroidManifest.xml`

## 核心实现路径

### UI 入口

- `main()` 先 `WidgetsFlutterBinding.ensureInitialized()`，只注入 `UserController`
- `runApp()` 后由 `LuminousApp` 在 `initState()` 启动 warmup

### 状态来源

- 全局用户态来自 `UserController.user`
- 路由和页面层不直接持有登录持久化逻辑，而是读 `UserController`

### 网络 / 本地存储 / 后端流转

- 首帧后 warmup 会并行预热 token、SharedPreferences、SQLite、通知插件
- 如果恢复出登录用户，则再触发 `SessionSyncService.syncForUser()`

### 结果如何回到 UI

- `UserController.user` 变更后，首页、药品页、提醒页、相册页等通过 `ever` 或 `Obx` 自动刷新

## 关键代码位置

- `lib/main.dart:11`
  Flutter 真正入口，只保留轻量依赖注入。
- `lib/main.dart:38`
  `LuminousApp` 在首帧后启动 warmup。
- `lib/startup/app_startup_warmup.dart:23`
  统一调度首帧后的异步预热任务。
- `lib/startup/app_startup_warmup.dart:57`
  恢复本地登录态并决定是否触发云同步。
- `lib/routes/routes.dart:16`
  构建 `MaterialApp` 与全局主题。
- `lib/routes/routes.dart:42`
  根命名路由表。
- `lib/stores/user_controller.dart:32`
  从 SharedPreferences 恢复用户。
- `lib/stores/session_sync_service.dart:29`
  登录后串行同步“我的药品 / 提醒 / 相册”。

## 容易忽略的实现细节

- 启动预热是“首帧后”才开始，不是 `main()` 里同步等待。
- `SessionSyncService` 用 `_syncTail` 串行化，避免不同用户会话交叉覆盖。
- 启动后首页会先以游客态构建，再由用户恢复和同步逐步校正。

## 如果以后要改，优先改哪里

- 想改启动阶段节奏：先看 `lib/startup/app_startup_warmup.dart`
- 想加全局路由 / 主题：先看 `lib/routes/routes.dart`
- 想改登录态持久化方式：先看 `lib/stores/user_controller.dart`

## 相关测试在哪

- 当前没有专门覆盖 warmup 和会话恢复时序的测试
- 间接覆盖登录表单的是 `test/login_page_test.dart`
