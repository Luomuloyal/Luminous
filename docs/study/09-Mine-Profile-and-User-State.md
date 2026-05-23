# 09 我的页、资料卡与用户状态

## 这一篇最重要的结论

“我的”页在当前项目里更像一个个人中心入口容器，而不是一个强业务页面。

它的核心价值不在“自己请求了什么数据”，而在于：

- 根据登录态切换展示
- 把用户引导到提醒、搜索、设置等入口
- 把用户态、设置页、退出登录和暗黑模式串起来

## 这个功能是干什么的

当前“我的”相关功能主要包含：

- 顶部资料卡
- 三个快捷入口
- 菜单区
- 关于弹窗
- 设置页入口
- 设置页中的暗黑模式和退出登录

所以这一篇不只看 `MineView`，还要把 `SettingsPage` 一起看进去。

## 建议你第一次怎么读

推荐顺序：

1. `lib/pages/Mine/mine.dart`
2. `lib/components/mine.dart`
3. `lib/viewmodels/mine.dart`
4. `lib/pages/Settings/settings.dart`
5. `lib/stores/user_controller.dart`
6. `lib/stores/theme_controller.dart`

这样你会先明白“页面层只做什么”，再理解“展示组件承担了什么”，最后再回到状态层。

## 用户从哪里进入 / 如何触发

- 底部 Tab 第四项就是“我的”
- 未登录时点击资料卡或右侧按钮，会跳登录页
- 已登录时点击资料卡或右侧按钮，会跳设置页
- 设置页里再提供暗黑模式开关和退出登录

## 关键页面、组件、API、store、backend、native 文件

- 页面入口：`lib/pages/Mine/mine.dart`
- 设置页：`lib/pages/Settings/settings.dart`
- Mine UI 组件：`lib/components/mine.dart`
- Mine 展示模型：`lib/viewmodels/mine.dart`
- 用户态：`lib/stores/user_controller.dart`
- 主题模式：`lib/stores/theme_controller.dart`
- 用户展示字段：`lib/viewmodels/auth.dart`

## 页面层和组件层是怎么分工的

这是“我的”页最值得学的一点。

### 页面层 `lib/pages/Mine/mine.dart`

页面层主要负责：

- 判断登录态
- 定义点击行为
- 决定跳到哪个页面
- 通过 `Obx` 把用户态传给展示组件

### 组件层 `lib/components/mine.dart`

组件层主要负责：

- 页面整体背景和装饰
- 资料卡布局
- 快捷入口网格布局
- 菜单卡片布局

也就是说，当前 Mine 的结构是“交互上收、展示下沉”。

这对你以后维护很有帮助：

- 想改跳转逻辑，先看 `mine.dart`
- 想改布局视觉，先看 `components/mine.dart`

## 核心实现路径

### UI 入口

`lib/pages/Mine/mine.dart:106-128` 是整个“我的”页真正的组装入口。

这里做了几件事：

1. 传入顶部横幅配色
2. 用 `Obx` 包住 `MineProfileCard`
3. 传入快捷入口数据 `_quickActions`
4. 注入几个点击回调
5. 提供“关于”弹窗

### 资料卡如何感知登录态

`lib/pages/Mine/mine.dart:109-117` 用 `Obx` 监听 `UserController.user`。

这意味着：

- 登录后不用手动刷新“我的”页
- 退出登录后资料卡会立刻切回未登录样式

真正展示“昵称 / 副标题 / 按钮”的代码在：

- `lib/components/mine.dart:15-133`

其中最关键的是：

- `:42-43`
  判断是否已登录
- `:84-97`
  登录态和未登录态展示不同标题、副标题
- `:112-126`
  右侧按钮在登录和未登录时显示不同文案

### 快捷入口是怎么组织的

快捷入口数据本身定义在：

- `lib/pages/Mine/mine.dart:37-59`

点击分发在：

- `lib/pages/Mine/mine.dart:86-100`

展示卡片结构在：

- `lib/components/mine.dart:225-259`
- `lib/viewmodels/mine.dart:5-30`
- `lib/viewmodels/mine.dart:33-145`

这说明 Mine 的快捷入口不是写死在布局里，而是“数据驱动 + 点击分发”。

### 设置页如何接手后续行为

当前“退出登录”已经不放在 Mine 首页，而是放在设置页。

`lib/pages/Settings/settings.dart` 里现在主要有两项：

- 暗黑模式
- 退出登录

其中：

- `lib/pages/Settings/settings.dart:32-57`
  通过 `Obx` 绑定 `ThemeController.isDarkMode`
- `lib/pages/Settings/settings.dart:64-98`
  根据登录态决定是否允许退出
- `lib/pages/Settings/settings.dart:107-140`
  退出登录确认弹窗和真正的登出动作

## 这一部分的数据从哪里来

“我的”页本身没有独立接口请求，核心数据几乎都来自全局状态。

### 用户数据

来自：

