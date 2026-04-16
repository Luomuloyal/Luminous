# Study

架构学习与问题定位文档目录。

非 README 的 Study Markdown 已统一整理到仓库根目录 `.md/study/` 下，本目录保留导航说明。

## Goals

- 快速定位功能实现链路
- 提供重构与排障的阅读路径

## Recommended Reading

1. [../.md/study/00-Review-Summary.md](../.md/study/00-Review-Summary.md)
2. [../.md/study/01-App-Startup-and-Architecture.md](../.md/study/01-App-Startup-and-Architecture.md)
3. [../.md/study/02-Navigation-and-Main-Tabs.md](../.md/study/02-Navigation-and-Main-Tabs.md)
4. 按业务主题阅读 `03-09` 与 `11`

## Document Index

- [../.md/study/00-Review-Summary.md](../.md/study/00-Review-Summary.md): 风险与 review 结论
- [../.md/study/01-App-Startup-and-Architecture.md](../.md/study/01-App-Startup-and-Architecture.md): 启动流程与分层
- [../.md/study/02-Navigation-and-Main-Tabs.md](../.md/study/02-Navigation-and-Main-Tabs.md): 导航与主容器
- [../.md/study/03-Authentication.md](../.md/study/03-Authentication.md): 认证与用户态
- [../.md/study/04-Home-and-Today-Reminders.md](../.md/study/04-Home-and-Today-Reminders.md): 首页与提醒
- [../.md/study/05-Medicine-Search-and-Detail.md](../.md/study/05-Medicine-Search-and-Detail.md): 搜索与详情
- [../.md/study/06-Scan-Album-and-Safety.md](../.md/study/06-Scan-Album-and-Safety.md): 识别、相册、安全
- [../.md/study/07-Reminders-and-CheckIn.md](../.md/study/07-Reminders-and-CheckIn.md): 提醒与打卡
- [../.md/study/08-Local-Storage-and-Sync.md](../.md/study/08-Local-Storage-and-Sync.md): 本地存储与同步边界
- [../.md/study/09-Mine-Profile-and-User-State.md](../.md/study/09-Mine-Profile-and-User-State.md): 我的页与设置
- [../.md/study/11-Android-Native-Startup.md](../.md/study/11-Android-Native-Startup.md): Android 原生侧

## Troubleshooting Entry Map

- 登录或用户状态: 先看 `03`、`09`
- 首页样式或提醒: 先看 `04`、`07`
- 识别或药品详情: 先看 `05`、`06`
- 本地缓存与同步: 先看 `08`
- 接口联调: 先看 `.md/lib-docs/backend-api.md`，再看 `backend/src/handlers`
- 后端端口占用或服务编排: 先看 `../backend/README.md` 的 Docker 与端口排查章节

## Related Docs

- 项目总览: [../README.md](../README.md)
- 后端运行说明: [../backend/README.md](../backend/README.md)
- 部署配置清单: [../.md/lib-docs/deployment-config.md](../.md/lib-docs/deployment-config.md)
