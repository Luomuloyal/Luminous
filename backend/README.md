# Luminous App Backend

App 后端服务，提供认证与药品能力接口。

## Stack

- Node.js + TypeScript
- Express
- JWT (Access Token + Refresh Token)
- MongoDB (用户数据)
- MySQL (药品库)
- OpenAI SDK（用于豆包/方舟兼容调用）

## Directory Layout

```text
backend/
  src/
    ai/
    config/
    db/
    handlers/
    http/
    models/
    routes/
    app.ts
    server.ts
```

更详细的源码分层见 [src/README.md](src/README.md)。

## Requirements

- Node.js 18+
- 可访问 MongoDB
- 可访问 MySQL

## Getting Started

### Install

```bash
npm install
```

### Configure Environment

Create `backend/.env`:

```env
PORT=8787
CORS_ORIGIN=*

MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=medicine_db
MYSQL_TABLE=国产本位码

MONGODB_URI=mongodb://127.0.0.1:27017/luminous

JWT_SECRET=replace_with_strong_secret
JWT_REFRESH_SECRET=replace_with_another_strong_secret

DOUBAO_API_KEY=your_doubao_api_key
DOUBAO_BASE_URL=https://ark.cn-beijing.volces.com/api/v3
DOUBAO_VISION_ENDPOINT_ID=ep-vision-xxx
DOUBAO_TEXT_ENDPOINT_ID=ep-text-xxx
```

Model selection priority:

- Vision: `DOUBAO_VISION_ENDPOINT_ID` > `DOUBAO_VISION_MODEL_ID`
- Text: `DOUBAO_TEXT_ENDPOINT_ID` > `DOUBAO_TEXT_MODEL_ID`

### Run in Development

```bash
npm run dev
```

### Build and Run in Production

```bash
npm run build
npm run start
```

## API Summary

- `GET /health`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/medicines/search`
- `POST /api/medicines/detail`
- `POST /api/medicines/ai-detail`
- `POST /api/medicines/ai-safety`
- `POST /api/medicines/scan`

Full schema and examples: [../lib/docs/backend-api.md](../lib/docs/backend-api.md)

## Response Envelope

```json
{
  "code": "1",
  "msg": "",
  "result": {}
}
```

## Integration Notes

- Flutter base URL config: `lib/constants/constants.dart`
- Flutter network parser: `lib/utils/DioRequest.dart`

请确保 Flutter 的 `GlobalConstants.BASE_URL` 指向本服务地址。

## Troubleshooting

### MySQL connection failed

检查 `.env` 中 `MYSQL_*` 与网络白名单。

### MongoDB connection failed

检查 `MONGODB_URI` 可达性与账号权限。

### AI endpoints failed

检查以下配置与网络：

- `DOUBAO_API_KEY`
- 文本/视觉模型 ID
- `DOUBAO_BASE_URL`

## Related Docs

- Project README: [../README.md](../README.md)
- Backend Mapping Docs: [../BackendMd/README.md](../BackendMd/README.md)
- Deployment Config: [../lib/docs/deployment-config.md](../lib/docs/deployment-config.md)
