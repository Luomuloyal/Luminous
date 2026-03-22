# 01 应用启动与架构

## 这一篇最重要的结论

这个项目的启动设计思路很清楚：只把“首帧前必须完成的事情”留在 `main()`，其余偏重 I/O 的工作都延后到首帧之后。

你以后不管是要优化启动速度，还是排查“为什么页面一开始是游客态、随后又切成已登录态”，都要先回到这篇。

## 这一部分到底负责什么

这一部分负责四件事：

1. 把 Flutter 应用真正跑起来
2. 在 `runApp()` 之前只完成必要的全局依赖注入
3. 在首帧后异步恢复登录态、本地缓存、通知和数据库
4. 把应用按相对清晰的层次拆开，避免所有逻辑都堆进页面文件

## 建议你第一次怎么读

第一次看这部分，推荐顺序如下：

1. 先看 `lib/main.dart`
2. 再看 `lib/startup/app_startup_warmup.dart`
3. 再看 `lib/routes/routes.dart`
4. 最后看 `lib/pages/Main/main.dart`

这样你能先理解“应用是怎么起来的”，再去理解“起来以后先看到的是谁”。

## 冷启动的真实时间线

如果从 Android 冷启动开始，当前项目的主线是这样的：

1. 系统先显示 Android 原生启动屏
2. Flutter 进入 `lib/main.dart:12-21`
3. `main()` 里先执行 `WidgetsFlutterBinding.ensureInitialized()`
4. 紧接着注入 `UserController` 和 `ThemeController`
5. `ThemeController.init()` 会在 `runApp()` 前等待完成，保证主题模式一开始就是对的
6. `runApp(LuminousApp(...))` 后进入根组件
7. `LuminousApp.initState()` 在 `lib/main.dart:42-45` 里创建 `AppStartupWarmup`
8. `AppStartupWarmup.start()` 在 `lib/startup/app_startup_warmup.dart:23-31` 里把真正的 warmup 放到首帧后
9. `getRootWidget()` 在 `lib/routes/routes.dart:20-31` 里构建 `MaterialApp`
10. 初始路由 `/` 进入 `MainPage`
11. 首帧完成后，warmup 再去恢复登录态、预热 token、数据库和通知插件
12. 如果恢复出了用户 id，再触发一次会话同步

这里最值得记住的一点是：用户态恢复不是发生在 `main()` 里，而是发生在首帧之后。

## 为什么主题要首帧前恢复，用户态却不用

这其实体现了当前项目对体验优先级的选择：

- 主题模式如果首帧前不恢复，用户会明显看到明暗闪一下，所以值得提前做
- 用户态恢复虽然也重要，但它涉及 SharedPreferences、同步服务和后续数据刷新，适合首帧后做

对应代码分别在：

- `lib/main.dart:19-20`
- `lib/stores/theme_controller.dart:22-35`
- `lib/startup/app_startup_warmup.dart:57-75`

## 当前项目的分层，大概应该怎么理解

这一套目录不是严格的“教科书分层”，但已经有比较清楚的职责边界。

### 入口与路由层

- `lib/main.dart`
- `lib/routes/routes.dart`

这一层负责把应用跑起来、决定根路由和全局主题，不写具体业务。

### 页面层

- `lib/pages/`

页面层负责：

- 用户交互
- 页面布局
- 什么时候触发加载
- 什么时候跳转

页面层一般不应该自己实现复杂的持久化和跨页面同步逻辑。

### 组件层

- `lib/components/`

组件层主要放可复用 UI，比如卡片、网格、顶部横幅。它们一般不应该自己决定业务行为，而是由页面传入回调和数据。

### 状态与本地数据层

- `lib/stores/`

这里是你以后最需要熟悉的一层，因为很多“看起来像页面 bug”的问题，其实根因都在这里。它负责：

- 全局用户态
- SQLite
- SharedPreferences
- 本地提醒/打卡数据
- 登录后的云端同步

### 网络层

- `lib/api/`

这一层负责把接口路径、请求体、响应解析封装掉，让页面只关心“我要调用什么能力”。

### 数据模型层

- `lib/viewmodels/`

这里主要是接口返回模型和展示模型。以后如果前后端字段对不上，通常要同时看 `api/` 和 `viewmodels/`。

### 启动协调层

- `lib/startup/`

这是当前项目比较重要也比较值得保留的设计。它把启动阶段特殊逻辑从页面里拿了出来。

## 核心实现路径

### UI 入口

- `lib/main.dart:12-21`
  只做 Flutter binding、全局控制器注入、主题恢复、`runApp()`
- `lib/main.dart:42-45`
  根组件在 `initState()` 里启动 warmup
- `lib/routes/routes.dart:20-31`
  构建 `MaterialApp`
- `lib/routes/routes.dart:38-54`
  根路由表
- `lib/pages/Main/main.dart:108-158`
  真正的一级页面容器

### 状态来源

- 用户态来自 `lib/stores/user_controller.dart:17-18`
- 主题模式来自 `lib/stores/theme_controller.dart:11-19`
- 登录恢复完成状态来自 `lib/stores/user_controller.dart:18` 的 `sessionReady`

