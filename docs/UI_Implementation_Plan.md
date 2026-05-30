# Luminous UI 实现计划

最后更新: 2026-05-30

> 本文档基于当前“重置后的干净骨架”，服务于二次开工阶段的 UI 重建。

---

## 当前状态

当前不是“旧功能继续打磨”的阶段，而是“在新骨架上重新建立 UI 主线”的阶段。

当前已经具备：

- 五栏骨架：`today / record / medicine / mine / more`
- 响应式 design token
- Lucent OpenAPI 客户端接入
- Flutter 原生国际化基础设施
- Today 占位版首页已接进 shell

当前还没有恢复的内容：

- 认证页面
- 用药闭环页面
- 提醒与打卡页面
- 扫描与上传链路
- 设置页与完整主题页
- 各 feature 的真实数据态

---

## 当前 UI 目标

先把 UI 做成一个能稳定承接产品重建的前端壳层，而不是急着复活旧页面。

现阶段重点：

1. 做稳新的响应式视觉系统
2. 先把 Today 做成真正的新首页
3. 让另外四栏进入可继续演进的空骨架态
4. 再逐步接入 Lucent 数据和业务流程

---

## 第一阶段：设计系统落地

目标：

- 让手机、桌面、Web 共用同一套可扩展的视觉 token

当前已完成：

- 颜色 token
- 字体 token（移动端 / 桌面端双尺度）
- 圆角 token
- 间距 token
- 阴影 token
- 布局 token
- 断点 token
- Theme extension 接入

落点：

- `lib/core/design/`
- `lib/core/theme/`
- `lib/core/constants/app_breakpoints.dart`

下一步：

- 将 shell / today / placeholder 之外的页面骨架逐步迁到同一套 token

---

## 第二阶段：Today 重建

目标：

- Today 成为新的产品入口页

当前已完成：

- 响应式占位版 Today
- 基于 token 的卡面、间距、渐变和标签样式
- 中英双语基础文案

下一步拆分：

1. 问候头部
2. 喝水卡片
3. 用药提醒卡片
4. 健康快照卡片
5. 饮食建议卡片
6. 环境提醒卡片
7. Lumi 建议卡片

参考提交：

- `acb3db2`

注意：

- 只参考模块拆分与节奏
- 不恢复旧 mock 常量组织
- 不恢复旧 shared today 组件 API

---

## 第三阶段：其余四栏骨架

目标：

- 四个一级页面先从“占位提示”升级为“结构骨架”

顺序建议：

1. `record`
2. `medicine`
3. `mine`
4. `more`

每栏第一步只做：

- 页头结构
- 主分组结构
- 一级入口布局
- 响应式宽度与间距

暂不做：

- 完整业务逻辑
- 旧页面复活
- 大量状态管理

---

## 第四阶段：与 Lucent 对接的 UI 准备

目标：

- 在 UI 层为后续接 Lucent 做边界准备

当前约定：

- 网络基础设施统一放 `lib/core/network/`
- 不把协议层逻辑放进 `utils`
- 国际化统一走 Flutter 原生 `gen-l10n`
- 页面只读本地化文案，不自己管理语言文案映射

后续 UI 会优先接入：

1. `auth`
2. `medicine search / detail`
3. `reminder`
4. `today check-in`

---

## 当前不做什么

以下内容当前不进入 UI 主排期：

- 复活旧 `home` / `drug` / `scan` / `settings` 页面
- 恢复旧 ornament / soft banner / 全局装饰体系
- 恢复旧 base64 上传页面流程
- 在 UI 未稳定前提前做重型状态抽象

---

## 验收方式

每次 UI 基础层改动都至少通过：

```bash
flutter analyze
flutter test
```

如果改的是响应式与视觉基础设施，还应额外检查：

- 手机宽度下是否溢出
- 桌面宽度下是否过空
- 文案切换中英时是否破版

---

## 当前最推荐的下一步

如果继续沿 UI 主线推进，建议顺序是：

1. 拆 Today 卡片组件
2. 给 Today 建 mock provider
3. 把 record / medicine / mine / more 从 placeholder 升级为空骨架页
4. 再开始 auth / medicine / reminder 的业务页面重建
