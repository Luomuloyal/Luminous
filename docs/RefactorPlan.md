---
title: "Luminous 重构路线总控"
tags:
  - strategy
  - refactor
aliases:
  - 重构路线
  - 重构计划
created: 2026-05-26
---

# Luminous 重构路线总控

Last updated: 2026-06-02

## 文档定位

本文只负责把控大方向，避免重构路线走偏。具体执行清单放在 [[ExecutionPlan]]，历史流水记录放在 [[MigrationLog]]。

相关文档边界：

- [[Promise]]：产品愿景和长期边界。
- [[ROADMAP]]：产品功能路线图与优先级。
- [[ExecutionPlan]]：从当前仓库状态开始的可执行步骤。
- [[MigrationLog]]：迁移历史记录。
- [[TODO]]：已知待修复问题。
- `Lucent/docs/*`：Lucent 内部 API、环境、数据源和后端实现约定。

## 北极星

Luminous 的最终形态不是单纯的药品查询或提醒工具，而是跨平台、全终端、按终端能力分工的个人与家庭健康管家：

- 手机端：快速采集、扫码、提醒、打卡、日常记录。
- Web 端：家庭照护、共享面板、医生临时访问、就诊前摘要。
- 桌面端：大屏长期健康数据银行、报告导入、多年时间线和对比分析。

近期不得跳过“用药闭环”。先把药品知识、药品详情、提醒、打卡、用药反应记录、安全提示做扎实，再扩展到报告、症状、生命体征、家庭协作。

## 当前基线

截至 2026-06-02，项目已完成 Phase 0-2 主体工作：

- Flutter 主体目录已迁向 `lib/core`、`lib/shared`、`lib/features`。
- `lib/components`、`lib/pages`、`lib/stores`、`lib/viewmodels` 已全部退为兼容导出壳或归入 `lib/deprecated/*`。
- **GetX 已完全抹除**：`pubspec.yaml` 不含 `get` 依赖，所有 feature 零 GetX 引用，测试中 `Get.testMode` / `Get.reset` 已清理。
- 全部 13 个 feature 切片（Settings/MainShell/Home/Search/Scan/Drug/Reminders/Safety/Mine/Album/CheckIn/Login/Register）均已迁入 `lib/features/` 并切到 Riverpod。
- `lib/core/network/` 已建立，legacy Express client 与 Lucent client 已拆开。
- JSON 生成迁移已完成：15 个共享模型使用 `@JsonSerializable(createFactory: false)` + `_$XxxToJson` 生成 + 手写 `fromJson`；已修复嵌套容器 `toJson` 回归和 `done` 字段解析。
- 所有文件 ≤600 行，`safety_assist_page.dart` 已拆分到 424 行。
- 测试：`flutter test` **118/118 通过**，含 17 个模型 round-trip/fromJson 测试；`flutter analyze` 零 issue。
- `integration_test/app_smoke_test.dart` 含 5 项 smoke 测试（启动/导航/tab 遍历/登录入口/未认证跳转），当前环境无移动设备无法执行。
- `test/support/fake_sqflite_database.dart` 覆盖生产路径用到的 WHERE / ORDER BY 模式，可扩展。

当前后端边界：

- `backend/` 是旧 Express 服务，只作为低优先级参考和当前 `https://devluo.com` 旧接口基线。
- `Lucent/` 是目标后端，技术栈明确为 NestJS + PostgreSQL + Prisma + Redis + Passport JWT。
- 新接口：全局 prefix `/api` + NestJS URI versioning（Flutter 端 baseURL = `domain/api`，请求路径 = `/v1/xxx`）。不需要兼容旧 Express 路由。
- 旧 Express envelope 是 `{ code, msg, result }`。
- Lucent envelope 是 `{ code, message, data }`，只有分页等真实响应级信息才附加 `meta`。
- `requestId` 通过 `X-Request-Id` 返回；`timestamp` 默认留在服务端日志中。

## 总体原则

