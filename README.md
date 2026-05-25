# Luminous

Luminous 正在从移动端智慧用药助手演进为个人健康管理副驾驶（Personal Health Copilot），当前提供药品识别、药品信息查询、提醒与历史回看能力，下一阶段会以服务端药品知识库、Markdown 长文展示和 AI 健康副驾驶能力作为核心方向。

本仓库为 Flutter App。后端已独立为 [Lucent](https://github.com/LuoMuLoyal/Lucent)（NestJS + PostgreSQL），旧 Express `backend/` 处于退役过渡期。

## Features

- 药品搜索与药品详情
- 拍照识别与候选回查
- 数据库驱动的药品说明书展示
- Markdown 药品详情与 AI 输出展示（规划中）
- AI 安全辅助、报告解读与健康副驾驶（规划中）
- 今日提醒与本地打卡
- 识别相册与结果沉淀
- 多主题与深浅色模式

## Tech Stack

- App: Flutter (Dart)
- Backend (current): Node.js + TypeScript + Express
- Backend (target): NestJS + PostgreSQL + Prisma + Redis + Passport
- Auth: JWT (Access Token + Refresh Token)
- Data (current): MongoDB (用户) + MySQL (药品库) + Redis（部分缓存/验证码）
- Data (target): PostgreSQL（主存储与药品知识库），Redis（验证码、冷却、短期缓存），Prisma（schema/migration/import）
- Knowledge Data (external): `D:\DrugDataBase\FullDrugDetail.xlsx` 与 `D:\DrugDataBase` 只作为本地导入源，不进入 Git
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

迁移期目录约束见 [AGENTS.md](AGENTS.md) 和 [docs/README.md](docs/README.md)。

当前迁移基线与执行记录：

- [docs/RefactorPlan.md](docs/RefactorPlan.md)
- [docs/knowledge-data-platform-plan.md](docs/knowledge-data-platform-plan.md)
- [docs/migration_log.md](docs/migration_log.md)

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

- File: `lib/constants/constants.dart`（兼容 barrel；新代码优先使用拆分后的 core/shared 常量入口）
- Key: `GlobalConstants.BASE_URL`

常见开发取值：

- Android 模拟器: `http://10.0.2.2:8787`
- 真机: `http://<LAN-IP>:8787`

### Backend Environment

- File: `backend/.env`
- Loader: `backend/src/config/env.ts`

当前部署配置仍在整理中；后端迁移方向见 [docs/backend-nestjs-pgsql-migration-plan.md](docs/backend-nestjs-pgsql-migration-plan.md)。

## Documentation

- Backend API: [docs/lib-docs/backend-api.md](docs/lib-docs/backend-api.md)
- Backend Runtime: [backend/README.md](backend/README.md)
- Migration Plan: [docs/RefactorPlan.md](docs/RefactorPlan.md)
- Knowledge Data Platform: [docs/knowledge-data-platform-plan.md](docs/knowledge-data-platform-plan.md)
- Migration Log: [docs/migration_log.md](docs/migration_log.md)

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

本项目基于 [Apache License 2.0](LICENSE) 许可开源。详情请参阅源代码中的 `LICENSE` 文件。
