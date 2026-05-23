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
