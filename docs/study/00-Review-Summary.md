# 全仓库 Review 总结

这份总结保留第一次 review 的问题视角，但状态已经同步到当前代码。下面每条 finding 都会明确标出 `已解决`、`已缓解` 或 `仍待处理`，方便你后面继续对照消化。

## Findings

### P1. 用药打卡原来依赖远端创建记录，撤销时却只改本地，状态口径不一致

- 状态
  已解决
- 当前实现
  用药打卡已经改成纯本地链路：打卡页直接读取本地 `reminders` 计划，打卡和撤销都只写 `checkins / checkin_overrides`，不再调用 `checkin-create`，也不再把“远端已打卡 / 本地撤销”混在一起。
- 风险 / 影响
  这条“本地打卡、云端撤销缺失”的一致性问题已经消失；当前产品语义就是“打卡状态只保存在本机”。
- 触发条件或复现线索
  现在进入打卡页时，即使不请求后端，也能直接从本地提醒计划生成当天条目；点击打卡 / 撤销后只会影响当前设备显示。
- 文件与位置
  `lib/pages/CheckIn/checkin.dart:17`
  `lib/pages/CheckIn/checkin.dart:67`
  `lib/pages/CheckIn/checkin.dart:336`
  `lib/pages/CheckIn/checkin.dart:373`
  `lib/stores/today_reminder_local_store.dart:210`
- 后续修复方向
  如果以后又想做跨设备同步，再重新定义“打卡是否需要上云”的产品语义，并单独补完整的远端增删接口，不要再落回“创建走云端、撤销只改本地”的中间态。

### P1. 首页和打卡页都会优先吃本地提醒缓存，远端改动很容易被旧本地数据盖住

- 状态
  已解决
- 当前实现
  首页和打卡页现在都会先请求 `today-reminders`，成功后把完整结果覆盖到 `today_reminder_snapshots`，再统一从“当天快照 + checkins + checkin_overrides”读取最终 UI 数据；失败时只回退到当天快照，不再回退到 `reminders` 表去“猜今天该显示什么”。
- 风险 / 影响
  这条高优覆盖问题已经收口；后续只有在把 `reminders` 表重新接回首页/打卡页主渲染链路时，才会再次引入回归风险。
- 触发条件或复现线索
  现在即使本地旧计划仍留在 `reminders` 表里，只要这次 `today-reminders` 请求成功，首页和打卡页都会显示新的远端结果。
- 文件与位置
  `lib/pages/Home/home.dart:328`
  `lib/pages/Home/home.dart:348`
  `lib/pages/Home/home.dart:357`
  `lib/pages/CheckIn/checkin.dart:67`
  `lib/pages/CheckIn/checkin.dart:93`
  `lib/pages/CheckIn/checkin.dart:101`
  `lib/stores/today_reminder_local_store.dart:68`
  `lib/stores/today_reminder_local_store.dart:185`
  `lib/stores/app_database.dart:176`
- 后续修复方向
  继续保持“远端成功结果优先 + 单一当天快照源”的口径，不要把 `reminders` 表直接当成首页/打卡页当天展示真相。

### P2. 相册远端同步在服务端返回空列表时不会清理本地旧远端记录，跨设备删除后会一直残留旧数据

- 状态
  仍待处理
- 问题描述
  `AlbumLocalStore.syncRemoteForUser()` 拉完整个远端列表后只会调用 `upsertRemoteRecords()` 做增量回写；而 `upsertRemoteRecords()` 在 `remoteItems.isEmpty` 时直接 `return`，不会删除当前用户本地已经同步过的远端记录。
- 风险 / 影响
  如果用户在另一台设备或云端把识别相册清空，本机同步后仍会继续看到旧条目，形成“云端已删、本地一直残留”的状态分叉。
- 触发条件或复现线索
  先让本地存在带 `remoteId` 的相册记录，再让远端列表返回空数组，随后执行 `syncRemoteForUser()`，本地旧记录仍然保留。
- 文件与位置
  `lib/stores/album_local_store.dart:99`
  `lib/stores/album_local_store.dart:122`
  `lib/stores/album_local_store.dart:139`
- 简短修复方向
  把相册同步改成“远端列表就是用户当前完整真相”的全量替换逻辑；至少在远端返回空列表时清理当前用户已有的远端记录，同时保留未同步成功的本地 pending 记录。

