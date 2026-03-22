# Luminous

Luminous 是一个以 Flutter 为主的健康助手应用，当前重点覆盖药品搜索、药品详情、药品识别、用药提醒、安全辅助和本地相册等能力。

这份 README 主要面向你自己后续维护项目使用，所以它更像开发手册，而不是公开展示型项目首页。

## 项目简介

当前项目的目标是做一个偏轻量、移动端优先的健康助手：

- Flutter 负责 Android 端主应用
- 后端目前优先走 Sealos 云函数
- 药品基础数据来自 MySQL
- AI 能力目前基于豆包 / 火山方舟

现阶段你不需要先学完 Node.js 再把项目跑起来。推荐路径是：

- 先继续用 Sealos 云函数
- 一边看 `BackendMd/` 文档，一边理解接口
- 以后再把 `backend/` 迁到云服务器

## 当前技术结构

- 前端：Flutter
- 后端部署方式：Sealos 云函数优先
- 后端代码基础：`Node + TypeScript`
- 数据库：MySQL
- AI 服务：豆包 / 火山方舟

## 仓库目录说明

几个最重要的目录如下：

- `lib/`
  Flutter 主代码目录，页面、组件、API 封装、viewmodels 都在这里。
- `lib/Backend/`
  最早的后端接口草稿文档，原始思路来源，保留不动。
- `BackendMd/`
  现在的后端学习文档目录。这里保留 `.md` 风格，并补了 Flutter 调用入口、`backend/` 代码映射和 Sealos 部署说明。
- `backend/`
  真正的后端代码目录。现在已经整理成可以打包云函数、以后也能迁移到云服务器的 `Node + TypeScript` 结构。
- `android/`
  Android 原生工程，启动屏、主题、清单配置等都在这里。
- `test/`
  Flutter 测试目录。

## 前端运行方式

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 运行应用

```bash
flutter run
```

### 3. 常用检查命令

```bash
flutter analyze
flutter test
```

### 4. 接口基址配置位置

Flutter 当前请求地址配置在：

- `lib/constants/constants.dart`

如果你后端域名变了，通常只需要改：

- `GlobalConstants.BASE_URL`

## 后端现状

当前推荐部署路径是 Sealos 云函数，而不是直接上云服务器。

原因很简单：

- 你现在已经能直接用云函数跑接口
- 你还在学习 Node.js，先不用把精力花在服务器运维上
- 现在 `backend/` 已经帮你整理成了以后能迁服务器的基础代码，所以这一步不会白做

也就是说，当前后端是“两条线并行”：

- `BackendMd/` 负责学习和查文档
- `backend/` 负责真正的代码实现和后续迁移基础

## 后端学习路径

推荐你按这个顺序看：

1. 先看 [BackendMd/README.md](BackendMd/README.md)
2. 再看 `BackendMd/` 里的 5 个已实现接口文档
3. 然后去看 `backend/src/handlers`
4. 最后再看 `backend/src/cloud` 和 `backend/src/routes`

如果你只是想先把功能跑起来：

1. 看 `BackendMd/README.md` 的 Sealos 最短路径
2. 去 `backend/` 填环境变量
3. 执行打包命令
4. 把生成的 bundle 上传到 Sealos

## AI 接口说明

Flutter 侧已经对接了这几个 AI / 药品相关接口：

- `/medicine-search`
- `/medicine-detail`
- `/medicine-ai-detail`
- `/medicine-ai-safety`
- `/medicine-scan`

对应的前端 API 封装在：

- `lib/api/medicine_api.dart`
- `lib/api/safety_api.dart`
- `lib/api/scan_api.dart`

对应的后端代码在：

- `backend/src/handlers`
- `backend/src/cloud`

## Sealos 云函数使用流程

如果你现在继续走 Sealos，建议按下面这条最短路径：

### 1. 配置环境变量

在 `backend/` 里复制：

```bash
Copy-Item .env.example .env
```

然后补齐：

- MySQL 连接信息
- 豆包 API Key
- 豆包文本 / 视觉 endpoint

### 2. 安装依赖

```bash
cd backend
npm install
```

### 3. 打包云函数

```bash
npm run build:cloud
```

当前会生成这些单文件云函数：

- `dist/cloud-bundle/medicine-search.js`
- `dist/cloud-bundle/medicine-detail.js`
- `dist/cloud-bundle/medicine-ai-detail.js`
- `dist/cloud-bundle/medicine-ai-safety.js`
- `dist/cloud-bundle/medicine-scan.js`

### 4. 上传到 Sealos

把上面的单文件上传到 Sealos 云函数即可。

当前云函数只需要重点理解这三件事：

- 单文件 bundle
- `exports.main = async (ctx) => { ... }`
- 环境变量

### 5. 对应文档入口

- 学习文档入口：[`BackendMd/README.md`](BackendMd/README.md)
- 后端代码入口：[`backend/README.md`](backend/README.md)

## `backend/` 现在是什么

`backend/` 不是要你现在立刻上服务器，而是提前整理好的正式后端代码基础。

它的设计目的是：

- 现在能打包成 Sealos 云函数
- 以后也能直接挂到云服务器

也就是说，当前你可以先不完全掌握 Node.js，也能先把接口用起来。

## 后续待补内容

当前已经实现并整理好的重点是药品搜索和 AI 相关接口。后面还可以继续补这些：

- `scan-record-create`
- `scan-record-list`
- `send-code`
- `login-user`
- `register-user`
- `my-medicine`
- `today-reminders`
- `reminder`
- `checkin-create`

## 文档入口

如果你现在只想快速定位：

- 看项目整体：[`README.md`](README.md)
- 看后端学习文档：[`BackendMd/README.md`](BackendMd/README.md)
- 看后端代码部署说明：[`backend/README.md`](backend/README.md)
