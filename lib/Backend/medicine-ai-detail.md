访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /medicine-ai-detail
公网访问路径: https://wty10hv6az.sealosbja.site/medicine-ai-detail

用途:
- 药品详情页: 点击“获取详细信息”后，由后端调用 AI 查询更详细信息并返回

请求体(二选一即可，推荐 drugCode):
- drugCode: string
- approvalNo: string

返回体:
- code: string
- msg: string
- result:
  - text: string

说明:
- 该接口是为后续接入 AI 预留的。你也可以先按下面的示例返回占位内容，保证前端 UI 联调可用。

```typescript
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

  const drugCode = String((ctx.body as any).drugCode || '').trim()
  const approvalNo = String((ctx.body as any).approvalNo || '').trim()
  if (!drugCode && !approvalNo) {
    return fail('drugCode 或 approvalNo 不能为空')
  }

  // TODO: 在这里接入 AI (例如: 根据 drugCode/approvalNo 查询基础信息后拼 prompt，再调用模型)
  return success({
    text: 'AI 接口尚未接入：这里会返回更详细的用法用量、禁忌、相互作用、特殊人群提示等内容。',
  })
}
```

