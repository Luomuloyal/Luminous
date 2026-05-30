# AGENTS.md — Luminous

> Luminous 项目 AI Agent 操作规范

## 项目概览

- **类型**：Flutter 个人健康管理应用
- **状态管理**：Riverpod（禁止 GetX）
- **路由**：GoRouter（禁止 Navigator.push）
- **后端**：Lucent（NestJS + Prisma + PostgreSQL）

## ✅ 可以做

| 场景                      | 说明                                                   |
| ------------------------- | ------------------------------------------------------ |
| 新增业务代码              | 统一放在 `lib/features/` 或 `lib/core/`                |
| 使用自动生成的 API 客户端 | 代码在 `packages/lucent_openapi/`，业务层走 `core/network/` |
| 使用 Riverpod 管理状态    | `flutter_riverpod`                                     |
| 使用 GoRouter 导航        | `context.pushNamed()` 或 GoRoute 注册                  |

## ❌ 禁止事项

| 类别          | 禁止内容                                                                     |
| ------------- | ---------------------------------------------------------------------------- |
| 旧目录加代码  | `lib/pages/`、`lib/stores/`、`lib/viewmodels/`、`lib/components/` 是遗留目录 |
| 引入 GetX     | 已从 pubspec.yaml 移除，使用 Riverpod                                        |
| 绕过 GoRouter | 禁止 `Navigator.push(MaterialPageRoute(...))`                                |
| 提交到 Git    | `DrugDataBase/`、`build/`、`outputs/`、`Roadshow/`、`.env.*`、IDE 配置       |

## 常用命令

```bash
# 提交前必须跑
flutter analyze
flutter test

# 依赖安装
flutter pub get

# API 客户端重新生成
cd ../Lucent && pnpm export:openapi
cd ../Luminous && openapi-generator-cli generate -g dart-dio -i ../Lucent/docs/openapi.json -o lib/api/generated --additional-properties=pubName=luminous_api,pubAuthor=Lumos
cd lib/api/generated && dart pub get && dart run build_runner build --delete-conflicting-outputs
```

## 后端对接规范

- API 契约：`../Lucent/docs/api-contract.md`、`auth-api-mock.md`
- 响应格式：`{ code, message, data }`
- 认证：`Authorization: Bearer <accessToken>`
- token 存储：优先安全存储，回退 `SharedPreferences`
- 网络基础设施统一放 `lib/core/network/`
- `Accept-Language` 请求头由前端 network 层统一注入

## 当前基础设施位置

- OpenAPI 生成客户端：`packages/lucent_openapi/`
- 统一网络入口：`lib/core/network/`
- Flutter 原生国际化：`lib/l10n/` + `l10n.yaml`
- 响应式 design token：`lib/core/design/`

## 本轮踩坑总结

以下错误已经真实发生过，后续不要再重复：

1. **不要把旧状态误判成还可复用**
   旧 auth / reminder / scan / settings 很多实现已经和当前 Lucent 协议、信息架构、UI 方向不兼容。

2. **不要把 network 层放进 `utils/`**
   envelope、鉴权、401 refresh、语言头、token 注入都属于 `core/network/`。

3. **不要继续把 token 只放 `SharedPreferences`**
   移动端优先用 `flutter_secure_storage`，桌面/Web 再回退。

4. **不要新增英文或中文硬编码文案**
   新页面文案必须先进 `arb`，再跑 `flutter gen-l10n`。

5. **不要忘记更新 `pubspec.yaml` 的 `flutter: generate: true`**
   否则 `gen-l10n` 不会生成 `AppLocalizations`。

6. **不要在 import 路径里混入反斜杠转义**
   Dart import 一律用正斜杠，避免出现 `\t`、`\r` 这类隐式转义。

7. **不要让 segmented control 因文案切换导致宽度抖动**
   对会切换的 label 要做等宽约束。

8. **不要在小测试视口里假设页面一定不溢出**
   需要在移动端优先验证单列布局和滚动容器。

9. **不要在文档里继续宣称旧功能“已完成”**
   二次开工阶段的 README / 计划文档必须反映真实现状。

## 提交规范

格式：`type(scope): subject`

常用 type：`feat`、`fix`、`docs`、`refactor`、`test`、`chore`

## 提交前检查清单

- [ ] `flutter analyze` — No issues
- [ ] `flutter test` — 全量通过
- [ ] 未引入 GetX 依赖
- [ ] 新代码在 `lib/features/`、`lib/shared/` 或 `lib/core/`
- [ ] 未提交禁提交的文件

## AI 协作原则

1. **先想再做**：不确定就问，不猜测
2. **简洁优先**：只写解决问题所需的最小代码
3. **精准修改**：不改未损坏的东西
4. **目标驱动**：把任务转成可验证的目标
