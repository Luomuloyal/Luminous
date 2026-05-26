---
title: "Luminous 当前顺序执行计划"
tags:
  - execution
  - migration
aliases:
  - 执行计划
  - 当前执行计划
  - 顺序执行计划
created: 2026-05-26
---

# Luminous 当前顺序执行计划

Last updated: 2026-05-26

## 用法

这份文档用于在 Codex 暂时不参与实现时，交给 DeepSeek 按顺序推进。它不是愿景文档，也不是历史日志，而是从当前项目状态出发的执行手册。

执行约定：

1. 严格按步骤推进。除非上一步已经通过验收，否则不要跳到后续步骤。
2. 每次只做一个步骤中的一个小切片。如果步骤过大，先拆成子切片，但不要扩大范围。
3. 每个切片必须更新 [[migration_log]]，记录做了什么、验证了什么、还有什么风险。
4. 代码改动前先看当前文件，不要按文档猜测。
5. 任何涉及协议、数据库、状态管理、跨端体验的决策，都以 [[RefactorPlan]] 的红线为准。
6. 发现计划过期时，先写清楚差异和建议，等待审核，不要直接重写路线。

默认验证门：

```bash
flutter analyze
flutter test
```

涉及代码生成时：

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

涉及 Lucent 时：

```bash
pnpm test
pnpm test:e2e
pnpm build
```

## 当前起点

当前项目已经完成：

- Flutter 目录主线迁入 `lib/core`、`lib/shared`、`lib/features`。
- **GetX 已完全抹除**：全部 13 个 feature 切片已迁 Riverpod，`pubspec.yaml` 不含 `get`。
- legacy Express client 与 Lucent client 已拆分。
- `integration_test/app_smoke_test.dart` 已存在，含 5 项 smoke 测试。
- `collection`、`json_annotation`、`build_runner`、`json_serializable` 已加入依赖。
- **JSON 生成迁移已完成**：15 个共享模型使用 `@JsonSerializable(createFactory: false)` + 手写 `fromJson`；嵌套容器 `toJson` 回归已修复。
- 所有文件 ≤600 行。
- `flutter test` **118/118 通过**；`flutter analyze` 零 issue。
- `test/support/fake_sqflite_database.dart` 覆盖生产路径 WHERE / ORDER BY 模式。

当前还未完成：

- Lucent 还未成为 Flutter 主数据源（当前仍以 legacy Express backend 为主要数据源）。
- 药品知识平台还未从 `DrugDataBase` 导入到 PostgreSQL。
- Markdown 药品详情和 AI 输出还未成为主展示路径。
- 用药闭环还没有完全建立在权威药品知识和 JWT 用户边界上。

## Step 0：建立本轮执行快照

最终效果：

- 后续执行者清楚当前代码状态，避免按过期文档改错方向。

具体做法：

- 运行 `git status --short`，确认工作区是否干净。
- 扫描活跃 GetX：`rg -n "package:get/get\\.dart|GetBuilder|GetxController" lib test`。
- 扫描大文件：列出 `lib/**/*.dart` 中前 30 个最长文件。
- 运行 `flutter analyze` 和 `flutter test`。
- 把结果追加到 [[migration_log]]。

验收标准：

- 有一段明确的基线记录：当前验证是否通过、活跃 GetX 还在哪些 feature、大文件排序如何。
- 如果验证失败，先修复失败，不进入 Step 1。

注意事项：

- 这个步骤只记录和修复基线，不做功能迁移。
- 如果工作区已有用户未提交改动，必须先说明，不要覆盖。

## Step 1：迁移 Home 到 Riverpod

最终效果：

- 首页不再依赖 `HomeController` / `GetBuilder`。
- 首页提醒、打卡记录、健康提示等状态由 Riverpod provider 管理。

具体做法：

