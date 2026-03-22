# 09 我的页、资料卡与用户状态

## 这个功能是干什么的

负责“我的”页面入口组织、登录态展示、资料卡交互以及退出登录。

## 用户从哪里进入 / 如何触发

- 底部 Tab 第四个就是“我的”
- 未登录时点击资料卡或操作按钮会跳登录页
- 已登录时点击退出会走确认弹窗

## 关键页面、组件、API、store、backend、native 文件

- 页面：`lib/pages/Mine/mine.dart`
- UI 组件：`lib/components/mine.dart`
- 数据模型：`lib/viewmodels/mine.dart`
- 用户态：`lib/stores/user_controller.dart`

## 核心实现路径

### UI 入口

- `MinePage` 负责整体布局
- `MineProfileCard` 通过 `Obx` 订阅当前用户

### 状态来源

- 登录状态来自 `UserController.isLoggedIn`
- 展示文案来自 `UserSafe.displayTitle` / `displaySubtitle`

### 网络 / 本地存储 / 后端流转

- 我的页本身没有单独请求接口
- 退出登录时会清本地用户信息、token 和通知

### 结果如何回到 UI

- `UserController.user` 变化后，资料卡自动更新为已登录或未登录样式

## 关键代码位置

- `lib/pages/Mine/mine.dart:64`
  点击资料卡的行为。
- `lib/pages/Mine/mine.dart:75`
  点击右侧动作按钮，已登录时走退出流程。
- `lib/pages/Mine/mine.dart:114`
  快捷入口分发。
- `lib/pages/Mine/mine.dart:130`
  用 `Obx` 订阅用户态并渲染资料卡。
- `lib/stores/user_controller.dart:23`
  是否已登录的判断。
- `lib/stores/user_controller.dart:60`
  设置当前用户。
- `lib/stores/user_controller.dart:72`
  退出登录清理本地状态。
- `lib/viewmodels/auth.dart:191`
  用户展示标题 / 副标题生成逻辑。

## 容易忽略的实现细节

- 我的页不是自己持有用户对象，而是完全依赖 `UserController`
- 退出登录时会取消本地通知，避免旧提醒残留

## 如果以后要改，优先改哪里

- 改“我的”页入口组织：`lib/pages/Mine/mine.dart`
- 改资料卡展示：`lib/components/mine.dart`
- 改退出登录副作用：`lib/stores/user_controller.dart`

## 相关测试在哪

- 当前没有专门覆盖“我的”页面登录态联动和退出流程的测试
