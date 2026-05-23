# 04 首页与今日提醒

## 这一篇最重要的结论

首页虽然看起来只是一个展示页，但它其实是多个能力的汇合点。

尤其是“今日提醒”这块，当前真正的口径已经不是直接读 `reminders` 表，而是：

1. 先请求远端 `today-reminders`
2. 成功后把当天结果完整覆盖到 `today_reminder_snapshots`
3. 再叠加本地 `checkins` 和 `checkin_overrides`
4. 最后才映射成首页 UI

所以你以后如果感觉“首页提醒不对”，优先不要去查 UI 文案，而是先查当天快照和本地覆盖状态。

## 这个功能是干什么的

首页当前承担四类职责：

1. 展示顶部健康助手色块
2. 展示“健康小贴士”和下一条提醒
3. 展示常用功能快捷入口
4. 展示今日提醒列表

它本身不是单纯静态页面，而是一个“轻交互 + 轻聚合”的入口页。

## 建议你第一次怎么读

推荐顺序：

1. `lib/pages/Home/home.dart`
2. `lib/components/home.dart`
3. `lib/api/home_api.dart`
4. `lib/stores/today_reminder_local_store.dart`
5. `lib/stores/app_database.dart`
6. `test/home_top_section_test.dart`
7. `test/home_today_reminders_test.dart`

这样你会先搞清楚页面怎么组装，再理解提醒数据到底从哪里来，最后再看测试验证了哪些关键规则。

## 用户从哪里进入 / 如何触发

- 冷启动默认第一页就是首页 Tab
- 切回首页时，如果用户态发生过变化，会重新刷新提醒
- 下拉刷新会主动重新拉取今日提醒
- 点快捷入口可跳搜索、识别、提醒、打卡、安全辅助等页面
- 点健康小贴士会切换文案，长按会弹出全部列表

## 关键页面、组件、API、store、backend、native 文件

- 页面入口：`lib/pages/Home/home.dart`
- 首页组件：`lib/components/home.dart`
- 顶部配色：`lib/components/soft_banner.dart`
- 首页 API：`lib/api/home_api.dart`
- 首页模型：`lib/viewmodels/home.dart`
- 今日提醒本地仓库：`lib/stores/today_reminder_local_store.dart`
- 本地数据库：`lib/stores/app_database.dart`
- 用户态：`lib/stores/user_controller.dart`
- 测试：
  - `test/home_top_section_test.dart`
  - `test/home_today_reminders_test.dart`

## 首页页面层和组件层怎么分工

这部分很值得你以后参考，因为分层是清楚的。

### 页面层 `lib/pages/Home/home.dart`

页面层负责：

- 绑定用户变化
- 发起今日提醒请求
- 处理成功、失败和回退逻辑
- 管理小贴士当前值
- 处理快捷入口跳转

### 组件层 `lib/components/home.dart`

组件层负责：

- 顶部卡片布局
- 常用功能网格
- 今日提醒列表
- 小贴士切换动画

对应关键组件是：

- `lib/components/home.dart:42-102`
  `HomeFeatureSection`
- `lib/components/home.dart:107-147`
  `HomeReminderSection`
- `lib/components/home.dart:152-334`
  `HomeTopSection`

这意味着以后你要改首页：

- 改数据和跳转，优先看 `home.dart`
- 改视觉和动画，优先看 `components/home.dart`

## 首页的真实结构

首页在 `lib/pages/Home/home.dart:256-284` 里的结构其实很简单：

1. 顶部 `HomeTopSection`
2. 常用功能 `HomeFeatureSection`
3. 今日提醒 `HomeReminderSection`

但真正复杂的不是布局，而是顶部提醒文案和今日提醒的数据来源。

## 核心实现路径

### UI 入口

- `lib/pages/Home/home.dart:191-204`
  `initState()` 里注册用户态和 `sessionReady` 监听
- `lib/pages/Home/home.dart:256-284`
  首页页面骨架
- `lib/pages/Home/home.dart:291-356`
  快捷入口点击分发
- `lib/pages/Home/home.dart:358-437`
  今日提醒主数据流

