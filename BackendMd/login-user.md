访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /login-user
公网访问路径: https://wty10hv6az.sealosbja.site/login-user

用途:
- 支持手机号/邮箱双栈登录
- 每种账号类型都支持：
  - 密码登录
  - 验证码登录

请求体:
- `identifierType`: `'email' | 'phone'`
- `loginMode`: `'password' | 'code'`
- `identifier`: string
- `password`: string（密码登录必填）
- `code`: string（验证码登录必填）
- `codeId`: string（验证码登录必填）

返回体:
- `code`: string
- `msg`: string
- `result`: `user`（脱敏）

特殊业务码:
- `NOT_REGISTERED`
  - 仅验证码登录时使用
  - 表示验证码校验通过，但当前手机号/邮箱尚未注册
  - 此时不要消费验证码，允许前端跳转注册页继续复用

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
  const loginMode = String((ctx.body as any).loginMode || '').trim()
  const identifier = String((ctx.body as any).identifier || '').trim()
  const password = String((ctx.body as any).password || '')
  const code = String((ctx.body as any).code || '').trim()
  const codeId = String((ctx.body as any).codeId || '').trim()

  if (!['email', 'phone'].includes(identifierType)) {
    return fail('identifierType 无效')
  }
  if (!['password', 'code'].includes(loginMode)) {
    return fail('loginMode 无效')
  }
  if (!identifier) {
    return fail(identifierType === 'email' ? '邮箱不能为空' : '手机号不能为空')
  }

  if (loginMode === 'password') {
    return loginWithPassword({ identifierType, identifier, password })
  }
  return loginWithCode({ identifierType, identifier, code, codeId })
}

async function loginWithPassword({
  identifierType,
  identifier,
  password,
}: {
  identifierType: string
  identifier: string
  password: string
}) {
  if (!password) {
    return fail('密码不能为空')
  }

  const encryptedPassword = createHash('sha256')
    .update(password)
    .digest('hex')

  const user = (
    await db
      .collection('users')
      .where(
        identifierType === 'email'
          ? { email: identifier, password: encryptedPassword }
          : { phone: identifier, password: encryptedPassword },
      )
      .getOne()
  ).data

  if (!user) {
    return fail('账号或密码错误')
  }
  if (user.lock === 1) {
    return fail('用户已被锁定，请联系管理员')
  }

  await touchLoginMeta(user._id)
  return success(toSafeUser(user), '登录成功')
}

async function loginWithCode({
  identifierType,
  identifier,
  code,
  codeId,
}: {
  identifierType: string
  identifier: string
  code: string
  codeId: string
}) {
  const isValid = await peekBusinessCode({
    codeId,
    channel: identifierType,
    target: identifier,
    scene: 'login',
    code,
  })
  if (!isValid) {
    return fail('验证码不正确或已过期')
  }

  const user = (
    await db
      .collection('users')
      .where(identifierType === 'email' ? { email: identifier } : { phone: identifier })
      .getOne()
  ).data

  if (!user) {
    return fail('该账号尚未注册，是否前往注册？', 'NOT_REGISTERED')
  }
  if (user.lock === 1) {
    return fail('用户已被锁定，请联系管理员')
  }

  await consumeBusinessCode(codeId)
  await touchLoginMeta(user._id)
  return success(toSafeUser(user), '登录成功')
}

async function peekBusinessCode({
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
  const record = await db.collection('codes').where({
    _id: codeId,
    channel,
    target,
    scene,
    code: Number(code),
  }).getOne()
  return !!record.data
}

async function consumeBusinessCode(codeId: string) {
  if (!codeId) return
  await db.collection('codes').where({ _id: codeId }).remove()
}

async function touchLoginMeta(userId: string) {
  await db
    .collection('users')
    .where({ _id: userId })
    .update({
      lastLoginTime: Date.now(),
    })
}

function toSafeUser(user: any) {
  return {
    _id: user._id,
    username: user.username,
    email: user.email,
    phone: user.phone,
    name: user.name,
    type: user.type,
  }
}
```

## 当前项目对应关系

- 接口用途:
  支持账号密码登录和验证码登录。
- Flutter 端调用入口:
  `lib/api/auth_api.dart` 的 `loginWithPassword()` 和 `loginWithCode()`。
- `backend/src/handlers` 对应实现:
  暂未整理进 `backend/`。
- `backend/src/cloud` 对应云函数入口:
  暂未整理进 `backend/`。
- Sealos 云函数部署要点:
  当前如果要继续在 Sealos 使用，仍然可以按本文档协议单独维护这个云函数；后续建议补成 `backend/` 中的认证模块。
- 后续迁移到云服务器时是否还能复用:
  协议和鉴权思路都能复用，但需要先把它整理成正式 handler。
