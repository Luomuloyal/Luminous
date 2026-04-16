# 06 扫描、相册与安全辅助

## 这一篇最重要的结论

这一组功能表面上是三块页面：

- 药物识别
- 识别相册
- 安全辅助

但底层其实共享了两条很重要的主线：

1. 药品对象最终都尽量回到 `MedicineItem` / 身份字段这套体系
2. 相册和识别结果始终坚持“本地优先、远端尽力同步”

所以你以后如果发现这几块联动有问题，不要只看某一个页面，通常要一起看扫描页、本地相册仓库、以及安全辅助的选药链路。

## 这个功能是干什么的

这一部分负责：

- 从相机或相册选图并识别药品
- 把识别结果存到应用内相册
- 已登录时把识别记录和远端做同步
- 从相册记录进入药品详情或重新识别
- 用 AI 做单药建议或双药相互作用分析

## 建议你第一次怎么读

推荐顺序：

1. `lib/pages/Scan/medicine_scan.dart`
2. `lib/api/scan_api.dart`
3. `lib/stores/album_local_store.dart`
4. `lib/pages/Album/album.dart`
5. `lib/pages/Safety/safety_assist.dart`
6. `lib/api/safety_api.dart`
7. `backend/src/handlers/medicine-scan.ts`
8. `backend/src/handlers/medicine-ai-safety.ts`

这样你会先看“图片如何变成识别结果”，再看“结果如何落本地和回到其他页面”。

## 用户从哪里进入 / 如何触发

- 首页 / 药品页点击“药物识别”
- 相册页查看历史记录、进详情或重识别
- 安全辅助页选择一款或两款药后发起 AI 查询

## 关键页面、组件、API、store、backend、native 文件

- 扫描页：`lib/pages/Scan/medicine_scan.dart`
- 相册页：`lib/pages/Album/album.dart`
- 安全辅助页：`lib/pages/Safety/safety_assist.dart`
- 扫描 API：`lib/api/scan_api.dart`
- 安全 API：`lib/api/safety_api.dart`
- 相册本地仓库：`lib/stores/album_local_store.dart`
- 后端：
  - `backend/src/handlers/medicine-scan.ts`
  - `backend/src/handlers/medicine-ai-safety.ts`
- 相关测试：
  - `test/ai_scan_flow_test.dart`
  - `test/album_local_store_test.dart`

## 扫描页的真实链路

扫描页是这一组功能的起点。

### 第一步：先选图片来源

入口在：

- `lib/pages/Scan/medicine_scan.dart:74-87`

`openMedicineScanFlow()` 会先调用 `pickMedicineScanImage()`，并不是直接进扫描页。

真正的来源选择和权限处理在：

- `lib/pages/Scan/medicine_scan.dart:90-128`

这里会：

1. 弹出来源选择 sheet
2. 如果是相机则请求相机权限
3. 用 `ImagePicker` 读图
4. 读取 bytes 和 mimeType

### 第二步：进入扫描页并承载图片

页面入口在：

- `lib/pages/Scan/medicine_scan.dart:137-203`

它会在首帧后做两件事：

1. 自动展开底部结果面板
2. 如果已有 `initialImage`，直接开始识别

这就是为什么：

- 从首页进扫描可以直接带着刚选的图进去
- 从相册重识别也能直接带原图进去

### 第三步：真正发识别请求

识别主流程在：

- `lib/pages/Scan/medicine_scan.dart:682-719`

顺序是：

1. `_applyImageAndScan()`
   先清空旧结果、重置选中索引
2. `_scan()`
   把 bytes 转成 base64
3. 调 `ScanApi.scanMedicine()`
4. 用识别结果更新 `_scanResult`
5. 自动选一个“最合适的候选”

调用 API 的位置在：

- `lib/pages/Scan/medicine_scan.dart:697-703`
- `lib/api/scan_api.dart:16-39`

## 扫描结果为什么还能继续进详情、搜索或存相册

因为扫描结果不是只展示一段文本，而是尽量映射成候选药品列表。

后端 `medicine-scan` 的职责不是直接给一个最终答案，而是：

1. 先让视觉模型识别结构化字段
2. 再按 `approvalNo / productName / manufacturer` 回查药品库
3. 返回候选列表

对应后端在：

- `backend/src/handlers/medicine-scan.ts:34-69`

这也是为什么扫描页后续动作很多：

- 选中候选
- 进入药品详情
- 继续搜索
- 保存到相册

## “保存到软件相册”是怎么走的

入口在：

