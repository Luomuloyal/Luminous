# Flutter 后续改进计划

Last updated: 2026-05-25

## 目标

在 Lucent 后端逐步成形的同时，继续把 Flutter 端收口到可维护的 Feature-first + Riverpod + GoRouter 结构：

- 硬编码配置有明确归属，不再散落在页面、controller、utils 中。
- GetX 依赖按功能切片迁出，最终从 `pubspec.yaml` 删除。
- 旧 Express 协议和 Lucent `/api/v1` 协议边界清晰，不在同一个 client 中静默混用。
- 大文件继续拆分，保留每次迁移都能验证的节奏。

## 当前扫描结论

- 默认 API 地址已经明确为旧 Express：`GlobalConstants.LEGACY_EXPRESS_BASE_URL = https://devluo.com`；Lucent 联调通过 `--dart-define=API_BASE_URL=...` 覆盖。
- 当前网络层 `DioRequest` 仍按旧 Express `{ code, msg, result }` 和 `code == "1"` 解析；Lucent 的 `{ code, message, data, meta? }` 不应直接塞进这个入口。
- 活跃 `lib/` 中仍有 38 个文件命中 GetX 关键词，主要是 `features/*/presentation/controllers/*` 和对应页面的 `GetBuilder`。
- `test/` 中仍有 10 个文件依赖 `Get.testMode` / `Get.reset`。
- `lib/deprecated/getx/` 中保留 3 个废弃控制器，作为历史兼容记录。
- 300 行以上 Dart 文件仍有 34 个；目前未超过 600 行，但多个 450-595 行文件继续扩展前应优先拆分。

主要大文件：

| 文件 | 行数 | 处理方向 |
| --- | ---: | --- |
| `lib/features/reminders/data/today_reminder_local_store.dart` | 595 | 继续拆 SQL/映射/合并逻辑 |
| `lib/features/safety/presentation/pages/safety_assist_page.dart` | 554 | 页面壳、状态区、输入区继续拆 widget |
| `lib/features/search/presentation/controllers/search_controller.dart` | 547 | 迁 Riverpod 时拆状态、查询、历史记录 |
| `lib/features/search/presentation/support/search_prompt_slivers.dart` | 500 | 拆 prompt 模型与 sliver widget |
| `lib/features/checkin/presentation/pages/checkin_page.dart` | 494 | 拆记录列表、统计、操作区 |
| `lib/core/startup/root_app_widget.dart` | 469 | 后续把主题 token/spec 单独迁出 |
| `lib/utils/dio_request.dart` | 422 | 迁 Lucent 时拆 legacy client 与新 client |

## 执行原则

- 每次只迁一个 feature 或一个基础层切片，保持 `flutter analyze` 可通过。
- 业务状态迁移优先用 Riverpod `Notifier` / `AsyncNotifier`；页面改为 `ConsumerWidget` 或 `ConsumerStatefulWidget`。
- 不在 GetX controller 外继续新增业务逻辑；需要新增逻辑时先建 Riverpod notifier。
- Lucent client 和 legacy Express client 分离。旧 `DioRequest` 只服务旧协议，新的 `/api/v1` 另建入口。
- 常量按所有权归档：运行时配置、协议路径、存储 key、路由名、UI token、业务枚举、文案分别放置。

## 分步骤计划

### Step 1：网络配置与协议边界

目标：先把旧 Express 和 Lucent 的客户端边界建清楚。

- 新增 `lib/core/network/`，放置共享的网络错误、request id 调试读取、超时配置和基础拦截器。
- 保留当前 `DioRequest` 为 legacy Express client，不改成双协议解析。
- 新建 `LucentApiClient`，只解析 Lucent `{ code, message, data, meta? }`。
- 新建 Lucent endpoint 常量，统一以 `/api/v1` 开头。
- JWT 刷新逻辑迁移时以 Lucent auth contract 为准，不继续信任 request body `userId`。

完成标准：

- 旧 API 行为不变。
- 新 Lucent client 有最小单元测试覆盖 success/error envelope。（→ 切片 5）
- README 或本文件记录运行方式：`flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000`。

**进度：切片 1 完成 ✅（2026-05-25）**

已交付：

- `lib/core/network/api_exception.dart` — `ApiException` 迁出 + `hasCode()` helper
- `lib/core/network/timeout_config.dart` — 超时常量（default / AI safety / AI scan）
- `lib/core/network/lucent_client.dart` — `LucentApiClient` + `LucentApiResult<T>` + `LucentPaginationMeta`
- `lib/core/network/lucent_endpoints.dart` — `/api/v1/health`
- `lib/core/network/network.dart` — barrel export
- `lib/utils/dio_request.dart` — `ApiException` 类体迁出，改为 re-export；`DioRequest` 零改动

验证：`flutter analyze` 零问题通过。剩余：单元测试（切片 5）。

**切片 2 完成 ✅（2026-05-25）**

`main_shell` GetX → Riverpod：

- 新建 `providers/main_shell_provider.dart` — `MainShellNotifier`（Notifier）+ `MainShellState`，Tab 切换和冷启动预加载策略原样迁移
- `main_page.dart`：`MainPage` 从 `StatefulWidget` + `GetBuilder<MainController>` → `ConsumerWidget`
- `main_shell.dart`：移除 `import 'package:get/get.dart'`，provider 替代 controller export
- `main_controller.dart` → `lib/deprecated/getx/main_controller.dart`（零引用，仅历史保留）
- `test/main_controller_test.dart` → Riverpod `ProviderContainer` + `mainShellProvider`

验证：`flutter analyze` 零问题通过。

### Step 2：硬编码常量二次收口

