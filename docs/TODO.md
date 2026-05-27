---
title: "Luminous 待办事项"
tags:
  - todo
  - tech-debt
aliases:
  - TODO
  - 待办
created: 2026-06-03
---

# Luminous 待办事项

最后更新: 2026-06-03

本文档汇总五轮代码审查中已确认但暂不修复的问题，以及测试覆盖缺口。按类别和优先级排序。

---

## 性能

| # | 问题 | 位置 | 影响 | 建议 |
|---|------|------|------|------|
| 1 | 16 处 `ListView(children: [...])` 未用 `ListView.builder` | 多个 feature 页面 | 列表数据量增长后滚动性能下降 | 逐文件替换为 `ListView.builder` + `itemExtent`，优先处理搜索结果列表、药品列表、提醒列表 |

---

## 导航

| # | 问题 | 位置 | 影响 | 建议 |
|---|------|------|------|------|
| 2 | 多处 `Navigator.push(MaterialPageRoute(...))` | 药品详情跳转、设置子页等 | 绕过 GoRouter 的 URL 同步和历史栈管理，认证拦截失效 | 统一改用 `context.pushNamed()` 或为子页注册 GoRoute |
| 3 | Theme / Language 设置子页无独立 GoRoute | settings feature | 同上，但部分子页作为模态子页是合理的 | 评估哪些子页需要独立 URL，注册路由；纯模态保持现状 |

---

## 国际化

| # | 问题 | 位置 | 影响 | 建议 |
|---|------|------|------|------|
| 4 | `medicine_ai_card.dart` 中文 section headers 和 `endsWith('建议')` 硬编码 | drug feature | 非中文 locale 下 AI 解析逻辑完全失效 | AI 返回结构化 JSON 替代自由文本，或做 locale-aware 解析；短期可先加 fallback |

---

## 架构

| # | 问题 | 位置 | 影响 | 建议 |
|---|------|------|------|------|
| 5 | `global_provider_container.dart` 全局容器 | `lib/core/providers/` | 4 个非 widget 工具类绕过 Riverpod 树层级，破坏 DI 可测试性 | 重构为构造函数 DI 注入，删除全局容器；过渡期可保留但不再新增引用 |
| 6 | 4 个 `AsyncNotifierProvider` 返回裸 `List<T>`，无 State wrapper | reminders / checkin / search / home | 与其余 12 个 provider 风格不一致，扩展时需额外处理 loading/error | 统一加 `XxxState` wrapper（含 `items`、`isLoading`、`errorMessage`） |
| 7 | `BASE_URL` 默认值 `https://devluo.com` 硬编码 | `lib/core/network/` | 生产地址泄露到源码，且不可通过环境切换 | 通过 `--dart-define` 注入，或从 `.env` / CI/CD 变量读取；源码默认值改为空或 localhost |

---

## 测试覆盖缺口

以下 feature 完全无专属测试或缺少关键 provider test：

| # | Feature | 缺失 | 优先级 |
|---|---------|------|--------|
| 8 | `drug/` | 完全无专属测试 | 高 — 药品是核心功能 |
| 9 | `home/` | 无 `home_provider_test.dart` | 高 — 首页是入口 |
| 10 | `login/` | 无 `login_provider_test.dart` | 高 — 认证是关键路径 |
| 11 | `album/` | 无 `album_provider_test.dart` | 中 |
| 12 | `medicine_picker/` | 完全无专属测试 | 中 |
| 13 | `legal/` | 完全无专属测试 | 低 — 纯静态页面 |
