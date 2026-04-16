# 03 认证功能

## 这一篇最重要的主线

认证功能不要只把它理解成“两个表单页面”。它真正串起来的是下面这条链：

1. 登录页 / 注册页收集输入
2. `AuthApi` 发请求
3. 响应解析成 `viewmodels/auth.dart` 里的模型
4. 登录成功后把 token 写到 `tokenManager`
5. 再把用户写入 `UserController`
6. 再触发 `SessionSyncService`
7. 最后由全局用户态驱动其他页面自动刷新

## 这个功能现在负责什么

- 登录
- 注册
- 发送邮箱 / 手机验证码
- 用户态持久化
- 登录后的本地数据同步

注册流程已经按“新应用、轻交互”收敛成：

- 业务验证码
- 密码
- 确认密码
- 协议勾选


## 建议你第一次怎么读

推荐按下面顺序看：

1. `lib/pages/Login/login.dart`
2. `lib/api/auth_api.dart`
3. `lib/stores/user_controller.dart`
4. `lib/stores/session_sync_service.dart`
5. `lib/pages/Register/register.dart`
6. `test/login_page_test.dart`

## 用户从哪里进入 / 如何触发

- 命名路由 `/login`
- 登录页右上角“注册”按钮
- 未登录状态下从提醒、打卡、我的页等入口触发登录跳转
- 验证码登录失败且服务端返回 `NOT_REGISTERED` 时，会从登录页弹窗继续跳注册页

## 关键页面、组件、API、store 文件

- 登录页：`lib/pages/Login/login.dart`
- 注册页：`lib/pages/Register/register.dart`
- 认证 API：`lib/api/auth_api.dart`
- 认证模型：`lib/viewmodels/auth.dart`
- 认证 UI 组件：`lib/components/auth.dart`
- 用户态：`lib/stores/user_controller.dart`
- token 存储：`lib/stores/token_manager.dart`
- 登录后同步：`lib/stores/session_sync_service.dart`
- 测试：`test/login_page_test.dart`

## 登录页的真实结构

登录页由几块本地状态组成：

- 当前账号类型：手机号 / 邮箱
- 当前登录方式：密码 / 验证码
- 输入框控制器：账号、密码、验证码
- 验证码会话：`_codeId`、`_codeTarget`
- 提交态：`_sendingCode`、`_submitting`

这些状态都只影响当前页面，所以继续保留在页面本地维护。

## 注册页的真实结构

注册页现在比登录页多的是：

- 账号类型：手机号 / 邮箱
- 业务验证码会话：`_codeId`、`_codeTarget`
- 协议勾选状态：`_agreed`
- 提交态：`_sendingCode`、`_submitting`

注册页状态和交互现在更短、更清晰。

## 核心实现路径

### UI 入口

登录页：

- 顶部栏和注册入口
- 表单主体
- 登录按钮

注册页：

- 顶部栏
- 表单主体
- 注册按钮

### 网络层是怎么承接的

`lib/api/auth_api.dart` 统一封装了：

- `sendEmailCode()`
- `sendPhoneCode()`
- `loginWithPassword()`
- `loginWithCode()`
- `registerWithEmail()`
- `registerWithPhone()`

页面不再自己拼 `channel`、`scene`、`loginMode` 这些协议字段。

### 登录成功后的状态流

登录页 `_onLoginPressed()` 的顺序是：

1. 校验表单
2. 如果是验证码登录，确认 `_codeId` 和当前账号匹配
3. 调 `AuthApi.loginWithPassword()` 或 `AuthApi.loginWithCode()`
4. 从响应里取出 `loginResult`
5. 写 token 到 `tokenManager`
6. 写用户到 `UserController`
7. 触发 `sessionSyncService.syncForUser(...)`
8. 显示 toast
9. 延迟后返回上页

### 注册成功后的状态流

注册页 `_onRegisterPressed()` 的顺序是：

1. 校验表单
2. 校验业务验证码会话是否存在
3. 校验是否勾选协议
4. 调 `registerWithPhone()` 或 `registerWithEmail()`
5. 成功后 toast 提示
6. 延迟后返回上页

注意这里当前不会自动帮用户登录。

## “账号未注册自动跳注册页”是怎么做的

当验证码登录遇到服务端返回 `NOT_REGISTERED` 时：

- 登录页先弹出 `_showAutoRegisterDialog()`
- 用户确认后，直接跳到 `RegisterView`
- 同时把账号类型、账号内容、验证码、`codeId` 一起预填过去

这样用户不用重新输入一次账号和验证码。

## 用户态和 token 分别存到哪里

### 用户信息

用户信息由 `UserController` 统一持有和持久化。

### token

token 单独走 `tokenManager`，不和用户对象混在一起。

## 登录后同步为什么属于认证链路的一部分

因为在这个项目里，登录会影响：

- 我的药品
- 用药提醒

`SessionSyncService` 负责这件事，并会在同步过程中检查当前用户有没有切换掉，避免串用户。

## 一条最短的读码路径

如果你以后想快速重温认证主链，最短路径是：

1. `lib/pages/Login/login.dart`
2. `lib/api/auth_api.dart`
3. `lib/stores/user_controller.dart`
4. `lib/stores/session_sync_service.dart`
5. `lib/pages/Register/register.dart`

## 容易忽略的实现细节

- 验证码登录不是“输入验证码就能登”，还会校验 `_codeId` 是否对应当前账号，避免切换账号后误用旧验证码。
- 注册页现在只校验业务验证码。
- 注册页还要求先勾选协议，否则即使表单都填了也不能提交。
- 登录成功后同步失败不会直接算登录失败，而是以“登录成功，但部分云端数据同步失败”的提示呈现。

## 相关测试在哪

- `test/login_page_test.dart`
  空表单登录校验
- `test/login_page_test.dart`
  手机号格式校验
- `test/login_page_test.dart`
  未注册自动跳注册页并预填
- `test/login_page_test.dart`
  注册提交流程与业务验证码会话校验
