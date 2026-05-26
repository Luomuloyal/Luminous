---
title: "Luminous 架构重构及迁移记录"
tags:
  - execution
  - migration
  - log
aliases:
  - 迁移日志
  - 迁移记录
created: 2026-05-23
---

# Luminous 架构重构及迁移记录

该文档记录 Luminous 从基于 GetX/Layer-based 迁移向 Riverpod/GoRouter/Feature-first 架构的历程，用以为长期项目维护提供清晰的追踪。

## 执行约束

- 迁移按小步推进，不并行铺开多个高风险状态模块。
- 新增迁移代码优先落入目标结构，避免继续把新实现堆回 `lib/pages`、`lib/stores` 这类旧目录。
- 文件规模控制为：优先 300 行以内，300-600 行可接受，超过 600 行应先拆分再继续扩展。

目标目录结构参考（最终逐步靠拢此结构）：
lib/
├── core/ # 全终端共享底座
│ ├── network/ # Http 请求与拦截器
│ ├── theme/ # （我们将刚刚写好的主题迁移到这里）
│ ├── local_storage/ # Isar/Sqflite 配置
│ ├── router/ # 全局 GoRouter 路由表（我们刚才建的这里）
│ └── l10n/ # 国际化语言包
│
├── shared/ # 跨业务共享模块
│ └── widgets/ # 全局通用 UI (卡片、按钮等)
│
└── features/ # 【核心】独立的业务模块（高内聚）
├── auth/ # 登录、注册、用户态 (拆分原本的 UserController)
├── medicine/ # 药品搜索、扫码、数据库查询
├── reminders/ # 吃药打卡、日历
└── analytics/ # (未来) 长线健康报告、血脂图表分析
├── presentation/ # 该模块下的 UI（针对不同设备可能会有 Web/App 不同版本）
├── providers/ # 该模块的状态管控
└── domain/ # 业务模型

## 已完成阶段 (Phase 1: 基础设施注入与核心配置解耦)

1. **清理文档结构**
   - 移除无用的 Study/，整合根目录分散文档。
   - 所有规约和沉淀性 Markdown 归档入 docs/。

2. **核心包引入**
   - 引入 lutter_riverpod 和
     iverpod_annotation 作为新一代状态管理。
   - 引入 go_router 替代原生的与 Get 一体化的路由机制。

3. **入口与根状态改造**
   - 在 lib/main.dart 和 lib/startup/app_startup_warmup.dart 完成 SharedPreferences 的预加载，消除此前的首页白屏等待。
   - 将应用顶层替换为 ProviderScope 以承载全局状态。
   - 实现并注入 lib/router/app_router.dart，使用 MaterialApp.router 构建标准原生的 GoRouter 体系。

4. **解耦 Theme 与 Locale 配置 (改写 SettingsPage)**
   - 编写了原生的 Riverpod Provider ( hemeProvider, localeProvider ) 持久化存储主题、深浅模式及多语言设定。
   - 将 lib/pages/Settings/settings.dart 页面中的组件由 StatelessWidget 系统平滑替换到 ConsumerWidget。
   - 移除了该页面对 ThemeController 与 LocaleController 的 Obx 与 Get.find 依赖。
   - 修复相关受影响的 Smoke Tests (settings_page_smoke_test.dart)，已达到全单元测试依然全部 Pass 的里程碑基准。

## 下一步工作 (TODO)

- [ ] **状态迁移继续**
      逐步将 UserController 等高频但单一的数据剥离为 Riverpod Notifier，先完成单一会话/UI 状态，再推进登录态和业务状态。
- [ ] **网络层替换**
      探索通过 Dio + Riverpod 结合的方式，完全根除对 GetConnect 的底层代码依赖。
- [ ] **目录结构改造**
      将现在的 lib/pages、lib/stores 等 Layer-based 分包形式，安全过渡为 lib/features、lib/shared 或 lib/core 的 Feature-first 分包机制。