- `lib/stores/user_controller.dart:17-24`

### 暗黑模式状态

来自：

- `lib/stores/theme_controller.dart:11-19`

### 关于页版本号

当前 About 弹窗在：

- `lib/pages/Mine/mine.dart:122-127`

这里会直接显示当前应用版本字符串 `2.32.0+32`。

## 退出登录真正发生了什么

退出登录不只是把“我的”页切成未登录状态。

`lib/stores/user_controller.dart:85-91` 里还会：

1. 清空响应式用户对象
2. 删除本地持久化用户信息
3. 删除 token
4. 取消所有本地通知

所以如果你以后发现“退出后提醒还在弹”或“退出后页面还是旧用户”，就应该先回这里查。

## 暗黑模式是怎么落地的

暗黑模式不是 Mine 页自己持有，而是全局 ThemeController 统一管理。

实现主线是：

1. `lib/pages/Settings/settings.dart:32-57`
   开关触发 `themeController.setDarkMode`
2. `lib/stores/theme_controller.dart:28-35`
   把状态写入 SharedPreferences
3. `lib/routes/routes.dart:22-29`
   根 `MaterialApp` 监听 `themeMode`
4. `lib/routes/routes.dart:57-144`
   定义亮色和暗色主题

所以以后如果你觉得某个页面“暗黑模式没生效”，常见原因不是设置页没写对，而是页面自己写了过多固定颜色。

## 一条最短的读码路径

如果你以后想快速把 Mine 链路重温一遍，最短路径是：

1. `lib/pages/Mine/mine.dart:37-128`
2. `lib/components/mine.dart:15-133`
3. `lib/components/mine.dart:136-223`
4. `lib/viewmodels/mine.dart:5-145`
5. `lib/pages/Settings/settings.dart:16-140`
6. `lib/stores/user_controller.dart:17-91`
7. `lib/stores/theme_controller.dart:11-35`

## 关键代码位置

- `lib/pages/Mine/mine.dart:37-59`
  Mine 页快捷入口数据。
- `lib/pages/Mine/mine.dart:64-80`
  点击资料卡 / 动作按钮后的跳转逻辑。
- `lib/pages/Mine/mine.dart:86-100`
  快捷入口点击分发。
- `lib/pages/Mine/mine.dart:106-128`
  Mine 页整体装配。
- `lib/pages/Mine/mine.dart:122-127`
  关于弹窗与版本号。
- `lib/components/mine.dart:15-133`
  `MineProfileCard` 展示逻辑。
- `lib/components/mine.dart:139-223`
  `MinePage` 布局骨架。
- `lib/viewmodels/mine.dart:5-30`
  快捷入口数据模型。
- `lib/viewmodels/mine.dart:33-145`
  快捷入口单卡片组件。
- `lib/pages/Settings/settings.dart:32-57`
  暗黑模式开关。
- `lib/pages/Settings/settings.dart:64-98`
  退出登录入口启用态。
- `lib/pages/Settings/settings.dart:107-140`
  退出登录确认和执行。
- `lib/stores/user_controller.dart:85-91`
  退出登录副作用。
- `lib/stores/theme_controller.dart:22-35`
  暗黑模式持久化。

## 容易忽略的实现细节

- Mine 页并不直接请求“用户资料”接口，所有展示都依赖本地当前用户态。
- 当前登录后的右侧动作按钮文案已经不是“退出登录”，而是“设置”。
- 退出登录已经迁到设置页，所以以后不要再去 Mine 首页找退出逻辑。
- Mine 的很多视觉细节都在 `components/mine.dart`，不是在 `mine.dart`。

## 如果以后要改，优先改哪里

### 想改“我的”页入口组织

先看：

1. `lib/pages/Mine/mine.dart`
2. `lib/viewmodels/mine.dart`

### 想改资料卡视觉

先看：

1. `lib/components/mine.dart:15-133`

### 想改设置项

先看：

1. `lib/pages/Settings/settings.dart`

### 想改退出登录副作用

先看：

1. `lib/stores/user_controller.dart`
2. `lib/utils/notification_service.dart`

### 想改暗黑模式默认值或持久化方式

先看：

1. `lib/stores/theme_controller.dart`
2. `lib/routes/routes.dart`

## 初学时最容易卡住的点

- 误以为 Mine 是一个“功能重页面”。实际上它更多是入口页。
- 误以为退出登录逻辑在 Mine 页本身。实际上不在。
- 误以为主题切换只影响设置页。实际上是根 `MaterialApp` 级别的切换。

## 相关测试在哪

当前还没有专门覆盖这些内容的测试：

- Mine 页登录态联动
- 设置页暗黑模式切换
- 设置页退出登录流程

如果你以后想补测试，最值得先补的是：

1. `MineProfileCard` 在登录 / 未登录状态下的渲染测试
2. `SettingsPage` 的开关联动测试
3. `UserController.logout()` 的副作用测试
