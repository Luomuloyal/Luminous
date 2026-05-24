# Luminous

Luminous 是一个面向移动端的智慧用药助手，提供药品识别、药品信息查询、AI 辅助解读、提醒与历史回看能力。

本仓库包含 Flutter App 与 App Backend，可独立部署与联调。

## Features

- 药品搜索与药品详情
- 拍照识别与候选回查
- AI 解读与安全辅助
- 今日提醒与本地打卡
- 识别相册与结果沉淀
- 多主题与深浅色模式

## Tech Stack

- App: Flutter (Dart)
- Backend (current): Node.js + TypeScript + Express
- Backend (target): NestJS + PostgreSQL
- Auth: JWT (Access Token + Refresh Token)
- Data (current): MongoDB (用户) + MySQL (药品库) + Redis（部分缓存/验证码）
- Data (target): PostgreSQL（主存储），Redis（按需保留用于缓存/验证码）
- AI: LangChain / OpenAI-compatible gateway

## Repository Structure

```text
Luminous/
  lib/                Flutter 主代码
  test/               Flutter 测试
  backend/            App 后端服务
  docs/               架构计划、迁移记录与长文档
  android/ios/...     平台工程
```

更多目录说明见 [lib/README.md](lib/README.md)。

当前迁移基线与执行记录：

- [docs/RefactorPlan.md](docs/RefactorPlan.md)
- [docs/MIGRATION_LOG.md](docs/MIGRATION_LOG.md)

## Quick Start

### Run Flutter App

```bash
flutter pub get
flutter run
```

```bash
flutter analyze
flutter test
```

### Run Backend

```bash
cd backend
npm install
npm run dev
```

Health Check:

- `GET http://127.0.0.1:8787/health`

### Run With Docker Compose

在项目根目录执行：

```bash
docker compose up -d --build
```

默认会启动以下服务：

- `backend`（当前 Express 服务，8787）
- `mongodb`（当前用户数据，27017）
- `redis`（当前缓存/验证码，6379）
- `mysql`（当前药品库，3306）

停止服务：

```bash
docker compose down
```

## Configuration

### Flutter Base URL

- File: `lib/constants/constants.dart`
- Key: `GlobalConstants.BASE_URL`

常见开发取值：

- Android 模拟器: `http://10.0.2.2:8787`
- 真机: `http://<LAN-IP>:8787`

### Backend Environment

- File: `backend/.env`
- Loader: `backend/src/config/env.ts`

完整部署配置见 [docs/lib-docs/deployment-config.md](docs/lib-docs/deployment-config.md)。

## Documentation

- Backend API: [docs/lib-docs/backend-api.md](docs/lib-docs/backend-api.md)
- Deployment Guide: [docs/lib-docs/deployment-config.md](docs/lib-docs/deployment-config.md)
- Backend Runtime: [backend/README.md](backend/README.md)
- Migration Plan: [docs/RefactorPlan.md](docs/RefactorPlan.md)
- Migration Log: [docs/MIGRATION_LOG.md](docs/MIGRATION_LOG.md)

## Troubleshooting

### Backend port 8787 already in use

如果本地执行 `npm run dev` 报 `EADDRINUSE: 8787`，通常是另一个 Node 进程还在运行（常见于此前的 `tsx watch` 终端未关闭）。

PowerShell 排查命令：

```powershell
Get-NetTCPConnection -LocalPort 8787 -State Listen | Select-Object OwningProcess
Get-CimInstance Win32_Process -Filter "ProcessId = <PID>" | Select-Object Name,CommandLine
```

确认后可结束占用进程：

```powershell
Stop-Process -Id <PID> -Force
```

## Contributing

欢迎提交 Issue 与 Pull Request。

建议流程：

1. Fork 并创建功能分支。
2. 提交前执行 `flutter analyze`、`flutter test` 与后端构建检查。
3. 在 PR 中附上修改说明与验证方式。

## License

当前仓库未附带开源许可证文件。

若计划公开发布，建议新增 `LICENSE`（例如 MIT/Apache-2.0）。
