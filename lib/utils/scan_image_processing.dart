import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// 在后台把识别图片编码为 base64，避免阻塞主线程。
Future<String> encodeScanImageBase64(Uint8List bytes) {
  return compute(_encodeScanImageBase64, bytes);
}

/// 在后台把图片裁剪为圆形头像，并输出 data URL（image/png;base64）。
Future<String> buildCircularAvatarDataUrl({
  required Uint8List bytes,
  int size = 240,
}) {
  return compute(_buildCircularAvatarDataUrl, <String, Object>{
    'bytes': bytes,
    'size': size,
  });
}

/// 在后台生成相册缩略图的字节与 base64，避免阻塞主线程。
Future<Map<String, Object>> buildAlbumThumbPayload({
  required Uint8List bytes,
  String preferredThumbBase64 = '',
}) {
  return compute(_buildAlbumThumbPayload, <String, Object>{
    'bytes': bytes,
    'preferredThumbBase64': preferredThumbBase64.trim(),
  });
}

String _encodeScanImageBase64(Uint8List bytes) {
  return base64Encode(bytes);
}

String _buildCircularAvatarDataUrl(Map<String, Object> message) {
  final bytes = message['bytes'] as Uint8List;
  final size = (message['size'] as int?) ?? 240;
  if (size <= 0) {
    return '';
  }

  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return '';
    }

    final squareSide = math.min(decoded.width, decoded.height);
    final offsetX = ((decoded.width - squareSide) / 2).floor();
    final offsetY = ((decoded.height - squareSide) / 2).floor();

    final square = img.copyCrop(
      decoded,
      x: offsetX,
      y: offsetY,
      width: squareSide,
      height: squareSide,
    );

    final resized = img.copyResize(
      square,
      width: size,
      height: size,
      interpolation: img.Interpolation.average,
    );

    final masked = img.Image(width: size, height: size, numChannels: 4);
    final radius = size / 2;
    final center = (size - 1) / 2;

    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final dx = x - center;
        final dy = y - center;
        final inside = dx * dx + dy * dy <= radius * radius;
        if (!inside) {
          masked.setPixelRgba(x, y, 0, 0, 0, 0);
          continue;
        }

        final pixel = resized.getPixel(x, y);
        masked.setPixelRgba(
          x,
          y,
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
          pixel.a.toInt(),
        );
      }
    }

    final png = img.encodePng(masked, level: 6);
    return 'data:image/png;base64,${base64Encode(png)}';
  } catch (_) {
    return '';
  }
}

Map<String, Object> _buildAlbumThumbPayload(Map<String, Object> message) {
  final bytes = message['bytes'] as Uint8List;
  final preferredThumbBase64 =
      (message['preferredThumbBase64'] as String?)?.trim() ?? '';
  final thumbBase64 = _resolveThumbBase64(
    bytes: bytes,
    preferredThumbBase64: preferredThumbBase64,
  );

  return <String, Object>{
    'thumbBase64': thumbBase64,
    'thumbBytes': thumbBase64.isEmpty
        ? Uint8List(0)
        : Uint8List.fromList(base64Decode(thumbBase64)),
  };
}

String _resolveThumbBase64({
  required Uint8List bytes,
  required String preferredThumbBase64,
}) {
  if (preferredThumbBase64.isNotEmpty) {
    try {
      base64Decode(preferredThumbBase64);
      return preferredThumbBase64;
    } catch (_) {
      // Fall through to a locally generated thumbnail.
    }
  }
  return _generateThumbBase64(bytes);
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
