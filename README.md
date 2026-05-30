# Luminous

健康助手 Flutter 应用。

## 快速开始

```bash
flutter pub get
flutter run
```

## 项目结构

```
lib/
├── main.dart              # 入口
├── app/                   # 应用级配置（路由、主题入口）
├── core/                  # 跨 feature 共享（常量、主题、通用 widget）
├── features/              # 业务模块（feature-first）
│   ├── shell/             # 底部导航壳
│   ├── today/             # 今日
│   ├── record/            # 记录
│   ├── medicine/          # 用药
│   ├── mine/              # 我的
│   └── more/              # 更多
└── l10n/                  # 国际化
```

## 技术栈

- **框架**: Flutter 3.x
- **状态管理**: Riverpod
- **路由**: GoRouter
- **网络**: Dio
- **本地存储**: SharedPreferences + sqflite + flutter_secure_storage
- **代码生成**: freezed + json_serializable

## 开发

```bash
# 代码生成
dart run build_runner build --delete-conflicting-outputs

# 运行测试
flutter test

# 构建
flutter build apk
flutter build ios
```
