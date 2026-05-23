# 07 提醒与打卡

## 这一篇最重要的结论

当前“提醒计划”和“用药打卡”已经不是同一套后端模型了。

现在的关系是：

- 提醒计划：仍然是远端为主，本地缓存兜底
- 用药打卡：已经改成纯本地功能，只依赖本地提醒计划和当天本地状态

所以你以后碰到这块问题，先分清楚你改的是：

1. 提醒计划本身
2. 本地通知调度
3. 今天是否打过卡

这三者相关，但不再完全共用同一套来源。

## 这个功能是干什么的

这一部分负责：

- 提醒计划列表加载
- 提醒新增、编辑、启停、删除
- 系统通知重建
- 今日用药打卡
- 打卡状态回流到首页当天提醒

## 建议你第一次怎么读

推荐顺序：

1. `lib/pages/Reminders/reminder_list.dart`
2. `lib/pages/Reminders/reminder_edit.dart`
3. `lib/api/reminder_api.dart`
4. `lib/stores/reminder_local_store.dart`
5. `lib/utils/notification_service.dart`
6. `lib/pages/CheckIn/checkin.dart`
7. `lib/stores/today_reminder_local_store.dart`
8. `test/reminder_edit_page_test.dart`
9. `test/checkin_page_test.dart`

这样你会先把“提醒计划”这条远端链看清楚，再看“打卡”这条纯本地链。

## 用户从哪里进入 / 如何触发

- 首页快捷入口“用药提醒”进入提醒列表
- 首页快捷入口“用药打卡”进入打卡页
- 提醒列表右下角新增提醒
- 点击已有提醒进入编辑
- 提醒卡片开关启停
- 提醒卡片删除按钮删除计划
- 打卡页点击按钮切换已打卡 / 未打卡

## 关键页面、组件、API、store、backend、native 文件

- 提醒列表：`lib/pages/Reminders/reminder_list.dart`
- 提醒编辑：`lib/pages/Reminders/reminder_edit.dart`
- 打卡页：`lib/pages/CheckIn/checkin.dart`
- 提醒 API：`lib/api/reminder_api.dart`
- 提醒本地缓存：`lib/stores/reminder_local_store.dart`
- 今日提醒状态：`lib/stores/today_reminder_local_store.dart`
- 通知调度：`lib/utils/notification_service.dart`
- 测试：
  - `test/reminder_edit_page_test.dart`
  - `test/checkin_page_test.dart`

## 提醒列表的真实数据流

提醒列表的核心不是单纯“拉接口”，而是“远端成功时回写本地，失败时退本地”。

### 加载列表

主流程在：

- `lib/pages/Reminders/reminder_list.dart:75-120`

顺序是：

1. 先拿当前 `userId`
2. 未登录则直接清空列表
3. 防止重复加载
4. 调 `ReminderApi.list()`
5. 成功后排序并更新 `_items`
6. 写本地 `reminders` 表
7. 重新调度系统通知
8. 失败时退回本地缓存

对应回退逻辑在：

- `lib/pages/Reminders/reminder_list.dart:123-132`

这就是为什么提醒页在网络失败时，仍然可能显示上一次同步成功的本地列表。

### 为什么提醒列表要自己持久化本地缓存

因为它不仅是一个页面 UI，还承担了“本地通知调度输入源”的角色。

当前通知服务重建依赖的正是本地最新提醒计划，所以列表页每次成功更新、启停、删除后都会重新：

- 持久化本地
- `NotificationService.rescheduleAll()`

## 提醒编辑页真正要注意什么

编辑页既承担新增也承担编辑，因此它不是简单表单，而是带业务约束的表单。

### 选药流程

入口在：

- `lib/pages/Reminders/reminder_edit.dart:341-356`

会通过 `MedicinePickerPage` 选药，再回填：

- 药品名称
- `drugCode`
- `approvalNo`
- `_selectedProductName`

### 手改药名为什么要清身份字段

这是提醒编辑页非常关键的一条规则。

在：

- `lib/pages/Reminders/reminder_edit.dart:150-168`

如果用户手动改了药名，并且已经不等于原来选择器带回来的 `_selectedProductName`，页面会主动清掉：

- `_drugCode`
- `_approvalNo`

原因很简单：

- 否则会出现“药名是新值，但身份字段还是旧药”的错配风险

这个规则也是当前测试重点覆盖的一条。

### 保存提醒

