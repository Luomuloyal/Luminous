# 10 后端与 Sealos

## 这一篇最重要的结论

当前仓库里真正“正式整理成代码”的后端，只覆盖了 5 个药品相关接口。

而且这 5 个接口的核心业务都不写在 Sealos 云函数入口里，而是写在 `backend/src/handlers`。

这意味着：

- 你现在继续走 Sealos 云函数没问题
- 你以后迁到云服务器，也不用重写核心业务逻辑

## 这一部分到底负责什么

这篇主要是帮你把三件事对齐：

1. Flutter 端到底调了哪些接口
2. `backend/src` 里每一层各自负责什么
3. Sealos 云函数到底只是“部署外壳”，还是业务真正写在里面

答案是：Sealos 在当前结构里主要只是部署外壳。

## 建议你第一次怎么读

推荐顺序：

1. 先看 Flutter 侧 `lib/api/medicine_api.dart`、`lib/api/safety_api.dart`、`lib/api/scan_api.dart`
2. 再看 `backend/src/routes/api.ts`
3. 再看 `backend/src/handlers/*`
4. 如果涉及数据库，再看 `backend/src/db/medicine-repository.ts`
5. 如果涉及 AI，再看 `backend/src/ai/doubao-client.ts`
6. 最后再看 `backend/src/cloud/*` 和打包脚本

这样你会先理解“接口做了什么”，再看“它怎么被部署出去”。

## 先分清三份和后端有关的资料

这个仓库里和后端有关的内容，不止一份。

- `lib/Backend/`
  最初的接口草稿和思路来源
- `BackendMd/`
  适合学习和参考的整理版文档
- `backend/`
  当前正式的 TypeScript 后端代码

以后如果你的问题是“当前代码真正怎么跑”，优先看 `backend/`。

如果你的问题是“当初设计接口时是怎么想的”，再去看 `BackendMd/`。

## 当前后端结构应该怎么理解

### Flutter 调用层

Flutter 当前主要通过这几处进入后端：

- `lib/api/medicine_api.dart`
- `lib/api/safety_api.dart`
- `lib/api/scan_api.dart`

也就是说，页面本身不直接拼接口，而是先走 API 封装层。

### Express 入口层

- `backend/src/app.ts`
- `backend/src/routes/api.ts`

这一层负责：

- 创建 Express app
- 开启 CORS
- 解析 JSON
- 注册 HTTP 路由
- 接入统一错误处理

它不应该承载具体业务细节。

### 业务处理层

- `backend/src/handlers/*`

这是当前后端最关键的一层。真正值得你以后重点学习的，也是这一层。

因为：

- Express 路由会调它
- Sealos 云函数也会调它
- 迁移部署方式时，最希望保持不动的就是它

### 数据访问层

- `backend/src/db/medicine-repository.ts`

这里负责把 MySQL 表结构映射成后端能用的字段，并提供搜索、详情查询、扫描候选回查。

### AI 调用层

- `backend/src/ai/doubao-client.ts`
- `backend/src/ai/prompts.ts`

这里负责：

- 选择豆包模型或 endpoint
- 发文本 / 视觉请求
- 解析返回文本

### 云函数适配层

- `backend/src/cloud/*`

这里当前非常薄，基本只做一件事：

- 把 `ctx.body` 转给对应 handler

所以你以后不应该把复杂业务直接堆进 `cloud/*`。

## 当前后端的真实请求链路

以 `/medicine-search` 为例，调用链路是这样的：

1. 页面调用 `MedicineApi.search()`
2. `lib/api/medicine_api.dart:15-43` 发 HTTP 请求
3. Express 环境下，请求进入 `backend/src/routes/api.ts:10`
4. 再交给 `backend/src/handlers/medicine-search.ts:7-26`
5. handler 校验参数后，调用 `backend/src/db/medicine-repository.ts:59-90`
6. 查询结果用统一 `ApiEnvelope` 返回
7. Flutter 侧 `DioRequest` 解析 `code/msg/result`
8. `MedicineSearchResult` 再回到页面层

