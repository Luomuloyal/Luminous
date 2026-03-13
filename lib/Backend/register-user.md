访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /register-user

支持方式:
- 邮箱注册: type=2, codeType=2
- SVG注册: type=1, codeType=1, 额外传 uuid

```typescript
import cloud from '@lafjs/cloud'
import { createHash } from 'crypto'

const db = cloud.database()

export async function main(ctx: FunctionContext) {
  if (!ctx.body || typeof ctx.body !== 'object') {
    return { ok: false, msg: '请求参数格式错误' }
  }

  const {
    type,
    username,
    phone,
    email,
    password,
    code,
    codeType,
    uuid,
  } = ctx.body

  const registerType = Number(type)
  const currentCodeType = Number(codeType)
  const currentUsername = String(username || '').trim()
  const currentEmail = String(email || '').trim()
  const currentPhone = String(phone || '').trim()
  const currentPassword = String(password || '')

  if (![1, 2].includes(registerType)) {
    return { ok: false, msg: '无效的注册类型' }
  }

  if (!currentUsername && !currentPhone && !currentEmail) {
    return { ok: false, msg: '用户名/手机号/邮箱不能为空' }
  }

  if (!currentPassword || currentPassword.length < 6) {
    return { ok: false, msg: '密码不能小于6位!' }
  }

  const encryptedPassword = createHash('sha256')
    .update(currentPassword)
    .digest('hex')

  const existedByUsername = await db
    .collection('users')
    .where({ username: currentUsername })
    .getOne()
  if (existedByUsername.data) {
    return { ok: false, msg: '用户名已经存在！' }
  }

  if (registerType === 2 && currentEmail) {
    const existedByEmail = await db
      .collection('users')
      .where({ email: currentEmail })
      .getOne()
    if (existedByEmail.data) {
      return { ok: false, msg: '邮箱已经注册！' }
    }
  }

  const isCodeValid =
    registerType === 1
      ? await consumeSvgCode(String(uuid || ''), String(code || ''))
      : await consumeEmailCode(currentEmail || currentUsername, String(code || ''))

  if (!isCodeValid) {
    return { ok: false, msg: '验证码不正确！' }
  }

  const displayName = currentUsername || currentEmail || currentPhone
  const { id } = await db.collection('users').add({
    username: currentUsername,
    email: registerType === 2 ? currentEmail : '',
    phone: currentPhone,
    type: registerType,
    name: maskName(displayName),
    password: encryptedPassword,
    createTime: Date.now(),
  })

  return {
    ok: true,
    msg: '用户注册成功！',
    data: { id },
  }
}

async function consumeEmailCode(email: string, code: string) {
  if (!email || !code) return false
  const { deleted } = await db.collection('codes').where({
    type: 2,
    name: email,
    code: Number(code),
  }).remove()
  return deleted === 1
}

async function consumeSvgCode(uuid: string, code: string) {
  if (!uuid || !code) return false
  const { deleted } = await db.collection('codes').where({
    _id: uuid,
    type: 1,
    code: Number(code),
  }).remove()
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
