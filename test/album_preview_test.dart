import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/components/album.dart';
import 'package:luminous/viewmodels/album.dart';

const _tinyPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+nWZ0AAAAASUVORK5CYII=';

void main() {
  AlbumEntry buildEntry({String imageBase64 = ''}) {
    return AlbumEntry(
      remoteId: 'remote-1',
      productName: '阿莫西林胶囊',
      drugCode: '86900000000001',
      approvalNo: '国药准字H20000001',
      thumbBase64: _tinyPngBase64,
      imageBase64: imageBase64,
      takenAt: 1710000000000,
    );
  }

  testWidgets('album preview allows rescan when original image exists', (
    tester,
  ) async {
    var detailTapCount = 0;
    var rescanTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: AlbumPreviewPage(
          entry: buildEntry(imageBase64: _tinyPngBase64),
          onOpenDetail: () => detailTapCount++,
          onRescan: () => rescanTapCount++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('该旧记录仅有缩略图，无法高质量重识别。'), findsNothing);

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

    expect(find.text('该旧记录仅有缩略图，无法高质量重识别。'), findsOneWidget);

    final rescanButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('album_preview_rescan_button')),
    );
    expect(rescanButton.onPressed, isNull);
  });
}
