# Luminous 项目文档中心

本目录是项目规范、迁移计划、接口对齐和路演材料的归档入口。涉及架构或迁移决策时，优先以这里的文档为准。

## 文档索引

- `RefactorPlan.md`：当前 Flutter 优化、状态迁移和后端演进的主计划。
- `migration_log.md`：GetX/Layer-based 向 Riverpod/GoRouter/Feature-first 迁移的执行记录。
- `lib-docs/`：前后端接口、部署和联调文档。
- `Roadshow/`：路演稿、PPT、截图等参赛材料，暂留且不要清理。
- `privacy-policy.txt`：隐私政策文本。

## 迁移执行约束

- 迁移按小步推进，一次只做一块可验证的状态或结构调整，不追求一口气完成。
- 新增迁移代码要有意识落到目标结构：共享基础能力放 `lib/core/`，跨业务复用 UI 放 `lib/shared/`，业务模块放 `lib/features/`。
- 控制文件规模：单文件最好 300 行以内，300-600 行可接受，超过 600 行时优先拆分再继续扩展。
- 迁移涉及行为变化时，同步更新测试与这里的相关文档。
