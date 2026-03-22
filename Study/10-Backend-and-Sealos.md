# 10 后端与 Sealos

## 这个功能是干什么的

这一部分讲的是当前 `backend/` 的正式代码结构、Flutter API 和后端 handler 的对应关系，以及如何把云函数 bundle 上传到 Sealos。

## 用户从哪里进入 / 如何触发

- Flutter 页面通过 `lib/api/*.dart` 发起请求
- 本地调试可走 Express `backend/src/app.ts`
- Sealos 云函数走 `backend/src/cloud/*.ts`

## 关键页面、组件、API、store、backend、native 文件

- Express 应用：`backend/src/app.ts`
- 路由注册：`backend/src/routes/api.ts`
- 环境变量：`backend/src/config/env.ts`
- 药品查询：`backend/src/db/medicine-repository.ts`
- 5 个核心 handler：
  - `backend/src/handlers/medicine-search.ts`
  - `backend/src/handlers/medicine-detail.ts`
  - `backend/src/handlers/medicine-ai-detail.ts`
  - `backend/src/handlers/medicine-ai-safety.ts`
  - `backend/src/handlers/medicine-scan.ts`
- 云函数入口：
  - `backend/src/cloud/medicine-search.ts`
  - `backend/src/cloud/medicine-detail.ts`
  - `backend/src/cloud/medicine-ai-detail.ts`
  - `backend/src/cloud/medicine-ai-safety.ts`
  - `backend/src/cloud/medicine-scan.ts`

## 核心实现路径

### UI 入口

- Flutter 侧统一由 `lib/api/medicine_api.dart`、`lib/api/safety_api.dart`、`lib/api/scan_api.dart` 调用

### 状态来源

- handler 自己做参数校验和响应包装
- `medicine-repository.ts` 负责查询 MySQL

### 网络 / 本地存储 / 后端流转

- Express 路由把 `POST /xxx` 交给 handler
- Sealos 云函数入口只做 `ctx.body -> handler` 转发
- AI 相关 handler 再调 `ai/doubao-client.ts`

### 结果如何回到 UI

- 所有接口最终都返回统一 `ApiEnvelope`
- Flutter 侧 `DioRequest` 再把 `result` 解码成 viewmodel

## 当前已实现的 5 个接口对应关系

| 接口 | Flutter API | handler | cloud 入口 | bundle |
| --- | --- | --- | --- | --- |
| `/medicine-search` | `lib/api/medicine_api.dart:15` | `backend/src/handlers/medicine-search.ts:7` | `backend/src/cloud/medicine-search.ts:3` | `backend/dist/cloud-bundle/medicine-search.js` |
| `/medicine-detail` | `lib/api/medicine_api.dart:48` | `backend/src/handlers/medicine-detail.ts:7` | `backend/src/cloud/medicine-detail.ts:3` | `backend/dist/cloud-bundle/medicine-detail.js` |
| `/medicine-ai-detail` | `lib/api/medicine_api.dart:86` | `backend/src/handlers/medicine-ai-detail.ts:9` | `backend/src/cloud/medicine-ai-detail.ts:3` | `backend/dist/cloud-bundle/medicine-ai-detail.js` |
| `/medicine-ai-safety` | `lib/api/safety_api.dart:15` | `backend/src/handlers/medicine-ai-safety.ts:31` | `backend/src/cloud/medicine-ai-safety.ts:3` | `backend/dist/cloud-bundle/medicine-ai-safety.js` |
| `/medicine-scan` | `lib/api/scan_api.dart:16` | `backend/src/handlers/medicine-scan.ts:34` | `backend/src/cloud/medicine-scan.ts:3` | `backend/dist/cloud-bundle/medicine-scan.js` |

## 关键代码位置

- `backend/src/app.ts:21`
  创建 Express 应用。
- `backend/src/routes/api.ts:9`
  注册 5 个药品相关 POST 路由。
- `backend/src/config/env.ts:21`
  统一读取环境变量。
- `backend/src/db/medicine-repository.ts:59`
  关键词搜索药品。
- `backend/src/db/medicine-repository.ts:92`
  按 `drugCode/approvalNo` 查详情。
- `backend/src/db/medicine-repository.ts:164`
  识别候选回查。

## 容易忽略的实现细节

- `backend/src/cloud/*` 很薄，真正业务逻辑都在 `handlers/*`
- `medicine-scan` 当前不会在服务端生成缩略图，而是让 Flutter 本地兜底
- 当前 `backend/` 只正式整理了 5 个药品相关接口，App 其他接口仍要参考 `BackendMd/`

## 如果以后要改，优先改哪里

- 改协议或字段：先改 `handlers/*`，再同步 Flutter `api/*` 和 `viewmodels/*`
- 改部署方式：`handlers/*` 尽量不动，主要改 `cloud/*` 或 Express 入口
- 改 Sealos 打包：看 `backend/scripts/bundle-cloud.mjs` 和 `backend/README.md`

## 相关测试在哪

- 当前仓库没有后端单元测试
- 本轮至少验证过 `backend/` 的 `npm run build`
