import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// 用户为识别页选择的一张图片。
class SelectedScanImage {
  const SelectedScanImage({
    required this.bytes,
    required this.mimeType,
    required this.source,
  });

  final Uint8List bytes;
  final String mimeType;
  final ImageSource source;
}
