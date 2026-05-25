# Backend NestJS + PostgreSQL + Prisma Migration Plan

Last updated: 2026-05-25

## 1. 迁移目标

后端从当前 Express + TypeScript 服务迁移到 NestJS，并把 PostgreSQL 作为唯一主业务数据库。同时，后端要承接新的药品知识平台：`D:\DrugDataBase\FullDrugDetail.xlsx` 作为中文药品详情主来源，`D:\DrugDataBase` / DrugBank 作为科学知识和关联增强来源。

目标状态：

- 框架：NestJS。
- 主数据库：PostgreSQL。
- ORM / migration / import：Prisma。
- 鉴权：Passport + JWT strategy。
- 缓存与短期状态：Redis 仅保留验证码、发送冷却、热点搜索/详情缓存、AI 文本缓存等短生命周期能力。
- 退役对象：MongoDB 和 MySQL 只作为迁移来源，不作为长期运行依赖。
- Flutter 兼容：迁移期间保持现有 `/api/*` 路径、请求体和响应 envelope。
- 数据集边界：大体量 xlsx、DrugBank XML/CSV/FASTA/SDF 只作为外部导入源，不进入 Git，也不打包到 Flutter。

非目标：

- 不在框架迁移时重写 Flutter 页面交互。
- 不在同一批次切换 AI 供应商。
- 不把鉴权边界收紧、数据模型重做、部署切换混在一个不可回滚的大改里。
- 不让 AI 继续生成可由数据库直接提供的药品事实。

知识平台细节见 `docs/knowledge-data-platform-plan.md`。本文只记录后端迁移约束。

## 2. 当前后端基线

当前源码入口：

- `backend/src/server.ts`：启动 Express，并连接 MongoDB、Redis、MySQL。
- `backend/src/app.ts`：注册 CORS、JSON body、`/health` 和 API 路由。
- `backend/src/routes/api.ts`：集中注册 `/api/*` 路由。
- `backend/src/handlers/*`：业务 handler。
- `backend/src/models/*`：MongoDB/Mongoose 模型。
- `backend/src/db/medicine-repository.ts`：MySQL 药品库查询。
- `backend/src/ai/*`：LangChain AI 网关、prompt、AI 文本缓存。

现有存储职责：

| 数据 | 当前存储 | 迁移目标 |
| --- | --- | --- |
| 用户、登录资料、个人资料 | MongoDB `User` | PostgreSQL `users` |
| 我的药品 | MongoDB `MyMedicine` | PostgreSQL `my_medicines` |
| 用药提醒 | MongoDB `Reminder` | PostgreSQL `reminders` + `reminder_medicines` |
| 扫描记录 | MongoDB `ScanRecord` | PostgreSQL `scan_records` |
| 药品基础库 | MySQL `国产本位码` 表 | PostgreSQL `medicine_catalog` |
| 新中文药品详情库 | 外部 xlsx | PostgreSQL `medicine_products` + instruction/identifier/search tables |
| DrugBank 科学知识 | 外部 XML/CSV/FASTA/SDF | PostgreSQL `drugbank_*` + `medicine_drugbank_links` |
| 验证码、发送冷却 | Redis | Redis |
| AI 文本缓存 | Redis | Redis，审计/重要输出摘要落 PostgreSQL |

必须保持的兼容规则：

- `GET /health` 和现有 `/api/*` 路由路径不变。
- 响应 envelope 保持 `{ code, msg, result }`。
- `code = "1"` 仍表示业务成功。
- JWT access token 和 refresh token 的语义先不变。
- Flutter 现阶段仍按字符串处理 `id`，PostgreSQL 迁移不能把公开 `id` 变成破坏性格式。

## 3. 推荐技术路线

推荐先并行落 Nest 运行时，再切换主入口：

