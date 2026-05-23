
# Luminous 架构重构及迁移记录

该文档记录 Luminous 从基于 GetX/Layer-based 迁移向 Riverpod/GoRouter/Feature-first 架构的历程，用以为长期项目维护提供清晰的追踪。

## 已完成阶段 (Phase 1: 基础设施注入与核心配置解耦)
1. **清理文档结构**
   - 移除无用的 Study/，整合根目录分散文档。
   - 所有规约和沉淀性 Markdown 归档入 docs/。

2. **核心包引入**
   - 引入 lutter_riverpod 和 iverpod_annotation 作为新一代状态管理。
   - 引入 go_router 替代原生的与 Get 一体化的路由机制。

3. **入口与根状态改造**
   - 在 lib/main.dart 和 lib/startup/app_startup_warmup.dart 完成 SharedPreferences 的预加载，消除此前的首页白屏等待。
   - 将应用顶层替换为 ProviderScope 以承载全局状态。
   - 实现并注入 lib/router/app_router.dart，使用 MaterialApp.router 构建标准原生的 GoRouter 体系。

4. **解耦 Theme 与 Locale 配置 (改写 SettingsPage)**
   - 编写了原生的 Riverpod Provider ( 	hemeProvider, localeProvider ) 持久化存储主题、深浅模式及多语言设定。
   - 将 lib/pages/Settings/settings.dart 页面中的组件由 StatelessWidget 系统平滑替换到 ConsumerWidget。
   - 移除了该页面对 ThemeController 与 LocaleController 的 Obx 与 Get.find 依赖。
   - 修复相关受影响的 Smoke Tests (settings_page_smoke_test.dart)，已达到全单元测试依然全部 Pass 的里程碑基准。

## 下一步工作 (TODO)
- [ ] **状态迁移继续**
      逐步将 UserController、OrnamentController 等高频但单一的数据剥离为 Riverpod Notifier。
- [ ] **网络层替换**
      探索通过 Dio + Riverpod 结合的方式，完全根除对 GetConnect 的底层代码依赖。
- [ ] **目录结构改造**
      将现在的 lib/pages、lib/stores 等 Layer-based 分包形式，安全过渡为 lib/features 或 lib/core 的 Feature-first 分包机制。
- [ ] **Isar 结构优化**
      如果将来涉及本地相册和模型缓存结构重构，将其剥离至对应业务的 Data Repository 层。

