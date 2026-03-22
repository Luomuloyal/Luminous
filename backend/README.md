# Luminous Backend

这个目录是从你项目里的后端文档整理出来的一套可部署 `Node + TypeScript` 后端代码，重点覆盖当前 Flutter 端已经接好的这几个接口：

- `/medicine-search`
- `/medicine-detail`
- `/medicine-ai-detail`
- `/medicine-ai-safety`
- `/medicine-scan`

如果你现在是先按 Sealos 云函数来学和部署，建议先看：

- 根目录 `README.md`
- `BackendMd/README.md`

这份 `backend/README.md` 更偏代码目录自述，重点说明这份后端代码怎么运行、怎么打包，而不是替代整个项目的总说明文档。

设计目标有两个：

- 现在可以继续走云函数部署
- 后面迁移到云服务器时，不需要重写核心逻辑

## 目录结构

```text
backend/
  src/
    ai/            豆包调用与 prompt
    cloud/         云函数入口
    config/        环境变量
    db/            MySQL 连接与药品查询
    handlers/      业务处理核心
    http/          响应结构与 Express 适配
    routes/        Express 路由
    app.ts         Express app
    server.ts      服务启动入口
  scripts/
    bundle-cloud.mjs
```

其中最关键的是 `handlers/`。

- 云函数入口调用 `handlers`
- Express 路由也调用同一套 `handlers`

所以以后你迁到云服务器，基本只需要换部署方式，不用改业务逻辑。

## 环境变量

先复制一份环境变量模板：

```bash
Copy-Item .env.example .env
```

需要重点填写：

```env
PORT=8787
CORS_ORIGIN=*

MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=medicine_db
MYSQL_TABLE=国产本位码

DOUBAO_API_KEY=your_doubao_api_key
DOUBAO_BASE_URL=https://ark.cn-beijing.volces.com/api/v3
DOUBAO_VISION_ENDPOINT_ID=你的视觉endpoint
DOUBAO_TEXT_ENDPOINT_ID=你的文本endpoint
```

如果你不用 endpoint，也可以改用：

- `DOUBAO_VISION_MODEL_ID`
- `DOUBAO_TEXT_MODEL_ID`

模型选择优先级和你原来文档里保持一致：

- 视觉：`DOUBAO_VISION_ENDPOINT_ID` > `DOUBAO_VISION_MODEL_ID`
- 文本：`DOUBAO_TEXT_ENDPOINT_ID` > `DOUBAO_TEXT_MODEL_ID`

## 本地启动

```bash
npm install
npm run dev
```

启动后默认地址：

```text
http://127.0.0.1:8787
```

健康检查：

```text
GET /health
```

## 打包部署到云服务器

```bash
npm install
npm run build
npm run start
```

如果你部署到云服务器后地址变了，只需要回 Flutter 侧修改：

[constants.dart](/d:/25080/Documents/AndroidStudioProjects/Luminous/lib/constants/constants.dart#L16)

## 打包部署到云函数

如果你的云函数平台支持上传一个完整 Node 项目，可以直接把这个 `backend/` 当项目部署。

如果你的云函数平台更偏向“一个函数一个文件”，就用下面这条命令：

```bash
npm install
npm run build:cloud
```

会生成：

```text
dist/cloud-bundle/medicine-search.js
dist/cloud-bundle/medicine-detail.js
dist/cloud-bundle/medicine-ai-detail.js
dist/cloud-bundle/medicine-ai-safety.js
dist/cloud-bundle/medicine-scan.js
```

这些文件已经是单文件 bundle，适合直接上传到云函数平台。

每个文件都导出了：

```js
exports.main = async (ctx) => { ... }
```

也就是你现在文档里常见的那种 `main(ctx)` 入口风格。

## 返回格式

所有接口都统一返回：

```json
{
  "code": "1",
  "msg": "",
  "result": {}
}
```

这和 Flutter 端 [DioRequest.dart](/d:/25080/Documents/AndroidStudioProjects/Luminous/lib/utils/DioRequest.dart) 的解析逻辑保持一致。

## 当前接口说明

### `/medicine-search`

请求体：

```json
{
  "keyword": "阿莫西林",
  "page": 1,
  "pageSize": 20
}
```

### `/medicine-detail`

请求体：

```json
{
  "drugCode": "86900000000000"
}
```

或：

```json
{
  "approvalNo": "国药准字..."
}
```

### `/medicine-ai-detail`

请求体：

```json
{
  "drugCode": "86900000000000"
}
```

返回：

```json
{
  "code": "1",
  "msg": "",
  "result": {
    "text": "AI 返回的药品解读文本"
  }
}
```

### `/medicine-ai-safety`

请求体：

```json
{
  "mode": "pair",
  "medicines": [
    {
      "drugCode": "86900000000001",
      "approvalNo": "国药准字A",
      "productName": "药品A"
    },
    {
      "drugCode": "86900000000002",
      "approvalNo": "国药准字B",
      "productName": "药品B"
    }
  ]
}
```

### `/medicine-scan`

请求体：

```json
{
  "imageBase64": "base64内容",
  "mimeType": "image/jpeg"
}
```

说明：

- 后端会把图片传给豆包视觉模型
- 视觉模型只返回 JSON
- 服务端再用 `approvalNo / productName / manufacturer` 回查 MySQL
- 当前 `thumbBase64` 固定返回空字符串，避免服务端为了缩略图引入额外图像处理依赖
- Flutter 侧已经有本地缩略图兜底逻辑，所以不会影响现有流程

## 和 Flutter 的对应关系

Flutter 侧已经接好的调用入口分别在：

- [scan_api.dart](/d:/25080/Documents/AndroidStudioProjects/Luminous/lib/api/scan_api.dart)
- [medicine_api.dart](/d:/25080/Documents/AndroidStudioProjects/Luminous/lib/api/medicine_api.dart)
- [safety_api.dart](/d:/25080/Documents/AndroidStudioProjects/Luminous/lib/api/safety_api.dart)

页面调用在：

- [medicine_scan.dart](/d:/25080/Documents/AndroidStudioProjects/Luminous/lib/pages/Scan/medicine_scan.dart#L699)
- [medicine_detail.dart](/d:/25080/Documents/AndroidStudioProjects/Luminous/lib/pages/Drug/medicine_detail.dart#L109)
- [safety_assist.dart](/d:/25080/Documents/AndroidStudioProjects/Luminous/lib/pages/Safety/safety_assist.dart#L370)

## 后续建议

现在这版优先保证“能跑、结构清楚、方便迁移”。后面你可以再继续补：

- `/scan-record-create` 和 `/scan-record-list` 的服务端实现
- AI 请求日志、耗时统计、重试
- Redis 缓存
- 鉴权中间件
- 限流
- 医药类 prompt 的更细分模板

如果你愿意，我下一步可以继续把这两个也补上：

1. `scan-record-create` / `scan-record-list`
2. 一个 `curl` 或 Postman 测试清单，方便你逐个联调
