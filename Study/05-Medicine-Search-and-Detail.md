# 05 药品搜索与详情

## 这一篇最重要的结论

药品搜索、药品选择器、药品详情页、AI 解读，其实是一条连续链路，不是四个孤立页面。

它们串起来的主线是：

1. 从搜索页或选择器拿到一个 `MedicineItem`
2. 详情页再用 `drugCode/approvalNo` 补拉完整详情
3. 用户需要时再按同一身份字段请求 AI 解读
4. 用户也可以把药品加入“我的药品”，本地先写、远端尽量同步

所以你以后如果要改这块，通常不会只改一个页面文件。

## 这个功能是干什么的

这一部分负责：

- 手动搜索后端药品库
- 从“我的药品”或搜索页选择药品
- 进入药品详情页看基础信息
- 按需请求 AI 智能解读
- 把药品加入“我的药品”

## 建议你第一次怎么读

推荐顺序：

1. `lib/pages/Search/search.dart`
2. `lib/api/medicine_api.dart`
3. `lib/pages/Drug/medicine_detail.dart`
4. `lib/pages/Picker/medicine_picker.dart`
5. `lib/stores/my_medicine_repository.dart`
6. `backend/src/handlers/medicine-search.ts`
7. `backend/src/handlers/medicine-detail.ts`
8. `backend/src/handlers/medicine-ai-detail.ts`

这样你会先看前端交互主线，再补全后端契约。

## 用户从哪里进入 / 如何触发

- 首页快捷入口“手动搜索”
- 药品页中的手动搜索入口
- 安全辅助、提醒编辑等页面通过药品选择器选药
- 搜索结果点击卡片进入详情
- 搜索结果点击“添加”加入“我的药品”
- 详情页点击 AI 区域按钮请求智能解读

## 关键页面、组件、API、store、backend、native 文件

- 搜索页：`lib/pages/Search/search.dart`
- 药品详情：`lib/pages/Drug/medicine_detail.dart`
- 药品选择器：`lib/pages/Picker/medicine_picker.dart`
- 药品 API：`lib/api/medicine_api.dart`
- 药品模型：`lib/viewmodels/medicine.dart`
- “我的药品”仓库：`lib/stores/my_medicine_repository.dart`
- 后端：
  - `backend/src/handlers/medicine-search.ts`
  - `backend/src/handlers/medicine-detail.ts`
  - `backend/src/handlers/medicine-ai-detail.ts`

## 搜索页真正的状态拆分

搜索页最值得学习的地方，不是 UI，而是它把“输入态”和“请求态”分开了。

### 输入态

- 输入框 controller
- `_draftKeywordNotifier`

这部分只表示“用户现在正在输入什么”。

### 请求态

- `_keyword`
- `_page`
- `_hasMore`
- `_results`
- `_loading`
- `_loadingMore`

这部分才表示“当前真正发请求用的关键词和分页状态”。

这样拆开的好处是：

- 用户输入时不会立即发请求
- 页面不会因为每打一个字就触发整套搜索逻辑
- 翻页、重置搜索、清空搜索都更好控制

对应关键位置：

- `lib/pages/Search/search.dart:159-201`
- `lib/pages/Search/search.dart:341-368`
- `lib/pages/Search/search.dart:876-889`
- `lib/pages/Search/search.dart:1004-1060`

## 核心实现路径

### UI 入口

搜索页在视觉上是一个完整页面，但真正关键的是以下入口：

- `lib/pages/Search/search.dart:159-201`
  初始化、自动搜索和滚动分页监听
- `lib/pages/Search/search.dart:341-368`
  搜索输入框
- `lib/pages/Search/search.dart:606-647`
  结果列表
- `lib/pages/Search/search.dart:854-870`
  快捷标签搜索
- `lib/pages/Search/search.dart:876-889`
  手动提交搜索

### 自动搜索是怎么做的

当搜索页带 `initialKeyword` 进入，并且 `autoSearchOnInit = true` 时：

- `lib/pages/Search/search.dart:161-170`
  会先把输入框和 `_keyword` 初始化好
- `lib/pages/Search/search.dart:195-200`
  再在首帧后主动触发一次 `_search(reset: true)`