```text
backend/
  src/                 # 当前 Express，迁移窗口内继续可运行
  src-nest/            # 临时 Nest 迁移实现，完成切换后并回 src/
    main.ts
    app.module.ts
    common/
    config/
    auth/
    users/
    medicines/
    knowledge/
    safety/
    copilot/
    reports/
    my-medicines/
    reminders/
    scan-records/
    ai/
    db/
  prisma/              # PostgreSQL schema/migrations/seed/import 脚本
```

稳定后再把 `src-nest/` 合并为新的 `backend/src/`，并移除旧 Express 目录。这样迁移期可以同时跑 Express 和 Nest 做接口对比，不阻塞当前服务。

建议默认选型：

- NestJS `ConfigModule` 负责环境变量解析。
- Prisma 负责 PostgreSQL schema、migration、类型化访问和数据导入脚本。
- 药品搜索中需要复杂模糊查询、`pg_trgm` 排名、全文检索或批量导入时，Prisma 保留 raw SQL 查询口，不强行用 ORM 表达所有 SQL。
- Nest `ValidationPipe` + DTO 负责请求校验。
- 全局 interceptor 统一成功响应 envelope。
- 全局 exception filter 统一异常到 `{ code, msg, result }`。
- Passport `JwtStrategy` + `JwtAuthGuard` 负责受保护路由身份解析。
- Redis 封装为 `RedisModule`，只被 auth code、cooldown、AI cache 等明确场景依赖。

如果后续决定使用 TypeORM，也可以，但 Prisma 和 TypeORM 不要混用。迁移前先固定一种 PostgreSQL 访问层。

## 4. 目标模块拆分

| Nest 模块 | 对应当前代码 | 职责 |
| --- | --- | --- |
| `CommonModule` | `http/*` | envelope、异常映射、body/validation、JWT guard、公共 DTO |
| `ConfigModule` | `config/env.ts` | 环境变量、默认值、必填校验 |
| `DbModule` | `db/*` | PostgreSQL/Prisma、Redis provider、连接生命周期 |
| `AuthModule` | `handlers/auth.ts` | 验证码、注册、登录、刷新 token、Passport strategy |
| `UsersModule` | `handlers/auth.ts` profile/delete 部分 | 用户资料查询、更新、注销 |
| `MedicinesModule` | `medicine-search/detail/scan` | 药品搜索、数据库详情、Markdown sections、扫码候选 |
| `KnowledgeModule` | 新增 | xlsx/DrugBank 导入状态、source metadata、知识映射、enrichment lookup |
| `SafetyModule` | `ai-safety` + 新增规则 | 药品相互作用、特殊人群风险、确定性规则和 AI 辅助安全解释 |
| `AiModule` | `ai/*` + AI handlers | LangChain gateway、prompt registry、parser、AI cache |
| `CopilotModule` | 新增 | grounded explanation、报告解读、健康计划、医生/家庭分享摘要 |
| `ReportsModule` | 新增 | 报告上传、OCR、结构化指标、报告解读入口 |
| `MyMedicinesModule` | `handlers/my-medicine.ts` | 我的药品增删改查 |
| `RemindersModule` | `handlers/reminder.ts` | 提醒计划、今日提醒 |
| `ScanRecordsModule` | `handlers/scan-record.ts` | 扫描记录创建与分页列表 |

路由兼容映射：

| 当前路由 | Nest 控制器 |
| --- | --- |
| `GET /health` | `HealthController` |
| `POST /api/auth/codes` | `AuthController.sendCode` |
| `POST /api/auth/register` | `AuthController.register` |
| `POST /api/auth/login` | `AuthController.login` |
| `POST /api/auth/refresh` | `AuthController.refresh` |
| `POST /api/user/profile` | `UsersController.getProfile` |
| `POST /api/user/profile-update` | `UsersController.updateProfile` |
| `POST /api/user/delete` | `UsersController.deleteAccount` |
| `POST /api/medicines/search` | `MedicinesController.search` |
| `POST /api/medicines/detail` | `MedicinesController.detail` |
| `POST /api/medicines/scan` | `MedicinesController.scan` |
| `POST /api/medicines/ai-detail` | 兼容期保留，长期迁到 `CopilotController.explainMedicine` |
| `POST /api/medicines/ai-safety` | `SafetyController.review` / `CopilotController.safetyExplain` |
| `POST /api/medicines/my-upsert` | `MyMedicinesController.upsert` |
| `POST /api/medicines/my-delete` | `MyMedicinesController.delete` |
| `POST /api/medicines/my-list` | `MyMedicinesController.list` |
| `POST /api/reminders/upsert` | `RemindersController.upsert` |
| `POST /api/reminders/delete` | `RemindersController.delete` |
| `POST /api/reminders/list` | `RemindersController.list` |
| `POST /api/reminders/today` | `RemindersController.today` |
| `POST /api/medicines/scan-record-create` | `ScanRecordsController.create` |
| `POST /api/medicines/scan-record-list` | `ScanRecordsController.list` |

