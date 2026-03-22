# 02 导航与主 Tab

## 这个功能是干什么的

负责全局命名路由、四个一级页面的底部 Tab 切换，以及统一的页面过渡动画。

## 用户从哪里进入 / 如何触发

- 冷启动默认进入 `/`
- 首页、药品页、我的页等通过 `Navigator.pushNamed` 或 `MaterialPageRoute` 跳转

## 关键页面、组件、API、store、backend、native 文件

- 路由表：`lib/routes/routes.dart`
- Tab 容器：`lib/pages/Main/main.dart`
- 一级页面：`lib/pages/Home/home.dart`、`lib/pages/Drug/drug.dart`、`lib/pages/Album/album.dart`、`lib/pages/Mine/mine.dart`

## 核心实现路径

### UI 入口

- 根路由 `/` 对应 `MainPage`
- `MainPage` 用 `IndexedStack` 保活四个一级页面

### 状态来源

- 当前激活 Tab 仅由 `_currentIndex` 控制
- 各业务页自己的状态不放在 Tab 容器里

### 网络 / 本地存储 / 后端流转

- Tab 切换本身不触发统一网络请求
- 各子页面在自己的 `initState()` 或用户变化监听里加载数据

### 结果如何回到 UI

- `BottomNavigationBar.onTap` 改 `_currentIndex`
- `IndexedStack` 切换显示的 child，但保留其他页状态

## 关键代码位置

- `lib/routes/routes.dart:17`
  根 `MaterialApp` 配置。
- `lib/routes/routes.dart:23`
  全局轻量右进左出的页面切换动画。
- `lib/routes/routes.dart:42`
  命名路由注册。
- `lib/pages/Main/main.dart:35`
  底部 Tab 配置。
- `lib/pages/Main/main.dart:65`
  四个一级页面实例。
- `lib/pages/Main/main.dart:108`
  `IndexedStack + BottomNavigationBar` 的主容器结构。

## 容易忽略的实现细节

- 一级页面都被 `IndexedStack` 保活，所以切 Tab 不会重新 `initState()`
- 有些二级页面没有走命名路由，而是直接 `MaterialPageRoute`

## 如果以后要改，优先改哪里

- 想加一级 Tab：先改 `lib/pages/Main/main.dart`
- 想统一切换动画：改 `lib/routes/routes.dart`
- 想加新的命名路由：改 `lib/routes/routes.dart`

## 相关测试在哪

- 当前没有专门覆盖路由表和 Tab 切换保活的测试
