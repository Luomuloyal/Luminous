import 'package:flutter/services.dart';

/// 系统相册保存工具。
///
/// 当前通过 `MethodChannel` 调用原生平台能力把图片保存到系统相册。
class GallerySaver {
  /// 私有构造函数，当前类只作为静态工具使用。
  GallerySaver._();

  /// 原生平台通信通道。
  ///
  /// Android/iOS 原生层需要监听同名 channel 并实现对应的 `saveImage` 方法。
  static const MethodChannel _channel = MethodChannel(
    'com.dev.luminous/gallery',
  );

  /// 把图片字节流保存到系统相册。
  ///
  /// - `bytes`：图片二进制内容；
  /// - `fileName`：可选文件名；
  /// - `mimeType`：图片 MIME 类型，默认 jpeg。
  ///
  /// 成功时返回系统侧保存后的标识字符串，例如内容 Uri。
  static Future<String?> saveImage(
    Uint8List bytes, {
    String? fileName,
    String mimeType = 'image/jpeg',
  }) async {
    try {
      return await _channel.invokeMethod<String>('saveImage', <String, dynamic>{
        'bytes': bytes,
        'fileName': fileName,
        'mimeType': mimeType,
      });
    } on PlatformException {
      rethrow;
    }
  }
}