## 5. PostgreSQL schema 草案

公开给 Flutter 的 `id` 继续是字符串。为了迁移 MongoDB 数据时不破坏旧记录引用，建议 PostgreSQL 主键使用 `text`：

- 从 MongoDB 导入时写入原 `_id` 字符串。
- Nest 新建记录时生成 UUID 或 cuid 字符串。
- 所有响应继续返回字符串 `id`。

核心表：

```text
users
  id text primary key
  account text
  username text not null unique
  email text unique null
  phone text unique null
  password_hash text not null
  avatar text
  birthday text
  city_code text
  gender text
  nickname text
  profession text
  province_code text
  name text
  type integer default 0
  lock integer default 0
  last_login_time bigint default 0
  created_at timestamptz not null
  updated_at timestamptz not null

medicine_catalog
  id bigserial primary key
  serial_no text
  approval_no text
  product_name text not null
  dosage_form text
  specification text
  marketing_authorization_holder text
  manufacturer text
  drug_code text
  drug_code_remark text
  source_updated_at timestamptz

medicine_products
  id text primary key
  product_name text not null
  image_url text
  price_text text
  package_spec text
  approval_no text
  manufacturer text
  drug_type text
  main_category text
  sub_category text
  detail_url text
  brand_name text
  barcode text
  national_drug_code text
  source_row_number integer
  source_file text
  created_at timestamptz not null
  updated_at timestamptz not null

medicine_instruction_sections
  id bigserial primary key
  medicine_product_id text not null references medicine_products(id) on delete cascade
  section_key text not null
  section_title text not null
  content text not null
  sort_order integer not null

medicine_search_documents
  medicine_product_id text primary key references medicine_products(id) on delete cascade
  search_text text not null
  search_vector tsvector
  updated_at timestamptz not null

drugbank_drugs
  drugbank_id text primary key
  name text not null
  drug_type text
  cas_number text
  description text
  state text
  groups text[]
  exported_on date

drugbank_targets
  id text primary key
  name text not null
  gene_name text
  uniprot_id text
  species text

drugbank_drug_targets
  drugbank_id text not null references drugbank_drugs(drugbank_id) on delete cascade
  target_id text not null references drugbank_targets(id) on delete cascade
  primary key (drugbank_id, target_id)

medicine_drugbank_links
  id bigserial primary key
  medicine_product_id text not null references medicine_products(id) on delete cascade
  drugbank_id text not null references drugbank_drugs(drugbank_id) on delete cascade
  match_method text not null
  confidence numeric(5, 4) not null
  review_status text default 'pending'

my_medicines
  id text primary key
  user_id text not null references users(id) on delete cascade
  identity_key text not null
  drug_code text
  approval_no text
  product_name text not null
  dosage_form text
  specification text
  manufacturer text
  source text default 'search'
  created_at bigint not null
  updated_at bigint not null

reminders
  id text primary key
  user_id text not null references users(id) on delete cascade
  time text not null
  drug_code text
  approval_no text
  product_name text not null
  dosage text
  subtitle text
  enabled boolean default true
  repeat_rule text default 'daily'
  method text default 'notification'
  start_date text
  end_date text
  created_at bigint not null
  updated_at bigint not null

reminder_medicines
  id bigserial primary key
  reminder_id text not null references reminders(id) on delete cascade
  drug_code text
  approval_no text
  product_name text not null
  sort_order integer default 0

scan_records
  id text primary key
  user_id text not null references users(id) on delete cascade
  thumb_base64 text not null
  drug_code text
  approval_no text
  product_name text
  taken_at bigint not null
  created_at bigint not null
```

