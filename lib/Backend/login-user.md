访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /login-user
公网访问路径: https://wty10hv6az.sealosbja.site/login-user

请求体:
- type: 1 (SVG登录) 或 2 (邮箱登录)
- username: string
- email: string (邮箱登录可传，和 username 二选一即可)
- password: string
- uuid: string (仅 SVG 登录时必填, send-code(type=1) 返回的 id)
- code: string|number (仅 SVG 登录时必填)

返回体:
- code: string
- msg: string
- result: user (脱敏)

说明:
- 邮箱登录(type=2) 不需要传 uuid 和 code

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

  const { type, username, email, password, code, uuid } = ctx.body

  const loginType = Number(type || 2)
  const currentUsername = String(username || email || '').trim()
  const currentPassword = String(password || '')
  const currentUuid = String(uuid || '')
  const currentCode = String(code || '')

  if (![1, 2].includes(loginType)) {
    return fail('无效的登录类型')
  }

  if (loginType === 1) {
    const { deleted } = await db
      .collection('codes')
      .where({
        type: 1,
        _id: currentUuid,
        code: Number(currentCode),
      })
      .remove()
    if (deleted !== 1) {
      return fail('验证码不正确！')
    }
  }

  if (!currentUsername || !currentPassword) {
    return fail('用户名或密码不能为空')
  }

  const encryptedPassword = createHash('sha256')
    .update(currentPassword)
    .digest('hex')

  let user = (
    await db
      .collection('users')
      .where({
        email: currentUsername,
        password: encryptedPassword,
      })
      .getOne()
  ).data

  if (!user) {
    user = (
      await db
        .collection('users')
        .where({
          username: currentUsername,
          password: encryptedPassword,
        })
        .getOne()
    ).data
  }

  if (!user) {
    user = (
      await db
        .collection('users')
        .where({
          phone: currentUsername,
          password: encryptedPassword,
        })
        .getOne()
    ).data
  }

  if (!user) {
    return fail('用户名或密码错误')
  }

  if (user.lock === 1) {
    return fail('用户已被锁定，请联系管理员！')
  }

  await db
    .collection('users')
    .where({ _id: user._id })
    .update({
      lastIp: ctx.headers['x-real-ip'],
      lastLoginTime: Date.now(),
    })

  const safeUser = {
    _id: user._id,
    username: user.username,
    email: user.email,
    phone: user.phone,
    name: user.name,
    type: user.type,
  }

  return success(safeUser, '登录成功！')
}
```

