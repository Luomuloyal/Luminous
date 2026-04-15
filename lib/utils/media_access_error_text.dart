import 'package:image_picker/image_picker.dart';
import 'package:luminous/utils/app_i18n_text.dart';

/// 根据媒体来源和错误对象，生成更友好的系统媒体访问失败提示。
String mediaAccessErrorText({required ImageSource source, Object? error}) {
  final permissionDenied = _looksLikePermissionDenied(error);

  if (source == ImageSource.camera) {
    return permissionDenied
        ? AppI18nText.pick(
            zh: '无法打开相机，请在系统设置中允许相机权限后重试',
            en: 'Unable to open the camera. Please allow camera access in Settings and try again',
          )
        : AppI18nText.pick(
            zh: '打开相机失败，请稍后重试',
            en: 'Failed to open the camera. Please try again later',
          );
  }

  return permissionDenied
      ? AppI18nText.pick(
          zh: '无法访问系统相册，请在系统设置中允许照片访问后重试',
          en: 'Unable to access your photo library. Please allow Photos access in Settings and try again',
        )
      : AppI18nText.pick(
          zh: '打开系统相册失败，请稍后重试',
          en: 'Failed to open the photo library. Please try again later',
        );
}

bool _looksLikePermissionDenied(Object? error) {
  if (error == null) {
    return false;
  }

  final text = error.toString().toLowerCase();
  return text.contains('permission') ||
      text.contains('denied') ||
      text.contains('access') ||
      text.contains('photo') ||
      text.contains('camera') ||
      text.contains('gallery');
}
