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

你以后如果只是盯着登录按钮本身，很容易只看到表单，不会看到整条状态链。

## 这个功能是干什么的

这一部分负责：

- 登录
- 注册
- 发送验证码
- SVG 验证码校验
- 用户态持久化
- 登录后的本地数据同步

## 建议你第一次怎么读

推荐按下面顺序看：

1. `lib/pages/Login/login.dart`
2. `lib/api/auth_api.dart`
3. `lib/stores/user_controller.dart`
4. `lib/stores/session_sync_service.dart`
5. `lib/pages/Register/register.dart`
6. `test/login_page_test.dart`

这样你会先搞懂登录主链，再回头看注册和测试，会更容易。

## 用户从哪里进入 / 如何触发

- 命名路由 `/login`
- 登录页右上角“注册”按钮
- 未登录状态下从提醒、打卡、我的页等入口触发登录跳转
- 验证码登录失败且服务端返回 `NOT_REGISTERED` 时，会从登录页弹窗继续跳注册页

## 关键页面、组件、API、store、backend、native 文件

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

登录页不是单一表单，而是由几块状态一起组成：

- 当前账号类型：手机号 / 邮箱
- 当前登录方式：密码 / 验证码
- 输入框控制器：账号、密码、验证码
- 验证码会话：`_codeId`、`_codeTarget`
- 提交态：`_sendingCode`、`_submitting`

这些状态都在页面本地维护，因为它们属于“只影响当前页面”的临时 UI 状态。

对应代码主要在：

- `lib/pages/Login/login.dart:135-187`
- `lib/pages/Login/login.dart:189-286`
- `lib/pages/Login/login.dart:401-607`

## 注册页的真实结构

注册页比登录页多了一层 SVG 验证码和协议勾选，因此它的本地状态更多一些：

- 账号类型：手机号 / 邮箱
- 业务验证码会话：`_codeId`、`_codeTarget`
- SVG 验证码会话：`_svgCodeId`、`_svgContent`
- 协议勾选状态：`_agreed`
- 提交态：`_sendingCode`、`_loadingSvg`、`_submitting`

对应代码主要在：

- `lib/pages/Register/register.dart:167-219`
- `lib/pages/Register/register.dart:221-260`
- `lib/pages/Register/register.dart:262-333`
- `lib/pages/Register/register.dart:420-635`

## 核心实现路径

### UI 入口

登录页：

- `lib/pages/Login/login.dart:354-399`
  顶部栏和注册入口
- `lib/pages/Login/login.dart:401-577`
  表单主体
- `lib/pages/Login/login.dart:580-605`
  登录按钮

注册页：

- `lib/pages/Register/register.dart:384-418`
  顶部栏
- `lib/pages/Register/register.dart:420-607`
  表单主体
- `lib/pages/Register/register.dart:609-634`
  注册按钮

### 网络层是怎么承接的

`lib/api/auth_api.dart` 把认证相关请求统一封装掉了，页面只负责调用，不自己拼请求体。

最关键的几个接口入口是：

- `lib/api/auth_api.dart:12-20`
  获取 SVG 验证码
- `lib/api/auth_api.dart:23-52`
  发送邮箱/手机验证码
- `lib/api/auth_api.dart:95-134`
  密码登录 / 验证码登录
- `lib/api/auth_api.dart:136-167`
  注册

这里的设计好处是：以后如果接口路径、字段名或者加载提示文案要改，优先只改 API 层，不要到页面里找一堆 `dio.post`。

### 登录成功后的状态流

这是认证功能最值得记住的一段链路。

`lib/pages/Login/login.dart:189-286` 的 `_onLoginPressed()` 里，真正顺序是：

1. 校验表单
2. 如果是验证码登录，确认 `_codeId` 和当前账号匹配
3. 调 `AuthApi.loginWithPassword()` 或 `AuthApi.loginWithCode()`
4. 从响应里取出 `loginResult`
5. `lib/pages/Login/login.dart:225-230`
   写 token 到 `tokenManager`
6. `lib/pages/Login/login.dart:232`
   写用户到 `UserController`
7. `lib/pages/Login/login.dart:233-235`
   触发 `sessionSyncService.syncForUser(...)`
8. 显示 toast
9. 延迟 500ms 后 `Navigator.maybePop(context)`

这意味着登录成功并不是“接口返回就结束”，后面还有本地状态写入和同步动作。

### 注册成功后的状态流

注册页当前策略比登录轻一些。

`lib/pages/Register/register.dart:262-333` 的 `_onRegisterPressed()` 顺序是：

1. 校验表单
2. 校验业务验证码会话是否存在
3. 校验 SVG 验证码是否存在
4. 校验是否勾选协议
5. 调 `registerWithPhone()` 或 `registerWithEmail()`
6. 成功后 toast 提示
7. 延迟 600ms 返回上页

注意这里当前不会自动帮用户登录，返回后仍然要重新走登录流程。

## “账号未注册自动跳注册页”是怎么做的

这是认证功能里一个很容易忘掉但用户体验很重要的点。

当验证码登录遇到服务端返回 `NOT_REGISTERED` 时：

- `lib/pages/Login/login.dart:256-271`
  会先弹出 `_showAutoRegisterDialog()`
