# 11 Android 原生启动

## 这一篇最重要的结论

Android 冷启动时显示的并不是 Flutter 页面，而是 Android 原生资源。

所以你以后想改“冷启动看到的画面”，不要去找 Dart 里的 `Splash` 页面，先回到：

- `AndroidManifest.xml`
- `styles.xml`
- `launch_background.xml`
- `native_launch_screen.png`

这也是为什么你之前把 `splash.dart` 停用后，原生启动屏仍然能单独存在。

## 这个部分负责什么

这一部分当前其实承载了两类 Android 原生能力：

1. 冷启动时的原生启动屏
2. Flutter 保存图片到系统相册时的原生 `MethodChannel`

虽然它们都在 `android/` 目录里，但职责完全不同，别混在一起看。

## 建议你第一次怎么读

推荐顺序：

1. `android/app/src/main/AndroidManifest.xml`
2. `android/app/src/main/res/values/styles.xml`
3. `android/app/src/main/res/values-night/styles.xml`
4. `android/app/src/main/res/drawable/launch_background.xml`
5. `android/app/src/main/res/drawable-v21/launch_background.xml`
6. `android/app/src/main/kotlin/com/dev/luminous/MainActivity.kt`

这样你会先搞清楚启动屏怎么显示，再去看相册保存通道。

## Android 冷启动的真实链路

当前 Android 冷启动链路是这样的：

1. 系统启动 `MainActivity`
2. `AndroidManifest.xml` 把它的主题设成 `@style/LaunchTheme`
3. `LaunchTheme` 通过 `windowBackground` 显示 `launch_background.xml`
4. `launch_background.xml` 再把 `native_launch_screen` 画出来
5. Flutter 引擎初始化
6. Flutter 首帧完成后，系统切到 `NormalTheme`
7. 最终进入 Flutter 页面

对应关键位置：

- `android/app/src/main/AndroidManifest.xml:19-35`
- `android/app/src/main/res/values/styles.xml:4-17`
- `android/app/src/main/res/values-night/styles.xml:4-17`
- `android/app/src/main/res/drawable/launch_background.xml:2-8`

## 这套启动屏为什么和 Flutter Splash 页面完全是两回事

原因很简单：

- Android 原生启动屏发生在 Flutter 首帧之前
- Flutter 的 `Splash` 页面只能出现在 Flutter 已经开始绘制之后

所以：

- 冷启动第一眼的画面，看原生资源
- Flutter 页面内的启动过渡或欢迎页，看 Dart 代码

这两个阶段在时间上是前后关系，不是替代关系。

## 当前原生启动屏是怎么画出来的

### 第一步：Manifest 绑定启动主题

- `android/app/src/main/AndroidManifest.xml:24`
  `MainActivity` 使用 `@style/LaunchTheme`

### 第二步：LaunchTheme 指定 windowBackground

- `android/app/src/main/res/values/styles.xml:4-8`
- `android/app/src/main/res/values-night/styles.xml:4-8`

这两套样式都把 `android:windowBackground` 指到 `@drawable/launch_background`。

### 第三步：drawable 再去引用真正的图片

- `android/app/src/main/res/drawable/launch_background.xml:2-8`
- `android/app/src/main/res/drawable-v21/launch_background.xml:2-8`

当前实现是：

- 一个 `layer-list`
- 里面放一个 `bitmap`
- `bitmap` 的 `android:gravity="fill"`
- `src` 指向 `@drawable/native_launch_screen`

### 第四步：图片资源本体

当前真正被整屏显示的是：

- `android/app/src/main/res/drawable-nodpi/native_launch_screen.png`

如果你以后直接替换这张图，冷启动视觉就会跟着变。

## 现在这套实现的优点和限制

### 优点

- 结构简单
- 修改成本低
- 不依赖 Flutter 首帧

### 限制

- 因为用了整屏 `bitmap + fill`，不同设备比例差异大时可能被拉伸
- 当前亮色和夜间主题都复用了同一套启动背景资源
- 目前没有更细的自适配布局，比如“纯色背景 + 居中 logo + 文案”

这也是为什么之前 review 里会把“拉伸风险”记成一个待处理点。

## 你以后如果想改启动屏，应该去哪里改

这里按最常见的几种改法给你分开说。

### 只想换启动图内容

先改：

- `android/app/src/main/res/drawable-nodpi/native_launch_screen.png`

这是最直接的改法，适合你已经把整张启动屏设计成一张图的情况。

### 想改背景颜色

先看：

- `android/app/src/main/res/values/styles.xml:15-17`
- `android/app/src/main/res/values-night/styles.xml:15-17`
- `android/app/src/main/res/values/colors.xml:3`

这里的 `NormalTheme` 决定的是 Flutter 首帧出来之后、Flutter 界面背后的 window 背景色。

### 想改成更稳的适配方案

优先改：

- `android/app/src/main/res/drawable/launch_background.xml`
- `android/app/src/main/res/drawable-v21/launch_background.xml`