建议索引：

- `users(email)`、`users(phone)`、`users(username)` 唯一索引，空值需要按 PostgreSQL 语义确认唯一策略。
- `my_medicines(user_id, identity_key)` 唯一索引。
- `my_medicines(user_id, created_at desc)`。
- `reminders(user_id, time, created_at)`。
- `scan_records(user_id, taken_at desc, created_at desc)`。
- `medicine_catalog(drug_code)`、`medicine_catalog(approval_no)` 普通索引。
- `medicine_catalog(product_name)`、`medicine_catalog(manufacturer)` 使用 `pg_trgm` GIN 索引支撑模糊搜索。
- `medicine_products(product_name)`、`medicine_products(brand_name)`、`medicine_products(manufacturer)` 使用 `pg_trgm` GIN 索引。
- `medicine_products(approval_no)`、`medicine_products(barcode)`、`medicine_products(national_drug_code)` 普通索引。
- `medicine_search_documents(search_vector)` 使用 GIN 索引；中文分词方案未定前可先用 trigram + 拼接 search text。
- `drugbank_drugs(name)`、`drugbank_drugs(cas_number)` 和 `medicine_drugbank_links(medicine_product_id, review_status)` 建索引。

药品库搜索第一阶段先复刻当前 MySQL `LIKE` 行为，同时为新 xlsx 药品库建立 `pg_trgm` 模糊搜索。后续如果要优化中文搜索，再评估外部分词索引或专门搜索服务，不要在框架迁移首批次扩大范围。

Markdown 规则：

- `medicine_instruction_sections` 是事实来源。
- API 可以按 section 生成 `detailMarkdown`，但不要只存 Markdown 而丢失结构化 section。
- AI 输出默认使用 Markdown，但必须基于检索到的 section 或用户上下文生成。

## 6. 分阶段迁移步骤

### Phase 0: 基线冻结与合同测试

目标：迁移前先固定当前行为，后续每个 Nest 路由都能对比。

任务：

- 更新后端 API 文档，确认当前 `/api/*` 路由、请求体、响应体和错误码。
- 为 Express 当前核心接口补齐 contract/e2e 测试样例，至少覆盖 auth、medicine search/detail、my medicines、reminders、scan records。
- 记录当前默认验证门槛：`npm test --prefix backend`、`npm run build --prefix backend`。
- 准备本地迁移数据样本：最小用户、我的药品、提醒、扫描记录、药品目录。
- 记录新外部数据源元信息：xlsx 行列数、DrugBank 文件清单、导出日期、校验和、许可/使用边界。
- 准备小型合成 fixture，避免测试依赖完整 xlsx 或 1.78 GiB XML。

验收：

- 当前 Express 测试和 build 通过。
- 所有迁移范围内路由都有可复用的请求/响应样例。
- 本阶段不改 Flutter 调用方式。

### Phase 1: PostgreSQL 基础设施

目标：先让 PostgreSQL schema 和迁移工具可运行，但不切业务。

任务：

- 在 `docker-compose.yml` 和生产 compose 规划中新增 PostgreSQL 服务。
- 新增环境变量：`POSTGRES_HOST`、`POSTGRES_PORT`、`POSTGRES_USER`、`POSTGRES_PASSWORD`、`POSTGRES_DATABASE`、`DATABASE_URL`。
- 新增 Prisma schema 和第一版 migration。
- 增加数据导入脚本目录，例如 `backend/prisma/import/`。
- 增加知识库导入目录，例如 `backend/prisma/import/medicine-xlsx/` 和 `backend/prisma/import/drugbank/`。
- 编写数据库健康检查和本地连接测试。