### 顶部色块和健康小贴士怎么来的

顶部色块本身的视觉来自：

- `lib/components/home.dart:152-334`
- `lib/components/soft_banner.dart`

而小贴士当前值来自页面层的 `ValueNotifier<String>`：

- `lib/pages/Home/home.dart:193`
  初始化为 `_startupHealthTip`
- `lib/pages/Home/home.dart:474-495`
  点击后切换到下一条
- `lib/pages/Home/home.dart:497-552`
  长按后弹出全部列表并允许替换

真正的文字切换动画在：

- `lib/components/home.dart:250-295`

这里用的是 `ValueListenableBuilder + AnimatedSwitcher`，所以首页页面本身不需要为一行文字切换做整页 `setState()`。

## 今日提醒的真实数据流

这是首页最重要的一段逻辑。

### 第一步：等待会话恢复完成

`lib/pages/Home/home.dart:214-231` 的 `_refreshRemindersIfReady()` 会先判断：

- `UserController.sessionReady` 是否已完成
- 当前用户和上一次请求用户是否变化
- 是否需要强制刷新

这一步的意义是避免：

- 应用刚启动时在会话没恢复好就乱发请求
- 上一个用户的请求结果覆盖当前用户页面

### 第二步：真正请求 `today-reminders`

`lib/pages/Home/home.dart:358-437` 的 `_fetchTodayReminders()` 是主入口。

它会先做这些保护：

- `_loadingReminders` 防止并发重复加载
- `_refreshQueued` 记录是否有排队的刷新
- `_reminderRequestId` 保证旧请求结果不会覆盖新请求

### 第三步：远端成功后覆盖当天快照

请求成功后，当前不是直接把返回值塞给 UI，而是先写入本地：

- `lib/pages/Home/home.dart:378-382`
- `lib/stores/today_reminder_local_store.dart:81-127`

也就是：

- 按 `userId + dateKey` 删除当天旧快照
- 再按顺序插入远端完整结果

这是为了解决“旧本地计划表把远端当天结果盖掉”的问题。

### 第四步：叠加本地打卡和 override

写完快照后，页面会再去读：

- `loadTodayOverrides()`
- `loadTodaySnapshotItems()`

对应位置：

- `lib/pages/Home/home.dart:384-395`
- `lib/stores/today_reminder_local_store.dart:130-159`
- `lib/stores/today_reminder_local_store.dart:255-315`

这里真正起作用的规则是：

1. 先有当天快照
2. 再加载今天本地 override
3. 再加载今天本地 doneSet
4. 最后通过 `resolveDoneState()` 统一算出最终 `done`

`resolveDoneState()` 在：

- `lib/stores/today_reminder_local_store.dart:389-404`

优先级是：

1. `checkin_overrides`
2. `checkins`
3. 远端 `serverDone`

### 第五步：再映射成首页 UI

最后页面才会把 `ReminderItem` 转成首页卡片真正使用的 `HomeReminderItemData`：

- `lib/pages/Home/home.dart:452-470`

这样做的好处是：

- API 字段变化不会直接污染组件层
- 顶部“下一次提醒”文案可以统一在页面层处理

## 请求失败时怎么回退

当前失败回退策略也已经统一了，不再去猜今天应该显示什么。

失败时：

1. 仍然尝试从 `today_reminder_snapshots` 读取当天快照
2. 再叠加 `checkins` 和 `checkin_overrides`
3. 如果当天快照也没有，才退到 `_fallbackReminders`

对应代码在：

- `lib/pages/Home/home.dart:403-428`

这比直接去读 `reminders` 表更稳，因为 `reminders` 只代表计划，不代表“今天服务端真正给出的当天结果”。

## 快捷入口是怎么跳转的

快捷入口点击统一收口在：

- `lib/pages/Home/home.dart:291-356`

当前主要处理这些入口：

- 手动搜索
- 药物识别
- 用药提醒
- 用药打卡
- 安全辅助

而且有些跳转回来后会主动刷新今日提醒，保证首页状态尽量跟打卡页、提醒页同步。

## 一条最短的读码路径

如果你以后只想最快看懂首页真正怎么工作，推荐顺序：