- `lib/pages/Scan/medicine_scan.dart:721-781`

这段逻辑非常值得看，因为它体现了“本地优先、远端尽力”的设计。

顺序是：

1. 先从当前扫描结果里拿已选候选
2. 优先使用服务端返回的 `thumbBase64`
3. 如果服务端没给，就在本地自己生成缩略图
4. 如果已登录，尝试先调 `ScanApi.createScanRecord()`
5. 无论远端是否成功，都调用 `albumLocalStore.saveScanRecord()`

也就是说，远端创建失败不会阻止本地保存。

这是当前体验上很重要的策略。

## 相册页为什么是“本地先显示，再远端补齐”

相册页主流程在：

- `lib/pages/Album/album.dart:68-130`

它的顺序是：

1. 先读本地缓存
2. 立刻把本地结果显示出来
3. 如果当前已登录，再去同步远端
4. 同步完成后重新读本地并刷新 UI

这样做的好处是：

- 相册页打开速度更稳
- 即使网络慢，也不至于一片空白
- 登录用户还能补齐跨设备或历史数据

## 相册本地仓库真正做了什么

`lib/stores/album_local_store.dart` 是这组功能里最值得重点学习的一个 store。

### 读取列表

- `lib/stores/album_local_store.dart:36-60`

这里会按用户作用域读取，并在游客模式下兼容老数据范围。

### 保存新扫描记录

- `lib/stores/album_local_store.dart:62-96`

保存时会同时写：

- 远端 id
- 用户作用域
- identityKey
- 缩略图
- 原图 base64
- mimeType
- 时间戳

### 已登录用户同步远端

- `lib/stores/album_local_store.dart:98-123`

顺序是：

1. 先补推 pending 本地记录
2. 再分页拉取远端记录
3. 再执行 `upsertRemoteRecords()`

### 远端回写本地时保留原图

- `lib/stores/album_local_store.dart:125-210`

这是很关键的一点。回写远端记录时，它会尽量保留本地已有的：

- `imageBase64`
- `imageMimeType`
- 更早的 `createdAt`

这样远端同步不会把本地原图信息冲掉。

### pending 上传

- `lib/stores/album_local_store.dart:373-442`

这部分负责把“只有本地、还没 remoteId”的记录补推远端。失败时不会删本地，只会等待下一次同步。

## 当前相册同步还要注意什么

这块有一个需要你记住的边界：

- 相册同步现在更像“upsert 远端已有结果”
- 不是严格意义上的“让本地 100% 镜像远端”

所以如果远端列表已经删空，本地旧的远端记录当前不一定会自动被清掉。这也是之前 review 提醒过的残留风险之一。

## 安全辅助页的真实链路

安全辅助页本身逻辑不复杂，但它依赖前面的选药和后端 AI。

### 页面状态

核心状态在：

- `lib/pages/Safety/safety_assist.dart:28-49`

也就是：

- 当前模式 `_mode`
- 药品 A `_a`
- 药品 B `_b`
- AI 结果 `_result`

### 选药流程

入口在：

- `lib/pages/Safety/safety_assist.dart:166-190`
- `lib/pages/Safety/safety_assist.dart:315-332`

它会通过药品选择器收集药物 A/B，因此这块功能和 `Study/05` 是直接连着的。

### 发起安全查询

主流程在：

- `lib/pages/Safety/safety_assist.dart:337-395`

它会：

1. 先校验当前模式下药品数量是否够
2. 组装 `medicines` 数组
3. 调 `SafetyApi.query()`
4. 把返回的 `MedicineAiSafetyResult` 落到 `_result`

调用 API 的位置在：

- `lib/api/safety_api.dart:15-31`

后端对应：

- `backend/src/handlers/medicine-ai-safety.ts:31-74`

## 安全辅助后端在做什么

这个 handler 不是简单把前端传来的名称直接丢给 AI。

它会先：

1. 校验模式是 `single` 还是 `pair`
2. 规范化输入 medicines
3. 尝试按 `drugCode/approvalNo` 回查数据库补全细节
4. 再把 enriched 结果送给 AI prompt

所以如果以后你觉得安全辅助结果不稳定，除了 prompt，也要看看前端有没有把身份字段传完整。

## 一条最短的读码路径

如果你以后只想最快重温这一整条链，推荐顺序：

