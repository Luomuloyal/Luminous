# Luminous UI 实现计划

最后更新: 2026-05-29

> 基于设计稿，将 Luminous 从"用药查询工具"升级为"个人健康智能助手"。

---

## 现状分析

### ✅ 已实现（保留 & 打磨）

| 模块         | 功能                    | 状态        |
| ------------ | ----------------------- | ----------- |
| `auth/`      | 登录、注册、会话管理    | ✅ 完成     |
| `drug/`      | 药品搜索、详情、AI 卡片 | ✅ 完成     |
| `scan/`      | 条码扫描                | ✅ 完成     |
| `reminders/` | 用药提醒                | ✅ 完成     |
| `checkin/`   | 打卡记录                | ✅ 完成     |
| `safety/`    | 药品相互作用            | ✅ 完成     |
| `album/`     | 相册                    | ✅ 完成     |
| `mine/`      | 个人中心                | ✅ 基础完成 |
| `settings/`  | 设置                    | ✅ 完成     |
| `more/`      | 更多功能                | ✅ 基础完成 |
| `home/`      | 首页                    | ✅ 基础完成 |
| `today/`     | 今日页 UI 框架          | ✅ UI 完成  |

### ❌ 需要新增/重构（来自设计稿）

| 模块          | 功能                                   | 优先级 | 进度         |
| ------------- | -------------------------------------- | ------ | ------------ |
| `today/`      | 喝水追踪、健康快照、饮食建议、环境提醒 | 🔴 P0  | ✅ UI 已搭建 |
| `record/`     | 日历视图、时间线、多类型记录           | 🔴 P0  | ❌ 未开始    |
| `medication/` | 今日用药计划、服药率统计、补充提醒     | 🔴 P0  | ❌ 未开始    |
| `mine/`       | 健康档案、目标计划、周报               | 🟡 P1  | ❌ 未开始    |
| `more/`       | AI 工具箱、紧急帮助、设备管理          | 🟡 P1  | ❌ 未开始    |
| `family/`     | 关爱家人                               | 🟢 P2  | ❌ 未开始    |

---

## 分阶段实施计划

### 第一阶段：核心体验升级 🔴（2-3 周）

> 重点：今日页 + 记录页 + 用药页改造

#### 1.1 今日页（Today）重构

**文件**：`lib/features/today/`（新建独立 feature，替代原 `home/` 中的今日功能）

| 任务           | 说明                                 | 状态       |
| -------------- | ------------------------------------ | ---------- |
| 喝水追踪卡片   | 每日目标、已喝次数、进度环           | ✅ UI 完成 |
| 健康快照卡片   | 心率、血压、睡眠数据展示             | ✅ UI 完成 |
| 用药提醒卡片   | 今日待服药品列表、下次提醒           | ✅ UI 完成 |
| 饮食建议卡片   | AI 驱动的饮食推荐                    | ✅ UI 完成 |
| 环境提醒卡片   | 花粉、紫外线指数                     | ✅ UI 完成 |
| Lumi 建议卡片  | AI 健康建议（重构现有）              | ✅ UI 完成 |
| 国际化         | 27 个 l10n 键，中/英双语             | ✅ 完成    |
| 可复用组件封装 | 进度环、统计卡片、区块标题、环境标签 | ✅ 完成    |
| 全局常量       | `TodayConstants` 统一管理            | ✅ 完成    |
| Provider 接入  | 接入真实 API 数据                    | ⏳ 待做    |
| 数据模型       | `WaterIntake` / `HealthSnapshot` 等  | ⏳ 待做    |

**新增 Provider**：

```dart
// 喝水追踪
waterIntakeProvider          // AsyncNotifier<WaterIntake>
waterGoalProvider            // Provider<int>

// 健康快照
healthSnapshotProvider       // AsyncNotifier<HealthSnapshot>

// 饮食建议
dietSuggestionProvider       // AsyncNotifier<DietSuggestion>

// 环境提醒
environmentAlertProvider     // AsyncNotifier<EnvironmentAlert>
```

**新增数据模型**：

```dart
// lib/shared/models/
water_intake.dart            // 喝水记录
health_snapshot.dart         // 健康快照（心率、血压、睡眠）
diet_suggestion.dart         // 饮食建议
environment_alert.dart       // 环境提醒
```

---

#### 1.2 记录页（Record）实现

**文件**：`lib/features/record/`（当前为 placeholder，需完全重写）

| 任务         | 说明                     | 预估 |
| ------------ | ------------------------ | ---- |
| 日历组件     | 月视图 + 日期选择        | 4h   |
| 时间线视图   | 按时间展示当日记录       | 4h   |
| 快速记录入口 | 饮食、喝水、心情、运动等 | 3h   |
| 血压记录     | 手动录入 + 图表          | 3h   |
| 症状记录     | 身体部位标记 + 严重程度  | 4h   |
| 经期记录     | 日历标记 + 周期预测      | 3h   |
| 运动记录     | 类型 + 时长 + 强度       | 2h   |
| 心情记录     | 表情选择 + 备注          | 1h   |

**新增 Provider**：

```dart
recordListProvider           // AsyncNotifier<List<Record>>
calendarProvider             // StateProvider<DateTime>
recordFilterProvider         // StateProvider<RecordType>
```

**新增数据模型**：

```dart
daily_record.dart            // 每日记录聚合
health_record.dart           // 健康记录（血压、血糖等）
mood_record.dart             // 心情记录
exercise_record.dart         // 运动记录
symptom_record.dart          // 症状记录
menstrual_record.dart        // 经期记录
```

