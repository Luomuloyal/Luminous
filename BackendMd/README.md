# BackendMd

后端协议与实现映射文档目录。

## Purpose

- 定义接口协议（请求/响应/业务语义）
- 建立 Flutter 调用与后端实现的映射
- 为后续 API 变更提供文档基线

## Project Relationship

- `backend/`: 当前可部署后端代码
- `lib/Backend/`: 历史草稿文档
- `lib/docs/`: 标准化 API 与部署文档

## Reading Order

1. [../README.md](../README.md)
2. [../backend/README.md](../backend/README.md)
3. 本目录“已实现接口”文档

## Implemented API Docs

- [medicine-search.md](medicine-search.md)
- [medicine-detail.md](medicine-detail.md)
- [medicine-ai-detail.md](medicine-ai-detail.md)
- [medicine-ai-safety.md](medicine-ai-safety.md)
- [medicine-scan.md](medicine-scan.md)

Code mapping:

- `backend/src/handlers/*`
- `backend/src/routes/api.ts`

## Planned or Legacy Docs

- [send-code.md](send-code.md)
- [register-user.md](register-user.md)
- [login-user.md](login-user.md)
- [my-medicine.md](my-medicine.md)
- [today-reminders.md](today-reminders.md)
- [reminder.md](reminder.md)
- [checkin-create.md](checkin-create.md)
- [scan-record.md](scan-record.md)
- [aliyun-sms-auth.md](aliyun-sms-auth.md)

这些文档可能与当前实现存在偏差，联调时请优先以 `backend/src` 为准。

## Documentation Convention

建议每篇接口文档包含：

1. 接口目的
2. 请求参数
3. 成功/失败示例
4. Flutter 调用入口
5. 后端实现入口
6. 变更记录

## Quick Links

- API 总览: [../lib/docs/backend-api.md](../lib/docs/backend-api.md)
- 部署配置: [../lib/docs/deployment-config.md](../lib/docs/deployment-config.md)