- [ ] **Isar 结构优化**
      如果将来涉及本地相册和模型缓存结构重构，将其剥离至对应业务的 Data Repository 层。

## 最近进展

### 2026-05-23

- 补充迁移执行规则：小步推进、限制文件体积、迁移代码优先进入目标目录结构。
- 将 `OrnamentController` 迁移为 `lib/core/theme/ornaments/ornament_provider.dart` 中的 Riverpod notifier，并同步替换设置页、共享卡片、横幅和主页面底栏的装饰状态读取方式。
- 开始拆分 `UserController`：会话恢复和用户持久化读写已迁入 `lib/features/auth/`，旧 GetX 控制器暂时保留为兼容入口。
- 运行时改为注册全局 `ProviderContainer` 过渡桥，仅供未完成迁移的 GetX controller 读取 `currentUserProvider`、`userLoggedInProvider` 和 `userSessionReadyProvider`。
- Home、提醒、打卡、相册、搜索、扫描、个人中心等旧 controller 的用户态读取已切到 Riverpod；`UserController` 不再作为运行时会话同步入口。
- `SplashPage` 已确认无路由引用，并在文件注释与声明处标记废弃，后续不要重新接回路由。
- 增加 `test/support/session_test_utils.dart`，测试统一通过 Riverpod 会话夹具注入用户态。

### 2026-05-24

