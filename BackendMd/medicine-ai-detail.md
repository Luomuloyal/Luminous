访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /medicine-ai-detail
公网访问路径: https://wty10hv6az.sealosbja.site/medicine-ai-detail

用途:
- 药品详情页点击“尝试获取更详细信息”后调用
- 后端先查询药品基础信息，再调用豆包文本模型补充数据库中未保存的说明书内容

请求体（二选一即可，推荐 `drugCode`）:
- `drugCode`: string
- `approvalNo`: string

返回体:
- `code`: string
- `msg`: string
- `result`
  - `text`: string

输出目标:
- 继续返回纯文本，前端不改结构化解析
- 内容重点覆盖：
  - 成分
  - 适应症
  - 常见用法用量提示
  - 常见不良反应
  - 禁忌
  - 注意事项
  - 特殊人群提示

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

async function loadMedicineDetail({
  drugCode,
  approvalNo,
}: {
  drugCode: string
  approvalNo: string
}) {
  // TODO: 复用现有 /medicine-detail 的 MySQL 查询逻辑
  return {
    productName: '示例药品',
    dosageForm: '片剂',
    specification: '0.5g*20片',
    manufacturer: '示例制药',
    approvalNo,
    drugCode,
  }
}

export async function main(ctx: FunctionContext) {
  if (!ctx.body || typeof ctx.body !== 'object') {
    return fail('请求参数格式错误')
  }

  const drugCode = String((ctx.body as any).drugCode || '').trim()
  const approvalNo = String((ctx.body as any).approvalNo || '').trim()
  if (!drugCode && !approvalNo) {
    return fail('drugCode 或 approvalNo 不能为空')
  }

  const detail = await loadMedicineDetail({ drugCode, approvalNo })

  const prompt = [
    '你是一名药品说明书整理助手，请根据以下基础信息补充中文说明。',
    `产品名称: ${detail.productName}`,
    `剂型: ${detail.dosageForm}`,
    `规格: ${detail.specification}`,
    `生产单位: ${detail.manufacturer}`,
    `批准文号: ${detail.approvalNo}`,
    `药品编码: ${detail.drugCode}`,
    '请重点说明：成分、适应症、常见用法用量提示、常见不良反应、禁忌、注意事项、特殊人群提示。',
    '输出纯文本，不要输出 markdown 代码块，不要编造数据库已明确没有的信息来源。',
  ].join('\n')

  const text = await callTextModel(prompt)
  return success({ text })
}
```

## 当前项目对应关系

- 接口用途:
  给药品详情页补充 AI 解读文本，重点覆盖成分、适应症、用法用量、不良反应、禁忌和注意事项。
- Flutter 端调用入口:
  `lib/api/medicine_api.dart` 的 `MedicineApi.fetchAiDetail()`，页面触发位置主要在 `lib/pages/Drug/medicine_detail.dart`。
- `backend/src/handlers` 对应实现:
  `backend/src/handlers/medicine-ai-detail.ts`
- `backend/src/cloud` 对应云函数入口:
  `backend/src/cloud/medicine-ai-detail.ts`
- Sealos 云函数部署要点:
  在 `backend/` 填好 `.env` 后执行 `npm install`、`npm run build:cloud`，上传 `backend/dist/cloud-bundle/medicine-ai-detail.js` 到 Sealos 云函数。
- 后续迁移到云服务器时是否还能复用:
  可以；Express 路由和云函数都会复用同一个 handler，不需要重写核心逻辑。
