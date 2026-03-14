访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /send-code
公网访问地址: https://wty10hv6az.sealosbja.site/send-code

请求体:
- type: 1 (SVG验证码) 或 2 (邮箱验证码)
- value: 邮箱地址 (当 type=2 时必填)

返回体:
- code: string
- msg: string
- result:
  - type=1: { id: string, svg: string }
  - type=2: { id: string }

```typescript
import cloud from '@lafjs/cloud'
import captcha from 'svg-captcha'
import nodemailer from 'nodemailer'

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

  const type = Number(ctx.body.type)
  const value = ctx.body.value

  if (type === 2) {
    if (!value) return fail('邮箱地址不能为空')
    return await codeEmail(String(value))
  }

  return await codeSvg()
}

export async function codeSvg() {
  const options = {
    size: 4,
    ignoreChars: '0oO1IiLl',
    noise: 3,
    color: true,
    background: '#EEE',
    charPreset: '12345689',
  }
  const captchaData = captcha.create(options)

  try {
    const { id } = await db.collection('codes').add({
      type: 1,
      code: Number(captchaData.text),
      createdAt: new Date(),
      expiredAt: new Date(Date.now() + 5 * 60 * 1000),
    })

    return success({ id, svg: captchaData.data })
  } catch (e) {
    console.error('数据库写入失败:', e)
    return fail('生成验证码失败，请重试')
  }
}

export async function codeEmail(email: string) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(email)) {
    return fail('邮箱地址格式错误!')
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
    subject: 'Luminous注册验证码',
    html: `您好, 感谢您使用Luminous, 您的注册验证码为: ${code} , 5分钟内有效!`,
  }

  try {
    const transporter = nodemailer.createTransport(transportConfig)
    const { messageId } = await transporter.sendMail(mailOptions)
    if (!messageId) return fail('邮件发送异常，请稍后重试')

    const { id } = await db.collection('codes').add({
      type: 2,
      name: email,
      code,
      createdAt: new Date(),
      expiredAt: new Date(Date.now() + 5 * 60 * 1000),
    })

    return success({ id }, '验证码已发送到邮箱，请注意查收!')
  } catch (error) {
    console.error('邮件发送失败:', error)
    return fail('邮件发送失败，请检查邮箱地址或稍后重试')
  }
}
```

