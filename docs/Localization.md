# Flutter 国际化

最后更新: 2026-05-30

## 当前方案

项目使用 Flutter 原生 `gen-l10n` 方案。

文件位置：

- 配置：`l10n.yaml`
- 资源：`lib/l10n/app_zh.arb`、`lib/l10n/app_en.arb`
- 生成文件：`lib/l10n/app_localizations*.dart`

## 当前已接入

- `LuminousApp` 已注册 `localizationsDelegates`
- `supportedLocales` 已接入
- Tab 文案已切到 `AppLocalizations`
- `TodayPage` 和 `PlaceholderPage` 的可见文案已切到 `AppLocalizations`
- `LoginPage` / `RegisterPage` / `AuthShell` 已切到 `AppLocalizations`
- 前端 network 层会通过 `Accept-Language` 请求头把当前语言传给 Lucent
- 当前默认请求语言为英文，后续可由用户设置切换

## 新增文案流程

1. 在 `app_zh.arb` 和 `app_en.arb` 中新增 key
2. 运行：

```bash
flutter gen-l10n
```

3. 在页面中通过：

```dart
final l10n = AppLocalizations.of(context);
```

读取文案

## 原则

- 用户可见文案不要继续硬编码到页面里
- 不重新发明一套 `AppI18nText` 之类的文本工具类
- 页面、组件、Tab、按钮、提示文案统一走 Flutter 原生本地化