1. 每次只推进一个 feature 或一个基础层切片。
2. 每个切片必须能独立验证，不能把结构迁移、协议迁移、UI 改版、后端切换混在一起。
3. 新 Flutter 代码只能进入 `core`、`shared`、`features`，不得扩张旧目录或 deprecated 目录。
4. 活跃业务状态优先迁 Riverpod `Notifier` / `AsyncNotifier`，页面用 `ConsumerWidget` / `ConsumerStatefulWidget`。
5. GetX 只允许留在 `lib/deprecated/` 和尚未迁移 feature；新功能不得引入 GetX。
6. Flutter 不打包完整药品知识库，不提交 `DrugDataBase` 原始数据，不把大 xlsx / DrugBank 文件放入 assets。
7. 药品事实来自 Lucent/PostgreSQL 知识表，AI 只做解释、总结、对比、提示和个人化组织。
8. 用户授权边界必须收口到 JWT，Lucent 保护路由不得信任 body/query 中的 `userId`。
9. Markdown 是长文本默认展示路径，复杂正则分段不再继续扩张。
10. 文件体积继续按规则控制：优先低于 300 行，300-600 行可接受，超过 600 行先拆再加逻辑。

## 阶段顺序

### Phase A：当前 Flutter 基座收口

目标：让 Flutter 主线从“结构已迁移”进入“活跃状态管理统一、测试可托底”的状态。

必须完成：

- 迁移剩余活跃 GetX feature：Home、Search、Drug、Reminders、Scan、Safety。
- 移除活跃 `lib/` 中的 `package:get/get.dart`、`GetBuilder` 和 `GetxController`。
- 把直接依赖 GetX 的测试改为 Riverpod/GoRouter/MaterialApp 测试夹具。
- 拆分仍在增长的大文件，优先拆页面中的状态区、列表区、弹窗、文案、仓储映射。
- 扩展 integration smoke，至少覆盖启动、主导航、登录/注册入口、提醒创建或本地打卡主路径。

验收门槛：

- `flutter analyze` 通过。
- `flutter test` 通过。
- 有设备时 `flutter test integration_test/app_smoke_test.dart` 可运行。
- 活跃 `lib/` 中不再命中 GetX；`get` 依赖可以进入待删除状态。

### Phase B：类型安全与本地数据基础

目标：降低模型、JSON、SQLite 映射和本地缓存的维护风险。

必须完成：

- 从稳定共享模型和 API DTO 开始引入 `json_serializable`。
- 先迁 `shared/models`、auth、reminder、medicine、scan、safety 等稳定模型，不做全仓一次性替换。
- 用 `collection` 替换 JSON 字符串比较和手写复杂集合比较。
- 在新增更多本地表前评估 Drift；只有收益明确时再引入 `drift` / `drift_dev`。

验收门槛：

- `dart run build_runner build --delete-conflicting-outputs` 通过。
- `flutter analyze` 和模型相关 focused tests 通过。
- 不为尚未稳定的 Lucent DTO 过早生成大量代码。

### Phase C：Lucent 协议与 JWT 边界

目标：让新后端成为唯一新功能落点，并建立前后端共同遵守的协议边界。

必须完成：

- Lucent API v1 协议、错误码、JWT 身份规则、分页 `meta`、`X-Request-Id` 文档稳定。
- Nest 全局 validation pipe、exception filter、envelope interceptor、request id middleware 成为默认基线。
- Auth、用户资料、验证码、refresh、Passport JWT guard 成为第一批稳定模块。
- Flutter 新 Lucent client 不发送 body/query `userId` 作为授权边界。

验收门槛：

- Lucent 单元测试/e2e 覆盖 missing token、invalid token、跨用户访问、refresh 失败。
- Flutter Lucent client 覆盖 success、business error、network error、分页 meta。
- 旧 Express 仍可作为参考运行，但不影响 Lucent contract。

### Phase D：药品知识平台和 Markdown 详情

目标：把药品事实从旧小样例和 AI 生成迁到 Lucent/PostgreSQL。

必须完成：