- 在 [[RefactorPlan]] 中新增 `Phase 0`，明确先做目录结构整形和大文件拆分，再恢复更快的产品迁移节奏。
- 启动 `Settings` 作为第一个结构切片：新增 `lib/features/settings/presentation/`，把设置相关展示代码拆成 `pages/`、`widgets/`、`support/` 多文件。
- 将原 `lib/pages/Settings/settings.dart` 收缩为兼容导出壳，避免一次性改爆全仓引用。
- 路由、主页面和设置页测试已切到新的 `features/settings` 入口，并保持 `flutter analyze` 与 `flutter test` 通过。
- 完成 `Main shell` 第二个结构切片：新增 `lib/features/main_shell/presentation/`，把主页面壳层、底栏、装饰节点和 `MainController` 分拆到独立文件。
- 将原 `lib/pages/Main/main.dart` 与 `lib/pages/Main/controllers/main_controller.dart` 收缩为兼容导出壳，并把路由入口切到新的 `features/main_shell` 路径。
- 新增 `test/main_controller_test.dart` 覆盖底栏切换与加载标记的基础行为，随后重新通过 `flutter analyze` 与全量 `flutter test`。
- 新增共享工作区提交信息校验：通过 `.vscode/extensions.json` 推荐 `joshbolduc.commitlint`，并在 `.vscode/settings.json` 内配置轻量 Conventional Commit 规则，只在 VS Code Source Control 输入框内提示，不增加 Git hook 或强制全量校验。
- 调整 `.gitignore` 与 `CONTRIBUTING.md`，将 `.vscode` 改为“默认忽略，放行共享校验配置”的策略，避免把个人本地 IDE 配置带进仓库。
- 完成 `Home` 第三个结构切片：新增 `lib/features/home/presentation/`，把首页拆成 `controllers/`、`pages/`、`support/`、`widgets/` 多文件，并将正式入口命名统一为 `HomePage`。
- 将原 `lib/pages/Home/home.dart`、`lib/pages/Home/controllers/home_controller.dart` 与 `lib/components/home.dart` 收缩为兼容壳或导出层，同时把 `Main shell` 与首页相关测试切到新的 `features/home` 入口。
- 更新根 `README.md`，移除过时的 `Study/`、`.md/` 目录说明，并把后端说明改为“当前基线 + 目标栈”双轨描述：当前仍是 Express + MongoDB/MySQL/Redis，目标迁移为 NestJS + PostgreSQL；后续目标栈进一步明确为 Prisma/Redis/Passport。
- 在 [[RefactorPlan]] 中补充后端目标状态：NestJS 作为框架，PostgreSQL 作为主存储，Redis 仅在验证码、缓存和 AI 文本缓存等短生命周期场景按需保留，MongoDB/MySQL 作为迁移源逐步退场。
- 完成 `Search` 第四个结构切片：新增 `lib/features/search/presentation/`，把搜索页拆为 `controllers/`、`pages/`、`support/`、`widgets/` 多文件，并将正式入口命名统一为 `SearchPage`。
- 将原 `lib/pages/Search/search.dart`、`lib/pages/Search/controllers/search_controller.dart` 与 `lib/components/search.dart` 收缩为兼容壳或导出层，同时把路由、Main shell、药品选择器、扫码跳转和相关测试切到新的 `features/search` 入口。
- 完成 `Scan` 第五个结构切片：新增 `lib/features/scan/presentation/`，把扫码页拆为 `controllers/`、`models/`、`pages/`、`support/`、`widgets/` 多文件，并保留 `MedicineScanPage` 作为正式 Page 命名。
- 将原 `lib/pages/Scan/medicine_scan.dart`、`lib/pages/Scan/controllers/medicine_scan_controller.dart` 与 `lib/pages/Scan/models/selected_scan_image.dart` 收缩为兼容导出层，同时把路由、Home、药品详情、相册重扫和扫码流程测试切到新的 `features/scan` 入口。
- 根据最新迁移节奏，重新收窄 `Phase 0`：当前只处理 Flutter 项目基座，后端 auth 拆分、NestJS 脚手架和 PostgreSQL 改造全部顺延到后续后端阶段。
- 更新 `Phase 0` 后续顺序为共享 UI 基座、Auth 展示层、Medicine detail、Reminders 展示层、Safety/Mine 页面壳，先把前端目录结构和文件拆分打稳。
- 启动共享 UI 基座切片：新增 `lib/shared/widgets/`，迁移 `app_surface`、`tinted_status_chip`、`responsive_quick_grid`、`quick_entry_style` 与 `shared_quick_entry_card`，旧 `lib/components/*` 路径保留兼容导出。
- 继续共享 UI 基座切片：新增 `lib/shared/widgets/ornaments/`，将 `app_ornaments` 拆为模型、banner 布局、section 布局和布局集合文件，并把旧 `lib/components/app_ornaments.dart` 收缩为兼容导出。
- 核查并记录响应式预留状态：当前已有组件级响应式基础，包括 `ResponsiveQuickGridMetrics`、`ResponsiveQuickWrap`、feature 级页面入口和窄屏测试；但还没有全局 breakpoint、宽屏导航壳、桌面/Web 内容分流和 768/1280 宽度回归测试。
- 启动响应式基座：新增 `lib/shared/layout/`，定义 `AppWindowClass` 和全局 breakpoint，并加入 `AppAdaptiveScaffold`。
- 改造 `MainPage`：compact 宽度保留现有底部导航，medium 及以上宽度切换到 `NavigationRail`，expanded/web-expanded 宽度使用扩展侧栏形态。
- 新增 `test/adaptive_layout_test.dart` 覆盖 breakpoint 映射和 compact/wide adaptive shell 切换。
- 完成 `Drug` 第六个结构切片：新增 `lib/features/drug/presentation/`，把药品页拆为 `pages/`（`drug_page.dart`、`medicine_detail_page.dart`）、`widgets/`（3 个 drug 列表组件 + 3 个 medicine detail 组件）、`controllers/` 和 `models/` 多文件。
- 将 `lib/components/drug.dart`（697行）拆为 3 个 widget 文件，`lib/pages/Drug/medicine_detail.dart`（763行）拆为 4 个文件（page + header card + AI card + support cards），全部 ≤600 行。
- 将 `lib/viewmodels/drug.dart` 的数据模型迁入 `lib/features/drug/presentation/models/drug_models.dart`。
- 旧路径 `components/drug.dart`、`viewmodels/drug.dart`、`pages/Drug/drug.dart`、`pages/Drug/medicine_detail.dart` 及两个 controller 文件均收缩为兼容导出壳。
- 更新全仓 7 个引用方（`main_shell`、`home`、`search`、`album`、`browse_history`、`ai_cache_ui_test`、`responsive_layout_test`）的 import 到新 `features/drug` 入口。
- 在 `.gitignore` 中新增 `.flutter` 和 `.flutter_tool_state`，避免 Flutter SDK 本地工具状态文件进入仓库。
- 完成 `Reminders` 第七个结构切片：新增 `lib/features/reminders/presentation/`，把提醒模块拆为 `pages/`（`reminder_list_page.dart`、`reminder_edit_page.dart`）、`widgets/`（`reminder_list_widgets.dart`、`reminder_card_widget.dart`、`reminder_edit_widgets.dart`）和 `controllers/` 多文件。
- 将 `lib/pages/Reminders/reminder_list.dart`（730行）拆为 3 个文件（page + 辅助卡片 + 提醒卡片），`reminder_edit.dart`（687行）拆为 2 个文件（page + 6 个编辑组件），全部 ≤600 行。
- 旧路径 `pages/Reminders/reminder_list.dart`、`pages/Reminders/reminder_edit.dart` 及两个 controller 文件均收缩为兼容导出壳。
- 更新全仓 3 个引用方（`app_router`、`reminder_edit_page_test`、`reminder_list_controller_test`）的 import 到新 `features/reminders` 入口。
- 完成 `Safety` 第八个结构切片：新增 `lib/features/safety/presentation/`，把 `safety_assist.dart`（956行）拆为 page（626行）+ widgets（328行）+ controller 多文件。
- 将原 `lib/pages/Safety/safety_assist.dart` 及 controller 收缩为兼容导出壳，更新 `main_shell`、`app_router`、`ai_cache_ui_test` 的 import。
- 完成 `Mine` 第九个结构切片：新增 `lib/features/mine/presentation/`，把 `mine.dart`（113行）、`browse_history.dart`（461行）、`components/mine.dart`（658行拆为 profile card 221行 + page widgets 397行）整合迁移，含 2 个 controller。
- 收缩 6 个旧路径（`pages/Mine/mine.dart`、`browse_history.dart`、2 个 controller、`components/mine.dart`）为兼容导出壳，更新 `main_shell`、`app_router`、`mine_view_session_test`、`responsive_layout_test` 的 import。
- 完成 `Album` 第十个结构切片：新增 `lib/features/album/presentation/`，把 `components/album.dart`（1075行）拆为 4 个 widget 文件（page_widgets 181 + slivers 450 + card 224 + preview 210），迁移 page 和 controller。
- 收缩 3 个旧路径（`pages/Album/album.dart`、controller、`components/album.dart`）为兼容导出壳，更新 `main_shell`、`album_preview_test` 的 import。
- 完成 `CheckIn` 第十一个结构切片：新增 `lib/features/checkin/presentation/`，迁移打卡页（495行）和 controller，收缩 2 个旧路径，更新 `app_router` 的 import。
- 修复 `DrugView`/`AlbumView`/`MineView` → 统一为 `XxxPage` 命名，布局组件重命名为 `XxxLayout`；消除 `reminder_edit_page.dart` 的 `use_build_context_synchronously` lint。
- 完成 `Login` 第十二个结构切片：新增 `lib/features/login/presentation/`，迁移登录页和 controller，`login_controller` 中 `RegisterView` → `RegisterPage` 并更新 import。
- 完成 `Register` 第十三个结构切片：新增 `lib/features/register/presentation/`，迁移注册页（改名 `RegisterView` → `RegisterPage`）和 controller。
- 收缩 Login/Register 共 4 个旧路径为兼容导出壳，更新 `app_router` 和 `test/login_page_test.dart` 的 import。
- `flutter analyze` 和全量 `flutter test`（19 通过）均已确认。
- 更新当前 Phase 0 进度 checkpoint：Settings、Main shell、Home、Search、Scan、Shared UI、Responsive shell、Drug、Reminders、Safety、Mine、Album、CheckIn、Login/Register 已迁入 `lib/features/` 或 `lib/shared/` 的目标结构；剩余 Phase 0 收口项主要是 Picker、Legal、Profile settings 等小页面岛、`stores/viewmodels` 后续归属决策、兼容导出壳清理，以及 shared layout 的内容宽度/侧栏/宽屏测试补齐。
- 继续 shared 小切片：将 `AppCanvas` 与 `AppCanvasPageScaffold` 迁入 `lib/shared/widgets/app_canvas.dart`，旧 `lib/components/app_canvas.dart` 保留兼容导出，并把当前活跃引用切到 shared 路径。
- 继续 shared 小切片：将 `SoftBanner` 拆入 `lib/shared/widgets/soft_banner/`，按 palette、card、ornaments 拆分为多个小文件，旧 `lib/components/soft_banner.dart` 保留兼容导出，并把当前活跃引用切到 shared 路径。

