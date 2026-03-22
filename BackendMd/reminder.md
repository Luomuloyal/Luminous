访问地址: https://wty10hv6az.sealosbja.site

函数路径:
- POST /reminder-upsert
- POST /reminder-delete
- POST /reminder-list

公网访问路径:
- https://wty10hv6az.sealosbja.site/reminder-upsert
- https://wty10hv6az.sealosbja.site/reminder-delete
- https://wty10hv6az.sealosbja.site/reminder-list

用途:
- 用药提醒计划: 后端保存提醒计划，前端用于跨设备同步与首页“今日提醒”生成

ReminderPlan 字段:
- id: string
- userId: string
- time: string (HH:mm)
- drugCode: string
- approvalNo: string
- productName: string
- subtitle: string
- enabled: boolean
- repeatRule: string (当前先用 daily)
- method: string (notification)

请求体: POST /reminder-upsert
- userId: string (必填)
- id: string (可选，传则更新，不传则创建)
- time: string (必填，HH:mm)
- drugCode: string (可选)
- approvalNo: string (可选)
- productName: string (必填或由前端填充)
- subtitle: string (可选)
- enabled: boolean (可选，默认 true)
- repeatRule: string (可选，默认 daily)
- method: string (可选，默认 notification)

返回体: POST /reminder-upsert
- code: string
- msg: string
- result: ReminderPlan

请求体: POST /reminder-delete
- userId: string (必填)
- id: string (必填)

返回体: POST /reminder-delete
- code: string
- msg: string
- result: boolean

请求体: POST /reminder-list
- userId: string (必填)

返回体: POST /reminder-list
- code: string
- msg: string
- result: { items: ReminderPlan[] }

示例代码（Laf 云函数）
```typescript
import cloud from '@lafjs/cloud'

const db = cloud.database()
const COL = 'reminders'

function success(result: any, msg = '') {
  return { code: '1', msg, result }
}

function fail(msg: string, code = '0') {
  return { code, msg, result: null }
}

function isValidTime(t: string) {
  return /^\d{2}:\d{2}$/.test(t) && Number(t.slice(0, 2)) <= 23 && Number(t.slice(3)) <= 59
}

export async function main(ctx: FunctionContext) {
  const fn = String(ctx.__function_name || '').trim()
  if (!ctx.body || typeof ctx.body !== 'object') {
    return fail('请求参数格式错误')
  }

  if (fn.includes('reminder-upsert')) {
    const userId = String((ctx.body as any).userId || '').trim()
    const id = String((ctx.body as any).id || '').trim()
    const time = String((ctx.body as any).time || '').trim()
    const productName = String((ctx.body as any).productName || '').trim()
    if (!userId) return fail('userId 不能为空')
    if (!time || !isValidTime(time)) return fail('time 格式错误，应为 HH:mm')
    if (!productName) return fail('productName 不能为空')

    const enabled = (ctx.body as any).enabled !== false
    const repeatRule = String((ctx.body as any).repeatRule || 'daily').trim() || 'daily'
    const method = String((ctx.body as any).method || 'notification').trim() || 'notification'
    const drugCode = String((ctx.body as any).drugCode || '').trim()
    const approvalNo = String((ctx.body as any).approvalNo || '').trim()
    const subtitle = String((ctx.body as any).subtitle || '').trim()

    if (id) {
      await db.collection(COL).where({ _id: id, userId }).update({
        time,
        drugCode,
        approvalNo,
        productName,
        subtitle,
        enabled,
        repeatRule,
        method,
        updatedAt: Date.now(),
      })
      return success({
        id,
        userId,
        time,
        drugCode,
        approvalNo,
        productName,
        subtitle,
        enabled,
        repeatRule,
        method,
      })
    }

    const { id: newId } = await db.collection(COL).add({
      userId,
      time,
      drugCode,
      approvalNo,
      productName,
      subtitle,
      enabled,
      repeatRule,
      method,
      createdAt: Date.now(),
      updatedAt: Date.now(),
    })
    return success({
      id: newId,
      userId,
      time,
      drugCode,
      approvalNo,
      productName,
      subtitle,
      enabled,
      repeatRule,
      method,
    })
  }

  if (fn.includes('reminder-delete')) {
    const userId = String((ctx.body as any).userId || '').trim()
    const id = String((ctx.body as any).id || '').trim()
    if (!userId) return fail('userId 不能为空')
    if (!id) return fail('id 不能为空')
    const { deleted } = await db.collection(COL).where({ _id: id, userId }).remove()
    return success(deleted === 1)
  }

  if (fn.includes('reminder-list')) {
    const userId = String((ctx.body as any).userId || '').trim()
    if (!userId) return fail('userId 不能为空')
    const { data } = await db.collection(COL).where({ userId }).orderBy('time', 'asc').get()
    const items = (data || []).map((r: any) => ({
      id: r._id,
      userId: r.userId,
      time: r.time || '',
      drugCode: r.drugCode || '',
      approvalNo: r.approvalNo || '',
      productName: r.productName || '',
      subtitle: r.subtitle || '',
      enabled: r.enabled !== false,
      repeatRule: r.repeatRule || 'daily',
      method: r.method || 'notification',
    }))
    return success({ items })
  }

  return fail('未知函数')
}
```

## 当前项目对应关系

- 接口用途:
  提供提醒计划的新增、更新、删除和列表查询能力。
- Flutter 端调用入口:
  `lib/api/reminder_api.dart` 的 `list()`、`upsert()`、`delete()`。
- `backend/src/handlers` 对应实现:
  暂未整理进 `backend/`。
- `backend/src/cloud` 对应云函数入口:
  暂未整理进 `backend/`。
- Sealos 云函数部署要点:
  当前仍可按本文档协议继续使用 Sealos 云函数；后续建议补成 `backend/` 中的 reminder 模块，方便和打卡、首页提醒联动。
- 后续迁移到云服务器时是否还能复用:
  协议和字段设计可以复用，但目前还没有抽成正式 handler。
