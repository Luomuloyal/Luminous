# Luminous 当前迁移记录

最后更新: 2026-05-30

> 本文档只记录 **全量重置之后** 的当前阶段进展。
> 重置前的完整历史档案已移至：
>
> - `docs/MigrationLog_Archive_PreReset.md`

---

## 文档边界

当前推荐阅读顺序：

1. `docs/RestartPlan.md` — 当前阶段总计划
2. `docs/UI_Implementation_Plan.md` — 当前 UI 主线
3. `docs/OpenApi_Client.md` — Lucent OpenAPI 客户端接入
4. `docs/Localization.md` — Flutter 原生国际化
5. `docs/MigrationLog.md` — 当前阶段完成记录

---

## 当前阶段目标

全量重置后的目标不是“恢复旧项目”，而是：

- 在新的五栏骨架上继续开发
- 以 Lucent 作为唯一目标后端
- 先搭稳 design token、network、i18n、auth 基础设施
- 再逐步重建业务页面和数据流

---

## 当前阶段已完成

### 2026-05-30 — 全量重置后的前端基线

- 保留五栏骨架：`today / record / medicine / mine / more`
- 保留 `shell`、`today` 与最小主题结构
- 清理旧业务页面、旧工具类、旧基础设施与旧后端依赖
- 形成最小可运行 Flutter 主线

---

### 2026-05-30 — Lucent OpenAPI 客户端接入

- 使用 Lucent `docs/openapi.json`
- 使用 `dart-dio` 生成器
- 生成代码放入 `packages/lucent_openapi/`
- 主工程通过 `path package` 引用
- 新建 `lib/core/network/lucent_dio_client.dart`
- 新建 `lib/core/network/lucent_api.dart`

结果：

- 主工程不直接依赖生成器目录结构
- 后续可以独立重生成客户端

---

### 2026-05-30 — 响应式设计 token 落地

已新增：

- `lib/core/design/app_color_tokens.dart`
- `lib/core/design/app_radius_tokens.dart`
- `lib/core/design/app_spacing_tokens.dart`
- `lib/core/design/app_shadow_tokens.dart`
- `lib/core/design/app_typography_tokens.dart`
- `lib/core/design/app_layout_tokens.dart`
- `lib/core/design/app_design.dart`
- `lib/core/constants/app_breakpoints.dart`
- `lib/core/theme/app_theme_extensions.dart`

结果：

- 手机 / 桌面 / Web 共享同一套视觉基础
- `Shell`、`Today`、`PlaceholderPage` 已接入

---

### 2026-05-30 — Flutter 原生国际化初始化

- 新增 `l10n.yaml`
- 新增 `lib/l10n/app_zh.arb`
- 新增 `lib/l10n/app_en.arb`
- 接入 `LuminousApp.localizationsDelegates`
- 生成 `AppLocalizations`

当前已切到 `l10n` 的范围：

- App 标题
- Tab 文案
- Today 页主文案
- Placeholder 文案
- Login / Register / AuthShell 文案

结果：

- 前端不再继续扩张硬编码可见文本

---

### 2026-05-30 — Network 基础设施补齐

已新增：

- `lib/core/network/lucent_base_url.dart`
- `lib/core/network/lucent_result_code.dart`
- `lib/core/network/lucent_envelope.dart`
- `lib/core/network/lucent_api_exception.dart`
- `lib/core/network/lucent_session_store.dart`
- `lib/core/network/lucent_network_providers.dart`

关键行为：

- `baseUrl` 统一读取
- envelope 统一解析
- token 注入
- `401002 TOKEN_EXPIRED` 自动 refresh
- refresh 成功后自动重试原请求
- token 存储优先使用安全存储
- `Accept-Language` 自动注入

结果：

- `Dio` 归属正式固定在 `core/network/`

---

### 2026-05-30 — Lucent 后端对齐修正

后端已修正：

- `JwtAuthGuard` 区分：
  - `401001` 无效/缺失 token
  - `401002` token 过期
- Lucent i18n fallback 语言改为 `en`
- `Accept-Language` 约定写入公开 API 文档
- README 中过期的 submodule 说明已清理

结果：

- 前后端对 token 过期处理和语言协商的边界一致

---

### 2026-05-30 — Auth 基础业务接入

已新增：

- `features/auth/domain/entities/auth_session.dart`
- `features/auth/data/mappers/auth_mapper.dart`
- `features/auth/data/datasources/auth_remote_data_source.dart`
- `features/auth/data/providers/auth_data_providers.dart`
- `features/auth/presentation/providers/auth_session_provider.dart`
- `features/auth/presentation/providers/login_form_provider.dart`
- `features/auth/presentation/providers/register_form_provider.dart`

结果：

- auth 已不再停留在 network 层
- 已形成 domain + datasource + provider 的最小闭环

---

### 2026-05-30 — Login / Register 页面落地

已新增：

- `features/auth/presentation/widgets/auth_shell.dart`
- `features/auth/presentation/pages/login_page.dart`
- `features/auth/presentation/pages/register_page.dart`

已接入：

- `router.dart` 新增 `/login`、`/register`
- `TodayPage` 增加登录 / 注册 / 退出入口
- 登录页密码 / 验证码切换器已固定宽度
- 密码提示改为输入框内部 `hint/helper` 风格统一

结果：

- auth 页面已具备最小可用版本
- 响应式 auth 布局已成型

---

### 2026-05-30 — 响应式壳层基础推进

已新增：

- `lib/core/widgets/responsive_content_frame.dart`
- `lib/core/widgets/page_scaffold_shell.dart`

已完成：

- `Shell` 手机端使用底部 `NavigationBar`
- `Shell` 桌面 / Web 宽屏使用 `NavigationRail`
- `TodayPage` 切到 `PageScaffoldShell`
- `record / medicine / mine / more` 切到 `PageScaffoldShell`

结果：

- 五栏页面开始共享统一页面壳层
- 多端布局基础从 token / shell 进一步推进到页面级结构

---

## 当前基线验证

截至本次记录，以下验证通过：

```bash
flutter gen-l10n
flutter analyze
flutter test
```

以及：

```bash
cd ../Lucent
pnpm build
pnpm test
```

---

## 当前未完成

仍未进入主线实现的内容：

- 完整的 auth 页面校验与跳转流
- Today 卡片正式拆分
- record / medicine / mine / more 的真实骨架页
- medicine / reminder / scan 的业务页面重建
- Lucent medicine API 对接

---

## 下一步建议

推荐顺序：

1. 细化 `Today` 的 section 组件
2. 给 `Today` 建 mock provider
3. 提升 `record / medicine / mine / more` 的空骨架质量
4. 再继续 medicine / reminder 业务重建
