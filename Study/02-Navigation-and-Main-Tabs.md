# 02 导航与主 Tab

## 这一篇先帮你澄清一件事

当前项目已经不再走大范围自定义页面切换动画，而是尽量回到了 Flutter 自带的原生过渡。

所以如果你以后感觉“返回动画不自然”或者“切页有滞留感”，不要先去找复杂的动画组件，先确认是不是某个页面还在手动包 `MaterialPageRoute` 或者做了额外延迟。

## 这个部分负责什么

这一部分主要负责两类事情：

1. 全局路由注册
2. 四个一级页面的底部 Tab 组织方式

它不负责具体业务数据，也不负责页面内容本身。

## 建议你第一次怎么读

推荐顺序：

1. `lib/routes/routes.dart`
2. `lib/pages/Main/main.dart`
3. 再按四个 Tab 去看具体页面

先看路由，再看主容器，这样你能知道“页面是怎么被装起来的”，而不是只看到单个页面文件。

## 当前导航结构的真实样子

### 根路由层

`lib/routes/routes.dart:20-31` 使用的是标准 `MaterialApp`，不是 `GetMaterialApp`。

这里说明两件事：

- 项目虽然用了 GetX，但导航不是全量交给 GetX
- 绝大部分命名路由仍然走 Flutter 原生路由系统

### 命名路由表

`lib/routes/routes.dart:38-54` 里当前注册了这些主要入口：

- `/`
- `/login`
- `/register`
- `/search`
- `/scan`
- `/reminders`
- `/checkin`
- `/safety`
- `/settings`
- `/user-agreement`
- `/privacy-policy`

### 主 Tab 容器

`/` 对应的不是某个具体业务页，而是 `MainPage`。

`MainPage` 再负责这四个一级页：

- 主页
- 药品
- 相册
- 我的

## 为什么主 Tab 不是简单地一次性创建四个页面

当前实现用了两个策略一起配合：

1. `IndexedStack` 保活已经挂载过的页面
2. `_loadedIndexes` 只在首次点击后再真正挂载其他 Tab

对应代码在：

- `lib/pages/Main/main.dart:35-60`
- `lib/pages/Main/main.dart:66-74`
- `lib/pages/Main/main.dart:124-131`

这套设计的目的很实际：

- 冷启动时只先初始化首页，减轻初始压力
- 后续切换到其他 Tab 时，再做首次挂载
- 挂载完成后用 `IndexedStack` 保留状态，避免每次切回来都重新 `initState()`

所以它既不是“全量预加载”，也不是“每切一次都重建”。

## 核心实现路径

### UI 入口

- `lib/routes/routes.dart:20-31`
  根 `MaterialApp`
- `lib/routes/routes.dart:38-54`
  命名路由表
- `lib/pages/Main/main.dart:108-158`
  一级页面容器和底部导航栏

### 当前页面状态来自哪里

- 当前激活 Tab 只由 `lib/pages/Main/main.dart:101` 的 `_currentIndex` 决定
- 已经挂载过哪些页面由 `lib/pages/Main/main.dart:74` 的 `_loadedIndexes` 决定
- 业务状态不放在主 Tab 容器里，而是放在具体页面或 store 中

### 页面切换是怎么发生的

一级 Tab 切换：

- 通过 `BottomNavigationBar.onTap`
- 在 `lib/pages/Main/main.dart:139-144` 里更新 `_loadedIndexes` 和 `_currentIndex`
- `IndexedStack` 只切显示目标 child，不销毁其他已加载 child

二级页面跳转：

- 常规页面多数走 `Navigator.pushNamed`
- 部分需要直接传构造参数的页面走 `MaterialPageRoute`

## 当前“页面过渡动画”应该怎么理解

这里要特别说明一下，避免以后再被旧印象带偏。

### 命名路由

当前 `routes.dart` 没有统一包一层自定义 `PageRouteBuilder`，所以命名路由会走 Flutter 默认的 Material 过渡。

