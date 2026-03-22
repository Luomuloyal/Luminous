# 05 药品搜索与详情

## 这个功能是干什么的

负责手动搜索药品库、从“我的药品”或搜索库中选药，以及进入详情页查看基础信息和 AI 解读。

## 用户从哪里进入 / 如何触发

- 首页快捷入口“手动搜索”
- 药品页快捷入口“手动搜索”
- 安全辅助、提醒编辑、首页“药物信息”都会先打开药品选择器

## 关键页面、组件、API、store、backend、native 文件

- 搜索页：`lib/pages/Search/search.dart`
- 药品详情：`lib/pages/Drug/medicine_detail.dart`
- 药品选择器：`lib/pages/Picker/medicine_picker.dart`
- 药品 API：`lib/api/medicine_api.dart`
- “我的药品”仓库：`lib/stores/my_medicine_repository.dart`
- 模型：`lib/viewmodels/medicine.dart`
- 后端：`backend/src/handlers/medicine-search.ts`、`backend/src/handlers/medicine-detail.ts`、`backend/src/handlers/medicine-ai-detail.ts`

## 核心实现路径

### UI 入口

- 搜索页支持初始关键字和自动搜索
- 选择器页优先展示“我的药品”，也能跳搜索页
- 详情页收到初始药品对象后再补拉一次详情

### 状态来源

- 搜索输入态由 `_draftKeywordNotifier` 管理
- 已提交关键字用 `_keyword` 管理，避免输入中频繁请求
- 搜索结果“是否已添加”来自 `myMedicineRepository.loadIdentityKeys()`

### 网络 / 本地存储 / 后端流转

- 搜索页调用 `MedicineApi.search()`
- 点击详情后详情页调用 `MedicineApi.fetchDetail()`
- 用户点击 AI 按钮时再调用 `MedicineApi.fetchAiDetail()`
- 添加到“我的药品”时本地 SQLite 先写，再尽量同步远端

### 结果如何回到 UI

- 搜索结果分页追加到 `_results`
- 详情页用详情接口返回值覆盖初始 `MedicineItem`
- 选择器在 `pickerMode` 下直接 `Navigator.pop(item)` 返回上层

## 关键代码位置

- `lib/pages/Search/search.dart:159`
  搜索页初始化、自动搜索和滚动分页监听。
- `lib/pages/Search/search.dart:208`
  读取本地 identityKey，标记已添加药品。
- `lib/pages/Search/search.dart:861`
  快捷标签一键触发搜索。
- `lib/pages/Search/search.dart:1004`
  搜索 / 分页的统一请求方法。
- `lib/pages/Search/search.dart:959`
  把药品加入“我的药品”。
- `lib/pages/Picker/medicine_picker.dart:45`
  选择器加载本地药品和远端同步。
- `lib/pages/Picker/medicine_picker.dart:308`
  以 `pickerMode=true` 打开搜索页做选择。
- `lib/pages/Drug/medicine_detail.dart:64`
  拉基础详情。
- `lib/pages/Drug/medicine_detail.dart:101`
  拉 AI 解读。
- `lib/api/medicine_api.dart:15`
  搜索接口。
- `lib/api/medicine_api.dart:48`
  详情接口。
- `lib/api/medicine_api.dart:86`
  AI 解读接口。
- `backend/src/handlers/medicine-search.ts:7`
  搜索 handler。
- `backend/src/handlers/medicine-detail.ts:7`
  详情 handler。
- `backend/src/handlers/medicine-ai-detail.ts:9`
  AI 解读 handler。

## 容易忽略的实现细节

- 搜索页把“输入态”和“请求态”拆开了，这是减少无意义 rebuild 和请求的关键
- “最近搜索”目前只是内存态，没有持久化
- `MedicineDetailPage` 的 AI 解读不是自动请求，只有用户点击才会触发

## 如果以后要改，优先改哪里

- 改搜索交互：`lib/pages/Search/search.dart`
- 改选药来源：`lib/pages/Picker/medicine_picker.dart`
- 改详情页内容：`lib/pages/Drug/medicine_detail.dart`
- 改后端契约：先同步 `lib/api/medicine_api.dart` 和 `backend/src/handlers/*`

## 相关测试在哪

- `test/ai_scan_flow_test.dart:51`
  覆盖带初始关键字的自动搜索入口
