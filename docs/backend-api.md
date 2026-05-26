# Luminous Legacy Express Backend API

> This document describes the deprecated Express backend under `Luminous/backend`.
> It is kept as a reference for the currently deployed `https://devluo.com` service and data migration work.
> The target Lucent backend defines versioned `/api/v1` APIs in `Lucent/docs/api-contract.md` and does not need to keep this request body shape or envelope.

## 1. Service Info

- Base URL: 由部署环境决定，例如 `http://127.0.0.1:8787`
- Health Check: `GET /health`
- API Style: RESTful + JSON

Unified response envelope:

```json
{
  "code": "1",
  "msg": "",
  "result": {}
}
```

Notes:

- `code = "1"` 表示业务成功。
- `code != "1"` 表示业务失败，`msg` 提供错误信息。
- 业务失败常见为 HTTP 200 + `code != "1"`；框架或中间件错误可能返回 4xx/5xx。
- Lucent 不沿用该 legacy envelope；新协议默认使用 `{ code, message, data }`，分页等场景才增加 `meta`。
- 新药品长文本和 AI/copilot 输出默认面向 Markdown 渲染，事实字段仍以结构化 JSON 为准。

## 2. Authentication

### 2.1 Token Policy

- Access Token: 1 天
- Refresh Token: 14 天
- 刷新方式: 使用 refresh 接口换发一对新 token（滑动续期）

### 2.2 Verification Code Policy

- 验证码存储: Redis
- Redis key: `auth:code:{target}`
- value: `{ channel, target, scene, code, createdAt }`
- TTL: 默认 300 秒（5 分钟）
- 发送频率限制: 同一 target 60 秒内最多发送 1 次
- 校验口径: 仅校验 `手机号/邮箱 + 验证码 + 场景(scene)`

### 2.3 Auth Header

Protected endpoints should include:

```http
Authorization: Bearer <access_token>
```

当前公开业务路由暂未强制鉴权，但后端中间件已可用。

## 3. Auth Endpoints

### 3.1 Send Verification Code

- `POST /api/auth/codes`

Request body:

```json
{
  "channel": "phone",
  "scene": "login",
  "target": "13800138000"
}
```

字段说明:

- `channel`: `email | phone`
- `scene`: `register | login`
- `target`: 邮箱或手机号

Success `result`:

```json
{
  "id": "13800138000",
  "target": "13800138000",
  "expiresInSeconds": 300
}
```

Failure examples:

- `code: "INVALID_CHANNEL"`, `msg: "channel 无效"`
- `code: "INVALID_SCENE"`, `msg: "scene 无效"`
- `code: "INVALID_TARGET"`, `msg: "邮箱地址格式错误"`
- `code: "INVALID_TARGET"`, `msg: "手机号格式不正确"`
- `code: "CODE_SEND_TOO_FREQUENT"`, `msg: "发送过于频繁，请 xx 秒后重试"`
- `code: "CODE_SEND_FAILED"`, `msg: "验证码发送失败，请稍后重试"`

### 3.2 Register

- `POST /api/auth/register`

Request body:

```json
{
  "identifierType": "phone",
  "phone": "13800138000",
  "username": "luminous_user",
  "email": "",
  "code": "123456",
  "password": "abc123"
}
```

字段说明:

- `identifierType`: `email | phone`
- `phone/email`: 按 `identifierType` 传入
- `username`: 可选，自定义用户名（2-30 字符，不能含空格）
- `code`: 验证码
- `password`: 6-12 位字母或数字

Success `result`:

```json
{
  "id": "...",
  "accessToken": "...",
  "refreshToken": "...",
  "user": {
    "id": "...",
    "username": "13800138000",
    "email": "",
    "phone": "13800138000",
    "name": "13***00",
    "type": 3
  }
}
```

Failure examples:

