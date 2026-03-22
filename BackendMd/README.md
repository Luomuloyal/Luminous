# Luminous 后端学习文档

这个目录是给你继续学习和参考后端用的整理版文档区，目标是保留你熟悉的 `.md` 阅读方式，同时把它和现在已经写出来的 `backend/` 代码对应起来。

## 先搞清楚三个目录

- `lib/Backend/`
  最早的后端接口草稿和思路来源，原始文档保留不动。
- `BackendMd/`
  面向现在学习和 Sealos 云函数部署的整理版文档。这里会继续保留 `.md` 风格，并补充 Flutter 调用入口、`backend/` 代码映射、Sealos 部署说明。
- `backend/`
  真正可部署的 `Node + TypeScript` 后端代码。现在已经实现了 5 个药品相关接口，后面迁移到云服务器也会继续复用这套结构。

## 当前已实现的后端接口

下面这 5 个接口已经有对应代码，可以直接从 `backend/` 打包 Sealos 云函数：

| 接口 | Flutter 调用入口 | handler | cloud bundle |
| --- | --- | --- | --- |
| `/medicine-search` | `lib/api/medicine_api.dart` | `backend/src/handlers/medicine-search.ts` | `dist/cloud-bundle/medicine-search.js` |
| `/medicine-detail` | `lib/api/medicine_api.dart` | `backend/src/handlers/medicine-detail.ts` | `dist/cloud-bundle/medicine-detail.js` |
| `/medicine-ai-detail` | `lib/api/medicine_api.dart` | `backend/src/handlers/medicine-ai-detail.ts` | `dist/cloud-bundle/medicine-ai-detail.js` |
| `/medicine-ai-safety` | `lib/api/safety_api.dart` | `backend/src/handlers/medicine-ai-safety.ts` | `dist/cloud-bundle/medicine-ai-safety.js` |
| `/medicine-scan` | `lib/api/scan_api.dart` | `backend/src/handlers/medicine-scan.ts` | `dist/cloud-bundle/medicine-scan.js` |

## 现在怎么用 Sealos 云函数

如果你现在先不想折腾云服务器，最短路径就是这套：

1. 进入 `backend/`，把 `.env.example` 复制成 `.env`，填好 MySQL 和豆包环境变量。
2. 在 `backend/` 执行 `npm install`。
3. 在 `backend/` 执行 `npm run build:cloud`。
4. 把 `backend/dist/cloud-bundle/*.js` 上传到 Sealos 云函数。
5. 在 Sealos 云函数里补上对应环境变量。
6. Flutter 侧继续通过 `GlobalConstants.BASE_URL` 指向你的 Sealos 地址即可。

当前云函数部署只需要关心三件事：

- 单文件 bundle
- `exports.main = async (ctx) => { ... }`
- 环境变量

## 为什么保留 `backend/src/cloud`

`backend/src/cloud` 不是多余的，它是为了兼容你当前的 Sealos 云函数平台。

- `backend/src/handlers`
  放的是核心业务逻辑，尽量不和具体平台绑死。
- `backend/src/cloud`
  只是把 `ctx.body` 转给 handler，适配现在的云函数入口。
- `backend/src/routes` 和 `backend/src/server.ts`
  是给以后迁到云服务器准备的。

这样你现在可以继续走云函数，后面学完 Node.js 以后，也不用把业务逻辑重写一遍。

## 建议的学习顺序

如果你想边学边看，推荐这个顺序：

1. 先看根目录 `README.md`，了解整个项目的前后端关系。
2. 再看本目录的 5 个已实现接口文档：
   - `medicine-search.md`
   - `medicine-detail.md`
   - `medicine-ai-detail.md`
   - `medicine-ai-safety.md`
   - `medicine-scan.md`
3. 再去看 `backend/src/handlers` 对应实现。
4. 最后再看 `backend/src/cloud`，理解为什么同一个 handler 能同时服务云函数和未来服务器。

## 当前还没补到 `backend/` 的文档

下面这些文档目前还主要是协议和思路草稿，Flutter 端有些已经在调，但 `backend/` 里还没有整理成正式实现：

- `send-code.md`
- `register-user.md`
- `login-user.md`
- `my-medicine.md`
- `today-reminders.md`
- `reminder.md`
- `checkin-create.md`
- `scan-record.md`
- `aliyun-sms-auth.md`

这些文档仍然保留在这里，方便你继续参考、学习和后续补实现。

## 这份目录怎么读

每篇文档都会尽量补齐这些信息：

- 接口用途
- 请求体 / 返回体
- Flutter 端调用入口
- `backend/src/handlers` 对应实现
- `backend/src/cloud` 对应云函数入口
- Sealos 云函数部署要点
- 未来迁移到云服务器时能否复用

所以你后面如果看到某个接口想继续补，优先在 `BackendMd/` 里看文档，再去 `backend/` 对应目录找代码。