---

#### 1.3 用药页（Medication）重构

**文件**：新建 `lib/features/medication/` 或扩展现有

| 任务           | 说明                  | 预估           |
| -------------- | --------------------- | -------------- |
| 今日用药计划   | 待服药品列表 + 时间表 | 3h             |
| 服药率统计     | 按时服药率百分比      | 2h             |
| 服用记录时间线 | 已服/待服/漏服状态    | 2h             |
| 补充提醒       | 药品余量不足提醒      | 2h             |
| 用药安全守护   | 交互提醒 + 安全提示   | 1h（已有基础） |

**新增 Provider**：

```dart
todayMedicationProvider      // AsyncNotifier<TodayMedication>
medicationAdherenceProvider  // AsyncNotifier<AdherenceStats>
refillReminderProvider       // AsyncNotifier<List<RefillReminder>>
```

---

### 第二阶段：个人健康档案 🟡（2-3 周）

> 重点：我的页升级 + AI 工具箱

#### 2.1 我的页（Mine）升级

| 任务         | 说明                | 预估 |
| ------------ | ------------------- | ---- |
| 喝水目标设置 | 目标次数 + 提醒时间 | 1h   |
| 健康档案     | 体检报告 + 历史数据 | 5h   |
| 目标与计划   | 运动/饮水/用药目标  | 3h   |
| 本周报告     | 周数据汇总 + 趋势图 | 4h   |
| 隐私与安全   | 数据管理 + 账号安全 | 2h   |

#### 2.2 AI 智能工具箱

| 任务         | 说明                | 预估 |
| ------------ | ------------------- | ---- |
| 拍照识别食物 | 图像识别 + 营养分析 | 5h   |
| 皮肤情况识别 | 图像识别 + 建议     | 5h   |
| 症状智能助手 | AI 问诊 + 建议      | 4h   |
| 药品识别     | 重构现有 scan + AI  | 2h   |

#### 2.3 更多功能

| 任务     | 说明                    | 预估 |
| -------- | ----------------------- | ---- |
| 紧急帮助 | 紧急联系人 + 急救指南   | 3h   |
| 设备管理 | 设备列表 + 同步状态     | 2h   |
| 数据同步 | 云端备份 + 多设备       | 4h   |
| 知识库   | 健康知识 + 在线问诊入口 | 2h   |
| 环境中心 | 空气质量 + 花粉详情     | 2h   |

---

### 第三阶段：家人协作 & 多设备 🟢（3-4 周）

> 重点：关爱家人 + 设备联动

#### 3.1 关爱家人

| 任务         | 说明              | 预估 |
| ------------ | ----------------- | ---- |
| 家人档案     | 添加/管理家人信息 | 4h   |
| 用药提醒代管 | 为家人设置提醒    | 3h   |
| 健康报告共享 | 查看家人健康数据  | 3h   |
| 紧急通知     | 家人异常时推送    | 2h   |

#### 3.2 多设备支持

| 任务   | 说明                | 预估 |
| ------ | ------------------- | ---- |
| 手表端 | 用药提醒 + 快速记录 | 8h   |
| Web 端 | 健康数据查看        | 6h   |

---

## 技术实现要点

### 数据层

```
lib/core/network/
├── health_api.dart          # 健康数据 API
├── medication_api.dart      # 用药计划 API
└── record_api.dart          # 记录 API

lib/core/local_storage/
├── health_database.dart     # 健康数据本地存储
└── record_database.dart     # 记录本地存储
```

### 状态管理

```dart
// 统一使用 AsyncNotifier + State wrapper
class WaterIntakeState {
  final List<WaterIntake> records;
  final bool isLoading;
  final String? errorMessage;
  final int todayCount;
  final int dailyGoal;
}

@riverpod
class WaterIntake extends _$WaterIntake {
  @override
  Future<WaterIntakeState> build() async { ... }

  Future<void> addRecord(WaterIntake record) async { ... }
  Future<void> updateGoal(int goal) async { ... }
}
```

### UI 组件复用

```
lib/shared/widgets/
├── health_card/             # 通用健康数据卡片
├── record_entry/            # 通用记录入口组件
├── progress_ring/           # 进度环组件
├── timeline/                # 时间线组件
└── calendar/                # 日历组件
```

---

## 工作量估算

| 阶段     | 时间        | 主要产出                        |
| -------- | ----------- | ------------------------------- |
| 第一阶段 | 2-3 周      | 今日页 + 记录页 + 用药页        |
| 第二阶段 | 2-3 周      | 健康档案 + AI 工具箱 + 更多功能 |
| 第三阶段 | 3-4 周      | 家人协作 + 多设备               |
| **总计** | **7-10 周** | 完整的个人健康智能助手          |

---

## 下一步行动

1. **立即开始**：第一阶段 1.1 今日页重构
2. **本周完成**：喝水追踪 + 健康快照卡片
3. **下周启动**：记录页日历 + 时间线组件
4. **持续集成**：每完成一个模块立即更新 CHANGELOG

---

## 参考文档

- [Promise](../../../Lucent/docs/public/Promise.md) - 产品愿景
- [ROADMAP](../../../Lucent/docs/public/ROADMAP.md) - 产品路线图
- [design-system](../../../Lucent/docs/public/design-system.md) - 设计系统
- [MigrationLog](MigrationLog.md) - 迁移历史记录
