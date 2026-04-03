# Luminous App Backend

App 后端服务，提供认证与药品能力接口。

## Stack

- Node.js + TypeScript
- Express
- JWT (Access Token + Refresh Token)
- MongoDB (用户数据)
- Redis（验证码存储，5 分钟过期）
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
- 可访问 Redis
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
REDIS_URL=redis://127.0.0.1:6379

AUTH_CODE_TTL_SECONDS=300
AUTH_CODE_DELIVERY_MODE=log
AUTH_CODE_SMS_WEBHOOK_URL=
AUTH_CODE_EMAIL_HOST=smtp.qq.com
AUTH_CODE_EMAIL_PORT=465
AUTH_CODE_EMAIL_SECURE=true
AUTH_CODE_EMAIL_USER=
AUTH_CODE_EMAIL_PASS=
AUTH_CODE_EMAIL_FROM=

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

## Docker

### Build Backend Image

在项目根目录执行：

```bash
docker build -f backend/Dockerfile -t luminous-backend:local backend
```

### Run Backend Container Only

```bash
docker run --rm -p 8787:8787 --env-file backend/.env.development luminous-backend:local
```

### Run Full Stack With Compose

```bash
docker compose up -d --build
```

`docker-compose.yml` 会同时启动 backend、mongodb、redis、mysql。

## API Summary

- `GET /health`
- `POST /api/auth/codes`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/user/profile`
- `POST /api/user/profile-update`
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

### Redis connection failed

检查 `REDIS_URL` 可达性与白名单配置。

### AI endpoints failed

检查以下配置与网络：

- `DOUBAO_API_KEY`
- 文本/视觉模型 ID
- `DOUBAO_BASE_URL`

### Port 8787 occupied (EADDRINUSE)

若 `npm run dev` 报端口占用，通常是旧的 Node 进程仍在监听（例如之前开过 `tsx watch src/server.ts`）。

PowerShell 排查：

```powershell
Get-NetTCPConnection -LocalPort 8787 -State Listen | Select-Object OwningProcess
Get-CimInstance Win32_Process -Filter "ProcessId = <PID>" | Select-Object Name,CommandLine
```

结束占用进程：

```powershell
Stop-Process -Id <PID> -Force
```

## Related Docs

- Project README: [../README.md](../README.md)
- Deployment Config: [../lib/docs/deployment-config.md](../lib/docs/deployment-config.md)
