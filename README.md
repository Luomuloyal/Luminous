# Luminous

[![Backend](https://img.shields.io/badge/Backend-Lucent-3b82f6)](https://github.com/LuoMuLoyal/Lucent)

个人健康管理副驾驶（Personal Health Copilot）—— 从智慧用药起步，逐步走向全人全程健康管理。

当前提供药品识别与查询、用药提醒、打卡记录、AI 安全辅助，下一阶段重点为权威药品知识库驱动、Markdown 详情展示、AI 健康副驾驶。

## 功能

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

| 文档 | 说明 |
|------|------|
| [Promise](docs/Promise.md) | 产品最终愿景 |
| [ROADMAP](docs/ROADMAP.md) | 功能路线图与优先级 |
| [RefactorPlan](docs/RefactorPlan.md) | 架构重构方向与红线 |
| [ExecutionPlan](docs/ExecutionPlan.md) | 当前顺序执行步骤 |
| [MigrationLog](docs/MigrationLog.md) | 迁移历史记录 |
| [TODO](docs/TODO.md) | 已知待修复问题 |

后端相关文档在 `Lucent/` 和 `backend/` 各自的 README 中。

## License

[Apache License 2.0](LICENSE)