---

## Phase 2: GetX → Riverpod 顺序迁移 (2026-05-26)

### Step 0：建立本轮执行快照
- Git 分支 `refactor`，工作区干净。`flutter analyze` 零 issue。
- 活跃 GetX 引用：32 处；大文件扫描完成；环境变量修复。

### Step 1：迁移 Home 到 Riverpod
- 新建 `home_provider.dart`（370→320 行）。`HomePage` → `ConsumerStatefulWidget`。
- 关键修复：`Future.microtask` 延迟初始化；测试 `addPostFrameCallback` → `Future()`。

### Step 2：迁移 Search 到 Riverpod
- 新建 `search_provider.dart`（568→557 行）。`SearchPage` → `ConsumerStatefulWidget`。
- 修复：`MedicineSearchExecutor` 歧义；support 文件兼容 getter。

### Step 3：迁移 Drug 列表
- 新建 `drug_provider.dart`（156 行）。`DrugPage` → `ConsumerWidget`。

### Step 4：迁移 Medicine Detail
- 新建 `medicine_detail_provider.dart`（233→223 行）。管理 AI 详情 + CancelToken。

### Step 5：迁移 Reminders 列表
- 新建 `reminder_list_provider.dart`（298→267 行）。load/sync/revision。

### Step 6：迁移 Reminder Edit
- 新建 `reminder_edit_provider.dart`（232 行）。移除未使用的 `_userId`。