- 新建 `lib/features/home/presentation/providers/home_provider.dart`。
- 将 `HomeController` 中的加载状态、今日提醒、打卡记录、刷新逻辑迁入 `Notifier` 或 `AsyncNotifier`。
- 保留现有 `ReminderLocalGateway` 注入能力，方便测试继续使用 fake gateway。
- `HomePage` 改为 `ConsumerWidget` 或 `ConsumerStatefulWidget`。
- 旧 `HomeController` 移入 `lib/deprecated/getx/`，不要继续从活跃 barrel export。
- 更新 `home_today_reminders_test.dart`、`home_adaptive_layout_test.dart`、`home_top_section_test.dart` 的测试夹具。

验收标准：

- `lib/features/home/**` 不再 import `package:get/get.dart`。
- 首页相关测试通过。
- `flutter analyze` 和 `flutter test` 通过。

注意事项：

- 首页是用户第一屏，不要同时改视觉语言。
- 保持现有 demo/空态行为不变，除非测试明确覆盖。
- 刷新、同步、本地 fallback 的竞态逻辑要保留 request id 或等价防抖机制。

## Step 2：迁移 Search 到 Riverpod

最终效果：

- 搜索页不再依赖 `SearchController` / GetX。
- 搜索输入、历史、结果、我的药品标记、加载/错误/空态都由显式状态表达。

具体做法：

- 先把 `search_controller.dart` 拆成状态模型、查询服务/仓储调用、历史记录逻辑，再迁 provider。
- 新建 `search_provider.dart`，优先使用 `AsyncNotifier` 管理搜索结果。
- 将用户态读取改为 `ref.watch(currentUserProvider)`。
- 保持 legacy `MedicineApi` 调用不变，不在本步骤切 Lucent。
- 更新 `search_page.dart` 为 Consumer 页面。
- 更新搜索相关测试，至少覆盖：空关键词、正常结果、空结果、业务错误、我的药品标记。

验收标准：

- `lib/features/search/**` 不再 import GetX。
- `search_controller.dart` 从活跃路径移出或变为废弃记录。
- 搜索主路径测试通过。
- `flutter analyze` 和 `flutter test` 通过。

注意事项：

- 不要在搜索迁移时同时改药品详情协议。
- 搜索 prompt/sliver 文件较大，拆 widget 可以做，但不要改交互。

## Step 3：迁移 Drug 列表和我的药品状态

最终效果：

- Drug 列表页、我的药品列表、添加/删除本地与远端同步逻辑不再依赖 GetX。

具体做法：

- 新建 `drug_provider.dart` 或按职责拆成 `drug_search_provider.dart`、`my_medicines_provider.dart`。
- 先迁 `DrugController`，保留 `MyMedicineRepository` 当前 legacy API 调用。
- 明确本地库、待同步记录、远端同步状态的状态模型。
- 页面 `DrugPage` 改为 Consumer 页面。
- 更新 my medicine 相关 widget tests 或补一个 focused test。

验收标准：

- `lib/features/drug/presentation/pages/drug_page.dart` 不再使用 `GetBuilder`。
- 我的药品添加、删除、同步失败 fallback 的行为不倒退。
- `flutter analyze` 和 `flutter test` 通过。

注意事项：

- 此步骤不迁 `MedicineDetailController`，避免列表和详情同时变动。
- 旧 Express 的 body `userId` 还可以保留到 Lucent 切换阶段，但要标注为 legacy。

## Step 4：迁移 Medicine Detail 状态

最终效果：

- 药品详情页不再依赖 `MedicineDetailController`。
- 普通详情和 AI 详情分成清晰状态，后续可替换为 Lucent 结构化 sections + Markdown。

具体做法：

- 新建 `medicine_detail_provider.dart`。
- 将详情加载、AI 详情加载、缓存展示、重试逻辑从 controller 迁到 provider。
- 页面只负责展示不同状态，不直接拼接业务结果。
- 保留 legacy `MedicineApi.fetchDetail` 和 `fetchAiDetail`，不在本步骤改协议。
- 为详情成功、失败、AI 缓存/刷新补 focused tests。

验收标准：

