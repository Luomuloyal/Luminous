# Luminous

[![Backend](https://img.shields.io/badge/Backend-Lucent-3b82f6)](https://github.com/LuoMuLoyal/Lucent)

个人健康管理副驾驶（Personal Health Copilot）—— 从智慧用药起步，逐步走向全人全程健康管理。

当前提供药品识别与查询、用药提醒、打卡记录、AI 安全辅助，下一阶段重点为权威药品知识库驱动、Markdown 详情展示、AI 健康副驾驶。

## 功能

- 今日页：喝水追踪、用药提醒、健康快照、饮食建议、环境提醒、Lumi AI 建议
- 药品搜索、扫码识别、药品详情
- 用药提醒、打卡记录、服药反应记录
- AI 用药安全辅助
- 识别相册与浏览历史
- 多主题与深浅色模式

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
| [UI_Implementation_Plan](docs/UI_Implementation_Plan.md) | UI 实现计划与进度        |
| [multi-platform-plan](docs/multi-platform-plan.md)       | 多端适配计划             |
| [MigrationLog](docs/MigrationLog.md)                     | 架构迁移历史记录         |
| [TODO](docs/TODO.md)                                     | 已知技术债与测试覆盖缺口 |

后端文档在 `Lucent/README.md` 和 `Lucent/docs/` 中。

## License

[Apache License 2.0](LICENSE)