这就是为什么某些页面可以直接带着关键字进入搜索结果。

### 真正的搜索请求怎么发

真正的请求入口在：

- `lib/pages/Search/search.dart:1004-1060`

这里会区分两种情况：

1. `reset = true`
   清空旧结果，从第 1 页重新请求
2. `reset = false`
   保留旧结果，继续拉下一页

真正调用 API 的位置在：

- `lib/pages/Search/search.dart:1033-1044`
- `lib/api/medicine_api.dart:15-43`

接口返回后，会把结果追加到 `_results`，并更新：

- `_hasMore`
- `_page`

## 搜索结果如何标记“已添加”

这也是搜索页很关键的一段逻辑。

页面初始化时会先加载当前用户作用域下已存在的药品 identityKey：

- `lib/pages/Search/search.dart:208-232`
- `lib/stores/my_medicine_repository.dart:79-85`

结果卡片渲染时，再把每个结果生成 identityKey 去比对：

- `lib/pages/Search/search.dart:618-623`
- `lib/pages/Search/search.dart:948-953`

这样搜索结果一出现就知道：

- 哪些药已经在“我的药品”
- 哪些结果还可以点“添加”

## “加入我的药品”是怎么走的

入口在：

- `lib/pages/Search/search.dart:959-989`

流程是：

1. 先按当前用户作用域生成 identityKey
2. 调 `myMedicineRepository.addMedicine(...)`
3. repository 先写本地 SQLite
4. 如果当前已登录，再尽量同步到远端
5. 页面本地马上把 `_addedKeys` 补上
6. 按远端同步是否成功给出不同提示

真正的本地 + 远端逻辑在：

- `lib/stores/my_medicine_repository.dart:91-155`

这意味着“添加到我的药品”是本地优先体验，不会把整次操作完全绑死在远端成功上。

## 药品选择器是怎么复用搜索页的

药品选择器并不是重新实现一套搜索逻辑，而是：

1. 先读本地“我的药品”
2. 已登录时再尝试同步远端
3. 如果还想搜库，就以 `pickerMode = true` 打开搜索页

对应代码在：

- `lib/pages/Picker/medicine_picker.dart:39-68`
- `lib/pages/Picker/medicine_picker.dart:308-318`

搜索页在 `pickerMode` 下点击卡片时不会进详情，而是：

- `Navigator.pop(context, item)`

对应代码在：

- `lib/pages/Search/search.dart:631-639`

这就是为什么一个搜索页可以同时承担“正常搜索页”和“选药子流程”两种角色。

## 详情页怎么补全基础信息

详情页并不假设传进来的 `MedicineItem` 已经完整。

它的策略是：

1. 先用传入的 `initialItem` 起页面
2. 如果 `hasIdentity = true`
3. 再用 `drugCode/approvalNo` 请求完整详情
4. 返回后覆盖 `_item`

对应位置：

- `lib/pages/Drug/medicine_detail.dart:54-58`
- `lib/pages/Drug/medicine_detail.dart:64-96`

这样做的好处是：

- 从搜索结果进入详情时可以立即出页面
- 更完整的信息异步再补齐

## AI 解读为什么不是自动请求

AI 解读在当前实现里是按需触发，不是进详情页就自动打。

入口在：

- `lib/pages/Drug/medicine_detail.dart:101-134`

原因很实际：

- AI 请求更慢
- 成本更高
- 并不是每个用户进详情都一定需要

所以当前详情页把“基础详情”和“AI 解读”拆成了两条独立链路。

## 前后端对应关系

Flutter 侧：

- `lib/api/medicine_api.dart:15-43`
  搜索
- `lib/api/medicine_api.dart:48-81`
  详情
- `lib/api/medicine_api.dart:86-109`
  AI 解读

后端侧：

- `backend/src/handlers/medicine-search.ts:7-26`
- `backend/src/handlers/medicine-detail.ts:7-29`
- `backend/src/handlers/medicine-ai-detail.ts:9-31`

如果以后你改字段，不要只改前端或只改后端，要成对更新。

## 一条最短的读码路径

如果你以后只想最快看懂这一整条链，推荐顺序：

