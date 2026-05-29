---
title: "Luminous 当前聚焦执行版"
tags:
  - execution
  - strategy
  - focus
aliases:
  - 当前执行版
  - 聚焦执行版
created: 2026-05-27
---

# Luminous 当前聚焦执行版

最后更新: 2026-05-27

## 这份文档是做什么的

这不是收缩愿景，也不是否定 [[Promise]]。

这份文档的作用只有一个：在当前重构阶段，给项目一条**能持续推进、能验证结果、能积累信心**的主线。

原则：

1. [[Promise]] 继续作为长期北极星保留。
2. 当前只聚焦“用药闭环”主线，不并行铺开更多健康维度。
3. 其余方向统一使用“暂缓”而不是“放弃”。
4. 每个阶段必须有可验证结果，不能只停留在设计和文档层。

---

## 当前判断

项目不是推倒重来的状态，而是“前端基座基本成型、后端与数据主线还没接上”的状态。

### 当前已有资产

- Flutter 前端结构已经完成一轮比较完整的重构，feature-first + Riverpod + GoRouter 主线已经立住
- 首页、搜索、药品详情、提醒、打卡、扫码、相册、登录注册、设置等核心页面都已存在
- 本地缓存、本地提醒、本地打卡、相册本地资产这几条能力已经可复用
- `Lucent` 已经建起 NestJS + Prisma + JWT 的目标骨架
- `Promise`、`ROADMAP`、`ExecutionPlan` 这几层文档关系已经基本清晰

### 当前真正的卡点

- Flutter 仍主要依赖 legacy Express 接口
- `Lucent` 目前仍以 health/auth 为主，药品主数据和用户业务接口未接完
- `DrugDataBase/FullDrugDetail.xlsx` 还没有进入 PostgreSQL 主查询链路
- AI 仍没有完全退回到“解释层”，事实层还没有全部交给权威药品数据
- 当前测试基线有轻微漂移，GoRouter 迁移后有少量测试未同步

---

## 当前阶段唯一主线

> 先把“搜索药品 → 查看真实详情 → 加入我的药品 → 设置提醒 → 今日打卡 → 记录用药反应”做成可信、稳定、可演示、可继续扩展的闭环。

这条主线完成后，项目就会从“一个很有潜力的完整项目”进入“一个站得住的产品雏形”。

---

## 暂缓原则

以下方向都保留在愿景里，但当前阶段统一暂缓启动：

- 女性健康
- 情绪与心理量表
- 家庭协作
- 环境提醒
- 手表 / 桌面 / Web 差异化扩展
- 医生分享链接
- 筛查 / 疫苗 / 专科档案
- 主动建议流
- OCR 深度导入
- 智能硬件接入

暂缓的含义是：

- 文档保留
- 数据模型可以提前思考
- 不进入当前开发排期
- 不占用当前验收资源

---

## 顺序执行

## Milestone 0：先把基线拉平

目标：

- 让“当前项目状态”重新可信，避免文档与代码继续漂移

要做的事：

- 修复 Flutter 当前 3 个失败测试
- 确认 `flutter analyze` 与 `flutter test` 恢复全绿
- 补齐 Lucent 本地 `.env` 与测试环境说明
- 让 `pnpm test:e2e` 至少能稳定跑过 health 基线

验收标准：

```bash
cd Luminous
flutter analyze
flutter test

cd ../Lucent
pnpm test
pnpm test:e2e
pnpm build
```

完成定义：

- 文档里的“当前状态”与真实代码一致
- 前端测试失败不再挂在主线外面
- 后端 e2e 不再因为环境缺失而失败

---

## Milestone 1：稳住 Lucent 协议与认证边界

目标：

- 明确以后所有新后端能力都以 `Lucent` 为准

要做的事：

- 固化 `/api/v1` 路由规范
- 完成 auth 主链路的自测和 e2e：register / login / refresh / me / logout
- 明确 JWT 派生用户身份，不再以 body/query `userId` 作为授权边界
- 将 login rate limit 从内存方案标记为后续 Redis 化事项，但先保持接口行为稳定

验收标准：

- `Lucent/docs/api-contract.md` 与实际返回一致
- auth e2e 覆盖成功、失败、无 token、错 token、refresh 失败
- Flutter 端新 client 可以稳定解析 Lucent envelope

完成定义：

- 新后端不再只是“方向正确”，而是“第一块可依赖地基”

---

## Milestone 2：药品知识库先做 sample import

目标：

- 不追求一步导完 20 万条，先建立“可重复导入、可解释结果”的数据通路

要做的事：