验收：

- 空库执行 migration 成功。
- PostgreSQL schema 能被重建。
- 旧 Express 服务仍可按原方式运行。
- 小型 fixture 能导入 staging 表并输出导入报告。

### Phase 2: NestJS 运行时脚手架

目标：搭好 Nest 框架壳，并证明 envelope、异常、配置和 health check 可用。

任务：

- 新增 `backend/src-nest/main.ts`、`app.module.ts`。
- 添加 `CommonModule`：响应 interceptor、exception filter、统一错误类型。
- 添加 `ConfigModule`：迁移当前 `env.ts` 的变量读取逻辑。
- 添加 `DbModule`：Prisma provider、Redis provider。
- 添加 `HealthController`，返回和 Express `/health` 兼容的 envelope。
- 增加临时脚本：`dev:nest`、`build:nest`、`test:nest`。

验收：

- Nest `/health` 返回 `{ code: "1", msg: "", result: { ok: true } }`。
- Nest build/test 单独通过。
- Express 入口不受影响。

### Phase 3: 公共能力、AI 网关与 Markdown 输出基础

目标：优先迁移低数据库耦合能力，并建立 AI/Markdown 的新边界。

任务：

- 将 `backend/src/ai/*` 迁移或复用到 `AiModule`。
- 保持 `callTextModel`、`callVisionModel`、`extractTextContent`、`parseJsonObject` 等 helper contract。
- 迁移 AI 文本缓存，继续使用 Redis key 和 TTL。
- 建立 prompt registry 和 Markdown response DTO。
- 将 `medicine-ai-detail` 标记为兼容接口，后续迁移为 grounded explanation，而不是事实生成。
- 将 `medicine-ai-safety` 的核心逻辑拆成 `SafetyService`，暂不切外部路由。

验收：

- 现有 AI helper 测试在 Nest 结构下有等价覆盖。
- AI cache key 和 TTL 与旧实现一致。
- 不改变 AI 供应商环境变量语义。
- AI Markdown 输出包含免责声明和来源字段引用位置。

### Phase 4: 药品知识库与公开药品接口

目标：把旧 MySQL 药品库和新 xlsx/DrugBank 知识源迁到 PostgreSQL，并先迁移公开、低用户状态的接口。

任务：

- 编写 MySQL 到 PostgreSQL 的旧药品目录导入脚本，作为兼容和对比来源。
- 编写 xlsx 到 PostgreSQL staging/normalized tables 的导入脚本。
- 编写 DrugBank CSV/XML 到 PostgreSQL staging/normalized tables 的流式导入脚本。
- 导入 `serialNo`、`approvalNo`、`productName`、`dosageForm`、`specification`、`marketingAuthorizationHolder`、`manufacturer`、`drugCode`、`drugCodeRemark`。
- 导入新 xlsx 的说明书字段：成份、性状、适应症、用法用量、不良反应、禁忌、注意事项、特殊人群、药物相互作用、药理毒理、药代动力学、药物过量、贮藏、有效期。
- 实现 `KnowledgeModule` 的 source metadata、import status 和 mapping 查询。
- 实现 `MedicinesModule.search/detail/scan`。
- `detail` 返回结构化 `sections` 和 `detailMarkdown`，兼容旧 Flutter 字段。
- 实现 PostgreSQL 模糊搜索，第一阶段与当前 MySQL `LIKE` 行为保持一致。
- 通过 Express/Nest 并行请求对比搜索结果字段、分页和错误信息。

验收：

- PostgreSQL 药品目录数量与 MySQL 来源一致或差异可解释。
- xlsx source rows、staging rows、normalized rows 有导入报告。
- DrugBank fixture 导入通过；完整 XML 支持流式导入，不要求在普通测试中跑完全量。
- `/api/medicines/search`、`/api/medicines/detail`、`/api/medicines/scan` 与旧响应兼容。
- 新详情响应能提供 Markdown 给 Flutter 渲染。
- Flutter 不需要改接口路径。

