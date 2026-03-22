# 03 认证功能

## 这个功能是干什么的

负责登录、注册、验证码发送、用户态持久化，以及登录后的云端数据同步。

## 用户从哪里进入 / 如何触发

- `/login` 进入登录页
- 登录页右上角进入注册页
- 未登录状态下从“提醒 / 打卡 / 我的”入口也会跳到登录页

## 关键页面、组件、API、store、backend、native 文件

- 登录页：`lib/pages/Login/login.dart`
- 注册页：`lib/pages/Register/register.dart`
- 认证 API：`lib/api/auth_api.dart`
- 认证模型：`lib/viewmodels/auth.dart`
- 用户态：`lib/stores/user_controller.dart`
- 登录后同步：`lib/stores/session_sync_service.dart`
- UI 组件：`lib/components/auth.dart`

## 核心实现路径

### UI 入口

- 登录页支持手机号/邮箱切换，也支持密码登录 / 验证码登录
- 注册页支持手机号/邮箱注册，并要求业务验证码 + SVG 验证码

### 状态来源

- 表单输入由页面本地 `TextEditingController` 管理
- 登录后的用户对象由 `UserController.user` 统一持有

### 网络 / 本地存储 / 后端流转

- 登录页通过 `AuthApi.loginWithPassword()` 或 `AuthApi.loginWithCode()` 请求服务端
- 注册页通过 `AuthApi.registerWithPhone()` / `registerWithEmail()` 提交
- 登录成功后 token 进入 `tokenManager`，用户进入 `UserController`
- 接着触发 `SessionSyncService.syncForUser()` 同步提醒、药品和相册

### 结果如何回到 UI

- 登录成功后页面 `maybePop()` 返回上层
- 全局依赖 `UserController.user` 的页面会自动感知登录态变化

## 关键代码位置

- `lib/pages/Login/login.dart:127`
  发送登录验证码。
- `lib/pages/Login/login.dart:181`
  登录主提交流程。
- `lib/pages/Login/login.dart:224`
  登录成功后写用户态并触发会话同步。
- `lib/pages/Register/register.dart:163`
  发送注册验证码。
- `lib/pages/Register/register.dart:217`
  获取 SVG 验证码。
- `lib/pages/Register/register.dart:258`
  注册主提交流程。
- `lib/api/auth_api.dart:11`
  SVG 验证码接口。
- `lib/api/auth_api.dart:23`
  邮箱/手机验证码接口。
- `lib/api/auth_api.dart:95`
  登录接口。
- `lib/api/auth_api.dart:136`
  注册接口。
- `lib/stores/user_controller.dart:60`
  登录后写本地持久化。
- `lib/stores/user_controller.dart:72`
  退出登录。
- `lib/stores/session_sync_service.dart:29`
  登录后同步入口。

## 容易忽略的实现细节

- 验证码登录会校验 `_codeId` 是否匹配当前账号，防止切号后误用旧验证码
- 登录页遇到 `NOT_REGISTERED` 会直接弹窗跳注册页，并把账号和验证码预填过去
- 用户信息只持久化安全字段，token 单独放在 `tokenManager`

## 如果以后要改，优先改哪里

- 改登录方式：`lib/pages/Login/login.dart` + `lib/api/auth_api.dart`
- 改注册校验：`lib/pages/Register/register.dart`
- 改登录态持久化：`lib/stores/user_controller.dart`
- 改登录后同步：`lib/stores/session_sync_service.dart`

## 相关测试在哪

- `test/login_page_test.dart:31`
  登录校验、未注册跳转注册、注册缺少验证码拦截等
