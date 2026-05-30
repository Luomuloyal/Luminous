---
title: "Luminous 二次开工清单"
tags:
  - execution
  - restart
  - strategy
aliases:
  - 二次开工
  - RestartPlan
created: 2026-05-30
---

# Luminous 二次开工清单

最后更新: 2026-05-30

## 文档目的

这份文档服务于当前这版“重置后的干净骨架”。

它的目标不是回退到旧项目继续修补，而是：

1. 以当前 `build(app): 全量重置` 之后的代码为主线继续开发。
2. 把旧项目降级为“参考素材库”。
3. 明确哪些历史提交值得参考，参考什么，不参考什么。
4. 给接下来 2-3 周一个稳定、能持续推进的启动顺序。

---

## 当前结论

在“认证、提醒、用药、拍照、主题、设置、页面结构都需要重做”的前提下：

- **主线保留当前重置版**
- **旧项目不整仓回退**
- **旧提交只做定向参考**

原因：

- 旧项目的很多核心逻辑已经和新的后端协议、信息架构、视觉目标不一致
- 当前重置版已经把产品结构改成更贴近最终愿景的五栏：`today / record / medicine / mine / more`
- 现在真正需要的是“第二次正确开始”，不是“把旧实现再搬回来”

---

## 参考提交总表

以下提交允许作为参考，但默认**不直接恢复整仓**。

### A. `acb3db2` — `feat(today): 完成今日页面及mock数据`

**用途：**

- 参考 Today 页的模块拆分方式
- 参考卡片粒度
- 参考文案结构与页面节奏
- 参考 `UI_Implementation_Plan.md` 的阶段拆法

**适合借鉴的内容：**

- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/today/presentation/widgets/*`
- `lib/shared/widgets/today/*`
- `docs/UI_Implementation_Plan.md`

**只借思路，不直接照搬的部分：**

- mock 数据结构
- 旧常量组织方式
- 已经依赖旧主题 token 的视觉参数
- 任何假设旧后端接口仍可沿用的逻辑

**结论：**

- 这是当前最重要的 UI 参考提交

---

### B. `c93fb46` — `refactor(ui): 删除全局装饰器`

**用途：**

- 作为“什么不该再带回来”的边界参考
- 核对哪些 ornament / soft banner / 全局装饰系统已经被移除

**适合借鉴的内容：**

- 删除范围本身
- 页面在失去 ornament 后仍能成立的最小视觉依赖

**不要借回来的内容：**

- `ornament_provider`
- `shared/widgets/ornaments/*`
- `soft_banner_ornaments`
- 旧 settings 中围绕装饰预览展开的设计

**结论：**

- 这是“防回潮参考提交”
- 主要用来提醒自己不要把旧全局装饰体系重新带回主线

---

### C. `61c666a` — `refactor(shell): 将自定义tab简化为自带tab`

**用途：**

- 参考轻量化底部导航思路
- 参考简化后的主壳结构

**适合借鉴的内容：**

- tab 切换最小实现
- “先用系统组件跑通，再逐步定制”的做法

**不要借回来的内容：**

- 旧 `main_shell` 相关 ornament
- 旧首页入口命名与信息结构

**结论：**

- 这是当前 shell 设计的思路来源
- 可以继续借它的“先简单、后定制”原则

---

### D. `34ef7b0` — `feat(api): 生成OpenApi Dio 客户端代码`

**用途：**

- 只作为“未来接 Lucent OpenAPI 时的流程参考”

**适合借鉴的内容：**

- 生成客户端的流程
- OpenAPI 驱动的接口组织思路

**当前不要恢复的内容：**

- 旧生成代码整包
- 和当前重置版不一致的 API 封装方式

**结论：**

- 不是现在第一优先级
- 等 Lucent API 稳定后再参考

---

## 明确不回滚的内容

以下内容当前阶段不建议整包恢复：

- 旧 `auth/` 前端流程
- 旧 `reminders/` 数据层
- 旧 `drug/` 和 `medicine_detail` 页面逻辑
- 旧 `scan/` 的 base64 上传方案
- 旧 `settings/` 页面和主题预览结构
- 旧 `global constants` / `utils` 大杂烩
- 旧 `shared/widgets` 中的大量视觉基础件
- 旧 `home/` 体系

原因不是它们写得差，而是它们已经不再代表你现在想做的产品边界。

---

## 二次开工总原则

1. 当前骨架优先，只补不回退。
2. 旧提交只允许“按文件、按组件、按思路”借鉴。
3. 新功能默认按新 feature 结构落地，不再向旧命名妥协。
4. 没有后端契约的逻辑，先用 mock domain model，不直接复活旧 API。
5. 视觉系统先搭最小可用版本，不提前重建整套复杂 design system。

---

## 第一阶段：把当前骨架补成“可开工底座”

目标：

- 让当前重置版从“空骨架”变成“能承接持续开发的主线”

### 任务 1：修复最小基线

要做的事：

- 修复 `test/widget_test.dart` 缺少 `ProviderScope` 的问题
- 确认 `flutter analyze` 和 `flutter test` 全绿
- 将 `TodayPage` 真正接入当前 shell，而不是继续显示 `PlaceholderPage('今日')`

验收标准：

```bash
flutter analyze
flutter test
```

---

### 任务 2：清理文档漂移

要做的事：

- 更新 `README.md`
- 更新 `docs/UI_Implementation_Plan.md`
- 标明哪些能力已经删除，哪些是计划重建

验收标准：

- 文档不再宣称当前项目“药品搜索、扫码、提醒、认证都已可用”

---

### 任务 3：定义新的最小主题层

要做的事：

- 保留当前 `AppTheme` 的简单结构
- 新建基础 token：颜色、圆角、间距、字体层级
- 暂不恢复旧的复杂 `shared/design_tokens`

参考提交：

- 看 `c93fb46`，确认不要把 ornament 系统带回来

验收标准：

- 今日页和 Shell 可以共用一套最小 token
- 设置页未来可以复用，而不是再起一套视觉逻辑

---

## 第二阶段：先把 Today 做成真正的新首页

目标：

- Today 成为这次二次开工的第一个完成度最高页面

### 任务 4：重建 Today 页面结构

要做的事：

- 参考 `acb3db2` 的 Today 页面信息分块
- 重新实现而不是直接恢复：
  - 问候头部
  - 喝水卡片
  - 用药提醒卡片
  - 健康快照卡片
  - 饮食建议卡片
  - 环境提醒卡片
  - Lumi 建议卡片

参考提交：

- `acb3db2`

重点参考文件：

- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/today/presentation/widgets/*`
- `lib/shared/widgets/today/*`

不要直接照搬：

- `TodayConstants`
- mock 文案细节
- 旧 shared today widgets 的全部 API

验收标准：

- 页面信息结构贴近五栏愿景图第一屏
- 不依赖全局 ornament
- 不依赖旧 utils 杂项

---

### 任务 5：建立 Today 的新状态层

要做的事：

- 新建 `today` 自己的 domain model
- 新建最小 provider：
  - `todaySummaryProvider`
  - `waterIntakeProvider`
  - `todayMedicationProvider`
- 当前先用 mock repository，不直接连旧 API

参考提交：

- `acb3db2` 只参考字段组织

不参考：

- 旧 `home_provider`
- 旧 `home_demo_data`

验收标准：

- Today 页面不再只是静态 UI
- mock 数据从 widget 内抽离到 provider / repository 边界

---

## 第三阶段：搭好新五栏的页面骨架

目标：

- 五个 Tab 都进入“能独立演进”的状态

### 任务 6：五个一级页面全部替换掉占位页

要做的事：

- `today`：优先完成
- `record`：先做日历 + 时间线的空骨架
- `medicine`：先做今日服药计划骨架
- `mine`：先做档案/目标/隐私分组骨架
- `more`：先做功能分组骨架

参考愿景图：

- 五栏布局图本身

参考提交：

- `61c666a` 只参考壳层简单化思路
- `acb3db2` 参考 Today 的版式节奏

验收标准：

- 五个页面都不是“即将上线”占位文案
- 每个页面具备自己的 feature 目录与最小入口

---

## 第四阶段：把高风险基础能力重新定义

目标：

- 在不复活旧实现的前提下，为后续接 Lucent 做准备

### 任务 7：认证重定义

要做的事：

- 根据 Lucent `/api/v1` 新协议重新设计前端 auth flow
- 不恢复旧登录/注册页逻辑
- 先完成流程设计，再决定页面交互

参考提交：

- 旧 auth 不作实现参考
- 只参考 Lucent 当前 `api-contract` 与 auth 文档

---

### 任务 8：用药与提醒重定义

要做的事：

- 重新定义：
  - medicine search state
  - medicine detail state
  - reminder entity
  - today check-in entity
- 不直接恢复旧 SQLite schema
- 先画新数据模型，再写本地缓存

参考提交：

- 旧 drug/reminder 仅作功能清单参考，不作结构参考

---

### 任务 9：拍照识别链路重定义

要做的事：

- 重新确认图片采集、压缩、上传协议
- 不默认继承旧 base64 方案
- 结合 Lucent 后端能力再决定 multipart / file upload / staged upload

参考提交：

- 旧 `scan` 只作为“用户流程参考”
- 不作为“技术方案参考”

---

## 建议的 2-3 周顺序

### 第 1 周

1. 修复当前测试基线
2. 让 Today 真正接进 shell
3. 清理 README 与 UI 计划文档漂移
4. 建立最小 theme token

### 第 2 周

1. 重建 Today 页面
2. 把 Today 的静态内容拆到 widgets
3. 给 Today 建 mock provider / repository

### 第 3 周

1. 把 record / medicine / mine / more 从 placeholder 升级为空骨架页
2. 写 auth / medicine / reminder / scan 的新数据边界草图
3. 开始准备 Lucent 对接方案

---

## 每周检查问题

每做一周，都问自己这 5 个问题：

1. 我是不是又把旧 feature 整包搬回来了？
2. 我现在写的代码是不是依赖了未来会被废弃的旧协议？
3. 我是不是在 UI 没稳定前就过早重建复杂基础设施？
4. 我是不是把“参考旧提交”误变成了“恢复旧实现”？
5. 当前新增代码是不是在服务最终五栏结构，而不是旧首页思维？

---

## 当前最推荐的起点

如果只选一个立即开始的点：

> 从当前重置版出发，先完成 “任务 1 + 任务 4”，也就是先修基线，再把 Today 做成真正的新首页。

这是最符合你当前判断、也最容易重新建立项目掌控感的开工方式。