- 用户确认后，直接 `MaterialPageRoute` 跳到 `RegisterView`
- 同时把账号类型、账号内容、验证码、`codeId` 一起预填过去

这样用户不用再重新输入一次账号和验证码。

## 协议和隐私政策入口在哪里

当前登录页和注册页都已经有明确入口：

- 登录页在 `lib/pages/Login/login.dart:346-349`
- 注册页在 `lib/pages/Register/register.dart:373-375`

对应的命名路由在：

- `lib/routes/routes.dart:52-53`

所以以后你想改协议文案、页面样式或路由名称，应该把认证页和 `Legal` 页面一起看。

## 用户态和 token 分别存到哪里

这是最容易学混的一点。

### 用户信息

用户信息由 `UserController` 统一持有和持久化：

- `lib/stores/user_controller.dart:17`
  响应式用户对象
- `lib/stores/user_controller.dart:38-68`
  启动时恢复用户
- `lib/stores/user_controller.dart:73-80`
  登录后保存用户
- `lib/stores/user_controller.dart:85-91`
  退出登录时清理用户

### token

token 不和用户对象混在一起，而是单独走 `tokenManager`。

当前登录页在 `lib/pages/Login/login.dart:225-230` 里直接决定：

- token 非空就写入
- token 为空就删除

这让“用户展示信息”和“认证凭证”分开管理，结构更清楚。

## 登录后同步为什么属于认证链路的一部分

因为在这个项目里，登录不只是让“我的”页显示用户名，还会影响：

- 我的药品
- 提醒计划
- 相册记录

`lib/stores/session_sync_service.dart:29-71` 负责这件事。

它的同步顺序是：

1. 我的药品
2. 用药提醒
3. 相册

而且它会在每一步之间用 `_shouldApplySync()` 判断当前用户有没有切换掉，避免串用户。

## 一条最短的读码路径

如果你以后想快速重温认证主链，最短路径是：

1. `lib/pages/Login/login.dart:135-187`
2. `lib/pages/Login/login.dart:189-286`
3. `lib/api/auth_api.dart:95-167`
4. `lib/stores/user_controller.dart:38-91`
5. `lib/stores/session_sync_service.dart:29-98`
6. `lib/pages/Register/register.dart:262-333`

## 关键代码位置

- `lib/pages/Login/login.dart:135-187`
  发送登录验证码。
- `lib/pages/Login/login.dart:189-286`
  登录主提交流程。
- `lib/pages/Login/login.dart:225-235`
  写 token、写用户、触发同步。
- `lib/pages/Login/login.dart:289-309`
  “未注册，是否去注册”弹窗。
- `lib/pages/Login/login.dart:261-270`
  携带预填信息跳转注册页。
- `lib/pages/Register/register.dart:167-219`
  发送注册验证码。
- `lib/pages/Register/register.dart:221-260`
  获取 SVG 验证码。
- `lib/pages/Register/register.dart:262-333`
  注册主提交流程。
- `lib/api/auth_api.dart:12-20`
  SVG 验证码请求。
- `lib/api/auth_api.dart:23-52`
  手机 / 邮箱验证码请求。
- `lib/api/auth_api.dart:95-134`
  登录请求。
- `lib/api/auth_api.dart:136-167`
  注册请求。
- `lib/stores/user_controller.dart:38-68`
  恢复本地用户态。
- `lib/stores/user_controller.dart:73-91`
  设置用户和退出登录。
- `lib/stores/session_sync_service.dart:29-71`
  登录后同步远端数据。
- `test/login_page_test.dart:31-155`
  登录、注册关键校验测试。

## 容易忽略的实现细节

- 验证码登录不是“输入验证码就能登”，还会校验 `_codeId` 是否对应当前账号，避免切换账号后误用旧验证码。
- 注册页要求两层校验：业务验证码 + SVG 验证码。
- 注册页还要求先勾选协议，否则即使表单都填了也不能提交。
- 登录成功后同步失败不会直接算登录失败，而是以“登录成功，但部分云端数据同步失败”的 toast 呈现。

## 如果以后要改，优先改哪里

### 想改登录方式

先看：

1. `lib/pages/Login/login.dart`
2. `lib/api/auth_api.dart`
3. `lib/viewmodels/auth.dart`

### 想改注册校验

先看：

1. `lib/pages/Register/register.dart`
2. `lib/components/auth.dart`

### 想改 token 和用户持久化方式

先看：

1. `lib/pages/Login/login.dart`
2. `lib/stores/token_manager.dart`
3. `lib/stores/user_controller.dart`

### 想改登录后自动同步策略

先看：

1. `lib/stores/session_sync_service.dart`
2. 相关本地 store

## 初学时最容易卡住的点

- 误以为 token 在 `UserController` 里保存。实际上不是。
- 误以为注册成功后自动登录。当前并没有。
- 误以为登录页只管登录本身。实际上它还承担“未注册跳注册”和“登录后同步”的职责。

## 相关测试在哪

- `test/login_page_test.dart:31-39`
  空表单登录校验
- `test/login_page_test.dart:41-55`
  手机号格式校验
- `test/login_page_test.dart:57-90`
  未注册自动跳注册页并预填
- `test/login_page_test.dart:92-121`
  注册缺少 SVG 验证码拦截
- `test/login_page_test.dart:124-155`
  注册缺少业务验证码会话拦截
