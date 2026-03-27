# Study

架构学习与问题定位文档目录。

## Goals

- 快速定位功能实现链路
- 提供重构与排障的阅读路径

## Recommended Reading

1. [00-Review-Summary.md](00-Review-Summary.md)
2. [01-App-Startup-and-Architecture.md](01-App-Startup-and-Architecture.md)
3. [02-Navigation-and-Main-Tabs.md](02-Navigation-and-Main-Tabs.md)
4. 按业务主题阅读 `03-11`

## Document Index

- [00-Review-Summary.md](00-Review-Summary.md): 风险与 review 结论
- [01-App-Startup-and-Architecture.md](01-App-Startup-and-Architecture.md): 启动流程与分层
- [02-Navigation-and-Main-Tabs.md](02-Navigation-and-Main-Tabs.md): 导航与主容器
- [03-Authentication.md](03-Authentication.md): 认证与用户态
- [04-Home-and-Today-Reminders.md](04-Home-and-Today-Reminders.md): 首页与提醒
- [05-Medicine-Search-and-Detail.md](05-Medicine-Search-and-Detail.md): 搜索与详情
- [06-Scan-Album-and-Safety.md](06-Scan-Album-and-Safety.md): 识别、相册、安全
- [07-Reminders-and-CheckIn.md](07-Reminders-and-CheckIn.md): 提醒与打卡
- [08-Local-Storage-and-Sync.md](08-Local-Storage-and-Sync.md): 本地存储与同步边界
- [09-Mine-Profile-and-User-State.md](09-Mine-Profile-and-User-State.md): 我的页与设置
- [10-Backend-and-Sealos.md](10-Backend-and-Sealos.md): 后端映射与部署
- [11-Android-Native-Startup.md](11-Android-Native-Startup.md): Android 原生侧

## Troubleshooting Entry Map

- 登录或用户状态: 先看 `03`、`09`
- 首页样式或提醒: 先看 `04`、`07`
- 识别或药品详情: 先看 `05`、`06`
- 本地缓存与同步: 先看 `08`
- 接口联调: 先看 `10`，再看 `backend/src/handlers`

## Related Docs

- 项目总览: [../README.md](../README.md)
- 后端文档入口: [../BackendMd/README.md](../BackendMd/README.md)
- 后端运行说明: [../backend/README.md](../backend/README.md)
- 部署配置清单: [../lib/docs/deployment-config.md](../lib/docs/deployment-config.md)
