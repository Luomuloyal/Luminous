访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /medicine-ai-safety
公网访问路径: https://wty10hv6az.sealosbja.site/medicine-ai-safety

用途:
- 安全辅助页调用
- 单药模式返回用药建议、注意事项、特殊人群提示
- 双药模式返回相互作用、联用风险与建议

请求体:
- `userId`: string (可选)
- `mode`: `'single' | 'pair'`
- `medicines`: MedicineRef[] (`single=1 个`, `pair=2 个`)

MedicineRef 字段:
- `drugCode`: string
- `approvalNo`: string
- `productName`: string

返回体:
- `code`: string
- `msg`: string
- `result`
  - `text`: string

设计约束:
- 前端继续消费纯文本 `text`
- 不引入结构化 JSON 返回，避免额外 UI 改造
- 推荐后端先查基础信息，再把基础信息和用户传入字段一起交给豆包文本模型

所需环境变量:
- `MYSQL_HOST`
- `MYSQL_PORT`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MYSQL_DATABASE`
- `DOUBAO_API_KEY`
- `DOUBAO_BASE_URL`
- `DOUBAO_TEXT_ENDPOINT_ID`
- `DOUBAO_TEXT_MODEL_ID`

参考资料:
- 对话(Chat)-文本 API: https://doubao.apifox.cn/265892759e0.md
- 火山方舟文本生成接入说明: https://www.volcengine.com/docs/82379/1399009
- 共享 helper: `doubao-ark-helper.md`

示例代码（Laf 云函数，TypeScript）
```typescript
import { callTextModel } from './doubao-ark-helper'

function success(result: any, msg = '') {
  return { code: '1', msg, result }
}

function fail(msg: string, code = '0') {
  return { code, msg, result: null }
}

export async function main(ctx: FunctionContext) {
  if (!ctx.body || typeof ctx.body !== 'object') {
    return fail('请求参数格式错误')
  }

  const mode = String((ctx.body as any).mode || 'single').trim()
  const medicines = Array.isArray((ctx.body as any).medicines)
    ? (ctx.body as any).medicines
    : []

  if (!['single', 'pair'].includes(mode)) {
    return fail('mode 必须是 single 或 pair')
  }
  if (mode === 'single' && medicines.length !== 1) {
    return fail('single 模式 medicines 必须为 1 个')
  }
  if (mode === 'pair' && medicines.length !== 2) {
    return fail('pair 模式 medicines 必须为 2 个')
  }

  const prompt =
    mode === 'pair'
      ? [
          '你是一名联合用药风险提示助手，请评估以下两种药物是否存在相互作用，并给出中文建议。',
          `药品A: ${JSON.stringify(medicines[0])}`,
          `药品B: ${JSON.stringify(medicines[1])}`,
          '请输出：是否存在相互作用、可能风险、联用建议、何时需要咨询医生或药师。',
          '输出纯文本，不要输出 markdown 代码块。',
        ].join('\n')
      : [
          '你是一名用药建议助手，请根据以下药物信息返回中文说明。',
          `药品: ${JSON.stringify(medicines[0])}`,
          '请输出：常见用途、禁忌/慎用人群、注意事项、何时需要咨询医生或药师。',
          '输出纯文本，不要输出 markdown 代码块。',
        ].join('\n')

  const text = await callTextModel(prompt)
  return success({ text })
}
```

## 当前项目对应关系

- 接口用途:
  用于安全辅助页，支持单药建议和双药联用风险分析，当前前端只消费纯文本结果。
- Flutter 端调用入口:
  `lib/api/safety_api.dart` 的 `SafetyApi.query()`，页面触发位置主要在 `lib/pages/Safety/safety_assist.dart`。
- `backend/src/handlers` 对应实现:
  `backend/src/handlers/medicine-ai-safety.ts`
- `backend/src/cloud` 对应云函数入口:
  `backend/src/cloud/medicine-ai-safety.ts`
- Sealos 云函数部署要点:
  在 `backend/` 执行 `npm install`、`npm run build:cloud` 后，上传 `backend/dist/cloud-bundle/medicine-ai-safety.js` 到 Sealos 云函数，并配置 MySQL 与豆包环境变量。
- 后续迁移到云服务器时是否还能复用:
  可以；现在的 cloud 入口只是薄适配层，后面迁到云服务器仍然沿用同一个 handler。