- `medicine_detail_page.dart` 不再 import GetX。
- 详情主路径和 AI 卡片现有行为保持。
- `flutter analyze` 和 `flutter test` 通过。

注意事项：

- AI 详情是后续要被 grounded copilot 替代的旧能力，不要继续扩大它的接口面。
- 不要在此步骤引入 Markdown renderer，Markdown 是后续独立步骤。

## Step 5：迁移 Reminders 列表状态

最终效果：

- 提醒列表页不再依赖 `ReminderListController`。
- 本地计划、远端同步、今日快照刷新进入 Riverpod 管理。

具体做法：

- 新建 `reminder_list_provider.dart`。
- 将 `ReminderLocalGateway` 作为 provider 注入，参考 CheckIn 的 gateway provider。
- 迁移列表加载、远端同步、删除计划、revision 监听。
- 页面改为 Consumer。
- 更新 `reminder_list_controller_test.dart` 为 provider test。

验收标准：

- 提醒列表 feature 不再使用 GetX。
- 空列表不自动创建默认提醒。
- 删除、同步、刷新测试通过。
- `flutter analyze` 和 `flutter test` 通过。

注意事项：

- 提醒本地存储和通知调度容易有副作用，测试要使用 fake gateway/store。
- 不要同时迁编辑页。

## Step 6：迁移 Reminder Edit 状态

最终效果：

- 提醒编辑页不再依赖 `ReminderEditController`。
- 表单状态、药品选择、保存、通知重排由 provider 管理。

具体做法：

- 新建 `reminder_edit_provider.dart`，表单字段使用不可变 state。
- 页面中的 TextEditingController 只保留 UI 输入职责；async 后写 controller 必须检查 `mounted`。
- 保存逻辑仍走现有 `ReminderLocalGateway` / legacy API。
- 更新 `reminder_edit_page_test.dart`。

验收标准：

- `lib/features/reminders/**` 活跃代码不再 import GetX。
- 编辑剂量、额外内容、药品关联 identity 的测试通过。
- `flutter analyze` 和 `flutter test` 通过。

注意事项：

- 不要破坏通知调度。
- 保存失败必须保留明确错误展示。

## Step 7：迁移 Scan 状态

最终效果：

- 扫码/图片识别页不再依赖 `MedicineScanController`。
- 图片选择、识别、结果展示、创建扫码记录由 Riverpod 管理。

具体做法：

- 新建 `medicine_scan_provider.dart`。
- 保留现有 image flow helper 和 widget，先只替换状态源。
- API 调用仍走 legacy `ScanApi`，不在本步骤切 Lucent。
- 将用户态读取改为 provider。
- 更新 `ai_scan_flow_test.dart` 和相册重扫相关测试。

验收标准：

- `lib/features/scan/**` 不再 import GetX。
- 扫描成功、失败、重新选择图片、相册重扫路径测试通过。
- `flutter analyze` 和 `flutter test` 通过。

注意事项：

- 图片权限和平台差异不要在此步骤重构。
- AI/scan 后端协议留到 Lucent 切换阶段。

## Step 8：迁移 Safety 状态

最终效果：

- 安全辅助页不再依赖 `SafetyAssistController`。
- 输入、当前药品、AI 安全结果、缓存刷新状态由 Riverpod 管理。

具体做法：

- 新建 `safety_assist_provider.dart`。
- 将 controller 中的查询、缓存、刷新、错误处理迁出。
- 页面改为 Consumer。
- 更新 `ai_cache_ui_test.dart`。

验收标准：

- `lib/features/safety/**` 不再 import GetX。
- 缓存 banner、refresh=true、错误态测试通过。
- `flutter analyze` 和 `flutter test` 通过。

注意事项：

- Safety 后续要从 AI 优先改为结构化规则 + AI 解释，不要在此步骤扩大 prompt。

## Step 9：清理活跃 GetX 和测试夹具

最终效果：

