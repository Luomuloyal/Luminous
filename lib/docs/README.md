# 项目文档目录

本目录存放面向开发与部署的规范化文档。

## 文档清单

- [backend-api.md](backend-api.md): App 后端 API 协议与示例
- [deployment-config.md](deployment-config.md): Flutter/App 后端/网站前后端部署配置清单

## 使用建议

1. 联调接口前先看 `backend-api.md`，确认路径、参数和返回结构。
2. 上线前按 `deployment-config.md` 的核对清单逐项确认。
3. 如果代码和文档不一致，以代码为准并及时回写文档。
4. 本地整套服务建议使用根目录 `docker compose up -d --build` 启动（backend + MongoDB + Redis + MySQL）。

## 相关入口

- 后端服务说明: [../../backend/README.md](../../backend/README.md)
- 项目总览: [../../README.md](../../README.md)