### P3. `medicine-ai-safety` 只会用 `drugCode/approvalNo` 回查药库，传入仅有 `productName` 的药品时会静默丢掉数据库补充信息

- 状态
  仍待处理
- 问题描述
  `handleMedicineAiSafety()` 已接收 `productName`，但 enrich 阶段调用 `findMedicine()` 时完全没使用它。
- 风险 / 影响
  当前安全辅助如果以后从更宽松的入口传入药名而非身份字段，AI prompt 会缺少数据库补充信息，结果质量会下降，而且调用方很难从响应里看出是“没查到库”还是“根本没查”。
- 触发条件或复现线索
  用只包含 `productName` 的 medicines 调 `/medicine-ai-safety`，`detail` 会恒为 `null`。
- 文件与位置
  `backend/src/handlers/medicine-ai-safety.ts:55`
  `backend/src/db/medicine-repository.ts:92`
- 简短修复方向
  为安全辅助补一个按 `productName` 的回查分支，或在当前 handler 里显式声明只有 `drugCode/approvalNo` 会参与库内 enrichment。

### P3. 当前测试覆盖不到“今日提醒数据源优先级”和“取消打卡”这两条高风险路径，上面两个问题都会漏过 CI

- 状态
  已解决
- 当前实现
  现在已经补了 3 组测试：
  `test/home_today_reminders_test.dart` 覆盖“远端结果覆盖旧快照并渲染新提醒”；
  `test/checkin_page_test.dart` 覆盖打卡页从本地提醒计划构建列表，以及“取消打卡”本地提示和 override 写入；
  `test/today_reminder_local_store_test.dart` 覆盖日期解析与 done 状态优先级 helper。
- 风险 / 影响
  提醒 / 打卡这两条高风险路径已经进入 `flutter test` 回归保护。
- 文件与位置
  `test/home_today_reminders_test.dart:36`
  `test/checkin_page_test.dart:38`
  `test/checkin_page_test.dart:91`
  `test/today_reminder_local_store_test.dart:6`
  `test/today_reminder_local_store_test.dart:20`
- 后续修复方向
  如果以后重新引入云端打卡，再追加一条“本地状态与远端状态必须保持同一口径”的行为契约测试。

### P3. Android 原生启动屏的整屏 PNG 拉伸问题已处理

- 状态
  已处理
- 问题描述
  启动屏已经切换到 Android 12 的系统 `SplashScreen`，不再使用 `native_launch_screen.png + launch_background.xml` 的整屏拉伸方案。
- 风险 / 影响
  冷启动图标现在使用矢量 `splash_wordmark_icon.xml`，在高 dpi 屏幕上清晰度更稳定，也避免了非常规比例设备上的整屏位图变形。
- 触发条件或复现线索
  可在不同 dpi 与纵横比设备上冷启动 App，确认系统 SplashScreen 只显示居中图标，不再出现整屏插画被拉伸的问题。
- 文件与位置
  `android/app/src/main/res/values/styles.xml:3`
  `android/app/src/main/res/values-night/styles.xml:3`
  `android/app/src/main/res/drawable/splash_wordmark_icon.xml:2`
- 简短修复方向
  后续如果还要调整品牌视觉，优先继续维护 SVG / VectorDrawable，而不是回到整屏静态位图。

## 优先级建议

1. 先补 `P2` 的相册全量同步，避免跨设备删除后本地继续残留旧记录。
2. 继续保持打卡纯本地这一条产品口径；如果以后改回云端同步，再把增删接口和一致性测试一次补齐。
3. 然后修 `medicine-ai-safety` 的按药名回查分支。
4. Android 启动屏这条已收敛完成，后续只需要按品牌视觉继续维护矢量图标即可。

## 本轮附带收口

- `04-Home-and-Today-Reminders.md` 已同步到“远端成功后覆盖当天快照，再统一从快照渲染”的新口径。
- `07-Reminders-and-CheckIn.md` 已同步到“打卡纯本地、状态只保存在当前设备”的新口径。
- `08-Local-Storage-and-Sync.md` 已补充 `today_reminder_snapshots` 表和它与 `reminders / checkins / checkin_overrides` 的职责边界。
- 根 `README.md` 已补充说明：用药打卡当前是纯本地功能，不依赖打卡后端接口。

## 本轮验证

- `flutter analyze`
- `flutter test`