保存入口在：

- `lib/pages/Reminders/reminder_edit.dart:382-421`

顺序是：

1. 检查是否登录
2. 校验药品名称不能为空
3. 调 `ReminderApi.upsert()`
4. 成功后 `Navigator.pop(context, response.result)`

也就是说，编辑页本身不负责更新列表页，而是把新的 `ReminderPlan` 返回给上一页。

## 列表页是怎么接住新增和编辑结果的

新增：

- `lib/pages/Reminders/reminder_list.dart:363-377`

编辑：

- `lib/pages/Reminders/reminder_list.dart:379-395`

共同点是：

1. 从编辑页拿回 `ReminderPlan`
2. 更新当前 `_items`
3. 本地持久化
4. 通知全量重建

这种写法的好处是：

- 编辑页更纯
- 列表页更容易保证本地缓存和通知状态始终一致

## 启停和删除提醒怎么走

### 启停

- `lib/pages/Reminders/reminder_list.dart:397-424`

这里会再次走 `ReminderApi.upsert()`，而不是本地直接改布尔值。成功后再：

- 更新 `_items`
- 写本地缓存
- 重建通知

### 删除

- `lib/pages/Reminders/reminder_list.dart:427-463`

这里会先确认，再调 `ReminderApi.delete()`，然后同步：

- 删页面内数据
- 删本地缓存对应结果
- 重建通知

## 通知服务和提醒计划是什么关系

`NotificationService` 当前不是页面级辅助，而是提醒功能的一部分。

最关键的方法在：

- `lib/utils/notification_service.dart:125-194`

它会：

1. 初始化通知插件
2. 确保有通知权限
3. 先取消全部旧通知
4. 遍历提醒计划重新 schedule

而且当前只会为这些提醒生成通知：

- `enabled = true`
- `repeatRule = daily`
- `method = notification`
- `id` 非空

这意味着如果你以后加了别的提醒类型，不改通知服务的话，系统通知不会自动支持。

## 打卡页为什么现在是纯本地

当前打卡页已经不再依赖打卡后端接口。

它的策略是：

1. 从本地 `reminders` 计划构建今天可打卡条目
2. 用 `todayReminderLocalStore.applyTodayState()` 叠加本地完成状态
3. 打卡时只写本地 `checkins` 和 `checkin_overrides`
4. 撤销时也只改本地

所以当前打卡状态只保证当前设备一致，不保证云端同步。

## 打卡页的真实加载路径

入口在：

- `lib/pages/CheckIn/checkin.dart:62-114`

顺序是：

1. 读取当前用户 id
2. 从本地加载提醒计划
3. 只保留 `enabled + 支持本地打卡` 的计划
4. 再用 `todayReminderStore.applyTodayState()` 叠加当天本地状态
5. 把结果显示成 `_items`

构建当天可打卡条目的位置在：

- `lib/pages/CheckIn/checkin.dart:426-447`

这里当前只支持：

- `repeatRule` 为空
- 或 `daily`

## 打卡和取消打卡是怎么实现的

### 标记已打卡

入口在：

- `lib/pages/CheckIn/checkin.dart:324-352`

它会：

1. 删除当天重复记录并写一条新的本地 `checkins`
2. 写 `checkin_overrides.done = true`
3. toast 提示“已记录到当前设备”
4. 直接本地更新当前 UI

### 撤销打卡

入口在：

- `lib/pages/CheckIn/checkin.dart:354-406`

它会先弹确认框，文案明确告诉用户：

- 当前用药打卡只保存在本机

确认后再：

1. 删除当天本地 `checkins`
2. 写 `checkin_overrides.done = false`
3. 本地更新 UI

这就是“临时本地缓解”的真实实现。

## 现在首页和打卡页为什么能保持同设备一致

因为首页和打卡页最终都走了同一套本地状态叠加规则：

- `checkins`
- `checkin_overrides`
- `today_reminder_snapshots`

而不是各自写各自的 done 状态。

真正统一判定在：

- `lib/stores/today_reminder_local_store.dart:268-315`
- `lib/stores/today_reminder_local_store.dart:389-404`

所以当前只要在同一台设备上操作，首页和打卡页当天表现可以保持一致。

## 一条最短的读码路径

如果你以后只想最快看懂这一整条链，推荐顺序：