Sealos 云函数环境下，区别只在第 3 步：

- 不是经过 Express 路由
- 而是由 `backend/src/cloud/medicine-search.ts:3-4` 直接把 `ctx.body` 转发给 handler

## 响应结构为什么这么重要

当前后端统一响应格式定义在：

- `backend/src/http/response.ts:1-12`

也就是：

```json
{
  "code": "1",
  "msg": "",
  "result": {}
}
```

这和 Flutter 端 `lib/utils/DioRequest.dart` 的解包逻辑是一一对应的。

所以以后如果你想改响应结构，不是只改后端就行，还必须同步改 Flutter 解码层。

## 当前已实现的 5 个接口对应关系

| 接口 | Flutter API | handler | cloud 入口 | bundle |
| --- | --- | --- | --- | --- |
| `/medicine-search` | `lib/api/medicine_api.dart:15-43` | `backend/src/handlers/medicine-search.ts:7-26` | `backend/src/cloud/medicine-search.ts:3-4` | `backend/dist/cloud-bundle/medicine-search.js` |
| `/medicine-detail` | `lib/api/medicine_api.dart:48-81` | `backend/src/handlers/medicine-detail.ts:7-29` | `backend/src/cloud/medicine-detail.ts:3-4` | `backend/dist/cloud-bundle/medicine-detail.js` |
| `/medicine-ai-detail` | `lib/api/medicine_api.dart:86-109` | `backend/src/handlers/medicine-ai-detail.ts:9-31` | `backend/src/cloud/medicine-ai-detail.ts:3-4` | `backend/dist/cloud-bundle/medicine-ai-detail.js` |
| `/medicine-ai-safety` | `lib/api/safety_api.dart:15-31` | `backend/src/handlers/medicine-ai-safety.ts:31-74` | `backend/src/cloud/medicine-ai-safety.ts:3-4` | `backend/dist/cloud-bundle/medicine-ai-safety.js` |
| `/medicine-scan` | `lib/api/scan_api.dart:16-39` | `backend/src/handlers/medicine-scan.ts:34-69` | `backend/src/cloud/medicine-scan.ts:3-4` | `backend/dist/cloud-bundle/medicine-scan.js` |

## 每一层里你最值得看的代码

### App 与路由层

- `backend/src/app.ts:21-35`
  创建 Express app、挂中间件、注册 `/health` 和 API 路由
- `backend/src/routes/api.ts:9-15`
  5 个 POST 接口的注册入口

### 环境变量层

- `backend/src/config/env.ts:21-43`
  所有环境变量的统一出口
- `backend/src/config/env.ts:45-70`
  视觉模型、文本模型和 API key 的选择逻辑

### 业务 handler 层

- `backend/src/handlers/medicine-search.ts:7-26`
  搜索接口
- `backend/src/handlers/medicine-detail.ts:7-29`
  详情接口
- `backend/src/handlers/medicine-ai-detail.ts:9-31`
  AI 详情解读
- `backend/src/handlers/medicine-ai-safety.ts:31-74`
  AI 安全分析
- `backend/src/handlers/medicine-scan.ts:34-69`
  图像识别与候选回查

### 数据访问层

- `backend/src/db/medicine-repository.ts:21-33`
  基础查询字段映射
- `backend/src/db/medicine-repository.ts:59-90`
  关键词搜索
- `backend/src/db/medicine-repository.ts:92-110`
  单药详情查询
- `backend/src/db/medicine-repository.ts:164-201`
  扫描候选去重与合并

### AI 层

- `backend/src/ai/doubao-client.ts:11-22`
  OpenAI SDK client 初始化
- `backend/src/ai/doubao-client.ts:73-80`
  文本模型调用
- `backend/src/ai/doubao-client.ts:83-105`
  视觉模型调用
- `backend/src/ai/doubao-client.ts:50-71`
  JSON 文本解析兜底

### Sealos 适配与打包层

- `backend/src/cloud/*.ts`
  云函数极薄入口
