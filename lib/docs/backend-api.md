# Luminous App Backend API

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

## 2. Authentication

### 2.1 Token Policy

- Access Token: 1 天
- Refresh Token: 14 天
- 刷新方式: 使用 refresh 接口换发一对新 token（滑动续期）

### 2.2 Auth Header

Protected endpoints should include:

```http
Authorization: Bearer <access_token>
```

当前公开业务路由暂未强制鉴权，但后端中间件已可用。

## 3. Auth Endpoints

### 3.1 Register

- `POST /api/auth/register`

Request body:

```json
{
  "username": "test_user",
  "password": "your_password"
}
```

Success `result`:

```json
{
  "accessToken": "...",
  "refreshToken": "...",
  "user": {
    "id": "...",
    "username": "test_user"
  }
}
```

Failure examples:

- `msg: "缺少用户名或密码"`
- `msg: "用户名已存在"`

### 3.2 Login

- `POST /api/auth/login`

Request body:

```json
{
  "username": "test_user",
  "password": "your_password"
}
```

Success `result` 与注册一致。

Failure examples:

- `msg: "缺少用户名或密码"`
- `msg: "用户不存在"`
- `msg: "密码错误"`

### 3.3 Refresh Token

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

- `msg: "缺少 Refresh Token"`
- `msg: "Refresh Token 无效或已过期"`

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

Failure examples:

- `msg: "drugCode 或 approvalNo 不能为空"`
- `msg: "未找到该药品信息"`

### 4.3 AI Detail

- `POST /api/medicines/ai-detail`

Request body:

```json
{
  "drugCode": "86900000000000"
}
```

Success `result`:

```json
{
  "text": "AI 解读文本..."
}
```

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
  "text": "AI 安全分析文本..."
}
```

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

## 5. Error and Status Conventions

- 业务失败: 常见为 HTTP 200 + `code != "1"`
- 未认证: HTTP 401
- 非法 JSON: HTTP 400
- 路由不存在: HTTP 404
- 未捕获异常: HTTP 500

## 6. Current Route List

- `GET /health`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/medicines/search`
- `POST /api/medicines/detail`
- `POST /api/medicines/ai-detail`
- `POST /api/medicines/ai-safety`
- `POST /api/medicines/scan`

## 7. Flutter Constant Compatibility Note

Flutter 端仍保留部分历史路径常量（如 `send-code`、`my-*`、`reminders/*`、`scan-record-create`）。

联调时请以本文件第 6 节为准。