1. `lib/pages/Search/search.dart:159-232`
2. `lib/pages/Search/search.dart:606-647`
3. `lib/pages/Search/search.dart:854-889`
4. `lib/pages/Search/search.dart:948-989`
5. `lib/pages/Search/search.dart:1004-1060`
6. `lib/pages/Drug/medicine_detail.dart:64-134`
7. `lib/pages/Picker/medicine_picker.dart:39-68`
8. `lib/pages/Picker/medicine_picker.dart:308-318`
9. `lib/stores/my_medicine_repository.dart:35-64`
10. `lib/stores/my_medicine_repository.dart:91-177`

## 关键代码位置

- `lib/pages/Search/search.dart:159-201`
  初始化、自动搜索和分页监听。
- `lib/pages/Search/search.dart:208-232`
  读取本地已添加药品 identityKey。
- `lib/pages/Search/search.dart:606-647`
  渲染搜索结果并决定“进详情”还是“直接返回”。
- `lib/pages/Search/search.dart:854-870`
  快捷标签直接搜索。
- `lib/pages/Search/search.dart:876-889`
  提交搜索入口。
- `lib/pages/Search/search.dart:948-953`
  当前结果 identityKey 生成。
- `lib/pages/Search/search.dart:959-989`
  把药品加入“我的药品”。
- `lib/pages/Search/search.dart:1004-1060`
  搜索和分页统一请求入口。
- `lib/pages/Drug/medicine_detail.dart:64-96`
  拉基础详情。
- `lib/pages/Drug/medicine_detail.dart:101-134`
  拉 AI 解读。
- `lib/pages/Picker/medicine_picker.dart:45-60`
  先读本地、登录后再同步远端。
- `lib/pages/Picker/medicine_picker.dart:308-318`
  以 `pickerMode = true` 打开搜索页。
- `lib/api/medicine_api.dart:15-43`
  搜索接口。
- `lib/api/medicine_api.dart:48-81`
  详情接口。
- `lib/api/medicine_api.dart:86-109`
  AI 解读接口。
- `lib/stores/my_medicine_repository.dart:35-64`
  带用户作用域的 identityKey 生成。
- `lib/stores/my_medicine_repository.dart:91-155`
  添加“我的药品”。
- `lib/stores/my_medicine_repository.dart:163-177`
  登录后同步远端药品。
- `lib/stores/my_medicine_repository.dart:244-290`
  游客药品迁移到登录用户作用域。

## 容易忽略的实现细节

- 搜索页不是输入即搜，而是“确认搜索”后才真正发请求。
- 快捷标签会直接同步输入态、请求态和最近搜索，然后立即触发搜索。
- “最近搜索”当前还是页面内状态，不是持久化能力。
- 详情页 AI 解读是按需触发，不是自动请求。
- 加入“我的药品”是本地先落地，远端同步是尽力而为。

## 如果以后要改，优先改哪里

### 想改搜索交互

先看：

1. `lib/pages/Search/search.dart`

### 想改选药逻辑

先看：

1. `lib/pages/Picker/medicine_picker.dart`
2. `lib/pages/Search/search.dart`

### 想改详情页信息块或 AI 区域

先看：

1. `lib/pages/Drug/medicine_detail.dart`

### 想改“我的药品” identityKey 或同步策略

先看：

1. `lib/stores/my_medicine_repository.dart`

### 想改接口契约

先看：

1. `lib/api/medicine_api.dart`
2. `lib/viewmodels/medicine.dart`
3. `backend/src/handlers/*`

## 初学时最容易卡住的点

- 误以为搜索页结果里的“已添加”来自后端字段。实际上不是，是本地 identityKey 比对。
- 误以为详情页拿到初始药品对象就够了。实际上它还会主动补拉详情。
- 误以为药品选择器自己实现了搜索。实际上它主要复用了搜索页的 `pickerMode`。

## 相关测试在哪

- `test/ai_scan_flow_test.dart:51-81`
  覆盖带初始关键字进入搜索页后的自动搜索入口。

当前还没有非常完整的搜索页分页、详情页 AI 解读、添加“我的药品”的组件测试。如果你以后要补，这三块最值得优先加。
