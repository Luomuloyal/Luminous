# 11 Android 原生启动

## 这个功能是干什么的

负责 Android 冷启动时先显示原生启动屏，再无缝切到 Flutter 首帧；同时这里还承载了一个保存图片到系统相册的原生通道。

## 用户从哪里进入 / 如何触发

- Android 冷启动时系统先走 `LaunchTheme`
- Flutter 首帧绘制后切到 `NormalTheme`
- Flutter 调用保存相册时会走 `MainActivity` 的 `MethodChannel`

## 关键页面、组件、API、store、backend、native 文件

- 清单：`android/app/src/main/AndroidManifest.xml`
- 主题：`android/app/src/main/res/values/styles.xml`
- 夜间主题：`android/app/src/main/res/values-night/styles.xml`
- 启动图背景：`android/app/src/main/res/drawable/launch_background.xml`
- v21 背景：`android/app/src/main/res/drawable-v21/launch_background.xml`
- 启动图资源：`android/app/src/main/res/drawable-nodpi/native_launch_screen.png`
- 原生活动：`android/app/src/main/kotlin/com/dev/luminous/MainActivity.kt`

## 核心实现路径

### UI 入口

- `AndroidManifest.xml` 把 `MainActivity` 的主题设成 `@style/LaunchTheme`
- `LaunchTheme` 的 `windowBackground` 指向 `launch_background.xml`
- `launch_background.xml` 再整屏绘制 `native_launch_screen`

### 状态来源

- 冷启动视觉内容完全来自 Android 资源，不依赖 Flutter Widget

### 网络 / 本地存储 / 后端流转

- 原生启动屏本身不涉及网络
- `MainActivity` 里另有一个 `MethodChannel`，用于把 Flutter 传来的图片 bytes 写入系统 `MediaStore`

### 结果如何回到 UI

- Flutter 首帧出来后，系统自动移除启动主题背景
- 图片保存完成后，原生通过 `result.success(uri)` 把结果回传 Flutter

## 关键代码位置

- `android/app/src/main/AndroidManifest.xml:19`
  `MainActivity` 声明和 `LaunchTheme` 绑定。
- `android/app/src/main/AndroidManifest.xml:27`
  `windowSoftInputMode="adjustResize"`。
- `android/app/src/main/res/values/styles.xml:4`
  白天 `LaunchTheme`。
- `android/app/src/main/res/values/styles.xml:15`
  白天 `NormalTheme`。
- `android/app/src/main/res/values-night/styles.xml:4`
  夜间 `LaunchTheme`。
- `android/app/src/main/res/drawable/launch_background.xml:2`
  启动背景 layer-list。
- `android/app/src/main/res/drawable-v21/launch_background.xml:2`
  Android 5.0+ 的同名背景。
- `android/app/src/main/kotlin/com/dev/luminous/MainActivity.kt:13`
  配置 Flutter MethodChannel。
- `android/app/src/main/kotlin/com/dev/luminous/MainActivity.kt:42`
  保存图片到 `MediaStore`。

## 容易忽略的实现细节

- 原生启动屏和 Flutter 的 `Splash` 页面不是一回事，冷启动显示的是 Android 资源
- 启动图文件是 `drawable-nodpi/native_launch_screen.png`，不是 Dart 代码
- 当前 `launch_background.xml` 用的是 `bitmap + gravity="fill"`，本质上是把整张 PNG 直接拉满屏幕，设备比例差异大时可能被拉伸
- 保存系统相册的原生通道和启动屏在同一个 `MainActivity` 文件里

## 如果以后要改，优先改哪里

- 改冷启动视觉：先改 `native_launch_screen.png` 或 `launch_background.xml`
- 改冷启动主题颜色：改 `styles.xml` / `styles-night.xml`
- 如果想避免不同设备上变形，优先把启动屏拆成更可适配的背景 + 居中元素，而不是继续依赖整屏截图式 PNG
- 改原生保存图片逻辑：改 `MainActivity.kt`

## 相关测试在哪

- 当前没有 Android 原生启动屏或 `MethodChannel` 的自动化测试
