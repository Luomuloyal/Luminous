# Luminous App Backend API 文档

## 1. 服务信息

- 服务根地址: 由部署环境决定，例如 `http://127.0.0.1:8787`
- 健康检查: `GET /health`
- 接口风格: RESTful + JSON
- 统一响应结构:

```json
{
  "code": "1",
  "msg": "",
  "result": {}
}
```

说明:
- `code = "1"` 表示业务成功。
- 其他 `code` 表示业务失败，`msg` 为错误信息。
- 大部分业务处理器会返回 HTTP 200，再通过 `code` 表示成功或失败；中间件/框架级错误会使用 4xx/5xx。

## 2. 认证机制

### 2.1 Token 约定

- Access Token: 有效期 1 天
- Refresh Token: 有效期 14 天
- 刷新策略: 通过 refresh 接口换发一对新 token（滑动续期）

### 2.2 请求头

受保护接口需带:

```http
Authorization: Bearer <access_token>
```

当前公开路由中暂未启用受保护业务接口，但中间件已可用。

## 3. Auth 接口

### 3.1 注册

- `POST /api/auth/register`

请求体:

```json
{
  "username": "test_user",
  "password": "your_password"
}
```

成功 `result`:

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

失败示例:
- `msg: "缺少用户名或密码"`
- `msg: "用户名已存在"`

### 3.2 登录

- `POST /api/auth/login`

请求体:

```json
{
  "username": "test_user",
  "password": "your_password"
}
```

成功 `result` 与注册一致。

失败示例:
- `msg: "缺少用户名或密码"`
- `msg: "用户不存在"`
- `msg: "密码错误"`

### 3.3 刷新 Token

- `POST /api/auth/refresh`

请求体:

```json
{
  "refreshToken": "..."
}
```

成功 `result`:

```json
{
  "accessToken": "...",
  "refreshToken": "..."
}
```

失败示例:
- `msg: "缺少 Refresh Token"`
- `msg: "Refresh Token 无效或已过期"`

## 4. Medicine 接口

### 4.1 药品搜索

- `POST /api/medicines/search`

请求体:

```json
{
  "keyword": "阿莫西林",
  "page": 1,
  "pageSize": 20
}
```

字段说明:
- `keyword`: 必填，关键字
- `page`: 可选，默认 1，最小 1
- `pageSize`: 可选，默认 20，范围 1-50

成功 `result`:

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

失败示例:
- `msg: "keyword 不能为空"`

### 4.2 药品详情

- `POST /api/medicines/detail`

请求体（二选一，至少提供一个）:

```json
{
  "drugCode": "86900000000000"
}
```

或

```json
{
  "approvalNo": "国药准字..."
}
```

成功 `result`: 单个药品对象（字段同搜索 `items` 元素）。

失败示例:
- `msg: "drugCode 或 approvalNo 不能为空"`
- `msg: "未找到该药品信息"`

### 4.3 AI 药品解读

- `POST /api/medicines/ai-detail`

请求体（同详情接口）:

```json
{
  "drugCode": "86900000000000"
}
```

成功 `result`:

```json
{
  "text": "AI 解读文本..."
}
```

失败示例:
- `msg: "drugCode 或 approvalNo 不能为空"`
- `msg: "未找到该药品信息"`
- `msg: "AI 解读生成失败，请稍后重试"`

### 4.4 AI 安全辅助

- `POST /api/medicines/ai-safety`

请求体:

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

字段说明:
- `mode`: `single` 或 `pair`
- `medicines`: `single` 必须 1 个，`pair` 必须 2 个

成功 `result`:

```json
{
  "text": "AI 安全分析文本..."
}
```

失败示例:
- `msg: "mode 必须是 single 或 pair"`
- `msg: "single 模式 medicines 必须为 1 个"`
- `msg: "pair 模式 medicines 必须为 2 个"`
- `msg: "AI 安全分析失败，请稍后重试"`

### 4.5 拍照识别

- `POST /api/medicines/scan`

请求体:

```json
{
  "imageBase64": "<base64或dataUrl>",
  "mimeType": "image/jpeg"
}
```

成功 `result`:

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

说明:
- `imageBase64` 支持纯 base64 或 Data URL，服务端会自动剥离 `base64,` 前缀。
- 目前服务端固定返回 `thumbBase64: ""`，缩略图由 Flutter 本地兜底。

失败示例:
- `msg: "imageBase64 不能为空"`
- `msg: "药品识别失败，请稍后重试"`

## 5. 错误与状态码约定

- 业务参数/业务失败: 多数为 HTTP 200 + `code != "1"`
- 中间件未认证: HTTP 401
- JSON 非法: HTTP 400
- 路由不存在: HTTP 404
- 未捕获异常: HTTP 500

## 6. 当前路由总览

- `GET /health`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/medicines/search`
- `POST /api/medicines/detail`
- `POST /api/medicines/ai-detail`
- `POST /api/medicines/ai-safety`
- `POST /api/medicines/scan`

## 7. 与 Flutter 端常量的注意事项

Flutter 里还保留了部分旧常量路径（如 `send-code`、`my-*`、`reminders/*`、`scan-record-create`），当前后端并未实现这些接口。联调时请以本文件第 6 节路由为准。
