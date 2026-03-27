# Luminous 上线部署配置清单

本文覆盖 4 个部分：
- Flutter App（本仓库）
- App 后端（本仓库 `backend`）
- 网站前端（`LuminousWebsite/luminousvue`）
- 网站后端（`LuminousWebsite/luminousBackend`）

目标是回答两件事：
- 需要配置什么
- 在哪里配置

## 1. 全局架构与端口建议

建议线上拆分：
- App API: `https://api.your-domain.com`（Luminous/backend）
- Website API: `https://site-api.your-domain.com`（luminousBackend）
- Website 静态站点: `https://www.your-domain.com`（luminousvue dist）

也可以把 Website 前后端合并到 luminousBackend 一个进程里（它支持静态托管 dist）。

## 2. Flutter App（Luminous）

### 2.1 后端地址

位置:
- `lib/constants/constants.dart`

需要配置:
- `GlobalConstants.BASE_URL`

说明:
- Android 模拟器开发常用 `http://10.0.2.2:8787`
- 真机调试用局域网 IP
- 线上发布改为 HTTPS 正式域名

### 2.2 Android 应用信息与签名

位置:
- `android/app/build.gradle.kts`
- `pubspec.yaml`

需要配置:
- `applicationId`（唯一包名）
- `minSdk / targetSdk / versionCode / versionName`
- `buildTypes.release.signingConfig`

当前状态:
- Release 仍使用 debug 签名，仅适合测试。

上线前必须改:
1. 生成正式 keystore。
2. 新建 `android/key.properties`（不入库）。
3. 在 `android/app/build.gradle.kts` 中添加 release signingConfigs 并绑定到 `buildTypes.release`。

### 2.3 Android 权限

位置:
- `android/app/src/main/AndroidManifest.xml`

已声明:
- `INTERNET`
- `CAMERA`
- `POST_NOTIFICATIONS`
- `SCHEDULE_EXACT_ALARM`
- `READ_EXTERNAL_STORAGE`（maxSdkVersion 32）

上线检查:
- 如接入 Android 13+ 相册新权限（`READ_MEDIA_IMAGES`），按实际功能补充。

## 3. App 后端（Luminous/backend）

### 3.1 环境变量

位置:
- 读取逻辑: `backend/src/config/env.ts`
- 运行文件: `backend/.env`（需自行创建）

必须配置:
- `PORT`（默认 8787）
- `CORS_ORIGIN`（建议填前端来源域名，多个用逗号分隔）
- `MYSQL_HOST`
- `MYSQL_PORT`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MYSQL_DATABASE`
- `MYSQL_TABLE`（默认 `国产本位码`）
- `MONGODB_URI`
- `JWT_SECRET`
- `JWT_REFRESH_SECRET`
- `DOUBAO_API_KEY`
- `DOUBAO_BASE_URL`（默认火山方舟地址）
- `DOUBAO_VISION_ENDPOINT_ID` 或 `DOUBAO_VISION_MODEL_ID`（二选一）
- `DOUBAO_TEXT_ENDPOINT_ID` 或 `DOUBAO_TEXT_MODEL_ID`（二选一）

建议 .env 示例:

```env
PORT=8787
CORS_ORIGIN=https://app.your-domain.com,https://www.your-domain.com

MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=app_user
MYSQL_PASSWORD=strong_password
MYSQL_DATABASE=medicine_db
MYSQL_TABLE=国产本位码

MONGODB_URI=mongodb://127.0.0.1:27017/luminous

JWT_SECRET=replace_with_long_random_secret
JWT_REFRESH_SECRET=replace_with_another_long_random_secret