1. `lib/pages/Home/home.dart:191-231`
2. `lib/pages/Home/home.dart:256-284`
3. `lib/pages/Home/home.dart:291-356`
4. `lib/pages/Home/home.dart:358-437`
5. `lib/pages/Home/home.dart:474-552`
6. `lib/components/home.dart:152-295`
7. `lib/stores/today_reminder_local_store.dart:81-127`
8. `lib/stores/today_reminder_local_store.dart:255-315`
9. `lib/stores/today_reminder_local_store.dart:389-404`

## 关键代码位置

- `lib/pages/Home/home.dart:191-204`
  首页初始化，绑定用户变化和会话恢复状态。
- `lib/pages/Home/home.dart:214-231`
  判断当前是否适合刷新提醒。
- `lib/pages/Home/home.dart:256-284`
  首页整体结构。
- `lib/pages/Home/home.dart:291-356`
  快捷入口点击分发。
- `lib/pages/Home/home.dart:358-437`
  今日提醒主数据流。
- `lib/pages/Home/home.dart:378-382`
  远端成功后覆盖当天快照。
- `lib/pages/Home/home.dart:387-395`
  从快照叠加本地状态并转换 UI。
- `lib/pages/Home/home.dart:474-495`
  点击切换健康小贴士。
- `lib/pages/Home/home.dart:497-552`
  长按展示全部小贴士。
- `lib/components/home.dart:152-334`
  顶部首页卡片。
- `lib/components/home.dart:250-295`
  小贴士 `AnimatedSwitcher` 动画。
- `lib/api/home_api.dart:13-34`
  今日提醒接口封装。
- `lib/stores/today_reminder_local_store.dart:81-127`
  用远端完整结果覆盖当天快照。
- `lib/stores/today_reminder_local_store.dart:130-159`
  读取今日 override。
- `lib/stores/today_reminder_local_store.dart:255-315`
  从快照和本地状态构建最终提醒。
- `lib/stores/today_reminder_local_store.dart:389-404`
  `done` 状态优先级判定。
- `lib/stores/app_database.dart:174-197`
  `today_reminder_snapshots` 表结构。

## 容易忽略的实现细节

- 小贴士当前值不是每次 build 随机，而是冷启动时先确定一条，再在当前会话内通过点击切换。
- 顶部小贴士的动画并不是页面整体动画，而是组件内部那一小块文字做 `AnimatedSwitcher`。
- 首页提醒请求有 `requestId` 保护，用户切换登录态时旧请求结果不会再覆盖新界面。
- 当前成功路径和失败回退都统一走“当天快照”口径，不再用 `reminders` 表来猜首页该显示什么。

## 如果以后要改，优先改哪里

### 想改顶部卡片、小贴士文字动画或样式

先看：

1. `lib/components/home.dart`
2. `lib/components/soft_banner.dart`

### 想改小贴士切换规则

先看：

1. `lib/pages/Home/home.dart:474-552`

### 想改今日提醒字段或接口契约

先看：

1. `lib/api/home_api.dart`
2. `lib/viewmodels/home.dart`
3. `lib/stores/today_reminder_local_store.dart`

### 想改首页提醒的真相来源

先看：

1. `lib/pages/Home/home.dart`
2. `lib/stores/today_reminder_local_store.dart`
3. `lib/stores/app_database.dart`

## 初学时最容易卡住的点

- 误以为首页直接把接口返回值显示出来。实际上中间还经过了本地快照和本地完成状态叠加。
- 误以为 `reminders` 表就是首页当天真相。现在已经不是。
- 误以为小贴士的动画写在页面层。实际上在 `components/home.dart`。

## 相关测试在哪

- `test/home_top_section_test.dart:39-64`
  覆盖小贴士点击和长按入口。
- `test/home_top_section_test.dart:66-90`
  覆盖小贴士文本更新。
- `test/home_today_reminders_test.dart:37-90`
  覆盖“远端成功后覆盖旧快照并渲染新提醒”。
- `test/home_today_reminders_test.dart:92-154`
  覆盖失败回退和当天快照读取逻辑。