- 为 `D:\25080\Documents\VSCodeProject\Lumos\DrugDataBase\FullDrugDetail.xlsx` 建 staging、导入、校验和 source metadata。
- 为 DrugBank 建分层 staging；大 XML 必须流式处理，不一次性读入内存。
- 建立中文产品详情、说明书章节、批准文号、条码、本位码、厂家、分类、搜索文档、DrugBank enrichment 的目标表。
- Lucent medicine search/detail 返回结构化 sections 和 `detailMarkdown`。
- Flutter medicine detail 和 AI/copilot 输出接入 Markdown renderer。

验收门槛：

- 数据源行数、staging 行数、normalized 行数可解释。
- 药品搜索支持名称、厂家、批准文号、条码、本位码等主路径。
- Flutter 不再把完整知识库放 assets。
- AI 药品详情不再编造药品事实，只基于检索到的结构化数据解释。

### Phase E：用药闭环切到 Lucent

目标：把 Stage 1 用药闭环变成真实后端驱动的稳定产品能力。

必须完成：

- Flutter 按 feature 切到 Lucent：auth、medicine search/detail、my medicines、reminders、scan records、check-in。
- 本地缓存只做离线/同步辅助，远端真实数据以 Lucent/PostgreSQL 为准。
- 提醒、打卡、用药反应记录形成同一用户时间线的基础数据。
- 旧 Express API 在 Flutter 中标记 deprecated，后续只保留必要回退开关。

验收门槛：

- 新注册用户可登录、搜索药品、查看详情、加入我的药品、创建提醒、打卡、查看记录。
- 保护路由全部从 JWT 派生用户身份。
- 旧 Express 与 Lucent 不在同一个 client 中混用。

### Phase F：AI 副驾驶重定位

目标：把 AI 从“生成药品事实”改成“基于权威数据和用户上下文解释、总结和提示”。

必须完成：

- 建立 grounded copilot 服务：输入必须包含检索到的药品 sections、用户已记录上下文和明确的安全边界。
- AI 输出默认 Markdown，带来源边界和不确定性说明。
- 药品安全提示先用确定性规则和结构化字段兜底，再用 AI 做解释层。
- 加入缓存、审计和失败降级，不让 AI 失败阻断基础药品详情。

验收门槛：

- AI 不能生成数据库已有字段的替代事实。
- AI 输出可追溯到 medicine sections / user records。
- Flutter 能清楚区分“事实字段”和“AI 解释”。

### Phase G：全终端健康管家扩展

目标：在用药闭环稳定后，扩展到个人/家庭健康管理。

顺序：

1. 报告导入、OCR、结构化指标和 Markdown 解读。
2. 症状、生命体征、用药反应记录。
3. 个人健康时间线。
4. 家庭成员与照护面板。
5. 医生临时分享链接、访问审计和撤销。
6. 桌面端长期数据银行与大屏分析。

验收门槛：

- 每个新健康领域都有数据模型、隐私边界、导入/编辑/删除能力。
- 共享默认给摘要，不默认暴露原始隐私数据。
- 移动、Web、桌面各自体现终端优势，而不是简单拉伸同一个页面。

## 默认验证门

Flutter 切片默认：

```bash
flutter analyze
flutter test
```

涉及代码生成：

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

涉及 integration smoke：

```bash
flutter test integration_test/app_smoke_test.dart
```

Lucent 切片默认：

```bash
pnpm test
pnpm test:e2e
pnpm build
```

跨端或 UI 适配切片至少覆盖 393、768、1280 逻辑宽度的 widget test 或截图检查。

## 明确禁止

- 不要在 `backend/` 继续实现新业务主线。
- 不要为兼容旧 Express 牺牲 Lucent 新协议。
- 不要把 `DrugDataBase` 或大型 xlsx/DrugBank 文件提交进 Git 或 Flutter assets。
- 不要把 AI 当作药品事实来源。
- 不要在新页面、新 provider、新 repository 中新增 GetX。
- 不要一次性全仓迁移 JSON、Drift、Lucent API 或 UI 重构。
- 不要在未建立验收测试前做大面积行为修改。

## 近期唯一推荐路线

按 [[ExecutionPlan]] 执行。
