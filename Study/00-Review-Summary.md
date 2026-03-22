# 全仓库 Review 总结

本轮 review 覆盖了 `lib/`、`backend/src/`、关键 `android/` 启动文件、`test/` 和现有开发文档，重点只看 correctness、回归风险、结构风险、测试缺口和文档漂移。

## Findings

### P1. 取消打卡只删本地记录，没有回写服务端，跨设备会出现状态反转

- 问题描述
  `CheckInPage._markUndone()` 只删除本地 `checkins` 记录并写本地 override，没有调用任何远端撤销接口。
- 风险 / 影响
  当前设备上会显示“未打卡”，但服务端和其他设备仍可能保留“已打卡”；下次重新拉取今日提醒后，也可能再次被远端状态改回“已打卡”。
- 触发条件或复现线索
  登录用户先打卡，再点击“取消打卡”，然后在另一台设备查看或重新同步今日提醒即可复现状态不一致。
- 文件与位置
  `lib/pages/CheckIn/checkin.dart:364`
  `lib/stores/today_reminder_local_store.dart:86`
  `lib/api/checkin_api.dart:15`
- 简短修复方向
  增加服务端“撤销打卡 / 删除今日打卡”接口，前端在 `_markUndone()` 中先回写远端，再更新本地缓存和 override。

### P1. 首页和打卡页都会优先吃本地提醒缓存，远端改动很容易被旧本地数据盖住

- 问题描述
  首页 `_fetchTodayReminders()` 和打卡页 `_load()` 都在请求成功后优先使用 `todayReminderLocalStore.loadReminderItems()` 的结果，只要本地不为空，就忽略本次服务端返回的 `today-reminders` 数据。
- 风险 / 影响
  远端刚删除、修改、禁用提醒时，首页和打卡页仍可能展示旧计划；跨设备修改提醒后，本机 UI 会长期被旧本地缓存“锁住”。
- 触发条件或复现线索
  先让本地存在 reminders/checkins 缓存，再从另一端修改今日提醒，回到首页或打卡页刷新即可看到旧数据继续占优。
- 文件与位置
  `lib/pages/Home/home.dart:311`
  `lib/pages/Home/home.dart:346`
  `lib/pages/CheckIn/checkin.dart:75`
  `lib/pages/CheckIn/checkin.dart:85`
  `lib/stores/today_reminder_local_store.dart:100`
- 简短修复方向
  让今日提醒接口成功结果先落本地再统一从单一来源渲染，或者至少用远端结果校正本地 reminders 表后再读本地。

### P2. 相册远端同步在服务端返回空列表时不会清理本地旧远端记录，跨设备删除后会一直残留旧数据

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

- 问题描述
  `handleMedicineAiSafety()` 已接收 `productName`，但 enrich 阶段调用 `findMedicine()` 时完全没使用它。
- 风险 / 影响
  当前安全辅助如果以后从更宽松的入口传入药名而非身份字段，AI prompt 会缺少数据库补充信息，结果质量会下降，而且调用方很难从响应里看出是“没查到库”还是“根本没查”。
- 触发条件或复现线索
  用只包含 `productName` 的 medicines 调 `/medicine-ai-safety`，`detail` 会恒为 `null`。
- 文件与位置
  `backend/src/handlers/medicine-ai-safety.ts:52`
  `backend/src/db/medicine-repository.ts:92`
- 简短修复方向
  为安全辅助补一个按 `productName` 的回查分支，或在当前 handler 里显式声明只有 `drugCode/approvalNo` 会参与库内 enrichment。

### P3. 当前测试覆盖不到“今日提醒数据源优先级”和“取消打卡”这两条高风险路径，上面两个问题都会漏过 CI

- 问题描述
  现有代表性测试主要覆盖首页顶部文案、登录注册、扫描入口、提醒编辑 identity 清理和相册本地存储，但没有任何测试覆盖 `CheckInPage._markUndone()` 或首页/打卡页“本地缓存覆盖远端结果”的分支。
- 风险 / 影响
  提醒/打卡同步行为回归后，`flutter test` 仍然会全部通过，CI 不能替你兜底这类状态一致性问题。
- 触发条件或复现线索
  查看当前测试文件即可发现没有 `checkin`、`today-reminders` 数据源优先级相关用例。
- 文件与位置
  `test/home_top_section_test.dart:1`
  `test/login_page_test.dart:13`
  `test/ai_scan_flow_test.dart:11`
  `test/reminder_edit_page_test.dart:9`
  `lib/pages/Home/home.dart:311`
  `lib/pages/CheckIn/checkin.dart:319`
- 简短修复方向
  增加两个 widget/unit 测试：一个覆盖“远端返回新提醒但本地有旧缓存”的渲染优先级，一个覆盖“取消打卡需要远端同步”的行为契约。

### P3. Android 原生启动屏现在是固定尺寸 PNG 配合 `bitmap fill` 整屏拉伸，换到非常规比例设备时容易出现视觉变形

- 问题描述
  当前启动屏是 `drawable-nodpi/native_launch_screen.png`，并通过 `launch_background.xml` 的 `<bitmap android:gravity="fill" .../>` 直接整屏铺满。
- 风险 / 影响
  这张图现在是按单一手机比例导出的，换到平板、折叠屏或比例差异更大的设备时，启动画面会被直接拉伸，和 Flutter 页面的真实设计风格不一定一致。
- 触发条件或复现线索
  在宽屏或非常规纵横比设备上冷启动 App，观察顶部块面、文字和插画比例是否被拉宽或拉高。
- 文件与位置
  `android/app/src/main/res/drawable/launch_background.xml:4`
  `android/app/src/main/res/drawable-v21/launch_background.xml:4`
  `android/app/src/main/res/drawable-nodpi/native_launch_screen.png`
- 简短修复方向
  把启动屏拆成“纯色 / 渐变背景 + 居中主体元素”，尽量避免整张截图式 PNG 用 `fill` 拉伸；或者至少为不同尺寸准备更稳妥的资源策略。

## 优先级建议

1. 先修 `P1` 的打卡撤销一致性问题。
2. 再统一今日提醒的数据源口径，避免首页和打卡页继续被本地旧缓存盖住。
3. 然后修相册远端全量同步逻辑，避免跨设备删除后本地继续残留旧记录。
4. 最后补对应测试，把上面两类状态问题纳入回归保护。

## 本轮附带收口

- 根 `README.md` 已补充说明：`backend/` 当前正式整理的是 5 个药品接口，但 App 运行仍依赖其他现有 Sealos 云函数。

## 本轮验证

- `flutter analyze`
- `flutter test test/home_top_section_test.dart test/login_page_test.dart test/ai_scan_flow_test.dart test/reminder_edit_page_test.dart test/album_local_store_test.dart`
- `npm run build`（在 `backend/`）