### 首帧后的 warmup 任务

`lib/startup/app_startup_warmup.dart` 里把 warmup 拆成了几块：

- `:34-46` `_runWarmup()`
  统一调度所有首帧后任务
- `:48-55` `_warmTokenStore()`
  预热 token 存储
- `:57-68` `_restoreUserSession()`
  从本地恢复登录用户
- `:71-77` `_syncCloudSession()`
  登录恢复后尝试同步远端数据
- `:80-89` `_warmDatabase()`
  预热 SQLite，仅原生端执行
- `:92-101` `_warmNotificationSdk()`
  预热通知插件，仅原生端执行

### 结果如何回到 UI

恢复用户态和同步完成后，页面不会手动一个个通知刷新，而是通过响应式状态自行回流：

- 页面通过 `Obx` 监听 `UserController.user`
- 某些页面会在用户变化后重新读取本地数据
- 登录后同步服务会把远端数据落到本地 store，再由页面重新渲染

## 一条最短的读码路径

如果你以后想重新把启动过程过一遍，最短路径就是：

1. `lib/main.dart:12-21`
2. `lib/main.dart:42-50`
3. `lib/startup/app_startup_warmup.dart:23-31`
4. `lib/startup/app_startup_warmup.dart:34-75`
5. `lib/routes/routes.dart:20-31`
6. `lib/routes/routes.dart:38-54`
7. `lib/pages/Main/main.dart:35-74`
8. `lib/pages/Main/main.dart:108-158`

看完这 8 段，整个应用的“入口结构”基本就清楚了。

## 关键代码位置

- `lib/main.dart:12-21`
  应用入口。决定哪些初始化必须挡在首帧前。
- `lib/main.dart:42-45`
  根组件在 `initState()` 里启动 warmup。
- `lib/startup/app_startup_warmup.dart:23-31`
  通过 `addPostFrameCallback` 把重操作延后到首帧后。
- `lib/startup/app_startup_warmup.dart:57-64`
  恢复本地用户并决定是否需要同步云端数据。
- `lib/startup/app_startup_warmup.dart:71-75`
  启动后延迟触发一次会话同步。
- `lib/routes/routes.dart:20-31`
  构建根 `MaterialApp`，并接入暗黑模式。
- `lib/routes/routes.dart:38-54`
  全局命名路由表。
- `lib/pages/Main/main.dart:35-74`
  一级 Tab 配置和按需挂载策略。
- `lib/stores/user_controller.dart:38-68`
  从 SharedPreferences 恢复用户态。
- `lib/stores/session_sync_service.dart:29-71`
  登录后同步我的药品、提醒、相册。

## 容易忽略的实现细节

- `UserController.markSessionPending()` 在 `lib/main.dart:18` 先把 `sessionReady` 设为 `false`，这意味着应用刚起来时，部分页面应该接受“会话还没恢复完”这个中间状态。
- warmup 里的多个任务不是同时瞬间启动，而是分别带了轻量延迟，目的是把 I/O 和插件初始化错开，降低首帧后短时间内的卡顿概率。
- `AppStartupWarmup._warmDatabase()` 和 `_warmNotificationSdk()` 在 Web 端直接跳过，所以你以后遇到“Web 和 Android 行为不完全一样”，先确认是不是这里的条件分支。
- `SessionSyncService` 通过 `_syncTail` 做串行化，防止 A 用户的同步结果覆盖到 B 用户上。

## 如果以后要改，优先改哪里

### 想继续压缩冷启动耗时

先看：

1. `lib/main.dart`
2. `lib/startup/app_startup_warmup.dart`

判断标准很简单：这个初始化是否必须在首帧前完成？

### 想加一个新的全局服务

你先决定它属于哪一类：

- 必须首帧前生效：放到 `main()` 前后
- 可以首帧后慢慢准备：放到 `AppStartupWarmup`
- 只和某个页面有关：不要放启动层，直接放页面自己的加载流程

### 想改全局主题或暗黑模式策略

先看：

1. `lib/stores/theme_controller.dart`
2. `lib/routes/routes.dart`

### 想改登录恢复或用户持久化方式

先看：

1. `lib/stores/user_controller.dart`
2. `lib/startup/app_startup_warmup.dart`

## 初学时最容易卡住的点

- 误以为 `main()` 已经恢复了登录态。实际上没有，真正恢复发生在首帧后。
- 误以为页面是直接从网络拿数据。实际上很多页面是“先读本地，再由同步服务补齐”。
- 误以为所有全局状态都在 GetX controller。实际上本地数据库、同步服务、通知服务也都参与了全局状态链路。

## 相关测试在哪

- 当前没有专门覆盖 warmup 调度和会话恢复时序的测试
- 间接能覆盖登录相关恢复基础行为的是 `test/login_page_test.dart:13-156`

如果以后你想继续提高这部分的可维护性，最值得补的测试是：

1. `ThemeController.init()` 的恢复测试
2. `UserController.init()` 的异常清理测试
3. `AppStartupWarmup` 的任务顺序和 Web 分支测试
