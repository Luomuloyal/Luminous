访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /send-code
公网访问地址: https://wty10hv6az.sealosbja.site/send-code

用途:
- 统一发送三类验证码：
  - `svg`: 注册阶段的人机校验
  - `email`: 邮箱登录/注册验证码
  - `phone`: 手机号登录/注册验证码（阿里云短信认证）

请求体:
- `channel`: `'svg' | 'email' | 'phone'`
- `scene`: `'register' | 'login'`
- `target`: string（`email/phone` 必填，`svg` 不传）

返回体:
- `code`: string
- `msg`: string
- `result`
  - `channel=svg`: `{ id: string, svg: string }`
  - `channel=email|phone`: `{ id: string }`

说明:
- 邮箱验证码继续走现有邮件发送方案
- 手机验证码固定采用阿里云“短信认证”
- 建议所有验证码记录统一写入 `codes` 集合，字段包括：
  - `channel`
  - `scene`
  - `target`
  - `code`
  - `createdAt`
  - `expiredAt`

示例代码（Laf 云函数，TypeScript）
```typescript
import cloud from '@lafjs/cloud'
import captcha from 'svg-captcha'
import nodemailer from 'nodemailer'
import { sendPhoneAuthCode } from './aliyun-sms-auth'

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

  const channel = String((ctx.body as any).channel || '').trim()
  const scene = String((ctx.body as any).scene || 'login').trim()
  const target = String((ctx.body as any).target || '').trim()

  if (!['svg', 'email', 'phone'].includes(channel)) {
    return fail('channel 无效')
  }
  if (!['register', 'login'].includes(scene)) {
    return fail('scene 无效')
  }

  if (channel === 'svg') {
    return createSvgCode(scene)
  }
  if (!target) {
    return fail('target 不能为空')
  }

  if (channel === 'email') {
    return await sendEmailCode(target, scene as 'register' | 'login')
  }
  return await sendPhoneCode(target, scene as 'register' | 'login')
}

async function createSvgCode(scene: string) {
  const captchaData = captcha.create({
    size: 4,
    ignoreChars: '0oO1IiLl',
    noise: 3,
    color: true,
    background: '#EEE',
    charPreset: '12345689',
  })

  const { id } = await db.collection('codes').add({
    channel: 'svg',
    scene,
    target: '',
    code: Number(captchaData.text),
    createdAt: new Date(),
    expiredAt: new Date(Date.now() + 5 * 60 * 1000),
  })

  return success({ id, svg: captchaData.data })
}

async function sendEmailCode(email: string, scene: 'register' | 'login') {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(email)) {
    return fail('邮箱地址格式错误')
  }

  const code = Math.floor(100000 + Math.random() * 900000)

  const transportConfig = {
    host: 'smtp.qq.com',
    port: 465,
    secureConnection: true,
    auth: {
      user: '2508015296@qq.com',
      pass: '', // TODO: 填入授权码
    },
  }

  const mailOptions = {
    from: '"<laf>" <2508015296@qq.com>',
    to: email,
    subject: scene === 'register' ? 'Luminous 注册验证码' : 'Luminous 登录验证码',
    html: `您好，您的${scene === 'register' ? '注册' : '登录'}验证码为：${code}，5分钟内有效。`,
  }

  const transporter = nodemailer.createTransport(transportConfig)
  const { messageId } = await transporter.sendMail(mailOptions)
  if (!messageId) return fail('邮件发送异常，请稍后重试')

  const { id } = await db.collection('codes').add({
    channel: 'email',
    scene,
    target: email,
    code,
    createdAt: new Date(),
    expiredAt: new Date(Date.now() + 5 * 60 * 1000),
  })

  return success({ id }, '验证码已发送到邮箱，请注意查收')
}

async function sendPhoneCode(phone: string, scene: 'register' | 'login') {
  const phoneRegex = /^1[3-9]\d{9}$/
  if (!phoneRegex.test(phone)) {
    return fail('手机号格式不正确')
  }

  const result = await sendPhoneAuthCode(phone, scene)
  return success({ id: result.id }, '验证码已发送到手机，请注意查收')
}
```

## 当前项目对应关系

- 接口用途:
  统一提供 SVG 验证码、邮箱验证码和手机验证码发送能力。
- Flutter 端调用入口:
  `lib/api/auth_api.dart` 的 `fetchSvgCode()`、`sendEmailCode()`、`sendPhoneCode()`。
- `backend/src/handlers` 对应实现:
  暂未整理进 `backend/`。
- `backend/src/cloud` 对应云函数入口:
  暂未整理进 `backend/`。
- Sealos 云函数部署要点:
  当前可以继续按本文档协议维护 Sealos 云函数；后续建议把邮箱 / 手机 / SVG 三种通道统一并入 `backend/` 中的 `send-code` handler。
- 后续迁移到云服务器时是否还能复用:
  可以；这个接口非常适合后面整理成统一认证模块的一部分。