1. `lib/pages/Scan/medicine_scan.dart:74-128`
2. `lib/pages/Scan/medicine_scan.dart:137-203`
3. `lib/pages/Scan/medicine_scan.dart:682-781`
4. `lib/api/scan_api.dart:16-101`
5. `lib/stores/album_local_store.dart:36-123`
6. `lib/stores/album_local_store.dart:125-210`
7. `lib/stores/album_local_store.dart:373-442`
8. `lib/pages/Album/album.dart:68-130`
9. `lib/pages/Album/album.dart:163-227`
10. `lib/pages/Safety/safety_assist.dart:166-190`
11. `lib/pages/Safety/safety_assist.dart:315-395`

## 关键代码位置

- `lib/pages/Scan/medicine_scan.dart:74-87`
  扫描入口。
- `lib/pages/Scan/medicine_scan.dart:90-128`
  选择来源、申请权限、读取图片。
- `lib/pages/Scan/medicine_scan.dart:137-203`
  扫描页初始化。
- `lib/pages/Scan/medicine_scan.dart:682-719`
  应用图片并发识别请求。
- `lib/pages/Scan/medicine_scan.dart:721-781`
  保存到软件相册。
- `lib/pages/Album/album.dart:68-130`
  本地优先、登录后再同步远端。
- `lib/pages/Album/album.dart:163-227`
  打开预览、详情和重识别。
- `lib/pages/Safety/safety_assist.dart:166-190`
  选药区域。
- `lib/pages/Safety/safety_assist.dart:315-332`
  打开药品选择器。
- `lib/pages/Safety/safety_assist.dart:337-395`
  安全辅助主查询流程。
- `lib/api/scan_api.dart:16-39`
  识别接口。
- `lib/api/scan_api.dart:44-68`
  创建远端识别记录接口。
- `lib/api/scan_api.dart:73-101`
  识别记录列表接口。
- `lib/api/safety_api.dart:15-31`
  安全辅助接口。
- `lib/stores/album_local_store.dart:36-60`
  读取本地相册并折叠重复记录。
- `lib/stores/album_local_store.dart:62-96`
  保存新的本地扫描记录。
- `lib/stores/album_local_store.dart:98-123`
  登录后同步远端记录。
- `lib/stores/album_local_store.dart:125-210`
  把远端记录 upsert 回本地，并保留原图。
- `lib/stores/album_local_store.dart:373-442`
  补推 pending 本地记录。
- `backend/src/handlers/medicine-scan.ts:34-69`
  识别 handler。
- `backend/src/handlers/medicine-ai-safety.ts:31-74`
  安全辅助 handler。

## 容易忽略的实现细节

- 服务端 `thumbBase64` 当前可能为空，Flutter 端自己会生成本地缩略图兜底。
- 保存到软件相册时，远端创建记录只是 best-effort，本地保存才是主路径。
- 相册页不是等远端回来才显示，而是本地先出内容。
- 安全辅助传给后端的不只是药名，还会尽量带 `drugCode/approvalNo`，这些身份字段很重要。

## 如果以后要改，优先改哪里

### 想改拍照识别入口或扫描页交互

先看：

1. `lib/pages/Scan/medicine_scan.dart`

### 想改相册同步策略

先看：

1. `lib/stores/album_local_store.dart`
2. `lib/pages/Album/album.dart`

### 想改安全辅助结果质量

先看：

1. `lib/pages/Safety/safety_assist.dart`
2. `lib/api/safety_api.dart`
3. `backend/src/handlers/medicine-ai-safety.ts`
4. `backend/src/ai/prompts.ts`

### 想改扫描识别结果质量

先看：

1. `backend/src/handlers/medicine-scan.ts`
2. `backend/src/ai/prompts.ts`
3. `backend/src/db/medicine-repository.ts`

## 初学时最容易卡住的点

- 误以为相册页是纯远端数据页。实际上不是，本地优先很明显。
- 误以为保存相册必须依赖远端创建成功。实际上本地保存才是硬保证。
- 误以为安全辅助只看药名。实际上身份字段越完整，后端 enrichment 越稳。

## 相关测试在哪

- `test/ai_scan_flow_test.dart:25-49`
  覆盖扫描入口的来源选择流程。
- `test/album_local_store_test.dart:23-44`
  覆盖本地保存扫描记录。
- `test/album_local_store_test.dart:45-76`
  覆盖用户作用域隔离。
- `test/album_local_store_test.dart:77-141`
  覆盖远端回写、本地原图保留等逻辑。
- `test/album_local_store_test.dart:143-205`
  覆盖 pending 上传和游客记录并入。

当前还没有很完整的扫描页 UI 级测试，以及“远端返回空列表时本地旧远端记录如何处理”的自动化测试，这两块以后最值得补。