目标：把“配置”和“设计 token”拆到更明确的归属，不让 `constants/` 继续成为杂物桶。

- 运行时配置：`lib/core/config/app_runtime_config.dart`。
- 存储 key：`lib/core/local_storage/storage_keys.dart`。
- 网络路径：`lib/core/network/legacy_express_endpoints.dart` 与 `lib/core/network/lucent_endpoints.dart`。
- UI token：`lib/shared/design_tokens/`，收口 spacing、radius、duration、opacity、shadow、常用尺寸。
- 路由名/path：`lib/router/app_routes.dart`。
- 业务枚举值：留在对应 feature 的 `models/` 或 `domain/`，不要放全局。

完成标准：

- 页面和 controller 不直接写 API path、storage key、全局 URL。
- 新增 token 后不扩大 `constants.dart` barrel 的职责。
- `flutter analyze` 通过。

### Step 3：GetX 迁移第一批：壳层和低风险页面

目标：先移除不依赖复杂后端状态的 GetX，用 Riverpod 建立统一写法。

优先顺序：

1. `main_shell`：`MainController` 改为 `StateProvider<int>` 或 `Notifier`，页面移除 `GetBuilder`。
2. `album`：本地相册状态迁为 `AsyncNotifier`，页面改 `ConsumerWidget`。
3. `checkin`：先抽状态模型，再迁 controller。
4. `medicine_picker`：搜索输入和选择态迁到 feature notifier。
5. `mine/browse_history`：本地数据读取用 `AsyncNotifier`。

完成标准：

- 对应 feature 不再 import `package:get/get.dart`。
- 相关测试不再需要 `Get.testMode` / `Get.reset`。
- 每个 feature 至少保留一个 smoke/widget test。

### Step 4：GetX 迁移第二批：认证与用户态

目标：把登录、注册、个人资料设置收口到现有 `features/auth/providers/`。

- `LoginController` / `RegisterController` 迁为 notifier，表单状态和提交状态显式建模。
- `ProfileSettingsController` 迁到 settings/auth 共享的用户资料 notifier。
- 登录态恢复、token 读写、用户信息读写统一走 `userSessionProvider` 和 `TokenManager`。
- 移除页面层对废弃 `UserController` 的隐性依赖。

完成标准：

- 登录、注册、退出、资料更新测试通过。
- 无新增 request body `userId` 授权逻辑。
- 认证失败和 token 过期路径有明确错误展示。

### Step 5：GetX 迁移第三批：后端强相关功能

目标：等 Lucent 关键 contract 稳定后，迁移网络强相关 feature。

顺序建议：

1. `search`
2. `drug`
3. `scan`
4. `safety`
5. `reminders`

这些模块同时依赖 API contract、离线缓存、AI 耗时请求或提醒调度，不应和基础 GetX 清理混在一个提交里。

完成标准：

- 对应 API 调用走 legacy 或 Lucent 的单一明确 client。
- 列表/详情/加载/错误/空态都用 Riverpod 状态表达。
- 单测覆盖成功、空结果、业务错误、网络错误。

### Step 6：Lucent API 切换

目标：把 Flutter 从旧 Express API 切到 Lucent `/api/v1`。

- 新增 Lucent auth、medicine、reminder、scan client。
- 响应解析使用 `code/message/data/meta`；分页只读 `meta.pagination`。
- `X-Request-Id` 仅用于调试和反馈上报，不进入普通业务模型。
- 旧 Express `devluo.com` 只保留为临时测试基线，不作为新协议兼容目标。
- 切换时按 feature 开关或分支推进，避免半数接口旧协议、半数接口新协议。

完成标准：

- Lucent health、login、search/detail、scan、reminder 主路径可联调。
- 旧 Express 专用常量和模型可被标记 deprecated。
- Flutter docs 更新当前默认后端和联调命令。

### Step 7：文案与本地化收口

目标：减少页面内中文 fallback 和工具层临时双语选择。

- 长文案优先放 `arb` 或独立数据文件；`legal_documents_page.dart` 不继续内嵌大段协议文本。
- 页面展示文案通过 `AppLocalizations` 获取。
- `AppI18nText` 仅作为无 `BuildContext` 的过渡工具，后续用可注入的 locale/message service 替代。
- 错误消息分为“服务端 message”和“客户端兜底文案”，避免各 utils 自行判断。

完成标准：

- 新页面不再直接写大段中文字符串。
- 中英文缺失 key 有检查方式。
- `AppI18nText` 的调用点逐步减少。

### Step 8：大文件拆分与测试补齐

目标：把 450 行以上文件作为优先拆分对象。

- `root_app_widget.dart`：主题 spec、ThemeData builder、fallback spec 拆到 `core/theme/`。
- `dio_request.dart`：legacy envelope、token refresh、error mapping 拆文件。
- `today_reminder_local_store.dart`：SQL、DTO 映射、合并规则拆文件。
- Search/Safety/CheckIn 页面拆 widget 和 state，不在页面文件内继续堆逻辑。

完成标准：

- 新增或修改文件保持 300 行以内为目标。
- 单次拆分不改业务行为。
- 拆分后至少跑 `flutter analyze`，高风险模块加 focused test。

## 推荐下一组小切片

1. 建 `lib/core/network/`，先把 legacy client 命名和 Lucent client 骨架建出来。
2. 迁 `main_shell`：用 Riverpod 替换 `MainController` 和页面 `GetBuilder`。
3. 迁 `album`：本地相册列表改为 `AsyncNotifier`。
4. 抽 `root_app_widget.dart` 的主题 spec 到 `core/theme/app_theme_spec.dart`。
5. 为 Lucent client envelope 写单元测试，再接 `/api/v1/health`。

这五步互相独立，适合按提交拆开做。