- 活跃 `lib/` 不再依赖 GetX。
- 测试不再需要 `Get.testMode` / `Get.reset`。
- `get` 依赖进入可删除状态。

具体做法：

- 运行 `rg` 确认 GetX 只存在于 `lib/deprecated/getx/`。
- 把 widget tests 中仅为历史 GetX 初始化保留的 `Get.testMode` / `Get.reset` 删除。
- 如果活跃代码 0 引用 GetX，尝试从 `pubspec.yaml` 删除 `get`。
- 跑 `flutter pub get`、`flutter analyze`、`flutter test`。
- 暂时保留 `lib/deprecated/getx/` 文件时，如果删除 `get` 会导致 deprecated 编译失败，则先将 deprecated GetX 文件移出编译路径或整体删除。

验收标准：

- `rg "package:get/get\\.dart|GetBuilder|GetxController" lib test` 不再命中活跃代码和测试。
- `pubspec.yaml` 不再包含 `get`，或文档明确说明为什么暂时不能删。
- 全量测试通过。

注意事项：

- 删除 deprecated 文件前确认没有 rollback 需要。
- 不要为保留历史代码牺牲主线依赖整洁度。

## Step 10：大文件二次拆分

最终效果：

- 主要活跃 Dart 文件稳定在可维护体积，后续不再在页面文件堆业务逻辑。

具体做法：

- 优先拆：
  - `today_reminder_local_store.dart`
  - `safety_assist_page.dart`
  - `checkin_page.dart`
  - `search_prompt_slivers.dart`
  - `login_page.dart`
  - `register_page.dart`
  - `reminder_edit_widgets.dart`
  - `drug_my_medicines_widgets.dart`
- 拆分方式按职责：page、section、card、dialog、form、state view、mapper、SQL helper。
- 每个拆分切片不改行为。

验收标准：

- 没有活跃业务文件超过 600 行。
- 新增文件尽量低于 300 行。
- `flutter analyze` 和相关 focused tests 通过。

注意事项：

- 不要为了行数拆出无意义的 `part1`、`utils2`。
- l10n 生成文件不纳入行数目标。

## Step 11：扩展 integration smoke

最终效果：

- 项目有最小端到端烟测，能在大迁移后快速确认主路径没断。

具体做法：

- 保留现有启动和主导航 smoke。
- 增加登录/注册入口导航，不依赖真实网络。
- 增加一个本地可控主路径：提醒创建/编辑/打卡，或 medicine picker 到本地我的药品。
- 使用 fake/mockable 数据优先，避免 smoke 被 devluo.com 或 Lucent 可用性阻断。

验收标准：

- `flutter test integration_test/app_smoke_test.dart` 在可用设备/桌面 target 上可运行。
- smoke 不追求覆盖所有分支，只保证启动、导航、一个核心流程。

注意事项：

- integration smoke 不要变成慢速全流程测试。
- 如果本机没有可用 target，在日志中记录无法运行原因。

## Step 12：JSON 生成迁移第一批

最终效果：

- 稳定共享模型开始使用 `json_serializable`，减少手写 JSON 错误。

具体做法：

- 先迁 `lib/shared/models/medicine.dart` 和 `lib/shared/models/home.dart`。
- 添加 `part '*.g.dart'`、`@JsonSerializable()`，保持 JSON key 与现有兼容。
- 为每个迁移模型补充 round-trip model tests。
- 运行 build_runner。

验收标准：

- 生成的 `*.g.dart` 已纳入版本管理。
- 旧测试和新增模型测试通过。
- `dart run build_runner build --delete-conflicting-outputs`、`flutter analyze`、`flutter test` 通过。

注意事项：

- 不要迁尚未稳定的 Lucent DTO。
- 不要在本步骤引入 Freezed。

## Step 13：JSON 生成迁移第二批

最终效果：

- Auth、Reminder、Medicine、Scan、Safety 等核心 DTO 的 JSON 解析更稳定。

具体做法：

- 按 feature 单独迁移，不要一次性全仓：
  - auth
  - reminders
  - drug / my medicine
  - scan
  - safety
  - search
  - album / browse history
