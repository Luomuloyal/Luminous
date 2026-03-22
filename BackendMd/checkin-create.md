访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /checkin-create
公网访问路径: https://wty10hv6az.sealosbja.site/checkin-create

用途:
- 用药打卡: 对某个 reminderId 记录一次服药/完成

请求体:
- userId: string (必填)
- reminderId: string (必填)
- takenAt: number (可选，毫秒时间戳，默认当前时间)

返回体:
- code: string
- msg: string
- result: { id: string }

说明:
- 后端可按 userId + reminderId + date 做“今日是否完成”判断（对应 today-reminders.done）

```typescript
import cloud from '@lafjs/cloud'

const db = cloud.database()
const COL = 'checkins'

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

  const userId = String((ctx.body as any).userId || '').trim()
  const reminderId = String((ctx.body as any).reminderId || '').trim()
  const takenAt = Number((ctx.body as any).takenAt || Date.now())

  if (!userId) return fail('userId 不能为空')
  if (!reminderId) return fail('reminderId 不能为空')

  const { id } = await db.collection(COL).add({
    userId,
    reminderId,
    takenAt,
    createdAt: Date.now(),
  })
  return success({ id })
}
```

## 当前项目对应关系

- 接口用途:
  创建一条用药打卡记录，通常由提醒页或首页打卡入口触发。
- Flutter 端调用入口:
  `lib/api/checkin_api.dart` 的 `CheckinApi.create()`。
- `backend/src/handlers` 对应实现:
  暂未整理进 `backend/`。
- `backend/src/cloud` 对应云函数入口:
  暂未整理进 `backend/`。
- Sealos 云函数部署要点:
  当前可以继续按本文档协议在 Sealos 单独保留这个云函数；后续建议补成 `backend/src/handlers/checkin-create.ts` 和 `backend/src/cloud/checkin-create.ts`。
- 后续迁移到云服务器时是否还能复用:
  接口协议和业务思路可以复用，但需要先整理成 `backend/` 里的正式实现。
