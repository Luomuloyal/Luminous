访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /register-user
公网访问路径: https://wty10hv6az.sealosbja.site/register-user

用途:
- 手机号注册或邮箱注册
- 注册时必须同时通过：
  - 业务验证码（邮箱或手机）
  - SVG 验证码
  - 密码与确认密码由前端校验一致性

请求体:
- `identifierType`: `'email' | 'phone'`
- `email`: string
- `phone`: string
- `code`: string
- `codeId`: string
- `svgCode`: string
- `svgId`: string
- `password`: string

返回体:
- `code`: string
- `msg`: string
- `result`: `{ id: string }`

约束:
- `email` / `phone` 二选一且只能有一个有效值
- 用户名 `username` 直接等于当前注册标识（手机号或邮箱）
- `name` 使用脱敏规则生成默认展示名称

示例代码（Laf 云函数，TypeScript）
```typescript
import cloud from '@lafjs/cloud'
import { createHash } from 'crypto'

const db = cloud.database()

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

  const identifierType = String((ctx.body as any).identifierType || '').trim()
  const email = String((ctx.body as any).email || '').trim()
  const phone = String((ctx.body as any).phone || '').trim()
  const code = String((ctx.body as any).code || '').trim()
  const codeId = String((ctx.body as any).codeId || '').trim()
  const svgCode = String((ctx.body as any).svgCode || '').trim()
  const svgId = String((ctx.body as any).svgId || '').trim()
  const password = String((ctx.body as any).password || '')

  if (!['email', 'phone'].includes(identifierType)) {
    return fail('identifierType 无效')
  }
  if (!password || password.length < 6) {
    return fail('密码不能小于6位')
  }

  const identifier = identifierType === 'email' ? email : phone
  if (!identifier) {
    return fail(identifierType === 'email' ? '邮箱不能为空' : '手机号不能为空')
  }

  const exists = await db
    .collection('users')
    .where(identifierType === 'email' ? { email: identifier } : { phone: identifier })
    .getOne()
  if (exists.data) {
    return fail(identifierType === 'email' ? '邮箱已经注册' : '手机号已经注册')
  }

  const codeValid = await consumeBusinessCode({
    codeId,
    channel: identifierType,
    target: identifier,
    scene: 'register',
    code,
  })
  if (!codeValid) {
    return fail('业务验证码不正确或已过期')
  }

  const svgValid = await consumeSvgCode(svgId, svgCode)
  if (!svgValid) {
    return fail('SVG验证码不正确或已过期')
  }

  const encryptedPassword = createHash('sha256')
    .update(password)
    .digest('hex')

  const { id } = await db.collection('users').add({
    username: identifier,
    email: identifierType === 'email' ? email : '',
    phone: identifierType === 'phone' ? phone : '',
    type: identifierType === 'email' ? 2 : 3,
    name: maskName(identifier),
    password: encryptedPassword,
    createTime: Date.now(),
  })

  return success({ id }, '用户注册成功')
}

async function consumeBusinessCode({
  codeId,
  channel,
  target,
  scene,
  code,
}: {
  codeId: string
  channel: string
  target: string
  scene: string
  code: string
}) {
  if (!codeId || !target || !code) return false
  const { deleted } = await db
    .collection('codes')
    .where({
      _id: codeId,
      channel,
      target,
      scene,
      code: Number(code),
    })
    .remove()
  return deleted === 1
}

async function consumeSvgCode(svgId: string, svgCode: string) {
  if (!svgId || !svgCode) return false
  const { deleted } = await db
    .collection('codes')
    .where({
      _id: svgId,
      channel: 'svg',
      scene: 'register',
      code: Number(svgCode),
    })
    .remove()
  return deleted === 1
}

function maskName(name: string) {
  if (!name) return ''
  if (name.length > 10) {
    return `${name.substring(0, 3)}****${name.substring(7)}`
  }
  if (name.length > 6) {
    return `${name.substring(0, 2)}***${name.substring(name.length - 2)}`
  }
  return name
}
```

## 当前项目对应关系

- 接口用途:
  支持邮箱或手机号注册，同时校验业务验证码和 SVG 验证码。
- Flutter 端调用入口:
  `lib/api/auth_api.dart` 的 `registerWithEmail()` 和 `registerWithPhone()`。
- `backend/src/handlers` 对应实现:
  暂未整理进 `backend/`。
- `backend/src/cloud` 对应云函数入口:
  暂未整理进 `backend/`。
- Sealos 云函数部署要点:
  目前可以继续按本文档协议单独维护注册云函数；后续建议和登录、验证码能力一起整理成认证模块。
- 后续迁移到云服务器时是否还能复用:
  可以，尤其是请求体和校验流程都能沿用，但需要补正式 Node 代码。
