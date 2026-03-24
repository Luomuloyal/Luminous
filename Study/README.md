# Luminous Study

这个目录是给你以后自己回头学习项目时用的“代码学习手册”，不是对外展示文档，也不是简单的功能清单。

它的目标只有两个：

- 帮你快速找到某个功能真正的实现入口
- 帮你在以后重构、修 bug、补接口时，知道应该先看哪里，再看哪里

## 这个目录怎么用

第一次读这个项目时，不建议从某个页面文件一路硬看下去。更稳的方式是：

1. 先看 `00-Review-Summary.md`，知道这份代码目前有哪些真实风险、哪些地方以后要特别小心。
2. 再看 `01-App-Startup-and-Architecture.md`，先把“应用怎么启动、全局状态在哪里、层次怎么分”搞清楚。
3. 然后看 `02-Navigation-and-Main-Tabs.md`，知道页面是怎么组织起来的。
4. 最后再按功能去看 `03` 到 `11`。

如果你不是想“系统学习”，而是想“马上定位一个功能”，可以直接按下面的路径走。

## 推荐阅读路径

### 路线 A：先理解架构，再看功能

适合第一次完整消化项目时走。

1. `00-Review-Summary.md`
2. `01-App-Startup-and-Architecture.md`
3. `02-Navigation-and-Main-Tabs.md`
4. `08-Local-Storage-and-Sync.md`
5. 再按兴趣或当前任务去看 `03` 到 `11`

### 路线 B：手上有 bug，要尽快定位

适合你以后“先修问题，再顺手学习”。

1. 先从 bug 所在页面对应的 Study 文档入手
2. 看文档里的“核心实现路径”和“关键代码位置”
3. 再顺着 `pages -> stores/api -> 本地存储/后端` 去读源码

你可以按下面的归类来选入口：

- 登录 / 注册 / 验证码：看 `03-Authentication.md`
- 首页顶部色块 / 小贴士 / 今日提醒：看 `04-Home-and-Today-Reminders.md`
- 药品搜索 / 详情 / AI 解读：看 `05-Medicine-Search-and-Detail.md`
- 拍照识别 / 相册 / 用药安全：看 `06-Scan-Album-and-Safety.md`
- 提醒计划 / 本地打卡 / 通知：看 `07-Reminders-and-CheckIn.md`
- SQLite / 用户作用域 / 同步：看 `08-Local-Storage-and-Sync.md`
- 我的页 / 设置 / 暗黑模式 / 退出登录：看 `09-Mine-Profile-and-User-State.md`
- 后端代码 / Sealos 云函数：看 `10-Backend-and-Sealos.md`
- Android 原生启动屏 / 原生保存相册：看 `11-Android-Native-Startup.md`

### 路线 C：以后想自己接手后端

这条路线适合你后面学 Node.js 时配合看。

1. 根目录 `README.md`
2. `BackendMd/README.md`
3. `Study/10-Backend-and-Sealos.md`
4. `backend/README.md`
5. 再进入 `backend/src/handlers` 和 `backend/src/cloud`

## 建议你怎么把文档和真实代码配合起来看

### 先看“入口文件”，不要一上来就钻组件细节

比如你要看认证功能，不要先盯着 `TextFormField`，而是先看：

1. 页面入口在哪
2. 提交函数是哪一个
3. 提交函数调了哪个 API / store
4. 返回结果最后怎么回到 UI

这样你读的是“链路”，不是“零散代码块”。

### 看到 `pages/` 不代表已经看完整个功能

这个项目的大多数功能都会跨几层：

- `pages/` 负责页面和交互
- `components/` 负责可复用 UI
- `stores/` 负责共享状态、本地缓存、同步
- `api/` 负责 HTTP 调用
- `viewmodels/` 负责接口数据模型
- `backend/src/` 负责真正的服务端实现
- `android/` 负责原生启动屏、相册保存等平台能力

所以读页面时，一定要问自己一句：这个页面显示的数据到底从哪里来？

### 如果只是想改文案或 UI，优先找页面和组件

通常先看：

- `lib/pages/` 对应页面
- `lib/components/` 对应卡片、列表、弹窗、顶部横幅

### 如果看见“数据不对”或“状态残留”，优先看 store 和本地存储

通常先看：

- `lib/stores/`
- `lib/api/`
- `lib/stores/app_database.dart`

### 如果前端和接口对不上，先确认是“当前正式后端”还是“历史文档接口”

这个仓库里有三份和后端相关的资料，定位不一样：

- `lib/Backend/`：最早的接口草稿和思路来源
- `BackendMd/`：保留学习风格的整理版文档
- `backend/`：当前正式的 TypeScript 后端代码

以后你要确认“现在代码真正调用了什么”，优先看 `backend/` 和 `lib/api/`，不要只看旧文档。

## 各文档分工

- `00-Review-Summary.md`
  这轮全仓库 review 的 findings、风险优先级和处理状态。修 bug 前先看这篇最省时间。
- `01-App-Startup-and-Architecture.md`
  应用入口、依赖注入、主题恢复、首帧后 warmup、全局目录分层。
- `02-Navigation-and-Main-Tabs.md`
  路由表、底部 Tab 容器、按需挂载、默认页面过渡以及“为什么切 tab 不会重建页面”。
- `03-Authentication.md`
  登录、注册、验证码、用户态持久化、token、登录后同步。
- `04-Home-and-Today-Reminders.md`
  首页顶部卡片、健康小贴士、今日提醒快照和首页渲染链路。
- `05-Medicine-Search-and-Detail.md`
  药品搜索、结果列表、详情页、AI 解读入口。
- `06-Scan-Album-and-Safety.md`
  拍照识别、相册、缩略图、本地记录和用药安全辅助。
- `07-Reminders-and-CheckIn.md`
  提醒计划、用药打卡、通知调度，以及当前“纯本地打卡”的实现。
- `08-Local-Storage-and-Sync.md`
  SQLite、SharedPreferences、用户作用域、同步边界和本地缓存职责划分。
- `09-Mine-Profile-and-User-State.md`
  我的页、资料卡、设置页、暗黑模式、退出登录和用户状态联动。
- `10-Backend-and-Sealos.md`
  `backend/src` 的分层、5 个已实现接口、handler/cloud 映射、Sealos 打包部署。
- `11-Android-Native-Startup.md`
  Android 12 系统启动屏、Manifest、主题资源、矢量启动图标和 `MainActivity`。

## 配合哪些文档一起看最省力

- 想知道项目整体现状：先看根目录 `README.md`
- 想学 Sealos 云函数和旧接口设计：看 `BackendMd/README.md`
- 想看正式后端代码怎么部署：看 `backend/README.md`
- 想知道曾经 review 出来的问题：看 `Study/00-Review-Summary.md`

## 建议你以后维护这套文档时遵守的规则

- 如果代码结构改了，优先更新这里的“关键代码位置”
- 如果功能策略变了，要先改文档里“核心实现路径”，再补充细节
- 如果某个问题已经修复，优先同步 `00-Review-Summary.md`
- 如果新增一个大功能，最好在 `Study/` 里单独补一篇，而不是把信息散落到多个文档里

这批文档默认基于当前仓库状态书写。以后你每做一次明显重构，最值得先更新的是：

1. `Study/README.md`
2. `Study/01-App-Startup-and-Architecture.md`
3. 对应功能那一篇 Study 文档
