访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /medicine-scan
公网访问路径: https://wty10hv6az.sealosbja.site/medicine-scan

用途:
- 药物识别: 前端拍照或从相册选择图片后上传
- 后端调用豆包视觉模型识别药盒/包装上的关键信息
- 后端继续基于识别出的批准文号、产品名称等字段查询 MySQL 药品库，返回候选药品列表

请求体:
- `userId`: string (可选)
- `imageBase64`: string (必填，图片 base64，不带 data:image 前缀)
- `mimeType`: string (可选，默认 `image/jpeg`)

返回体:
- `code`: string
- `msg`: string
- `result`
  - `candidates`: Candidate[]
  - `thumbBase64`: string

Candidate 字段:
- `drugCode`: string
- `approvalNo`: string
- `productName`: string
- `dosageForm`: string
- `specification`: string
- `manufacturer`: string
- `score`: number (可选，0~1)

识别链路:
1. 前端传 `imageBase64 + mimeType`
2. 后端拼成 `data:${mimeType};base64,${imageBase64}`
3. 把 data URL 作为 `image_url.url` 传给豆包视觉模型
4. 视觉 prompt 固定要求只输出 JSON
5. 后端解析 JSON 后，优先按 `approvalNo` 精确查，再按 `productName` / `manufacturer` 做兜底查询
6. 最终返回候选药品列表给前端

视觉 prompt 建议:
```text
你是一名药品包装识别助手。请读取图片中的药品包装信息，只输出一个 JSON 对象，不要输出任何解释文字。

JSON 字段固定为：
{
  "productName": "",
  "approvalNo": "",
  "manufacturer": "",
  "dosageForm": "",
  "specification": ""
}

要求：
1. 字段不存在时返回空字符串
2. 不要补充未看见的信息
3. 不要输出 markdown 代码块
```

所需环境变量:
- `MYSQL_HOST`
- `MYSQL_PORT`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MYSQL_DATABASE`
- `DOUBAO_API_KEY`
- `DOUBAO_BASE_URL`
- `DOUBAO_VISION_ENDPOINT_ID`
- `DOUBAO_VISION_MODEL_ID`

参考资料:
- 对话(Chat)-视觉 API: https://doubao.apifox.cn/265897481e0.md
- 火山方舟文本生成接入说明: https://www.volcengine.com/docs/82379/1399009
- 共享 helper: `doubao-ark-helper.md`

示例代码（Laf 云函数，TypeScript）
```typescript
import cloud from '@lafjs/cloud'
import { callVisionModel, parseJsonObject } from './doubao-ark-helper'

const db = cloud.database()

function success(result: any, msg = '') {
  return { code: '1', msg, result }
}

function fail(msg: string, code = '0') {
  return { code, msg, result: null }
}

function stripDataUrl(base64: string) {
  const idx = base64.indexOf('base64,')
  return idx >= 0 ? base64.substring(idx + 7) : base64
}

function buildDataUrl(imageBase64: string, mimeType: string) {
  return `data:${mimeType};base64,${stripDataUrl(imageBase64)}`
}

async function queryMedicineCandidates(parsed: {
  approvalNo?: string
  productName?: string
  manufacturer?: string
}) {
  // TODO: 复用现有 medicine-search / medicine-detail 的 MySQL 查询逻辑
  // 推荐顺序：
  // 1. approvalNo 精确查
  // 2. productName 模糊查
  // 3. manufacturer 兜底查
  return []
}

export async function main(ctx: FunctionContext) {
  if (!ctx.body || typeof ctx.body !== 'object') {
    return fail('请求参数格式错误')
  }

  const imageBase64 = String((ctx.body as any).imageBase64 || '').trim()
  const mimeType = String((ctx.body as any).mimeType || 'image/jpeg').trim()
  if (!imageBase64) {
    return fail('imageBase64 不能为空')
  }

  const prompt = [
    '你是一名药品包装识别助手。请读取图片中的药品包装信息，只输出 JSON 对象。',
    'JSON 字段固定为：productName、approvalNo、manufacturer、dosageForm、specification。',
    '字段不存在时返回空字符串，不要输出 markdown 代码块。',
  ].join('\n')

  const content = await callVisionModel({
    dataUrl: buildDataUrl(imageBase64, mimeType || 'image/jpeg'),
    prompt,
  })

  const parsed = parseJsonObject(content) || {}
  const candidates = await queryMedicineCandidates(parsed)

  return success({
    candidates,
    thumbBase64: '',
  })
}
```

## 当前项目对应关系

- 接口用途:
  上传药品包装图片，调用豆包视觉模型识别关键信息，再回查 MySQL 返回候选药品列表。
- Flutter 端调用入口:
  `lib/api/scan_api.dart` 的 `ScanApi.scanMedicine()`，页面触发位置主要在 `lib/pages/Scan/medicine_scan.dart`。
- `backend/src/handlers` 对应实现:
  `backend/src/handlers/medicine-scan.ts`
- `backend/src/cloud` 对应云函数入口:
  `backend/src/cloud/medicine-scan.ts`
- Sealos 云函数部署要点:
  在 `backend/` 配好豆包视觉模型和 MySQL 环境变量后，执行 `npm install`、`npm run build:cloud`，上传 `backend/dist/cloud-bundle/medicine-scan.js`。当前 `thumbBase64` 仍保持轻量实现，固定返回空字符串，由 Flutter 端本地缩略图兜底。
- 后续迁移到云服务器时是否还能复用:
  可以；当前识别流程已经是平台无关的 handler 结构，迁服务器时继续复用即可。