- 每次迁一个模型文件，补 focused tests，跑 build_runner。

验收标准：

- 每个已迁模型有 round-trip 或 fromJson 边界测试。
- 全量测试通过。

注意事项：

- 本地数据库 row mapper 先不要和 API DTO 混成同一个模型。
- 复杂不可变模型是否用 Freezed，等这一批稳定后再评估。

## Step 14：集合相等与本地比较清理

最终效果：

- 不再用 JSON 序列化字符串作为对象相等判断的默认方式。

具体做法：

- 用 `collection` 的 `ListEquality`、`SetEquality`、`DeepCollectionEquality` 替换：
  - `browse_history_store.dart` 的 JSON 比较。
  - search/reminder 中的手写集合比较。
- 为比较逻辑补单元测试。

验收标准：

- `rg "jsonEncode\\(|toJson\\(\\).*==" lib` 不再命中普通相等比较。
- focused tests 和全量测试通过。

注意事项：

- 如果某处确实需要比较 canonical JSON payload，必须注释说明产品原因。

## Step 15：安全 token 存储与会话过期

最终效果：

- token 存储和 refresh 失败行为更接近真实生产要求。

具体做法：

- 引入 `flutter_secure_storage`，新增 secure token storage service。
- `TokenManager` 改为可注入实现，逐步从 SharedPreferences 迁出敏感 token。
- refresh 失败时统一清 token、清 user session、只提示一次。
- 对并发 401 做防抖，避免多次弹 toast。
- 增加 token/session provider tests。

验收标准：

- 登录成功后 token 存在 secure storage。
- refresh 失败后用户态清空，受保护页面不显示旧用户数据。
- 相关测试和全量测试通过。

注意事项：

- 桌面/Web 平台 secure storage 行为要确认；如果 Web 暂不支持，文档记录 fallback。

## Step 16：稳定 Lucent API v1 合同

最终效果：

- Lucent 和 Flutter 对新协议有共同事实来源。

具体做法：

- 在 Lucent docs 明确：
  - route prefix `/api/v1`
  - envelope `{ code, message, data, meta? }`
  - error code taxonomy
  - pagination meta
  - `X-Request-Id`
  - JWT identity rules
- 补 Lucent e2e：health、validation error、business error、request id。
- Flutter `LucentApiClient` 跟文档保持一致。

验收标准：

- Lucent `pnpm test`、`pnpm test:e2e`、`pnpm build` 通过。
- Flutter lucent client tests 通过。

注意事项：

- 不要把 `ok`、`timestamp`、`requestId` 塞回 body。

## Step 17：Lucent Auth + JWT 主线

最终效果：

- 新后端认证边界建立，用户身份由 JWT 派生。

具体做法：

- Lucent 实现 auth module：register、login、refresh、profile、verification code。
- Redis 用于验证码、冷却和短期状态。
- Passport JWT guard 覆盖 protected route。
- 保护路由拒绝 body/query `userId` 授权。
- Flutter 新增 Lucent auth API，但先不替换生产登录入口，使用 feature flag 或单独联调入口。

验收标准：

- Lucent e2e 覆盖注册、登录、refresh、无 token、错 token、跨用户访问。
- Flutter 能通过 dart-define 联调 Lucent auth。

注意事项：

- 旧 Express auth 只作为参考，不要求 Lucent 兼容旧响应模型。

## Step 18：知识平台 staging schema

最终效果：

- 药品数据源能进入 PostgreSQL staging 层，不污染 Flutter。

具体做法：

- 在 Lucent Prisma schema 中建立 source metadata、xlsx staging、DrugBank staging 基础表。
- 写导入脚手架，不提交原始数据。
- 读取 `D:\25080\Documents\VSCodeProject\Lumos\DrugDataBase\FullDrugDetail.xlsx`，先做 schema 探测和小批量 sample import。
- 记录字段映射、空值规则、编码规则、重复规则。

