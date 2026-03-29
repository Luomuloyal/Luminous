# Luminous

Luminous 是一个面向移动端的智慧用药助手，提供药品识别、药品信息查询、AI 辅助解读、提醒与历史回看能力。

本仓库包含 Flutter App 与 App Backend，可独立部署与联调。

## Features

- 药品搜索与药品详情
- 拍照识别与候选回查
- AI 解读与安全辅助
- 今日提醒与本地打卡
- 识别相册与结果沉淀
- 多主题与深浅色模式

## Tech Stack

- App: Flutter (Dart)
- Backend: Node.js + TypeScript + Express
- Auth: JWT (Access Token + Refresh Token)
- Database: MongoDB (用户) + MySQL (药品库)
- AI: 豆包 / 火山方舟兼容调用

## Repository Structure

```text
Luminous/
  lib/                Flutter 主代码
  test/               Flutter 测试
  backend/            App 后端服务
  Study/              架构学习与问题定位文档
  android/ios/...     平台工程
```

更多目录说明见 [lib/README.md](lib/README.md)。

## Quick Start

### Run Flutter App

```bash
flutter pub get
flutter run
```

```bash
flutter analyze
flutter test
```

### Run Backend

```bash
cd backend
npm install
npm run dev
```

Health Check:

- `GET http://127.0.0.1:8787/health`

## Configuration

### Flutter Base URL

- File: `lib/constants/constants.dart`
- Key: `GlobalConstants.BASE_URL`

常见开发取值：

- Android 模拟器: `http://10.0.2.2:8787`
- 真机: `http://<LAN-IP>:8787`

### Backend Environment

- File: `backend/.env`
- Loader: `backend/src/config/env.ts`

完整部署配置见 [lib/docs/deployment-config.md](lib/docs/deployment-config.md)。

## Documentation

- Backend API: [lib/docs/backend-api.md](lib/docs/backend-api.md)
- Deployment Guide: [lib/docs/deployment-config.md](lib/docs/deployment-config.md)
- Backend Runtime: [backend/README.md](backend/README.md)
- Architecture Notes: [Study/README.md](Study/README.md)

## Contributing

欢迎提交 Issue 与 Pull Request。

建议流程：

1. Fork 并创建功能分支。
2. 提交前执行 `flutter analyze`、`flutter test` 与后端构建检查。
3. 在 PR 中附上修改说明与验证方式。

## License

当前仓库未附带开源许可证文件。

若计划公开发布，建议新增 `LICENSE`（例如 MIT/Apache-2.0）。