### Phase 5: Auth 和 Users 迁移

目标：把用户、验证码、登录、注册、刷新 token 和资料接口迁到 Nest。

任务：

- 编写 MongoDB `User` 到 PostgreSQL `users` 的导入脚本。
- 保留 bcrypt password hash，不强制用户重新设置密码。
- 保留 JWT payload 中的 `id` 和 `username`。
- 验证码继续存在 Redis，key 兼容 `auth:code:{target}` 和 cooldown key。
- 使用 Passport JWT strategy 和 Nest guard 承接受保护路由。
- 迁移 `sendCode/register/login/refresh/profile/profile-update/delete`。
- 保持当前错误码和中文错误信息。

验收：

- 旧账号可登录。
- refresh token 能继续换发新 token。
- 注册、验证码登录、密码登录、资料更新、注销都有 Nest 测试。
- 删除账户时 PostgreSQL 关联数据级联删除，与旧逻辑等价。

### Phase 6: 用户数据模块迁移

目标：迁移我的药品、提醒和扫描记录。

任务：

- 编写 MongoDB 到 PostgreSQL 的导入脚本：
  - `MyMedicine` -> `my_medicines`
  - `Reminder` -> `reminders` + `reminder_medicines`
  - `ScanRecord` -> `scan_records`
- 实现 `MyMedicinesModule`、`RemindersModule`、`ScanRecordsModule`。
- 保持当前兼容字段，例如提醒里的 legacy `drugCode`、`approvalNo`、`productName`。
- 保持排序逻辑：
  - 我的药品按 `createdAt desc`
  - 提醒列表按 `time asc, createdAt asc`
  - 扫描记录按 `takenAt desc, createdAt desc`
- `thumbBase64` 第一阶段继续存在 PostgreSQL `text` 字段，后续再评估对象存储。

验收：

- 导入前后用户记录数量、我的药品数量、提醒数量、扫描记录数量可核对。
- 列表、upsert、delete、today、分页接口响应字段与旧版本兼容。
- Flutter 现有调用不需要修改。

### Phase 7: 鉴权边界收紧

目标：在 Nest 迁移稳定后，再逐步修正用户数据归属边界。

任务：

- 为 user profile、my medicines、reminders、scan records 增加 `JwtAuthGuard`。
- 先兼容 body `userId`，但要求它与 JWT `sub/id` 一致。
- Flutter 后续停止传 `userId` 后，服务端改为完全从 token 派生用户身份。
- 统一 `401/403` envelope 和日志。

验收：

- 修改 body `userId` 不能访问其他用户数据。
- 旧 Flutter 在迁移窗口内仍能工作。
- 新 Flutter 合同不再依赖本地传入 `userId`。

### Phase 8: 并行验证与部署切换

目标：用可回滚方式把生产入口切到 Nest + PostgreSQL。

任务：

- Express 和 Nest 在不同端口运行，使用同一组测试样例做路由级对比。
- 切换前执行全量备份：
  - MongoDB dump
  - MySQL dump 或药品目录导出
  - PostgreSQL dump
  - Redis 不做主数据备份，但保留切换窗口说明
- 设置短维护窗口，冻结旧服务写入。
- 执行最终增量导入或全量重导。
- 切换 compose/backend image/env 到 Nest 入口。
- 观察日志、健康检查、关键接口、Flutter 登录与核心流程。

验收：

- Nest 入口承接生产流量。
- PostgreSQL 是唯一主业务数据库。
- 可在维护窗口内回滚到旧 Express + MongoDB/MySQL。

### Phase 9: 旧依赖退役

目标：切换稳定后移除旧 Express/MongoDB/MySQL 运行依赖。

任务：

- 删除或归档旧 Express handlers/routes/models/db 代码。
- 移除 `express`、`mongoose`、`mysql2` 等不再使用的依赖。
- 更新 `backend/README.md`、`backend/src/README.md`、`docs/lib-docs/backend-api.md`。
- 更新 Docker/compose，移除 MongoDB/MySQL 服务。
- 清理旧环境变量：`MYSQL_*`、`MONGODB_URI`。