DOUBAO_API_KEY=your_doubao_api_key
DOUBAO_BASE_URL=https://ark.cn-beijing.volces.com/api/v3
DOUBAO_VISION_ENDPOINT_ID=ep-vision-xxx
DOUBAO_TEXT_ENDPOINT_ID=ep-text-xxx
```

### 3.2 运行与部署

位置:
- 脚本: `backend/package.json`

命令:
- 开发: `npm run dev`
- 构建: `npm run build`
- 生产启动: `npm run start`

建议线上:
- 用 PM2/systemd 守护 Node 进程。
- 用 Nginx/Caddy 反向代理并启用 HTTPS。

### 3.3 数据库连接来源

位置:
- MySQL 连接: `backend/src/db/mysql.ts`
- Mongo 连接: `backend/src/db/mongodb.ts`

说明:
- Mongo 用于用户认证数据。
- MySQL 用于药品库查询。

## 4. 网站前端（LuminousWebsite/luminousvue）

### 4.1 环境变量

位置:
- 模板: `LuminousWebsite/luminousvue/.env.example`
- 实际: `LuminousWebsite/luminousvue/.env`
- 消费代码: `LuminousWebsite/luminousvue/src/lib/siteRuntime.js`

变量:
- `VITE_API_BASE_URL`

作用:
- 前端请求网站后端接口（例如 `/api/site-manifest`）时的基础地址。

示例:

```env
VITE_API_BASE_URL=https://site-api.your-domain.com
```

如果留空:
- 前端将使用相对路径请求（适合同域部署）。

### 4.2 构建与发布

位置:
- 脚本: `LuminousWebsite/luminousvue/package.json`

命令:
- `npm run build`

产物:
- `LuminousWebsite/luminousvue/dist`

可选部署模式:
- 模式 A: 仅部署 dist 到静态托管（Nginx/CDN/对象存储）。
- 模式 B: 让网站后端 luminousBackend 直接托管 dist（见下节）。

## 5. 网站后端（LuminousWebsite/luminousBackend）

### 5.1 环境变量

位置:
- 模板: `LuminousWebsite/luminousBackend/.env.example`
- 实际: `LuminousWebsite/luminousBackend/.env`
- 读取代码: `LuminousWebsite/luminousBackend/src/config.js`

变量:
- `PORT`（默认 3030）
- `LUMINOUS_APK_SOURCE`（Flutter APK 源文件路径）
- `ANDROID_SDK_ROOT`（可选，截图脚本用；不填时尝试从 `android/local.properties` 读取）
- `ANDROID_SERIAL`（可选，截图脚本选择设备）

示例:

```env
PORT=3030
LUMINOUS_APK_SOURCE=/opt/luminous/app-release.apk
ANDROID_SDK_ROOT=/opt/android-sdk
```

### 5.2 运行行为与接口

位置:
- 服务入口: `LuminousWebsite/luminousBackend/src/server.js`

主要接口:
- `GET /healthz`
- `GET /api/site-manifest`
- `GET /downloads/luminous-android-debug.apk`
- `GET /media/*`

说明:
- 若检测到 `luminousvue/dist` 存在，luminousBackend 会同时托管网站静态页面并处理前端路由回退。

### 5.3 资源同步脚本

位置:
- `LuminousWebsite/luminousBackend/package.json`

命令:
- `npm run sync:apk`（同步 APK 到下载目录并写 manifest 数据）
- `npm run capture:screenshots`（通过 adb 抓取截图）
- `npm run optimize:media`（压缩截图并写入媒体元数据）

## 6. 上线前核对清单

### 6.1 Flutter App

- `BASE_URL` 已切换到线上 API 域名
- Release 签名已替换 debug 签名
- `applicationId` 与商店包名一致
- `versionName/versionCode` 已更新

### 6.2 App 后端

- `.env` 已完整填写（MySQL/Mongo/JWT/DOUBAO）
- 数据库网络白名单已放通
- 反向代理 HTTPS 生效
- `CORS_ORIGIN` 已收敛到真实来源

### 6.3 网站前端

- `.env` 中 `VITE_API_BASE_URL` 正确
- `dist` 产物来自线上环境构建

### 6.4 网站后端

- `.env` 中端口/APK 路径正确
- `sync:apk` 已执行
- `site-manifest` 可访问且返回 `download.available=true`

## 7. 常见问题

### 7.1 App 登录后频繁 401

优先检查:
- `JWT_SECRET` / `JWT_REFRESH_SECRET` 是否在重启后变化
- Flutter 端 `BASE_URL` 是否指向了旧环境

### 7.2 网站下载按钮无文件

优先检查:
- `LUMINOUS_APK_SOURCE` 路径是否存在
- 是否执行 `npm run sync:apk`
- `GET /healthz` 返回的 `apkAvailable` 是否为 `true`

### 7.3 网站图片不显示

优先检查:
- 是否执行 `npm run optimize:media`
- `GET /api/site-manifest` 是否返回 screenshots
- 反向代理是否放通 `/media/*`
