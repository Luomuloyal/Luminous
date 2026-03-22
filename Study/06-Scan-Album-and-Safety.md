# 06 扫描、相册与安全辅助

## 这个功能是干什么的

这部分负责拍照识别药品、保存识别记录到本地相册、同步远端识别记录，以及用 AI 做单药建议或双药相互作用分析。

## 用户从哪里进入 / 如何触发

- 首页 / 药品页点击“药物识别”
- 相册页查看历史记录、重识别、进详情
- 安全辅助页选择一款或两款药后发起查询

## 关键页面、组件、API、store、backend、native 文件

- 扫描页：`lib/pages/Scan/medicine_scan.dart`
- 相册页：`lib/pages/Album/album.dart`
- 安全辅助页：`lib/pages/Safety/safety_assist.dart`
- 扫描 API：`lib/api/scan_api.dart`
- 安全 API：`lib/api/safety_api.dart`
- 相册本地仓库：`lib/stores/album_local_store.dart`
- 后端：`backend/src/handlers/medicine-scan.ts`、`backend/src/handlers/medicine-ai-safety.ts`

## 核心实现路径

### UI 入口

- `openMedicineScanFlow()` 先弹图片来源选择，再 push `MedicineScanPage`
- 扫描页展示图片区域 + 可拖拽结果面板
- 相册页先读本地，再在已登录时同步远端记录
- 安全辅助页通过药品选择器收集药品 A/B

### 状态来源

- 扫描页核心状态是 `_photoBytes`、`_scanResult`、`_selectedIndex`
- 相册页核心状态是 `_entries`
- 安全辅助页核心状态是 `_mode`、`_a`、`_b`、`_result`

### 网络 / 本地存储 / 后端流转

- 扫描页把图片转 base64 后调用 `ScanApi.scanMedicine()`
- 识别结果保存相册时，优先尝试 `ScanApi.createScanRecord()`，同时落本地 SQLite
- 相册页通过 `AlbumLocalStore.syncRemoteForUser()` 拉取远端列表并与本地原图合并
- 安全辅助页调用 `SafetyApi.query()`，后端再交给 AI 文本模型

### 结果如何回到 UI

- 扫描成功后 `_scanResult` 驱动候选卡片、搜索入口和保存相册入口
- 相册页 `_entries` 更新后重建列表
- 安全辅助页 `_result` 更新后直接显示 AI 文本

## 关键代码位置

- `lib/pages/Scan/medicine_scan.dart:74`
  扫描流程入口。
- `lib/pages/Scan/medicine_scan.dart:682`
  应用图片并开始识别。
- `lib/pages/Scan/medicine_scan.dart:693`
  调用识别接口。
- `lib/pages/Scan/medicine_scan.dart:721`
  保存到应用相册。
- `lib/pages/Album/album.dart:91`
  相册页本地优先、登录后再同步远端。
- `lib/pages/Album/album.dart:163`
  打开预览、详情和重识别。
- `lib/pages/Safety/safety_assist.dart:337`
  安全辅助主查询流程。
- `lib/api/scan_api.dart:16`
  识别接口。
- `lib/api/scan_api.dart:44`
  创建远端识别记录接口。
- `lib/api/scan_api.dart:73`
  识别记录列表接口。
- `lib/api/safety_api.dart:15`
  安全辅助接口。
- `lib/stores/album_local_store.dart:37`
  读取相册并折叠重复远端记录。
- `lib/stores/album_local_store.dart:99`
  远端同步主流程。
- `lib/stores/album_local_store.dart:126`
  把远端记录回写本地并保留原图。
- `lib/stores/album_local_store.dart:373`
  上传 pending 本地相册记录。
- `backend/src/handlers/medicine-scan.ts:34`
  识别 handler。
- `backend/src/handlers/medicine-ai-safety.ts:31`
  安全辅助 handler。

## 容易忽略的实现细节

- 服务端 `thumbBase64` 当前固定返回空，Flutter 端自己有本地缩略图兜底
- 相册同步时会尽量保留本地原图，不会被远端缩略图覆盖掉
- 相册同步当前更偏“upsert 远端结果”，如果远端删空了列表，本地旧远端记录不会自动被清掉，这是本轮 review 发现的风险点
- 安全辅助当前 UI 总会传 `drugCode/approvalNo/productName` 三项，但后端 enrichment 主要依赖前两项

## 如果以后要改，优先改哪里

- 改扫描 UI / 识别链路：`lib/pages/Scan/medicine_scan.dart`
- 改相册同步：`lib/stores/album_local_store.dart`
- 改安全辅助 prompt / 返回：`backend/src/handlers/medicine-ai-safety.ts`

## 相关测试在哪

- `test/ai_scan_flow_test.dart:25`
  覆盖扫描入口的来源选择弹层
- `test/album_local_store_test.dart:23`
  覆盖相册本地存储、远端回写和同步合并
- `test/album_local_store_test.dart:143`
  覆盖 pending 上传和游客原图并入，但还没有覆盖“远端返回空列表时清理本地旧远端记录”