验收标准：

- sample import 可重复运行。
- source row count、import row count 可输出。
- 原始数据不进入 Git。

注意事项：

- 不要一次性设计完所有 normalized 表，先保证 staging 可回放。

## Step 19：FullDrugDetail 正式导入与归一化

最终效果：

- 中文药品详情主源进入可查询的 normalized 表。

具体做法：

- 建 normalized 表：medicine_product、instruction_section、identifier、manufacturer、category、search_document。
- 将 xlsx 字段映射到结构化章节和 `detailMarkdown` 生成输入。
- 加导入校验：重复批准文号、空字段、异常长文本、条码/本位码格式。
- 建索引和基础搜索字段。

验收标准：

- 204,844 行来源可解释导入结果。
- 搜索 name/manufacturer/approvalNo/barcode/nationalDrugCode 主路径可查。
- normalized count、异常 count、有无丢弃规则都有日志。

注意事项：

- 不要用 AI 清洗药品事实。
- Markdown 生成可以先规则化，不需要 AI。

## Step 20：DrugBank staging 与中英增强

最终效果：

- DrugBank 成为科学增强源，但不强行替代中文药品产品事实。

具体做法：

- 用流式 XML parser 导入 DrugBank drug、target、protein、external ids。
- 建 source mapping 表，记录中文产品与 DrugBank entity 的人工/规则映射候选。
- 先保留候选，不自动强绑定。

验收标准：

- 大 XML 不一次性载入内存。
- staging import 可重复执行。
- 映射置信度和来源可追踪。

注意事项：

- 中英映射没定稿前，不要把 DrugBank 信息混入中文说明书事实字段。

## Step 21：Lucent medicine search/detail API

最终效果：

- Flutter 可以从 Lucent 获取数据库驱动的药品搜索和详情。

具体做法：

- Lucent 增加 public medicine search/detail routes。
- DTO 返回结构化 fields、sections、identifiers、source metadata、`detailMarkdown`。
- 分页只用 `meta.pagination`。
- 写 contract tests。
- Flutter 新增 Lucent medicine API client，但先只在测试入口/开关下使用。

验收标准：

- Lucent medicine search/detail e2e 通过。
- Flutter client tests 覆盖 search/detail 解析。

注意事项：

- 不要把 AI detail 作为 medicine detail 的主数据。

## Step 22：Flutter Markdown 渲染切片

最终效果：

- 药品详情和 AI/copilot 长文本可以统一渲染 Markdown。

具体做法：

- 引入 `flutter_markdown`。
- 新建 shared Markdown renderer，统一样式、链接策略、安全提示。
- Medicine detail 页面支持 `detailMarkdown` 展示，同时保留结构化 sections 卡片。
- AI 输出使用同一 renderer。

验收标准：

- Markdown 标题、列表、表格/链接等基础渲染可用。
- 安全 disclaimer 始终可见。
- widget tests 覆盖 Markdown 内容展示。

注意事项：

- 不要继续扩张复杂正则分段。
- 外链点击要有明确策略，不默认静默打开。

## Step 23：Flutter 药品搜索/详情切到 Lucent

最终效果：

- Stage 1 的药品事实主路径来自 Lucent/PostgreSQL。

具体做法：

- 将 search/detail feature 通过 feature flag 或明确配置切到 Lucent medicine API。
- 保留 legacy fallback 仅用于临时测试，不作为长期兼容目标。
- UI 展示 source、sections、detailMarkdown。
- 更新 tests 和 docs。

验收标准：

- 搜索、详情、空结果、错误、分页、Markdown 展示全通过。
- 旧 `lib/assets/data.json` 只作为开发兜底样例，不影响生产主路径。

注意事项：

- 切换前确保 Lucent API 可稳定启动和测试。

## Step 24：用药闭环 user-scoped API 切到 Lucent

最终效果：

- 我的药品、提醒、打卡、扫码记录使用 Lucent JWT 身份和 PostgreSQL 数据。