验收：

- `npm test --prefix backend` 和 `npm run build --prefix backend` 只针对 Nest 服务。
- compose 只保留 backend、PostgreSQL、Redis 和必要网关。
- 文档不再指向退役存储作为运行依赖。

## 7. 数据迁移规则

导入脚本必须满足：

- 幂等：重复执行不会产生重复数据。
- 可分批：药品目录和扫描记录这类大表要支持分页/游标导入。
- 可核对：每张表输出来源数量、目标数量、失败数量和样例失败原因。
- 可回滚：切换前保留 PostgreSQL dump 或重建脚本。
- 不改业务含义：第一阶段只搬迁结构，不顺手修改字段语义。

推荐导入顺序：

1. `medicine_catalog`，来源旧 MySQL，用于兼容对比。
2. `medicine_products`、`medicine_instruction_sections`、`medicine_search_documents`，来源 xlsx。
3. `drugbank_*` 和 `medicine_drugbank_links`，来源 DrugBank CSV/XML 和后续映射。
4. `users`，来源 MongoDB `User`。
5. `my_medicines`，来源 MongoDB `MyMedicine`。
6. `reminders` 和 `reminder_medicines`，来源 MongoDB `Reminder`。
7. `scan_records`，来源 MongoDB `ScanRecord`。

切换前核对：

- 用户数一致。
- 每个用户的我的药品、提醒、扫描记录数量一致。
- 药品搜索随机关键词结果字段齐全，分页数量差异可解释。
- xlsx 204,844 条数据行的导入成功/失败数量可解释。
- DrugBank 大文件导入有可恢复 checkpoint 或批次日志。
- 至少抽样验证 20 个真实用户或测试用户的登录、资料、我的药品、提醒、扫描记录。

## 8. 验证门槛

每个后端迁移 slice 至少运行：

```powershell
npm test --prefix backend
npm run build --prefix backend
```

引入 Nest 后新增并逐步替代为：

```powershell
npm run test:nest --prefix backend
npm run build:nest --prefix backend
```

切换前必须完成：

- Express/Nest route parity 测试。
- PostgreSQL migration 从空库执行成功。
- 数据导入脚本在测试数据和备份样本上执行成功。
- Docker compose 本地完整启动成功。
- Flutter 核心链路手动验证：注册/登录、药品搜索、药品详情、Markdown 详情、AI/copilot 输出、扫码、我的药品、提醒、扫描记录。

## 9. 执行顺序清单

- [ ] Phase 0：冻结 API 合同和 Express 基线测试。
- [ ] Phase 1：新增 PostgreSQL、Prisma schema 和迁移工具。
- [ ] Phase 2：新增 Nest 运行时脚手架和 `/health`。
- [ ] Phase 3：迁移 common/config/Redis/AI 网关和 Markdown 输出基础。
- [ ] Phase 4：迁移药品知识库、DrugBank enrichment 和公开药品接口。
- [ ] Phase 5：迁移 Auth 和 Users。
- [ ] Phase 6：迁移我的药品、提醒、扫描记录。
- [ ] Phase 7：收紧用户数据鉴权边界。
- [ ] Phase 8：并行验证、数据最终同步、部署切换。
- [ ] Phase 9：退役 Express/MongoDB/MySQL 运行依赖。

## 10. 近期建议

下一步不要直接改生产入口。推荐先做 Phase 0 和 Phase 1：

1. 补齐当前 Express contract 测试和 API 样例。
2. 新增 PostgreSQL compose 服务和 schema 草案。
3. 为 xlsx 和 DrugBank 准备小型 fixture，不直接依赖完整外部大文件跑测试。
4. 跑通空库 migration 和 fixture import。
5. 再开始 Nest 脚手架。

这样即使后续迁移暂停，当前 Express 服务也不会被半成品 Nest 代码影响。