1. `lib/pages/Reminders/reminder_list.dart:75-132`
2. `lib/pages/Reminders/reminder_list.dart:363-463`
3. `lib/pages/Reminders/reminder_edit.dart:150-168`
4. `lib/pages/Reminders/reminder_edit.dart:341-421`
5. `lib/api/reminder_api.dart:11-88`
6. `lib/stores/reminder_local_store.dart:19-61`
7. `lib/utils/notification_service.dart:125-194`
8. `lib/pages/CheckIn/checkin.dart:62-114`
9. `lib/pages/CheckIn/checkin.dart:324-447`
10. `lib/stores/today_reminder_local_store.dart:162-228`

## 关键代码位置

- `lib/pages/Reminders/reminder_list.dart:75-120`
  提醒列表加载主流程。
- `lib/pages/Reminders/reminder_list.dart:123-132`
  网络失败时回退本地缓存。
- `lib/pages/Reminders/reminder_list.dart:152-160`
  持久化当前列表到本地。
- `lib/pages/Reminders/reminder_list.dart:363-377`
  新增提醒后的回写流程。
- `lib/pages/Reminders/reminder_list.dart:379-395`
  编辑提醒后的回写流程。
- `lib/pages/Reminders/reminder_list.dart:397-424`
  启停提醒。
- `lib/pages/Reminders/reminder_list.dart:427-463`
  删除提醒。
- `lib/pages/Reminders/reminder_edit.dart:150-168`
  手改药名时清空旧身份字段。
- `lib/pages/Reminders/reminder_edit.dart:341-356`
  打开药品选择器并回填。
- `lib/pages/Reminders/reminder_edit.dart:382-421`
  保存提醒。
- `lib/pages/CheckIn/checkin.dart:62-114`
  打卡页从本地提醒计划加载今日列表。
- `lib/pages/CheckIn/checkin.dart:324-352`
  标记已打卡。
- `lib/pages/CheckIn/checkin.dart:354-406`
  撤销本地打卡。
- `lib/pages/CheckIn/checkin.dart:426-447`
  从提醒计划构建可打卡条目。
- `lib/api/reminder_api.dart:11-29`
  列表接口。
- `lib/api/reminder_api.dart:31-66`
  新增 / 编辑 / 启停接口。
- `lib/api/reminder_api.dart:68-88`
  删除接口。
- `lib/stores/reminder_local_store.dart:19-61`
  提醒计划本地缓存。
- `lib/stores/today_reminder_local_store.dart:162-228`
  本地 override 和本地 checkin 写入。
- `lib/utils/notification_service.dart:125-194`
  全量重建系统通知。

## 容易忽略的实现细节

- 提醒列表和通知调度是绑在一起的，列表更新后必须重建通知。
- 手改药名会清身份字段，这不是 bug，而是故意避免错配。
- 打卡页当前完全不走打卡后端接口。
- 撤销打卡文案已经明确提示“只影响当前设备”，不要把它当成云端撤销。

## 如果以后要改，优先改哪里

### 想改提醒列表、启停或删除流程

先看：

1. `lib/pages/Reminders/reminder_list.dart`
2. `lib/api/reminder_api.dart`
3. `lib/stores/reminder_local_store.dart`

### 想改提醒编辑表单

先看：

1. `lib/pages/Reminders/reminder_edit.dart`
2. `05-Medicine-Search-and-Detail.md`

### 想改通知调度规则

先看：

1. `lib/utils/notification_service.dart`

### 想改打卡口径

先看：

1. `lib/pages/CheckIn/checkin.dart`
2. `lib/stores/today_reminder_local_store.dart`

## 初学时最容易卡住的点

- 误以为提醒计划和打卡都还是后端主导。现在不是。
- 误以为打卡页从 `today-reminders` 直接读当天数据。当前不是，它先从本地提醒计划构建条目。
- 误以为撤销打卡只是 UI 改一下。实际上还会写本地 override，保证同设备当天状态稳定。

## 相关测试在哪

- `test/reminder_edit_page_test.dart:19-63`
  覆盖“手改药名后清掉旧 identity”。
- `test/checkin_page_test.dart:37-99`
  覆盖“从本地提醒计划构建打卡列表并叠加本地完成状态”。
- `test/checkin_page_test.dart:101-154`
  覆盖“撤销打卡前提示本地-only，并写入 override”。

当前还没有特别完整的提醒列表交互测试和通知调度自动化测试，这两块如果以后要补质量，会很值得优先做。