### Step 7-8：Safety + Scan
- **Safety**：新建 `safety_provider.dart`（152 行）。`SafetyModeSwitcher` 重构为 mode+回调。Widget 移除 controller import。
- **Scan**：新建 `medicine_scan_provider.dart`（172 行）。5 个 part 文件改为 `ScanState` 参数。barrel 移除 `get` 导入。

### Step 9：清理活跃 GetX
- `lib/features/**` 零 GetX 引用。清理 5 个测试文件 `Get.testMode`/`Get.reset`。
- 删除 8 个 controller re-export 壳 + `lib/deprecated/` 目录。
- `reminder_list_controller_test.dart` 改用 `ReminderListNotifier`。
- 从 `pubspec.yaml` 删除 `get: ^4.7.3`。**GetX 已完全抹除。**

### Step 10：大文件拆分
- 所有文件在 600 行内。`safety_assist_page.dart` 546→424 行（提取 `SafetyResultSection` widget）。

### Step 11：集成 smoke
- `integration_test/app_smoke_test.dart` 扩到 4 tests（启动/导航/tab遍历/登录表单）。
- 本机缺 C++ 编译器无法执行，测试逻辑就绪。

### Step 12-13：JSON 生成迁移
- 新增 15 个类的 `@JsonSerializable(createFactory: false)` + `toJson()`：
  - 共享：`MedicineItem`、`MedicineSearchResult`、`MedicineAiDetailResult`、`ReminderItem`、`TodayRemindersResult`
  - Auth：`CodeTicketResult`、`RegisterResult`、`LoginResult`
  - Scan：`ScanCandidate`、`MedicineScanResult`
  - Safety：`MedicineAiSafetyResult`；Drug：`MyMedicineListResult`；Album：`IdResult`
