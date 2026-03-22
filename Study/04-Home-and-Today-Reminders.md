# 04 首页与今日提醒

## 这个功能是干什么的

首页负责把健康小贴士、顶部色块、快捷入口和“今日提醒”汇总到同一屏。

## 用户从哪里进入 / 如何触发

- 冷启动默认第一页就是首页 Tab
- 下拉刷新会重新拉取今日提醒
- 点击快捷入口进入搜索、识别、提醒、打卡、安全辅助等功能

## 关键页面、组件、API、store、backend、native 文件

- 页面：`lib/pages/Home/home.dart`
- API：`lib/api/home_api.dart`
- 模型：`lib/viewmodels/home.dart`
- 本地今日提醒存储：`lib/stores/today_reminder_local_store.dart`
- 用户态：`lib/stores/user_controller.dart`
- 顶部 UI：`lib/components/home.dart`
- 顶部配色：`lib/components/soft_banner.dart`

## 核心实现路径

### UI 入口

- `HomeView` 初始化时立即加载今日提醒
- 顶部色块展示启动期随机选中的小贴士
- “健康小贴士”支持点按切换、长按显示全部列表

### 状态来源

- 小贴士来自本地 `_localHealthTips`
- 今日提醒来自 `HomeApi.fetchTodayReminders()` 和 `todayReminderLocalStore`

### 网络 / 本地存储 / 后端流转

- 首页请求 `today-reminders`
- 同时读取 `checkin_overrides` 和本地 reminders/checkins
- 当前实现里本地提醒非空时会优先渲染本地结果

### 结果如何回到 UI

- `_reminders` 改变后，顶部“下一次提醒”和下方提醒列表同步刷新
- 返回提醒页和打卡页后，首页会再次触发 `_fetchTodayReminders()`

## 关键代码位置

- `lib/pages/Home/home.dart:170`
  首页初始化时绑定用户变化并拉取提醒。
- `lib/pages/Home/home.dart:244`
  快捷入口点击分发。
- `lib/pages/Home/home.dart:311`
  今日提醒主数据流。
- `lib/pages/Home/home.dart:433`
  点按切换健康小贴士。
- `lib/pages/Home/home.dart:457`
  长按展示全部小贴士列表。
- `lib/api/home_api.dart:13`
  今日提醒接口封装。
- `lib/stores/today_reminder_local_store.dart:22`
  读取今日 override。
- `lib/stores/today_reminder_local_store.dart:100`
  从本地 reminders/checkins 组合出首页可用提醒。

## 容易忽略的实现细节

- 小贴士随机值在文件级初始化时确定，整个冷启动会保持同一条
- 首页对提醒请求做了 requestId 防抖，避免旧请求覆盖新用户结果
- 当前提醒渲染口径受本地缓存影响较大，这也是本轮 review 的重点风险之一

## 如果以后要改，优先改哪里

- 改顶部卡片和小贴士逻辑：`lib/pages/Home/home.dart`
- 改今日提醒接口字段：`lib/api/home_api.dart` 和 `lib/viewmodels/home.dart`
- 改本地提醒组合口径：`lib/stores/today_reminder_local_store.dart`

## 相关测试在哪

- `test/home_top_section_test.dart:39`
  覆盖小贴士点击和文字切换动画
- 当前没有覆盖首页“今日提醒数据源优先级”的测试
