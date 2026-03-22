访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /today-reminders
公网访问路径: https://wty10hv6az.sealosbja.site/today-reminders

用途:
- 首页“今日提醒”内容

请求体:
- date: string (可选, YYYY-MM-DD, 默认今天)
- userId: string (可选, 预留用户维度)

返回体:
- code: string
- msg: string
- result:
  - date: string
  - items: ReminderItem[]

ReminderItem 字段:
- id: string
- time: string (例如 19:30)
- title: string (例如 阿莫西林)
- subtitle: string (例如 晚餐后服用 1 粒)
- done: boolean

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

  const date = String((ctx.body as any).date || '').trim() || new Date().toISOString().slice(0, 10)

  // TODO: 后续可按 userId + date 从数据库读取用户自己的提醒计划
  return success({
    date,
    items: [
      {
        id: '1',
        time: '08:30',
        title: '维生素D',
        subtitle: '早餐后服用 1 粒',
        done: true,
      },
      {
        id: '2',
        time: '19:30',
        title: '阿莫西林',
        subtitle: '晚餐后服用 1 粒',
        done: false,
      },
      {
        id: '3',
        time: '22:00',
        title: '血压记录',
        subtitle: '睡前记录并上传',
        done: false,
      },
    ],
  })
}
```

## 当前项目对应关系

- 接口用途:
  拉取当天提醒数据，主要服务首页和今日提醒展示。
- Flutter 端调用入口:
  `lib/api/home_api.dart` 的 `HomeApi.fetchTodayReminders()`。
- `backend/src/handlers` 对应实现:
  暂未整理进 `backend/`。
- `backend/src/cloud` 对应云函数入口:
  暂未整理进 `backend/`。
- Sealos 云函数部署要点:
  当前可以继续按本文档协议保留 Sealos 云函数；后续建议结合 `reminder` 和 `checkin` 模块一起整理进 `backend/`。
- 后续迁移到云服务器时是否还能复用:
  可以，特别适合以后做成首页聚合查询接口。
