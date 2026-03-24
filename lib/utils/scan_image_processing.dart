import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// 在后台把识别图片编码为 base64，避免阻塞主线程。
Future<String> encodeScanImageBase64(Uint8List bytes) {
  return compute(_encodeScanImageBase64, bytes);
}

/// 在后台生成相册写入需要的原图/缩略图 payload。
Future<Map<String, String>> buildAlbumImagePayload({
  required Uint8List bytes,
  String preferredThumbBase64 = '',
}) {
  return compute(_buildAlbumImagePayload, <String, Object>{
    'bytes': bytes,
    'preferredThumbBase64': preferredThumbBase64.trim(),
  });
}

String _encodeScanImageBase64(Uint8List bytes) {
  return base64Encode(bytes);
}

Map<String, String> _buildAlbumImagePayload(Map<String, Object> message) {
  final bytes = message['bytes'] as Uint8List;
  final preferredThumbBase64 =
      (message['preferredThumbBase64'] as String?)?.trim() ?? '';

  return <String, String>{
    'imageBase64': base64Encode(bytes),
    'thumbBase64': preferredThumbBase64.isNotEmpty
        ? preferredThumbBase64
        : _generateThumbBase64(bytes),
  };
}

String _generateThumbBase64(Uint8List bytes) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return '';
    }

    final resized = img.copyResize(decoded, width: 240);
    final jpg = img.encodeJpg(resized, quality: 80);
    return base64Encode(jpg);
  } catch (_) {
    return '';
  }
}