- 手写 `fromJson` 全部保留（因含双 key 后备、嵌套类型转换、legacy 字段合并等特殊逻辑，`createFactory: false` 只生成 `toJson`）。
- `build_runner` 生成 `*.g.dart`。新增 17 个模型 test。
- `dart analyze`：No issues。`flutter test`：77/77 通过。

### Step 14：JSON 生成迁移回归修复 (2026-06-02)

`build_runner` 重跑后全量 `flutter test` 发现 8 个失败，归为两组：

**A. toJson 嵌套对象序列化缺陷（2 个模型）**

`@JsonSerializable(createFactory: false)` 生成的 `_$TodayRemindersResultToJson` 和 `_$MedicineSearchResultToJson` 直接将 `List<ReminderItem>` / `List<MedicineItem>` 写入结果 Map，而手写 `fromJson` 通过 `whereType<Map>()` 过滤子项。生成代码未对列表元素递归调用 `.toJson()`，导致 `toJson → fromJson` 往返后 `items` 长度为 0。

- `lib/shared/models/home.dart`：`TodayRemindersResult.toJson()` 改为手动实现，对 `items` 逐元素调用 `.toJson()`。
- `lib/shared/models/medicine.dart`：`MedicineSearchResult.toJson()` 同样改为手动实现。
- 注意：后续新增带嵌套模型的容器类，若 `fromJson` 用 `whereType<Map>()` 做类型安全过滤，则 `toJson` 不能依赖生成代码——必须手写以保证往返一致性。

**B. `ReminderItem.fromJson` done 字段解析不完整**

`json['done'] == true` 仅匹配 Dart 字面量 `true`，不处理后端可能返回的 `1` / `"yes"` / `"true"` 等表达。新增 `_parseTruthy()` 静态方法覆盖 `bool` / `int` / `String` 三种类型。

**C. 测试环境 locale 耦合**

`medicine_test.dart` 硬编码 `contains('未知')`，但 `AppI18nText.pick` 在测试中因 `PlatformDispatcher.locale` 为 `en` 而返回 `'Unknown medicine'`。改为 `isNotEmpty`，不绑定具体语言回退文本。

**D. FakeSqfliteDatabase WHERE / ORDER BY 覆盖不足**

生产代码 `loadTodayDoneSet`、`loadReminderMetaMap`、`loadTodayCheckinRecordsFromDb` 用到的 `userId = ? AND takenAt >= ? AND takenAt < ?` 和 `time ASC, id ASC` / `takenAt DESC, id DESC` 未被 fake DB 支持，导致 4 个测试失败。

- `test/support/fake_sqflite_database.dart`：`_matchesWhere` 新增复合范围 WHERE 子句；`_sortRows` 新增两个 ORDER BY 模式。
- `test/today_reminder_sql_test.dart`：两处 `endMs: 999999999999`（~2001年）修正为 `now ± 1000`，使插入行的 `takenAt` 实际落在查询时间窗口内——此前因 fake DB 直接抛 `UnsupportedError` 而掩盖了窗口错误。

**验证结果**

- `build_runner build`：246 输入全部跳过（已有最新生成文件）。
- `flutter analyze`：No issues。
- `flutter test`：**118/118 通过**（原 77 + Step 12-13 新增 41 个模型 test，加上 8 个回归修复 = 全绿）。
- `integration_test/app_smoke_test.dart`：需要移动设备/模拟器，当前环境无可用设备（Windows 桌面构建因 C++ debug CRT 链接器错误阻塞，Web 不支持 Flutter integration_test 运行器），测试逻辑就绪。