- `backend/scripts/bundle-cloud.mjs:11-35`
  把 `src/cloud` 打成 `dist/cloud-bundle`

## 为什么 `handlers/*` 是真正的学习重点

因为它刚好处在“协议”和“底层实现”中间：

- 向上接请求体、接口参数、响应格式
- 向下接数据库查询和 AI 模型调用

你以后无论是：

- 改字段
- 补校验
- 增加错误提示
- 增加缓存
- 迁到云服务器

都大概率要从 handler 这层动手。

## Sealos 当前最短部署路径

如果你现在还是先用 Sealos 云函数，最短路径就是：

1. 在 `backend/.env` 填好环境变量
2. 在 `backend/` 目录执行 `npm install`
3. 执行 `npm run build:cloud`
4. 上传 `backend/dist/cloud-bundle/*.js` 到 Sealos 云函数
5. 在 Sealos 侧配置同样的环境变量

这里最关键的文件和位置是：

- `backend/package.json:9`
  `build:cloud` 命令
- `backend/scripts/bundle-cloud.mjs:9`
  输出目录 `dist/cloud-bundle`
- `backend/scripts/bundle-cloud.mjs:11-17`
  当前会打包的 5 个云函数入口

## 以后迁到云服务器时，哪些能复用

能直接复用的主要有：

- `backend/src/handlers/*`
- `backend/src/db/*`
- `backend/src/ai/*`
- `backend/src/http/*`
- `backend/src/config/*`

主要需要改的通常是：

- `backend/src/cloud/*`
- 部署方式
- 进程管理、日志、鉴权、中间件等外围设施

## 当前还没有正式落到这套后端代码里的内容

这点很重要，避免以后误判“是不是漏文件了”。

当前 `backend/` 里正式整理好的主要是药品相关 5 个接口。

下面这些方向还没有完整落成这套正式 Node 后端：

- 登录 / 注册 / 发送验证码
- 提醒计划相关接口
- 打卡撤销后端接口
- `scan-record-create`
- `scan-record-list`

这些内容目前要结合 `BackendMd/` 去看，不能只看 `backend/src`。

## 一条最短的读码路径

如果你以后想用最短时间重新看懂后端主线，推荐这条顺序：

1. `lib/api/medicine_api.dart`
2. `backend/src/routes/api.ts`
3. `backend/src/handlers/medicine-search.ts`
4. `backend/src/db/medicine-repository.ts`
5. `backend/src/http/response.ts`
6. `backend/src/cloud/medicine-search.ts`
7. `backend/scripts/bundle-cloud.mjs`

看懂一条链后，再去看其他 4 个 handler 会快很多。

## 容易忽略的实现细节

- `backend/src/cloud/*` 很薄，不是业务主战场。
- `medicine-scan` 当前不会在服务端生成缩略图，`thumbBase64` 固定留空，由 Flutter 本地兜底。
- `medicine-ai-safety` 会优先根据 `drugCode/approvalNo` 回查数据库，再把补充后的信息送给 AI。
- 环境变量里 endpoint id 和 model id 是有优先级的，不是任意混用。

## 如果以后要改，优先改哪里

### 想改协议字段

先改：

1. `backend/src/handlers/*`
2. `lib/api/*`
3. `lib/viewmodels/*`

### 想改数据库查询逻辑

先改：

1. `backend/src/db/medicine-repository.ts`

### 想改 AI 提示词或模型

先改：

1. `backend/src/ai/prompts.ts`
2. `backend/src/ai/doubao-client.ts`
3. `backend/src/config/env.ts`

### 想改部署方式

优先保持 `handlers/*` 不动，只动：

1. `backend/src/cloud/*`
2. `backend/src/app.ts`
3. 打包和部署脚本

## 相关测试在哪

当前仓库还没有正式的后端单元测试或集成测试。

现在至少确认过的是：

- `backend/` 可以通过 `npm run build`

如果你以后要继续补质量保障，最值得先补的测试是：

1. handler 参数校验测试
2. `medicine-repository` 查询测试
3. `medicine-scan` 的 AI 结果解析测试
