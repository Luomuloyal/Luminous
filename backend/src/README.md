# backend/src 说明

`backend/src` 是当前 Express App 后端服务源码目录。目标后端会迁移到 NestJS + PostgreSQL + Prisma + Redis + Passport；迁移完成前，本目录仍是当前运行时基线。

## 分层约定

- `ai/`: AI 服务调用与 prompt 构造
- `config/`: 环境变量读取与配置解析
- `db/`: MySQL / MongoDB / Redis 数据访问层
- `handlers/`: 业务处理核心（接口逻辑主体）
- `http/`: 统一响应、参数读取、错误处理、JWT 中间件
- `models/`: Mongoose 数据模型
- `routes/`: 路由注册

目标 Nest 模块会增加：

- `knowledge/`: xlsx/DrugBank 导入状态、source metadata、知识映射
- `safety/`: 药品相互作用、特殊人群风险和 AI 辅助安全解释
- `copilot/`: grounded explanation、报告解读、健康计划和分享摘要
- `reports/`: 报告上传、OCR、结构化指标和解释入口

## 启动链路

1. `server.ts`: 启动入口，先连接 Mongo + Redis，再启动 HTTP 服务
2. `app.ts`: 组装 Express 中间件与路由
3. `routes/api.ts`: 注册 `/api/*` 接口
4. `handlers/*`: 执行业务逻辑

## 开发建议

1. 新增接口时，优先在 `handlers/` 实现业务，再在 `routes/api.ts` 暴露路由。
2. 所有返回建议统一用 `http/response.ts` 的 `success/fail`。
3. 参数解析统一使用 `http/body.ts`，避免各处重复校验。
4. 涉及鉴权的路由，使用 `http/jwt.ts` 的 `authMiddleware`。

## 相关文档

- 后端服务说明: [../README.md](../README.md)
- API 文档: [../../docs/lib-docs/backend-api.md](../../docs/lib-docs/backend-api.md)
- 后端迁移计划: [../../docs/backend-nestjs-pgsql-migration-plan.md](../../docs/backend-nestjs-pgsql-migration-plan.md)
- 知识库数据平台计划: [../../docs/knowledge-data-platform-plan.md](../../docs/knowledge-data-platform-plan.md)

## 运行补充

- 单服务调试可在 `backend/` 目录执行 `npm run dev`。
- 本地整套服务（含数据库）建议在仓库根目录执行 `docker compose up -d --build`。