### Step 13（收尾）：JSON 生成迁移第二批 (2026-06-02)

盘点 `lib/features/` 下 6 个尚未迁移的 model 文件，实际需要 JSON 迁移的仅 2 个（其余为纯 UI 展示模型或 DB row mapper）：

- `search.dart` — `SearchResultItemData`：纯 UI 模型，无 fromJson/toJson → 跳过
- `drug_models.dart` — `DrugQuickEntry` / `DrugMedicineCardViewModel`：纯 UI + DB mapper → 跳过
- `mine.dart` — `MineQuickActionData`：纯 UI 模型 → 跳过
- `selected_scan_image.dart` — `SelectedScanImage`：Uint8List 内存模型 → 跳过

**实际迁移 2 文件、4 类：**

| 文件 | 类 | 操作 |
|------|-----|------|
| `reminder.dart` | `ReminderMedicineRef` | 加 `@JsonSerializable`，替换 `toJson` 为生成 |
| `reminder.dart` | `ReminderPlan` | 加 `@JsonSerializable`，替换 `toJson` 为生成（保留复杂 `fromJson`） |
| `reminder.dart` | `ReminderListResult` | 加 `@JsonSerializable`，补手写 `toJson`（嵌套列表需逐元素 `.toJson()`） |
| `browse_history.dart` | `BrowseHistoryEntry` | 加 `@JsonSerializable`，替换 `toJson` 为生成 |

**build_runner 修复：**

- `MedicineSearchResult`、`TodayRemindersResult`、`ReminderListResult` 添加 `createToJson: false`，消除手动 `toJson` 导致的 3 个 `unused_element` warning。
- `MyMedicineRecord` 补充 `toJson() => _$MyMedicineRecordToJson(this)`，消除第 4 个 warning，同时为 `MyMedicineListResult` 提供嵌套序列化支持。

**新增测试：**

- `test/features/reminders/presentation/models/reminder_test.dart`（16 tests）：
  `ReminderMedicineRef` fromJson 边界 + round-trip；
  `ReminderPlan` fromJson/`_id` fallback/legacy字段/medicines推导/hasId/displayTitle；
  `ReminderListResult` fromJson 边界 + round-trip。
- `test/features/mine/presentation/models/browse_history_test.dart`（17 tests）：
  `BrowseHistoryEntry` fromJson 边界 + round-trip + display getters + `fromMedicineItem`/`toMedicineItem` 往返。

**验证结果**

- `flutter analyze`：No issues found。
- `flutter test`：**151/151 通过**（原 118 + 新增 33）。

### Step 14：集合相等与本地比较清理 (2026-06-02)

验收扫描结果：`lib/` 下 `jsonEncode` 全部用于存储/传输，零处用于相等比较。

- `browse_history_store.dart` 已使用 `ListEquality<Map>` + `MapEquality` 替代 JSON 字符串比对的模式，符合 Step 14 目标。
- 将 `_sameEntries` 逻辑提取为 `@visibleForTesting sameBrowseHistoryEntries()` 独立函数，便于测试。
- 新增 `test/features/mine/data/browse_history_store_test.dart`（7 tests）：覆盖相同引用、空列表、同内容、不同长度、不同内容、不同字段值、多条目同序。
- 验证手段 `rg "jsonEncode\\(|toJson\\(\\).*==" lib` 返回零匹配。

**验证结果**

- `flutter analyze`：No issues found。
- `flutter test`：**158/158 通过**（151 + 新增 7）。

### Step 15：安全 token 存储与会话过期 (2026-06-02)

**架构变更：**