更推荐的方向是：

- 背景用纯色或渐变
- logo / 插画单独放中间
- 避免继续使用“整张截图直接铺满”的方案

这样不同屏幕比例下更稳，也更不容易出现黑边和拉伸。

### 想做亮色和暗色两套启动图

当前项目已经有：

- `values/styles.xml`
- `values-night/styles.xml`

但它们都用了同一个 `launch_background`。

所以如果以后要做夜间版原生启动屏，你需要的不只是改 theme，还要配对应的 night 资源文件。

## `windowSoftInputMode="adjustResize"` 为什么也在这里值得看

`android/app/src/main/AndroidManifest.xml:27` 当前配置了：

```xml
android:windowSoftInputMode="adjustResize"
```

这虽然不是启动屏本身，但和 Android 页面交互体验相关，尤其会影响登录、注册这类输入页的键盘弹出行为。

所以以后如果你遇到：

- 键盘弹出时页面布局异常
- 输入框被遮挡
- Web 和 Android 体验不一样

Manifest 这一段也值得一起看。

## 原生保存图片到系统相册是怎么接进来的

这部分和启动屏是同一个 Activity 文件，但职责不同。

### MethodChannel 入口

- `android/app/src/main/kotlin/com/dev/luminous/MainActivity.kt:13-39`

这里注册了 channel：

- `com.dev.luminous/gallery`

并监听 `saveImage` 方法。

### 真正写入系统相册

- `android/app/src/main/kotlin/com/dev/luminous/MainActivity.kt:42-73`

这里会：

1. 构造 `ContentValues`
2. 往 `MediaStore.Images.Media.EXTERNAL_CONTENT_URI` 插入记录
3. 打开输出流写入 bytes
4. Android 10+ 再把 `IS_PENDING` 设回 0
5. 最后返回保存后的 uri

所以以后如果你碰到“保存相册失败”，先看 `MainActivity.kt`，不要去启动屏资源里找。

## 一条最短的读码路径

如果你以后只想快速搞清楚原生启动屏和相册保存通道，最短路径是：

1. `android/app/src/main/AndroidManifest.xml:19-35`
2. `android/app/src/main/res/values/styles.xml:4-17`
3. `android/app/src/main/res/drawable/launch_background.xml:2-8`
4. `android/app/src/main/kotlin/com/dev/luminous/MainActivity.kt:13-73`

## 关键代码位置

- `android/app/src/main/AndroidManifest.xml:19-27`
  `MainActivity` 声明、启动主题、软键盘模式。
- `android/app/src/main/AndroidManifest.xml:32-35`
  `NormalTheme` 元数据绑定。
- `android/app/src/main/res/values/styles.xml:4-8`
  亮色 `LaunchTheme`。
- `android/app/src/main/res/values/styles.xml:15-17`
  亮色 `NormalTheme`。
- `android/app/src/main/res/values-night/styles.xml:4-8`
  夜间 `LaunchTheme`。
- `android/app/src/main/res/values-night/styles.xml:15-17`
  夜间 `NormalTheme`。
- `android/app/src/main/res/values/colors.xml:3`
  `launch_background_color`。
- `android/app/src/main/res/drawable/launch_background.xml:2-8`
  启动背景资源。
- `android/app/src/main/res/drawable-v21/launch_background.xml:2-8`
  Android 5.0+ 同名背景。
- `android/app/src/main/kotlin/com/dev/luminous/MainActivity.kt:13-39`
  相册保存 channel 注册。
- `android/app/src/main/kotlin/com/dev/luminous/MainActivity.kt:42-73`
  把图片写入 `MediaStore`。

## 容易忽略的实现细节

- 原生启动屏不是 Dart 页面。
- 当前夜间主题和白天主题都复用了同一张启动图。
- `native_launch_screen.png` 放在 `drawable-nodpi`，这是为了避免 Android 再按 dpi 对它做缩放分桶处理。
- 保存相册通道和启动屏在同一个 `MainActivity` 文件里，但它们不是一条业务线。

## 如果以后要改，优先改哪里

### 改冷启动视觉

优先看：

1. `android/app/src/main/res/drawable-nodpi/native_launch_screen.png`
2. `android/app/src/main/res/drawable/launch_background.xml`

### 改冷启动背景或主题颜色

优先看：

1. `android/app/src/main/res/values/styles.xml`
2. `android/app/src/main/res/values-night/styles.xml`
3. `android/app/src/main/res/values/colors.xml`

### 解决拉伸问题

优先从 `launch_background.xml` 的布局方式下手，而不是只重新导出更大 PNG。

### 改原生保存图片逻辑

优先看：

1. `android/app/src/main/kotlin/com/dev/luminous/MainActivity.kt`

## 相关测试在哪

当前没有针对下面两部分的自动化测试：

- Android 原生启动屏显示
- `MethodChannel` 保存相册

这部分目前主要依赖真机或模拟器手动验证。
