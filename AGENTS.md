# AGENTS.md — Luminous

> 面向 AI agent 的项目专属约束与操作指南。每次对话发现的错误应追加到文件末尾的踩坑记录中。

---

## 项目结构

Luminous 是一个 Flutter 个人健康管理应用，当前架构：

```
lib/
├── core/                  # 全终端共享底座
│   ├── network/           # HTTP 请求与拦截器（Dio）
│   ├── theme/             # 主题与装饰
│   ├── local_storage/     # Isar / SharedPreferences / SecureStorage
│   ├── router/            # GoRouter 路由表
│   └── l10n/              # 国际化语言包
├── shared/                # 跨业务共享模块
│   ├── widgets/           # 全局通用 UI
│   └── layout/            # 响应式布局（AppWindowClass / AdaptiveScaffold）
└── features/              # 业务模块（Feature-first，高内聚）
    ├── auth/              # 登录、注册、会话管理
    ├── medicine/          # 药品搜索、扫码、数据库查询
    ├── reminders/         # 用药打卡、日历
    ├── drug/              # 药品详情
    ├── checkin/           # 打卡记录
    ├── scan/              # 扫码识别
    ├── album/             # 识别相册
    ├── home/              # 首页
    ├── settings/          # 设置
    ├── safety/            # AI 安全辅助
    ├── mine/              # 个人中心
    ├── login/             # 登录页
    ├── register/          # 注册页
    ├── medicine_picker/   # 药品选择器
    └── legal/             # 法律文本
```

- 状态管理：**Riverpod**（已完成 GetX → Riverpod 迁移）
- 路由：**GoRouter**
- 后端目标：**Lucent**（`../Lucent/`，NestJS + Prisma + PostgreSQL）

---

## 常用命令

```bash
# Flutter
flutter pub get          # 安装依赖
flutter analyze          # 静态分析（提交前必须跑）
flutter test             # 全量单元测试（提交前必须跑）
flutter run              # 启动应用

# 后端（Lucent）
pnpm --prefix ../Lucent test        # Lucent 单元测试
pnpm --prefix ../Lucent test:e2e    # Lucent e2e 测试
pnpm --prefix ../Lucent start:dev   # Lucent 开发模式
```

---

## 禁止事项

### 永远不要提交到 Git

| 类别 | 路径 / 模式 |
|------|------------|
| 大型外部数据集 | `DrugDataBase/` — 包含 zip/xml/sdf/fasta/xlsx，仅本地使用 |
| 构建产物 | `build/`、`android/build/`、`backend/dist/` |
| 本地依赖 | `backend/node_modules/` |
| 演示输出 | `outputs/`、`Roadshow/`、`*.pptx` |
| IDE 个人配置 | `.idea/`、`.vscode/*`（除 `extensions.json` 和 `settings.json` 外） |
| 真实环境变量 | `backend/.env.development`、`backend/.env.production` |
| Flutter SDK 状态 | `.flutter`、`.flutter_tool_state` |

### 代码约束

- **不要往旧目录加新代码**：`lib/pages/`、`lib/stores/`、`lib/viewmodels/`、`lib/components/` 是 Layer-based 遗留目录，仅保留兼容导出壳。所有新代码必须落在 `lib/features/`、`lib/shared/` 或 `lib/core/`。
- **不要重新引入 GetX**：已从 pubspec.yaml 移除。使用 Riverpod (`flutter_riverpod`)。
- **不要绕过 GoRouter**：禁止 `Navigator.push(MaterialPageRoute(...))`，统一使用 `context.pushNamed()` 或 GoRoute 注册。

---

## 后端对接

- 目标后端是 **Lucent**（`../Lucent/`），NestJS + Prisma v7 + PostgreSQL。
- API 契约文档位于 `../Lucent/docs/`，以 `api-contract.md` 和 `auth-api-mock.md` 为准。
- 响应格式统一为 `{ code, message, data }`。
- 认证方式：`Authorization: Bearer <accessToken>`，token 管理由 `lib/core/network/` 下的 `TokenManager` 和 `TokenRefreshService` 负责。

---

## 提交前检查清单

- [ ] `flutter analyze` — No issues
- [ ] `flutter test` — 全量通过
- [ ] 未引入新的 GetX 依赖
- [ ] 新代码未落入 `lib/pages/`、`lib/stores/` 等旧目录
- [ ] 未提交 `DrugDataBase/`、构建产物、env 文件

---

## 通用 AI 协作原则

> 以下为补充性的通用原则，优先级低于上述项目专属约束。

### 1. 先想再做

- 不确定时主动说明假设、提出多种理解、指出更简单的替代方案。
- 有困惑就停下来问，不要猜测。

### 2. 简洁优先

- 只写解决问题所需的最小代码。
- 不添加未要求的功能、不为单次使用创建抽象、不处理不可能发生的错误。
- 200 行能解决的问题写 50 行就重写。

### 3. 精准修改

- 不改相邻代码、注释或格式。不重构未损坏的东西。
- 只清理你自己的修改产生的孤立 import/变量/函数。
- 发现无关的死代码可以提，但不要动手删。

### 4. 目标驱动

- 把任务转成可验证的目标（"添加验证" → "先写测试再让它通过"）。
- 多步骤任务先列计划，每步明确验证方式。

---

## 踩坑记录

> 以下为 AI agent 在本项目中犯过的错误。每次对话发现的新错误请追加到此区域。

### 模板

```markdown
### N. 错误简述

**错误**：具体做了什么

**正确**：应该怎么做

**教训**：如何避免
```

（暂无记录 — 有新踩坑时按模板追加）
