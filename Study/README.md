# Luminous Study

这个目录是给你以后自己回头学习项目时用的索引文档，不是对外展示文档。

建议阅读顺序：

1. `00-Review-Summary.md`
2. `01-App-Startup-and-Architecture.md`
3. `02-Navigation-and-Main-Tabs.md`
4. 再按具体功能挑 `03` 到 `11`

各文档分工：

- `00-Review-Summary.md`
  这轮全仓库 review 的重点问题、风险和优先级建议。
- `01-App-Startup-and-Architecture.md`
  从 `main.dart` 开始看应用是怎么启动、注入依赖、首帧后预热的。
- `02-Navigation-and-Main-Tabs.md`
  看路由表、底部 Tab 容器和全局页面切换动画。
- `03-Authentication.md`
  看登录、注册、验证码、用户态持久化和登录后同步。
- `04-Home-and-Today-Reminders.md`
  看首页顶部卡片、健康小贴士和今日提醒数据流。
- `05-Medicine-Search-and-Detail.md`
  看手动搜索、药品选择器、详情页和 AI 解读。
- `06-Scan-Album-and-Safety.md`
  看药品识别、相册、本地缩略图和安全辅助。
- `07-Reminders-and-CheckIn.md`
  看提醒列表、提醒编辑、打卡和通知调度。
- `08-Local-Storage-and-Sync.md`
  看 SQLite、本地缓存、会话同步和用户作用域隔离。
- `09-Mine-Profile-and-User-State.md`
  看“我的”页面、登录态联动和退出流程。
- `10-Backend-and-Sealos.md`
  看 `backend/src` 的分层、handler/cloud 映射和 Sealos 打包入口。
- `11-Android-Native-Startup.md`
  看 Android 原生启动屏、Manifest、主题和原生相册保存通道。

辅助阅读建议：

- 想快速定位一个页面先去看 `lib/pages/`
- 想看 UI 拆分再去 `lib/components/`
- 想看接口契约先去 `lib/api/` 和 `lib/viewmodels/`
- 想看后端背景资料先配合 `BackendMd/README.md`

这批文档默认基于当前仓库状态写成，如果以后你改了文件结构，优先先更新这里的行号锚点。
