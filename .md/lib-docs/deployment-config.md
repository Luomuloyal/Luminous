# Luminous Deployment Configuration Guide

本文覆盖四部分：

- Flutter App（本仓库）
- App 后端（本仓库 `backend`）
- 网站前端（`LuminousWebsite/luminousvue`）
- 网站后端（`LuminousWebsite/luminousBackend`）

目标：说明“需要配置什么”以及“在哪里配置”。

## 1. Architecture and Port Suggestions

推荐线上拆分：

- App API: `https://api.your-domain.com`（Luminous/backend）
- Website API: `https://site-api.your-domain.com`（luminousBackend）
- Website Static: `https://www.your-domain.com`（luminousvue dist）

也可将网站前后端合并到 luminousBackend（其支持托管 `dist`）。

## 2. Flutter App (Luminous)

### 2.1 Backend Address

Location:

- `lib/constants/constants.dart`

Required config:

- `GlobalConstants.BASE_URL`

Notes:

- Android 模拟器常用 `http://10.0.2.2:8787`
- 真机调试使用局域网地址
- 生产建议使用 HTTPS 域名

### 2.2 Android Identity and Signing

Location:

- `android/app/build.gradle.kts`
- `pubspec.yaml`

Required config:

- `applicationId`
- `minSdk` / `targetSdk` / `versionCode` / `versionName`
- `buildTypes.release.signingConfig`

Current status:

- Release 仍为 debug 签名，仅适合测试。

Before release:

1. 生成正式 keystore。
2. 新建 `android/key.properties`（不入库）。
3. 在 `android/app/build.gradle.kts` 中配置 release signing。

### 2.3 Android Permissions

Location:

- `android/app/src/main/AndroidManifest.xml`

Declared permissions:

- `INTERNET`
- `CAMERA`
- `POST_NOTIFICATIONS`
- `SCHEDULE_EXACT_ALARM`
- `READ_EXTERNAL_STORAGE`（maxSdkVersion 32）

Release check:

- 若启用 Android 13+ 相册读取能力，按需补充 `READ_MEDIA_IMAGES`。

## 3. App Backend (Luminous/backend)

### 3.1 Environment Variables

Location:

- Parser: `backend/src/config/env.ts`
- Runtime file: `backend/.env`

Required keys:

- `PORT`（默认 8787）
- `CORS_ORIGIN`
- `MYSQL_HOST`
- `MYSQL_PORT`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MYSQL_DATABASE`
- `MYSQL_TABLE`
- `MONGODB_URI`
- `REDIS_URL`
- `AUTH_CODE_TTL_SECONDS`
- `AUTH_CODE_DELIVERY_MODE`（`log` 或 `provider`）
- `AUTH_CODE_SMS_WEBHOOK_URL`（phone 通道，可选）
- `AUTH_CODE_EMAIL_HOST`（email 通道，provider 模式必填）
- `AUTH_CODE_EMAIL_PORT`
- `AUTH_CODE_EMAIL_SECURE`
- `AUTH_CODE_EMAIL_USER`
- `AUTH_CODE_EMAIL_PASS`
- `AUTH_CODE_EMAIL_FROM`
- `JWT_SECRET`
- `JWT_REFRESH_SECRET`
- `AI_PROVIDER`（当前支持 `openai-compatible`）
- `AI_API_KEY`
- `AI_BASE_URL`
- `AI_VISION_MODEL`
- `AI_TEXT_MODEL`
- `AI_TEXT_TEMPERATURE`（默认 0.3）
- `AI_VISION_TEMPERATURE`（默认 0.2）

Example `.env`:

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
REDIS_URL=redis://127.0.0.1:6379

AUTH_CODE_TTL_SECONDS=300
AUTH_CODE_DELIVERY_MODE=log
AUTH_CODE_SMS_WEBHOOK_URL=
AUTH_CODE_EMAIL_HOST=smtp.qq.com
AUTH_CODE_EMAIL_PORT=465
AUTH_CODE_EMAIL_SECURE=true
AUTH_CODE_EMAIL_USER=
AUTH_CODE_EMAIL_PASS=
AUTH_CODE_EMAIL_FROM=

JWT_SECRET=replace_with_long_random_secret
JWT_REFRESH_SECRET=replace_with_another_long_random_secret

AI_PROVIDER=openai-compatible
AI_API_KEY=your_ai_api_key
AI_BASE_URL=https://ark.cn-beijing.volces.com/api/v3
AI_VISION_MODEL=ep-vision-xxx
AI_TEXT_MODEL=ep-text-xxx
AI_TEXT_TEMPERATURE=0.3
AI_VISION_TEMPERATURE=0.2
```

Compatibility:

