import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/album/presentation/album.dart';
import 'package:luminous/viewmodels/album.dart';

const _tinyPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+nWZ0AAAAASUVORK5CYII=';

void main() {
  late Directory tempDir;
  late String thumbPath;
  late String imageFilePath;

  AlbumEntry buildEntry({String imagePath = ''}) {
    return AlbumEntry(
      remoteId: 'remote-1',
      productName: '阿莫西林胶囊',
      drugCode: '86900000000001',
      approvalNo: '国药准字H20000001',
      thumbPath: thumbPath,
      imagePath: imagePath,
      imageMimeType: imagePath.isEmpty ? '' : 'image/png',
      takenAt: 1710000000000,
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('album-preview-test');
    final bytes = base64Decode(_tinyPngBase64);
    thumbPath = '${tempDir.path}${Platform.pathSeparator}thumb.png';
    imageFilePath = '${tempDir.path}${Platform.pathSeparator}image.png';
    await File(thumbPath).writeAsBytes(bytes, flush: true);
    await File(imageFilePath).writeAsBytes(bytes, flush: true);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('album preview allows rescan when original image exists', (
    tester,
  ) async {
    var detailTapCount = 0;
    var rescanTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: AlbumPreviewPage(
          entry: buildEntry(imagePath: imageFilePath),
          onOpenDetail: () => detailTapCount++,
          onRescan: () => rescanTapCount++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前记录仅保存缩略图，无法高质量重识别。'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('album_preview_detail_button')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('album_preview_rescan_button')));
    await tester.pump();

    expect(detailTapCount, 1);
    expect(rescanTapCount, 1);
  });

  testWidgets('album preview disables rescan when only thumbnail exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AlbumPreviewPage(
          entry: buildEntry(),
          onOpenDetail: () {},
          onRescan: null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前记录仅保存缩略图，无法高质量重识别。'), findsOneWidget);

    final rescanButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('album_preview_rescan_button')),
    );
    expect(rescanButton.onPressed, isNull);
  });
}