- 在 `Lucent` 建立 staging 层 schema
- 从 `FullDrugDetail.xlsx` 做字段探测
- 先导入小样本，验证字段映射、空值规则、重复规则、编码规则
- 输出 source row / imported row / rejected row / sample errors

验收标准：

- sample import 可重复执行
- 导入日志可读
- 原始数据不进入 Git
- 代码中没有把知识库塞回 Flutter assets

完成定义：

- 数据迁移从“想法”进入“可运行脚手架”

---

## Milestone 3：Lucent 提供真实药品搜索与详情

目标：

- 用数据库驱动药品事实，不再主要依赖本地样例和 AI 文本

要做的事：

- 建立 medicine search/detail API
- 返回结构化字段：名称、厂家、批准文号、章节、来源信息
- 同时返回 `detailMarkdown`
- 优先支持名称、厂家、批准文号；条码/本位码放在字段准备充分后接入

验收标准：

- `search` 和 `detail` 有 contract tests / e2e
- 空结果、错误结果、分页结果都可验证
- AI 详情不再充当药品事实主来源

完成定义：

- 药品事实层第一次真正落到新后端

---

## Milestone 4：Flutter 搜索与详情切到 Lucent

目标：

- 把用户最能感知的“查药”路径切到新数据源

要做的事：

- Flutter 新增 feature flag 或清晰配置切换 Lucent
- 搜索页改走 Lucent medicine search
- 药品详情页改走 Lucent detail
- 页面展示结构化 sections + Markdown 详情
- 保留短期 fallback，仅用于联调与回滚

验收标准：

- 搜索、详情、空态、错误态、分页能跑通
- `lib/assets/data.json` 只保留开发兜底职责
- 不再把本地样例当成主产品数据源

完成定义：

- “查药”从演示态进入真实产品态

---

## Milestone 5：把用药闭环切到 Lucent

目标：

- 让“我的药品 / 提醒 / 打卡 / 扫码记录”都绑定到用户身份

建议顺序：

1. 我的药品
2. 提醒列表与提醒编辑
3. 今日提醒 / 打卡记录
4. 扫码记录

要做的事：

- Flutter 请求不再主动传授权意义上的 `userId`
- 本地 SQLite 从“主数据源”降级为“离线缓存 / 同步辅助层”
- 新用户登录后，可以完整走一条自己的闭环路径

验收标准：

- 登录后可搜索药品、加入我的药品、创建提醒、今日打卡、查看记录
- 跨用户越权请求在后端被拦住
- 本地缓存不会污染另一个用户的数据

完成定义：

- 项目完成第一阶段真正闭环

---

## Milestone 6：AI 重定位为解释层

目标：

- 保留 AI 的价值，但不让 AI 承担药品事实真相

要做的事：

- 药品详情中的事实字段只来自知识库
- AI 只做解释、翻译、总结、提醒、对比
- 安全能力优先规则化，再由 AI 做通俗化说明
- 输出统一走 Markdown 渲染

验收标准：

- AI 失败时，基础详情仍然完整可用
- AI 输出不覆盖数据库已有事实字段
- UI 上清楚区分“药品事实”和“AI 解释”

完成定义：

- AI 从风险点变成增强层

---

## 当前阶段不做什么

为了让项目持续进步，当前阶段不做以下并行扩张：

- 不一边接新后端，一边继续大面积扩张新健康维度
- 不在 legacy Express 里继续落新主线功能
- 不为了兼容旧接口而拖慢 Lucent 协议清晰度
- 不让 AI 继续承担结构化药品事实生成
- 不同时推进多终端差异化大改版

---

## 建议节奏

如果按稳步推进的节奏，建议顺序是：

1. 第 1 周：Milestone 0
2. 第 2 周：Milestone 1
3. 第 3-4 周：Milestone 2
4. 第 5-6 周：Milestone 3 + 4
5. 第 7-8 周：Milestone 5
6. 闭环稳定后：Milestone 6

说明：

- 如果某个阶段验证不过，不进入下一个阶段
- 每完成一个 milestone，都更新 [[MigrationLog]] 或新增阶段记录
- 每次只让一个核心风险源处于“正在变化”状态

---

## 当前阶段完成标志

当以下条件同时成立，可以认为当前重构阶段的第一目标完成：

- Flutter 前端测试与分析稳定
- Lucent e2e 基线稳定
- 药品搜索与详情使用 Lucent + PostgreSQL
- 我的药品 / 提醒 / 打卡 / 扫码记录切到 JWT 用户边界
- AI 退回解释层

到那时，再进入 [[ROADMAP]] 的第二阶段，会更加稳，也更配得上 [[Promise]]。
