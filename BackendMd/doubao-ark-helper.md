访问地址: 火山方舟（Doubao）

用途:
- 统一封装豆包文本模型与视觉模型调用
- 统一封装 endpoint-id / model-id 双模式选择
- 统一处理响应文本提取、JSON 提取与环境变量校验
- 避免 `/medicine-scan`、`/medicine-ai-detail`、`/medicine-ai-safety` 三个云函数重复写客户端初始化逻辑

参考资料:
- 对话(Chat)-文本 API: https://doubao.apifox.cn/265892759e0.md
- 对话(Chat)-视觉 API: https://doubao.apifox.cn/265897481e0.md
- 签名/鉴权说明: https://doubao.apifox.cn/6107417m0.md
- 火山方舟文本生成接入说明: https://www.volcengine.com/docs/82379/1399009

依赖:
- `openai`

环境变量:
- `DOUBAO_API_KEY`
- `DOUBAO_BASE_URL`（可选，默认 `https://ark.cn-beijing.volces.com/api/v3`）
- `DOUBAO_VISION_ENDPOINT_ID`（推荐）
- `DOUBAO_TEXT_ENDPOINT_ID`（推荐）
- `DOUBAO_VISION_MODEL_ID`（兼容）
- `DOUBAO_TEXT_MODEL_ID`（兼容）

模型选择优先级:
- 视觉模型: `DOUBAO_VISION_ENDPOINT_ID` > `DOUBAO_VISION_MODEL_ID`
- 文本模型: `DOUBAO_TEXT_ENDPOINT_ID` > `DOUBAO_TEXT_MODEL_ID`
- 若两者都为空，直接抛错，避免请求发出后才发现配置不完整

示例代码（Laf 云函数，TypeScript）
```typescript
import OpenAI from 'openai'

export function mustEnv(name: string) {
  const value = String(process.env[name] || '').trim()
  if (!value) {
    throw new Error(`缺少环境变量: ${name}`)
  }
  return value
}

export function createDoubaoClient() {
  return new OpenAI({
    apiKey: mustEnv('DOUBAO_API_KEY'),
    baseURL:
      String(process.env.DOUBAO_BASE_URL || '').trim() ||
      'https://ark.cn-beijing.volces.com/api/v3',
  })
}

export function resolveVisionModel() {
  const endpointId = String(process.env.DOUBAO_VISION_ENDPOINT_ID || '').trim()
  if (endpointId) return endpointId

  const modelId = String(process.env.DOUBAO_VISION_MODEL_ID || '').trim()
  if (modelId) return modelId

  throw new Error('缺少 DOUBAO_VISION_ENDPOINT_ID 或 DOUBAO_VISION_MODEL_ID')
}

export function resolveTextModel() {
  const endpointId = String(process.env.DOUBAO_TEXT_ENDPOINT_ID || '').trim()
  if (endpointId) return endpointId

  const modelId = String(process.env.DOUBAO_TEXT_MODEL_ID || '').trim()
  if (modelId) return modelId

  throw new Error('缺少 DOUBAO_TEXT_ENDPOINT_ID 或 DOUBAO_TEXT_MODEL_ID')
}

export function extractTextContent(content: any): string {
  if (typeof content === 'string') {
    return content.trim()
  }
  if (Array.isArray(content)) {
    return content
      .map((item) => {
        if (typeof item === 'string') return item
        if (item && typeof item.text === 'string') return item.text
        return ''
      })
      .join('\n')
      .trim()
  }
  return ''
}

export function parseJsonObject(text: string): Record<string, any> | null {
  const raw = String(text || '').trim()
  if (!raw) return null

  try {
    return JSON.parse(raw)
  } catch (_) {
    const match = raw.match(/\{[\s\S]*\}/)
    if (!match) return null
    try {
      return JSON.parse(match[0])
    } catch (_) {
      return null
    }
  }
}

export async function callVisionModel({
  dataUrl,
  prompt,
}: {
  dataUrl: string
  prompt: string
}) {
  const client = createDoubaoClient()
  const model = resolveVisionModel()

  const response = await client.chat.completions.create({
    model,
    temperature: 0.2,
    messages: [
      {
        role: 'user',
        content: [
          { type: 'text', text: prompt },
          {
            type: 'image_url',
            image_url: { url: dataUrl },
          },
        ],
      },
    ],
  })

  return extractTextContent(response.choices?.[0]?.message?.content)
}

export async function callTextModel(prompt: string) {
  const client = createDoubaoClient()
  const model = resolveTextModel()

  const response = await client.chat.completions.create({
    model,
    temperature: 0.3,
    messages: [{ role: 'user', content: prompt }],
  })

  return extractTextContent(response.choices?.[0]?.message?.content)
}
```

建议:
- `/medicine-scan` 只负责：base64 组装成 data URL -> 视觉模型识别 -> 解析 JSON -> 查 MySQL 药品库
- `/medicine-ai-detail` 与 `/medicine-ai-safety` 只负责：查基础信息 -> 组装 prompt -> 调文本模型
- 如果后续要加重试、日志、限流、耗时统计，都统一放在这个 helper 里

## 当前项目对应关系

- 接口用途:
  这是 AI 调用层的共享 helper，不是单独给 Flutter 直接调用的 HTTP 接口。
- Flutter 端调用入口:
  无独立入口；当前间接服务于 `lib/api/scan_api.dart`、`lib/api/medicine_api.dart`、`lib/api/safety_api.dart`。
- `backend/src/handlers` 对应实现:
  当前由 `backend/src/handlers/medicine-scan.ts`、`backend/src/handlers/medicine-ai-detail.ts`、`backend/src/handlers/medicine-ai-safety.ts` 共享调用。
- `backend/src/cloud` 对应云函数入口:
  无独立云函数入口；由上述 3 个接口各自的 cloud 入口复用。
- `backend/src/ai` 对应代码:
  `backend/src/ai/doubao-client.ts` 和 `backend/src/ai/prompts.ts`。
- Sealos 云函数部署要点:
  这个 helper 不需要单独上传；执行 `npm install` 和 `npm run build:cloud` 后，相关能力会被一起打进各自的单文件 bundle。
- 后续迁移到云服务器时是否还能复用:
  可以，复用性很高；这类 helper 天生适合继续留在 `backend/src/ai` 中给 Express 路由和云函数共用。