具体做法：

- 按顺序切：
  1. my medicines
  2. reminders
  3. today/check-in records
  4. scan records
- Flutter 请求不传 body/query `userId`。
- 本地仓储变为离线缓存/同步层，不再是长期主数据源。
- 加迁移/清理逻辑，避免旧本地数据污染新用户。

验收标准：

- 新注册用户完成：登录、搜索、加入我的药品、创建提醒、打卡、查看记录。
- Lucent e2e 覆盖跨用户越权失败。
- Flutter integration smoke 增加用药闭环主路径。

注意事项：

- 不要一次切完所有 user-scoped API。
- 每切一个 feature，都保留 rollback 开关直到验收通过。

## Step 25：AI 副驾驶重定位

最终效果：

- AI 从“生成药品详情”变成“基于权威药品知识和个人上下文的解释层”。

具体做法：

- Lucent 新建 copilot service，输入必须包括 source sections 和用户上下文。
- 药品安全先规则化检查，再 AI 解释。
- 输出 Markdown，带来源边界和不确定性。
- Flutter 把 AI 卡片标注为“解释/建议”，不与事实字段混排。

验收标准：

- AI 不生成 dosage/contraindication 等数据库已有事实字段。
- 失败时基础药品详情仍可用。
- 相关 prompt 和 parser 有测试。

注意事项：

- 不要让 AI 给诊断或处方调整建议。

## Step 26：用药反应记录和健康时间线雏形

最终效果：

- 用药闭环从“提醒/打卡”扩展到“服药后反应记录”，为长期健康时间线打基础。

具体做法：

- Lucent 增加 medication response record model。
- Flutter 增加记录入口：效果、症状、不适、备注、发生时间。
- 在药品详情/我的药品/打卡后提供轻量记录入口。
- 时间线先只展示用药相关事件。

验收标准：

- 用户能新增、查看、删除自己的用药反应记录。
- 数据受 JWT 保护。
- 时间线能按时间排序展示打卡和反应记录。

注意事项：

- 仍然不做疾病诊断。
- 不要急着加入报告/生命体征，先稳定用药时间线。

## Step 27：报告和生命体征扩展

最终效果：

- 项目开始从用药管家扩展为个人健康记录管家。

具体做法：

- 先设计 reports/vitals/symptoms 的数据模型和隐私边界。
- 报告导入先做文件记录和手动结构化字段，再接 OCR。
- AI 解读必须基于结构化指标和免责声明。

验收标准：

- 用户能保存报告元数据和关键指标。
- 时间线能合并展示报告事件。
- AI 解读不替代医生诊断。

注意事项：

- 不要在用药闭环未稳定前启动此步骤。

## Step 28：家庭、医生分享和全终端差异化

最终效果：

- Luminous 进入个人/家庭健康管家阶段，并体现不同终端的独特价值。

具体做法：

- Web：家庭 dashboard、成员管理、短期医生分享链接。
- Desktop：大屏时间线、报告导入、长期对比分析。
- Mobile：继续强化采集、提醒、扫码、即时记录。
- 所有共享能力必须有过期时间、撤销、访问审计。

验收标准：

- 家庭成员权限清晰。
- 医生链接可过期、可撤销、有访问日志。
- Web/Desktop 不只是移动端拉伸版。

注意事项：

- 分享默认输出摘要，不默认暴露原始隐私数据。
- 先做最小闭环，再做复杂权限矩阵。

## Codex 审核重点

每次 DeepSeek 完成一个步骤后，Codex 审核时优先看：

1. 是否严格按当前步骤做，是否夹带了后续阶段。
2. 是否破坏 [[RefactorPlan]] 的红线。
3. 是否保留旧 Express / Lucent 协议边界。
4. 是否新增 GetX 或扩大 deprecated 目录。
5. 是否有足够测试覆盖成功、空态、错误、权限边界。
6. 是否运行并记录了必要验证。
7. 是否更新 [[migration_log]]，必要时更新本计划。