### 直接 `MaterialPageRoute`

像登录页跳转注册页，当前是在 `lib/pages/Login/login.dart:378-383` 和 `lib/pages/Login/login.dart:261-270` 里直接用 `MaterialPageRoute`。

这样做的原因通常是：

- 需要直接传构造参数
- 页面之间是局部流程跳转，不一定非得走命名路由

### 返回时为什么有时会觉得“不一样”

如果以后你又感觉某个返回动画特别别扭，优先排查：

1. 这个页面是不是还在用旧的自定义转场组件
2. 这个页面的 `Navigator` 调用前后有没有额外 `Future.delayed`
3. 这个页面是不是在返回前做了大量同步工作，导致视觉上像“停了一下”

## 一条最短的读码路径

如果你只是想快速看明白页面组织方式，最短路径是：

1. `lib/routes/routes.dart:20-31`
2. `lib/routes/routes.dart:38-54`
3. `lib/pages/Main/main.dart:35-60`
4. `lib/pages/Main/main.dart:66-74`
5. `lib/pages/Main/main.dart:108-158`

看完这几段以后，再进入某个具体页面会轻松很多。

## 关键代码位置

- `lib/routes/routes.dart:20-31`
  根 `MaterialApp`，包括主题模式和命名路由接入。
- `lib/routes/routes.dart:38-54`
  全局路由注册表。
- `lib/pages/Main/main.dart:35-60`
  底部四个 Tab 的图标、文案和主色。
- `lib/pages/Main/main.dart:66-71`
  四个一级页面实例。
- `lib/pages/Main/main.dart:74`
  已加载 Tab 的集合。
- `lib/pages/Main/main.dart:108-158`
  `IndexedStack + BottomNavigationBar` 主结构。
- `lib/pages/Main/main.dart:139-144`
  点击 Tab 后的状态更新。

## 容易忽略的实现细节

- 虽然页面被 `IndexedStack` 保活，但项目并没有在应用启动时一次性把四个一级页全挂上去，而是用了“按需挂载”策略。
- Tab 图标资源直接来自 `lib/assets/`，如果你以后换底部栏图标，首先应该回到 `lib/pages/Main/main.dart:35-60`。
- 当前项目同时存在 `Navigator.pushNamed` 和 `MaterialPageRoute` 两种写法，这是正常的，不代表结构混乱，只是用途不同。

## 如果以后要改，优先改哪里

### 想新增一个一级 Tab

先改：

1. `lib/pages/Main/main.dart:35-60`
2. `lib/pages/Main/main.dart:66-71`
3. 目标页面本身

你要保证 `_tablist.length` 和 `_pages.length` 始终对应。

### 想新增一个二级页面并走命名路由

先改：

1. `lib/routes/routes.dart:38-54`
2. 发起跳转的页面

### 想统一导航风格

先确认你想统一的是哪一层：

- 一级 Tab 切换：改 `MainPage`
- 二级页面跳转：优先清理页面里的 `MaterialPageRoute` 使用方式
- 全局主题或 app 级路由行为：改 `routes.dart`

## 初学时最容易卡住的点

- 把 `MainPage` 当成业务页去读。实际上它只是容器。
- 以为切换 Tab 会重新走页面初始化。实际上已经挂载过的页面会被保活。
- 看到有些页面用 `pushNamed`，有些页面用 `MaterialPageRoute`，就误以为项目同时存在两套路由系统。实际上依旧是同一个 Navigator，只是入栈方式不同。

## 相关测试在哪

当前没有专门覆盖以下内容的自动化测试：

- 命名路由表完整性
- Tab 保活行为
- 底部栏图标与索引是否一致

如果你以后要补测试，最值得先补的是：

1. `MainPage` 的切 tab 保活测试
2. 登录页到注册页的跳转测试
3. 设置页、协议页等命名路由的 smoke test
