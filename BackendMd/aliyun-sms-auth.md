访问地址: 阿里云短信认证

用途:
- 用于手机号验证码发送与校验
- 当前项目手机号登录/注册验证码固定采用“短信认证”，不采用传统 SMS 服务

为什么不用传统 SMS:
- 当前场景是“个人开发者 + 注册登录验证码”
- 阿里云官方对个人开发者验证码场景推荐使用“短信认证”
- 相比短信服务 SMS，短信认证更贴合验证码发送/校验场景，接入门槛更低

官方文档:
- 短信服务主页: https://help.aliyun.com/zh/sms/
- 个人开发者验证码场景说明: https://help.aliyun.com/zh/pnvs/use-cases/sms-verify-for-individual-developers

建议环境变量:
- `ALIYUN_ACCESS_KEY_ID`
- `ALIYUN_ACCESS_KEY_SECRET`
- `ALIYUN_SMS_AUTH_ENDPOINT`
- `ALIYUN_SMS_AUTH_SCENE_ID`

推荐封装:
- `sendPhoneAuthCode(phone, scene)`：发送手机号验证码，返回 `{ id }`
- `verifyPhoneAuthCode({ phone, code, codeId, scene })`：校验验证码，返回 `true/false`

说明:
- `scene` 建议沿用前端契约：`register` / `login`
- `codeId` 建议映射为短信认证返回的请求流水号或业务侧自建验证码记录 id
- 若阿里云返回的是“已发送，但校验需走独立接口”的模式，后端应把校验依赖信息写入 `codes` 集合，再在 `login-user` / `register-user` 中消费

示例代码（示意，Laf 云函数/共享 helper）
```typescript
function mustEnv(name: string) {
  const value = String(process.env[name] || '').trim()
  if (!value) {
    throw new Error(`缺少环境变量: ${name}`)
  }
  return value
}

export async function sendPhoneAuthCode(phone: string, scene: 'register' | 'login') {
  // TODO: 按阿里云短信认证官方 SDK / OpenAPI 实际调用方式接入
  // 官方资料:
  // - https://help.aliyun.com/zh/sms/
  // - https://help.aliyun.com/zh/pnvs/use-cases/sms-verify-for-individual-developers

  const fakeRequestId = `sms_${Date.now()}`
  return { id: fakeRequestId }
}

export async function verifyPhoneAuthCode({
  phone,
  code,
  codeId,
  scene,
}: {
  phone: string
  code: string
  codeId: string
  scene: 'register' | 'login'
}) {
  // TODO: 按阿里云短信认证官方校验接口实现
  // 若短信认证产品线本身不返回可直接复用的 codeId，
  // 推荐在 send-code 阶段同步把 phone/scene/code/expiredAt 写入 `codes` 集合。
  return true
}
```

## 当前项目对应关系

- 接口用途:
  这是短信验证码能力的底层思路文档，通常作为 `send-code` 的手机号发送能力来源。
- Flutter 端调用入口:
  无独立 HTTP 入口；当前由 `lib/api/auth_api.dart` 的 `sendPhoneCode()` 间接依赖这类能力。
- `backend/src/handlers` 对应实现:
  暂未整理进 `backend/`。
- `backend/src/cloud` 对应云函数入口:
  暂未整理进 `backend/`。
- Sealos 云函数部署要点:
  目前如果你要继续用它，建议按本文档思路先在 Sealos 中手写短信发送逻辑，后续再统一并入 `send-code` 对应 handler。
- 后续迁移到云服务器时是否还能复用:
  可以复用思路，但当前还没有整理成 `backend/` 里的正式 provider 或 handler。