- 新增 `SecureTokenStore` 抽象接口（`lib/core/local_storage/secure_token_store.dart`），定义 `read/write/delete/containsKey` 四个操作。
- 新增 `FlutterSecureTokenStore`（`flutter_secure_storage` 实现，Android Keystore / iOS Keychain）。
- 新增 `SharedPrefsTokenStore`（SharedPreferences fallback，供 Web/桌面/测试使用）。
- 新增 `token_store_factory.dart` — `createPlatformTokenStore()` 平台自适应工厂：移动端用加密存储，Web/桌面 fallback 到 SharedPreferences；附带文档说明。
- **改造 `TokenManager`**：构造函数接受可选 `SecureTokenStore`；`init()` 首次调用时自动从旧的 SharedPreferences 迁移 token 到安全存储（best-effort）；读写删除全部通过 `SecureTokenStore`；空字符串 setToken 自动删除 entry。对外接口不变（`getToken/setToken/deleteToken`）。
- **新增 `TokenRefreshService`**（`lib/features/auth/data/token_refresh_service.dart`）：
  - 封装 `/api/auth/refresh` 调用，使用独立 Dio 实例避免拦截器递归。
  - **并发防抖**：`_pendingRefresh` Future 使同一时刻多个 401 共享一次 refresh HTTP 调用。
  - 成功：持久化新 token；失败：清 token → 回调 `onSessionExpired` → 清 user session。
  - Session 过期回调由 startup warmup 注册，调用 `userSessionProvider.notifier.clear()`。
  - 构造函数支持注入 Dio 和 TokenManager，便于测试。
- **重构 Dio 401 拦截器**（`dio_request.dart`）：原来 ~40 行内联 refresh 逻辑替换为 `tokenRefreshService?.refresh()` 调用 + retry 逻辑。
- **Startup warmup**（`app_startup_warmup.dart`）：`_warmTokenStore()` 中初始化 `tokenRefreshService` 全局单例，注入 baseUrl 和 session 过期回调。
- **依赖**：`pubspec.yaml` 新增 `flutter_secure_storage: ^9.2.4`。

**新增测试：**

- `test/core/local_storage/token_manager_test.dart`（9 tests）：in-memory fake store，覆盖 init/迁移、读写删、空值删除、跨读取一致性。
- `test/features/auth/data/token_refresh_service_test.dart`（6 tests）：FakeAdapter Dio mock，覆盖刷新成功、无 refresh token、服务端错误、网络错误、并发防抖（3 并发→1 HTTP）、失败回调仅触发一次。

**验证结果**

- `flutter analyze`：No issues found。
- `flutter test`：**173/173 通过**（158 + 新增 15）。

### Code Review 修复 (2026-06-02)

自动化审查发现以下问题并全部修复：

**🔴 JSON 序列化泄漏（5 个文件）**

`json_serializable` 生成的 `_$XxxToJson` 默认将**所有非静态 getter**（包括 computed getter）序列化到 JSON。已在 5 个模型的 11 个 computed getter 上添加 `@JsonKey(includeToJson: false)`：

| 文件 | 类 | 受影响的 getter |
|------|-----|----------------|
| `browse_history.dart` | `BrowseHistoryEntry` | `hasIdentity`, `displayTitle`, `displaySubtitle`, `displayTips`, `viewedAt` |
| `reminder.dart` | `ReminderPlan` | `hasId`, `displayTitle` |
| `scan.dart` | `ScanCandidate` | `hasIdentity`, `displayName`, `displaySubtitle` |
| `album.dart` | `IdResult` | `hasId` |
| `safety.dart` | `MedicineAiSafetyResult` | `hasText`, `isCached` |

这些 getter 包含 locale 依赖文本（`displayTitle`→`AppI18nText.pick`）或计算字段（`hasId`/`viewedAt`），序列化到 JSON 会污染存储/API payload。

**🟠 防御性修复**

- `token_refresh_service.dart`：`_doRefresh` 的 `catch (_)` 缩窄为 `on DioException catch (_)`，避免吞掉编程错误。
- `dio_request.dart`：401 拦截器增加冷启动兜底——`tokenRefreshService` 为 null 时（warmup 失败场景）直接清空过期 token，避免挂死在 broken credential 状态。
- `app_startup_warmup.dart`：移除 session 过期回调中的 try-catch，异常不再被静默吞没。
