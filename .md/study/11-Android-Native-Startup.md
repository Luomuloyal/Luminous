# 11 Android 原生启动

## 这一篇最重要的结论

当前项目已经把 `minSdk` 提升到了 Android 12，也就是 API 31。

所以现在 Android 冷启动不再走旧的“整张位图铺满窗口”方案，而是直接走系统 `SplashScreen`：

1. `MainActivity` 在 `onCreate()` 里调用 `installSplashScreen()`
2. `AndroidManifest.xml` 给 `MainActivity` 绑定 `@style/LaunchTheme`
3. `LaunchTheme` 继承 `Theme.SplashScreen`
4. 系统根据 `windowSplashScreenBackground` 和 `windowSplashScreenAnimatedIcon` 绘制启动屏
5. Flutter 首帧完成后切到 `NormalTheme`

这意味着以后想改冷启动第一眼的画面，重点看的是：

- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/com/dev/luminous/MainActivity.kt`
- `android/app/src/main/res/values/styles.xml`
- `android/app/src/main/res/values-night/styles.xml`
- `android/app/src/main/res/drawable/splash_wordmark_icon.xml`

## 为什么旧资源被删掉了

以前项目里保留过一套“整屏位图 + 多套背景 xml”的旧链路。

那套方案本质上是“整屏静态图”，在 Android 12 之后已经不是最合适的原生启动方式了，而且还会带来：

- 资源冗余
- 屏幕比例适配不稳定
- 图片清晰度受 PNG 本身限制

现在这几项已经被清理掉，启动图标也改成了矢量资源：

- `android/app/src/main/res/drawable/splash_wordmark_icon.xml`

所以启动图本身不再依赖低分辨率 PNG。

## 当前启动链路

### 第一步：Manifest 绑定主题

- `android/app/src/main/AndroidManifest.xml`

`MainActivity` 使用 `@style/LaunchTheme`。

### 第二步：MainActivity 安装系统 SplashScreen

- `android/app/src/main/kotlin/com/dev/luminous/MainActivity.kt`

这里在 `onCreate()` 里调用了：

```kotlin
installSplashScreen()
```

### 第三步：LaunchTheme 配置启动屏背景和图标

- `android/app/src/main/res/values/styles.xml`
- `android/app/src/main/res/values-night/styles.xml`

当前 `LaunchTheme` 的关键项是：

- `windowSplashScreenBackground`
- `windowSplashScreenAnimatedIcon`
- `postSplashScreenTheme`

### 第四步：矢量图标作为启动图

- `android/app/src/main/res/drawable/splash_wordmark_icon.xml`

这张资源直接由 `lib/assets/app_icons/app_icon_source.svg` 转成了 Android Vector Drawable，
并在图标内部叠了淡黄色、淡紫色的柔和装饰层，配合更浅的暖白背景色。

优点很直接：

- 不再依赖固定像素的 PNG
- 高 dpi 屏幕不会发虚
- 后续换图时只需要改 SVG / vector 资源

## NormalTheme 现在负责什么

`NormalTheme` 不再引用旧的整屏背景资源，而是只保留窗口背景色。

它负责的是：

- Flutter 首帧完成后，原生窗口的底色
- Flutter 页面初始化期间的背景过渡

## 现在如果你要改启动屏，优先改哪里

### 想改启动图形

优先改：

- `lib/assets/app_icons/app_icon_source.svg`
- `android/app/src/main/res/drawable/splash_wordmark_icon.xml`

### 想改启动背景色

优先改：

- `android/app/src/main/res/values/colors.xml`

### 想改启动主题

优先改：

- `android/app/src/main/res/values/styles.xml`
- `android/app/src/main/res/values-night/styles.xml`

## 和 Flutter 页面内 Splash 的关系

Android 原生启动屏仍然发生在 Flutter 首帧之前。

所以：

- 冷启动第一眼看到的，是这里这套 Android 原生资源
- Flutter 里的页面级 splash / welcome，只会在 Flutter 已经开始绘制后出现

两者不是同一个阶段。

## 相册保存通道仍然在 MainActivity

虽然 `MainActivity.kt` 里现在既有系统 SplashScreen，也有保存图片到系统相册的 `MethodChannel`，但它们是两条不同职责的链路：

- 启动屏：`installSplashScreen()`
- 系统相册保存：`com.dev.luminous/gallery`

以后如果你遇到“保存图片失败”，还是去看 `MainActivity.kt` 里的 `saveImageToGallery()`，不要去启动主题里找。

## 一条最短的读码路径

如果你以后只想快速看懂当前 Android 原生启动，推荐顺序：

1. `android/app/src/main/AndroidManifest.xml`
2. `android/app/src/main/kotlin/com/dev/luminous/MainActivity.kt`
3. `android/app/src/main/res/values/styles.xml`
4. `android/app/src/main/res/drawable/splash_wordmark_icon.xml`

这四个位置已经覆盖了当前的完整冷启动链路。