- `code: "INVALID_IDENTIFIER_TYPE"`, `msg: "identifierType 无效"`
- `code: "INVALID_IDENTIFIER"`, `msg: "手机号不能为空"`
- `code: "PASSWORD_INVALID"`, `msg: "密码需为6-12位字母或数字"`
- `code: "USERNAME_INVALID"`, `msg: "用户名长度需为2-30个字符"`
- `code: "USERNAME_EXISTS"`, `msg: "用户名已被占用"`
- `code: "CODE_INVALID"`, `msg: "验证码错误"`
- `code: "CODE_EXPIRED"`, `msg: "验证码已过期，请重新获取"`
- `code: "IDENTIFIER_EXISTS"`, `msg: "手机号已经注册"`

### 3.3 Login

- `POST /api/auth/login`

Request body:

```json
{
  "identifierType": "phone",
  "loginMode": "code",
  "identifier": "13800138000",
  "password": "",
  "code": "123456"
}
```

字段说明:

- `identifierType`: `email | phone`
- `loginMode`: `password | code`
- `identifier`: 手机号或邮箱
- `password`: `password` 模式必填
- `code`: `code` 模式必填

Success `result` 与注册一致。

Failure examples:

- `code: "INVALID_LOGIN_MODE"`, `msg: "loginMode 无效"`
- `code: "LOGIN_FAILED"`, `msg: "账号或密码错误"`
- `code: "CODE_INVALID"`, `msg: "验证码错误"`
- `code: "CODE_EXPIRED"`, `msg: "验证码已过期，请重新获取"`
- `code: "NOT_REGISTERED"`, `msg: "该账号尚未注册，是否前往注册？"`

### 3.4 Refresh Token

- `POST /api/auth/refresh`

Request body:

```json
{
  "refreshToken": "..."
}
```

Success `result`:

```json
{
  "accessToken": "...",
  "refreshToken": "..."
}
```

Failure examples:

- `code: "MISSING_REFRESH_TOKEN"`, `msg: "缺少 Refresh Token"`
- `code: "REFRESH_TOKEN_INVALID"`, `msg: "Refresh Token 无效或已过期"`

## 4. Medicine Endpoints

### 4.1 Search Medicines

- `POST /api/medicines/search`

Request body:

```json
{
  "keyword": "阿莫西林",
  "page": 1,
  "pageSize": 20
}
```

Field notes:

- `keyword`: 必填
- `page`: 可选，默认 1，最小 1
- `pageSize`: 可选，默认 20，范围 1-50

Success `result`:

```json
{
  "items": [
    {
      "serialNo": "1",
      "approvalNo": "国药准字...",
      "productName": "...",
      "dosageForm": "...",
      "specification": "...",
      "marketingAuthorizationHolder": "...",
      "manufacturer": "...",
      "drugCode": "...",
      "drugCodeRemark": "..."
    }
  ],
  "total": 120,
  "page": 1,
  "pageSize": 20
}
```

Failure examples:

- `msg: "keyword 不能为空"`

### 4.2 Medicine Detail

- `POST /api/medicines/detail`

Request body（二选一，至少一个）:

```json
{
  "drugCode": "86900000000000"
}
```

or

```json
{
  "approvalNo": "国药准字..."
}
```

Success `result`: 单个药品对象（字段同搜索结果条目）。

Planned enriched `result` after knowledge-platform migration:

```json
{
  "id": "medicine-product-id",
  "productName": "药品名称",
  "approvalNo": "国药准字...",
  "manufacturer": "生产厂家",
  "packageSpec": "包装规格",
  "barcode": "条形码",
  "nationalDrugCode": "药品本位码",
  "sections": [
    {
      "key": "dosage",
      "title": "用法用量",
      "content": "结构化原文..."
    }
  ],
  "detailMarkdown": "## 用法用量\n\n结构化原文..."
}
```

Compatibility notes:

- 旧字段在迁移窗口内继续保留。
- `sections` 是事实来源，`detailMarkdown` 是展示层产物。
- Markdown 不应包含未转义 HTML。

Failure examples:

- `msg: "drugCode 或 approvalNo 不能为空"`
- `msg: "未找到该药品信息"`

### 4.3 AI Detail

- `POST /api/medicines/ai-detail`

Status:

- Compatibility endpoint. The long-term direction is to retire generic AI-generated medicine detail.
- Medicine facts should come from database-backed `detail` sections and `detailMarkdown`.
- Future AI output should move to grounded copilot explanation endpoints.

