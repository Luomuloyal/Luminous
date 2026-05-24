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

- 在 `docs/RefactorPlan.md` 中新增 `Phase 0`，明确先做目录结构整形和大文件拆分，再恢复更快的产品迁移节奏。
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
- 更新根 `README.md`，移除过时的 `Study/`、`.md/` 目录说明，并把后端说明改为“当前基线 + 目标栈”双轨描述：当前仍是 Express + MongoDB/MySQL/Redis，目标迁移为 NestJS + PostgreSQL，Redis 按需保留。
- 在 `docs/RefactorPlan.md` 中补充后端目标状态：NestJS 作为框架，PostgreSQL 作为主存储，Redis 仅在验证码、缓存和 AI 文本缓存等短生命周期场景按需保留，MongoDB/MySQL 作为迁移源逐步退场。
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