- 若完全未配置 `AI_*`，后端仍支持旧的 `DOUBAO_API_KEY` / `DOUBAO_BASE_URL` / `DOUBAO_VISION_ENDPOINT_ID` / `DOUBAO_TEXT_ENDPOINT_ID`。
- 一旦配置任意 `AI_*`，就不会再混用旧 `DOUBAO_*`，避免切换供应商时 key 与 base URL 串台。

### 3.2 Run and Deploy

Location:

- `backend/package.json`

Commands:

- Dev: `npm run dev`
- Build: `npm run build`
- Start: `npm run start`

Production recommendation:

- 使用 PM2 或 systemd 守护进程
- 使用 Nginx/Caddy 反向代理并启用 HTTPS

### 3.3 Database Connection Sources

Location:

- MySQL: `backend/src/db/mysql.ts`
- MongoDB: `backend/src/db/mongodb.ts`
- Redis: `backend/src/db/redis.ts`

Notes:

- MongoDB 用于用户账户与资料。
- Redis 用于验证码缓存（手机号/邮箱为 key，验证码为 value，默认 5 分钟过期）。
- MySQL 用于药品数据检索。

## 4. Website Frontend (LuminousWebsite/luminousvue)

### 4.1 Environment Variables

Location:

- Template: `LuminousWebsite/luminousvue/.env.example`
- Runtime: `LuminousWebsite/luminousvue/.env`
- Consumer: `LuminousWebsite/luminousvue/src/lib/siteRuntime.js`

Key:

- `VITE_API_BASE_URL`

Purpose:

- 指定网站前端请求网站后端（如 `/api/site-manifest`）的基础地址。

Example:

```env
VITE_API_BASE_URL=https://site-api.your-domain.com
```

If empty:

- 使用相对路径请求，适合同域部署。

### 4.2 Build and Publish

Location:

- `LuminousWebsite/luminousvue/package.json`

Build command:

- `npm run build`

Output:

- `LuminousWebsite/luminousvue/dist`

Deployment options:

- Option A: 单独部署 `dist` 到静态托管。
- Option B: 由 luminousBackend 直接托管 `dist`。

## 5. Website Backend (LuminousWebsite/luminousBackend)

### 5.1 Environment Variables

Location:

- Template: `LuminousWebsite/luminousBackend/.env.example`
- Runtime: `LuminousWebsite/luminousBackend/.env`
- Loader: `LuminousWebsite/luminousBackend/src/config.js`

Keys:

- `PORT`（默认 3030）
- `LUMINOUS_APK_SOURCE`
- `ANDROID_SDK_ROOT`（可选）
- `ANDROID_SERIAL`（可选）

Example:

```env
PORT=3030
LUMINOUS_APK_SOURCE=/opt/luminous/app-release.apk
ANDROID_SDK_ROOT=/opt/android-sdk
```

### 5.2 Runtime Behavior and Endpoints

Location:

- `LuminousWebsite/luminousBackend/src/server.js`

Main endpoints:

- `GET /healthz`
- `GET /api/site-manifest`
- `GET /downloads/luminous-android-debug.apk`
- `GET /media/*`

Notes:

- 若检测到 `luminousvue/dist`，会同时托管静态页面并处理前端路由回退。

### 5.3 Asset Sync Scripts

Location:

- `LuminousWebsite/luminousBackend/package.json`

Commands:

- `npm run sync:apk`
- `npm run capture:screenshots`
- `npm run optimize:media`

## 6. Release Checklist

### 6.1 Flutter App

- `BASE_URL` 已切换至生产地址
- Release 签名已配置
- `applicationId` 与商店包名一致
- `versionName/versionCode` 已更新

### 6.2 App Backend

- `.env` 已完整填写
- 数据库白名单已放通
- HTTPS 反向代理已配置
- `CORS_ORIGIN` 已收敛

### 6.3 Website Frontend

- `VITE_API_BASE_URL` 正确
- `dist` 来自生产构建

### 6.4 Website Backend

- `.env` 中端口与 APK 路径正确
- `npm run sync:apk` 已执行
- `GET /api/site-manifest` 返回 `download.available=true`

## 7. FAQ

### 7.1 App 登录后频繁 401

Check:

- `JWT_SECRET` / `JWT_REFRESH_SECRET` 是否频繁变更
- Flutter `BASE_URL` 是否指向错误环境

### 7.2 Website 下载按钮无文件

Check:

- `LUMINOUS_APK_SOURCE` 文件存在
- 已执行 `npm run sync:apk`
- `GET /healthz` 的 `apkAvailable=true`

### 7.3 Website 图片不显示

Check:

- 已执行 `npm run optimize:media`
- `GET /api/site-manifest` 返回 screenshots
- 反向代理已放通 `/media/*`