Request body:

```json
{
  "drugCode": "86900000000000"
}
```

Success `result`:

```json
{
  "text": "AI 解读文本...",
  "markdown": "## 通俗解释\n\n..."
}
```

Planned response rule:

- `markdown` becomes the preferred display field.
- AI must explain based on selected medicine sections and include disclaimer/source context.

Failure examples:

- `msg: "drugCode 或 approvalNo 不能为空"`
- `msg: "未找到该药品信息"`
- `msg: "AI 解读生成失败，请稍后重试"`

### 4.4 AI Safety

- `POST /api/medicines/ai-safety`

Request body:

```json
{
  "mode": "pair",
  "medicines": [
    {
      "drugCode": "86900000000001",
      "approvalNo": "国药准字A",
      "productName": "药品A"
    },
    {
      "drugCode": "86900000000002",
      "approvalNo": "国药准字B",
      "productName": "药品B"
    }
  ]
}
```

Field notes:

- `mode`: `single` 或 `pair`
- `medicines`: `single` 必须 1 个，`pair` 必须 2 个

Success `result`:

```json
{
  "text": "AI 安全分析文本...",
  "markdown": "## 安全提示\n\n..."
}
```

Planned response rule:

- `markdown` becomes the preferred display field.
- Safety review should combine deterministic database checks, user context, and AI explanation. AI must not invent contraindications or diagnose.

Failure examples:

- `msg: "mode 必须是 single 或 pair"`
- `msg: "single 模式 medicines 必须为 1 个"`
- `msg: "pair 模式 medicines 必须为 2 个"`
- `msg: "AI 安全分析失败，请稍后重试"`

### 4.5 Scan Medicine

- `POST /api/medicines/scan`

Request body:

```json
{
  "imageBase64": "<base64-or-data-url>",
  "mimeType": "image/jpeg"
}
```

Success `result`:

```json
{
  "candidates": [
    {
      "serialNo": "1",
      "approvalNo": "国药准字...",
      "productName": "...",
      "dosageForm": "...",
      "specification": "...",
      "marketingAuthorizationHolder": "...",
      "manufacturer": "...",
      "drugCode": "...",
      "drugCodeRemark": "...",
      "score": 0.98
    }
  ],
  "thumbBase64": ""
}
```

Notes:

- `imageBase64` 支持纯 base64 或 Data URL。
- 当前后端固定返回 `thumbBase64: ""`，缩略图由 Flutter 本地兜底。

Failure examples:

- `msg: "imageBase64 不能为空"`
- `msg: "药品识别失败，请稍后重试"`

### 4.6 My Medicines

- `POST /api/medicines/my-upsert`
- `POST /api/medicines/my-delete`
- `POST /api/medicines/my-list`

`my-upsert` request body:

```json
{
  "userId": "u_123",
  "identityKey": "user:u_123|drugCode:86900000000000",
  "productName": "阿莫西林胶囊",
  "drugCode": "86900000000000",
  "approvalNo": "国药准字...",
  "dosageForm": "胶囊剂",
  "specification": "0.25g",
  "manufacturer": "某药业",
  "source": "search"
}
```

`my-upsert` success `result`:

```json
{
  "id": "...",
  "userId": "u_123",
  "identityKey": "user:u_123|drugCode:86900000000000",
  "drugCode": "86900000000000",
  "approvalNo": "国药准字...",
  "productName": "阿莫西林胶囊",
  "dosageForm": "胶囊剂",
  "specification": "0.25g",
  "manufacturer": "某药业",
  "source": "search",
  "createdAt": 1710000000000
}
```

`my-delete` request body:

```json
{
  "userId": "u_123",
  "id": "..."
}
```

or

```json
{
  "userId": "u_123",
  "identityKey": "user:u_123|drugCode:86900000000000"
}
```

`my-delete` success `result`: `true | false`

`my-list` request body:

```json
{
  "userId": "u_123"
}
```

`my-list` success `result`:

