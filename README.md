# Luminous

[![Backend](https://img.shields.io/badge/Backend-Lucent-3b82f6)](https://github.com/LuoMuLoyal/Lucent)

个人健康管理副驾驶（Personal Health Copilot）—— 从智慧用药起步，逐步走向全人全程健康管理。

当前处于二次开工阶段：主线保留新的五栏骨架、响应式 design token、Lucent OpenAPI 客户端与 Flutter 原生国际化基础设施，后续逐步重建认证、用药、提醒、扫描与更多业务能力。

## 当前基线

- 五栏骨架：`today / record / medicine / mine / more`
- 响应式 design token：颜色、字号、间距、圆角、阴影、断点
- Lucent OpenAPI 客户端：`packages/lucent_openapi`
- 统一网络入口：`lib/core/network/`
- Flutter 原生国际化基础设施：中/英双语最小集已接入

## 快速开始

```bash
flutter pub get
flutter run
```

```bash
flutter analyze
flutter test
```

## 文档

### 共享文档（`Lucent/docs/public/`）

| 文档                                                    | 说明                 |
| ------------------------------------------------------- | -------------------- |
| [Promise](../Lucent/docs/public/Promise.md)             | 产品最终愿景         |
| [ROADMAP](../Lucent/docs/public/ROADMAP.md)             | 产品路线图与当前聚焦 |
| [design-system](../Lucent/docs/public/design-system.md) | 设计 token 规范      |
| [DESIGN](../Lucent/docs/public/DESIGN.md)               | Airbnb 设计语言分析  |
| [api-contract](../Lucent/docs/public/api-contract.md)   | API 规范与信封约定   |
| [data-sources](../Lucent/docs/public/data-sources.md)   | 外部数据源与导入规则 |

### Luminous 专属文档（`docs/`）

| 文档                                                     | 说明                     |
| -------------------------------------------------------- | ------------------------ |
| [Localization](docs/Localization.md)                     | Flutter 原生国际化方案   |
| [OpenApi_Client](docs/OpenApi_Client.md)                 | Lucent OpenAPI 客户端接入 |
| [UI_Implementation_Plan](docs/UI_Implementation_Plan.md) | UI 实现计划与进度        |
| [RestartPlan](docs/RestartPlan.md)                      | 当前重置版的二次开工清单 |
| [multi-platform-plan](docs/multi-platform-plan.md)       | 多端适配计划             |
| [MigrationLog](docs/MigrationLog.md)                     | 架构迁移历史记录         |
| [TODO](docs/TODO.md)                                     | 已知技术债与测试覆盖缺口 |

后端文档在 `Lucent/README.md` 和 `Lucent/docs/` 中。

## License

[Apache License 2.0](LICENSE)