```json
{
  "items": [
    {
      "id": "...",
      "userId": "u_123",
      "identityKey": "user:u_123|drugCode:86900000000000",
      "drugCode": "86900000000000",
      "approvalNo": "国药准字...",
      "productName": "阿莫西林胶囊",
      "dosageForm": "胶囊剂",
      "specification": "0.25g",
      "manufacturer": "某药业",
      "source": "search",
      "createdAt": 1710000000000
    }
  ]
}
```

### 4.7 Reminder Plans

- `POST /api/reminders/upsert`
- `POST /api/reminders/delete`
- `POST /api/reminders/list`
- `POST /api/reminders/today`

`upsert` request body:

```json
{
  "userId": "u_123",
  "time": "08:30",
  "productName": "维生素D",
  "subtitle": "早餐后服用 1 粒",
  "enabled": true,
  "repeatRule": "daily",
  "method": "notification"
}
```

`upsert` success `result`:

```json
{
  "id": "...",
  "userId": "u_123",
  "time": "08:30",
  "drugCode": "",
  "approvalNo": "",
  "productName": "维生素D",
  "subtitle": "早餐后服用 1 粒",
  "enabled": true,
  "repeatRule": "daily",
  "method": "notification"
}
```

`delete` request body:

```json
{
  "userId": "u_123",
  "id": "..."
}
```

`delete` success `result`: `true | false`

`list` request body:

```json
{
  "userId": "u_123"
}
```

`list` success `result`:

```json
{
  "items": [
    {
      "id": "...",
      "userId": "u_123",
      "time": "08:30",
      "drugCode": "",
      "approvalNo": "",
      "productName": "维生素D",
      "subtitle": "早餐后服用 1 粒",
      "enabled": true,
      "repeatRule": "daily",
      "method": "notification"
    }
  ]
}
```

`today` request body:

```json
{
  "date": "2026-03-29",
  "userId": "u_123"
}
```

`today` success `result`:

```json
{
  "date": "2026-03-29",
  "items": [
    {
      "id": "...",
      "time": "08:30",
      "title": "维生素D",
      "subtitle": "早餐后服用 1 粒",
      "done": false
    }
  ]
}
```

### 4.8 Scan Records

- `POST /api/medicines/scan-record-create`
- `POST /api/medicines/scan-record-list`

`scan-record-create` request body:

```json
{
  "userId": "u_123",
  "thumbBase64": "...",
  "drugCode": "86900000000000",
  "approvalNo": "国药准字...",
  "productName": "阿莫西林胶囊",
  "takenAt": 1710000000000
}
```

`scan-record-create` success `result`:

```json
{
  "id": "..."
}
```

`scan-record-list` request body:

```json
{
  "userId": "u_123",
  "page": 1,
  "pageSize": 20
}
```

`scan-record-list` success `result`:

```json
{
  "items": [
    {
      "id": "...",
      "thumbBase64": "...",
      "drugCode": "86900000000000",
      "approvalNo": "国药准字...",
      "productName": "阿莫西林胶囊",
      "takenAt": 1710000000000
    }
  ],
  "total": 1,
  "page": 1,
  "pageSize": 20
}
```

## 5. Error and Status Conventions

- 业务失败: 常见为 HTTP 200 + `code != "1"`
- 未认证: HTTP 401
- 非法 JSON: HTTP 400
- 路由不存在: HTTP 404
- 未捕获异常: HTTP 500

## 6. Current Route List

- `GET /health`
- `POST /api/auth/codes`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/medicines/search`
- `POST /api/medicines/detail`
- `POST /api/medicines/ai-detail`
- `POST /api/medicines/ai-safety`
- `POST /api/medicines/scan`
- `POST /api/medicines/my-upsert`
- `POST /api/medicines/my-delete`
- `POST /api/medicines/my-list`
- `POST /api/reminders/upsert`
- `POST /api/reminders/delete`
- `POST /api/reminders/list`
- `POST /api/reminders/today`
- `POST /api/medicines/scan-record-create`
- `POST /api/medicines/scan-record-list`

## 7. Flutter Constant Compatibility Note

Flutter 验证码路径统一为 `/api/auth/codes`。
