import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/api/user_api.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/utils/media_access_error_text.dart';
import 'package:luminous/utils/scan_image_processing.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/auth.dart';

/// 个人设置页页面级控制器。
///
/// 负责加载资料、管理表单编辑态、头像选择与资料保存。
class ProfileSettingsController extends GetxController {
  ProfileSettingsController({
    required this.onLogout,
    required this.onPurgeAccount,
    required this.onUserUpdate,
    UserController? userController,
    UserApi? userApi,
    ImagePicker? imagePicker,
  }) : _userController = userController ?? Get.find<UserController>(),
       _userApi = userApi ?? const UserApi(),
       _imagePicker = imagePicker ?? ImagePicker();

  final Future<void> Function() onLogout;
  final Future<void> Function(String userId) onPurgeAccount;
  final Future<void> Function(UserSafe user) onUserUpdate;

  final UserController _userController;
  final UserApi _userApi;
  final ImagePicker _imagePicker;

  final TextEditingController avatarController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController provinceCodeController = TextEditingController();
  final TextEditingController cityCodeController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _deleting = false;
  String _gender = 'other';

  bool get loading => _loading;
  bool get saving => _saving;
  bool get deleting => _deleting;
  String get gender => _gender;
  UserSafe? get currentUser => _userController.user.value;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    avatarController.dispose();
    nicknameController.dispose();
    birthdayController.dispose();
    professionController.dispose();
    provinceCodeController.dispose();
    cityCodeController.dispose();
    super.onClose();
  }

  void fillByUser(UserSafe user) {
    avatarController.text = user.avatar;
    nicknameController.text = user.nickname.isNotEmpty
        ? user.nickname
        : user.name;
    birthdayController.text = user.birthday;
    professionController.text = user.profession;
    provinceCodeController.text = user.provinceCode;
    cityCodeController.text = user.cityCode;
    _gender = _normalizeGenderForUi(user.gender);
  }

  void setGender(String value) {
    if (_gender == value) {
      return;
    }
    _gender = value;
    update();
  }

  Future<void> loadProfile() async {
    final current = currentUser;
    if (current == null || current.id.trim().isEmpty) {
      _loading = false;
      update();
      return;
    }

    fillByUser(current);
    update();

    try {
      final response = await _userApi.getProfile(userId: current.id);
      final user = response.result;
      await onUserUpdate(user);
      if (isClosed) {
        return;
      }
      fillByUser(user);
      update();
    } on ApiException catch (_) {
      // 保留本地缓存资料，接口失败不阻断编辑。
    } catch (_) {
      // 忽略刷新失败，避免影响设置页可用性。
    } finally {
      if (!isClosed) {
        _loading = false;
        update();
      }
    }
  }

  Future<void> pickBirthday(BuildContext context) async {
    final now = DateTime.now();
    DateTime initialDate = DateTime(now.year - 20, now.month, now.day);
    final text = birthdayController.text.trim();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
      final parsed = DateTime.tryParse(text);
      if (parsed != null) {
        initialDate = parsed;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: AppI18nText.pick(zh: '选择生日', en: 'Select Birthday'),
      cancelText: AppI18nText.pick(zh: '取消', en: 'Cancel'),
      confirmText: AppI18nText.pick(zh: '确定', en: 'Confirm'),
    );

    if (picked == null || !context.mounted || isClosed) {
      return;
    }
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    birthdayController.text = '${picked.year}-$month-$day';
    update();
  }

  Future<void> saveProfile(BuildContext context) async {
    final user = currentUser;
    if (user == null || user.id.trim().isEmpty) {
      _showToast(
        context,
        AppI18nText.pick(zh: '请先登录', en: 'Please sign in first'),
      );
      return;
    }
    if (_saving) {
      return;
    }

    final nickname = nicknameController.text.trim();
    if (nickname.isNotEmpty && (nickname.length < 2 || nickname.length > 30)) {
      _showToast(
        context,
        AppI18nText.pick(
          zh: '昵称长度需为2-30个字符',
          en: 'Nickname must be between 2 and 30 characters',
        ),
      );
      return;
    }
    final birthday = birthdayController.text.trim();
    if (birthday.isNotEmpty &&
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthday)) {
      _showToast(
        context,
        AppI18nText.pick(
          zh: '生日格式应为 YYYY-MM-DD',
          en: 'Birthday format must be YYYY-MM-DD',
        ),
      );
      return;
    }

    _saving = true;
    update();

    try {
      final response = await _userApi.updateProfile(
        userId: user.id,
        avatar: avatarController.text,
        nickname: nickname,
        gender: _gender,
        birthday: birthday,
        profession: professionController.text,
        provinceCode: provinceCodeController.text,
        cityCode: cityCodeController.text,
      );
      await onUserUpdate(response.result);
      if (!context.mounted || isClosed) {
        return;
      }
      fillByUser(response.result);
      update();
      _showToast(
        context,
        response.msg.trim().isEmpty
            ? AppI18nText.pick(zh: '个人资料已保存', en: 'Profile saved')
            : response.msg,
      );
    } on ApiException catch (error) {
      if (!context.mounted || isClosed) {
        return;
      }
      _showToast(context, error.message);
    } catch (error) {
      if (!context.mounted || isClosed) {
        return;
      }
      ToastUtils.instance.showError(context, error);
    } finally {
      if (!isClosed) {
        _saving = false;
        update();
      }
    }
  }

  Future<bool> deleteAccount(BuildContext context) async {
    final user = currentUser;
    if (user == null || user.id.trim().isEmpty) {
      _showToast(
        context,
        AppI18nText.pick(zh: '请先登录', en: 'Please sign in first'),
      );
      return false;
    }
    if (_deleting) {
      return false;
    }

    _deleting = true;
    update();

    try {
      final response = await _userApi.deleteAccount(userId: user.id);
      await onPurgeAccount(user.id);
      await onLogout();
      if (!context.mounted || isClosed) {
        return true;
      }
      _showToast(
        context,
        response.msg.trim().isEmpty
            ? AppI18nText.pick(zh: '账户已注销', en: 'Account deleted')
            : response.msg,
      );
      return true;
    } on ApiException catch (error) {
      if (!context.mounted || isClosed) {
        return false;
      }
      _showToast(context, error.message);
      return false;
    } catch (error) {
      if (!context.mounted || isClosed) {
        return false;
      }
      ToastUtils.instance.showError(context, error);
      return false;
    } finally {
      if (!isClosed) {
        _deleting = false;
        update();
      }
    }
  }

  ImageProvider<Object>? avatarProviderFromText(String text) {
    final raw = text.trim();
    if (raw.isEmpty) {
      return null;
    }
    if (raw.startsWith('http')) {
      return NetworkImage(raw);
    }
    if (!raw.startsWith('data:image/')) {
      return null;
    }
    final commaIndex = raw.indexOf(',');
    if (commaIndex <= 0 || commaIndex >= raw.length - 1) {
      return null;
    }
    try {
      final bytes = base64Decode(raw.substring(commaIndex + 1));
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  Future<void> pickAvatarFromGallery(BuildContext context) async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );
      if (file == null || !context.mounted || isClosed) {
        return;
      }

      final bytes = await file.readAsBytes();
      if (!context.mounted || isClosed) {
        return;
      }
      if (bytes.isEmpty) {
        _showToast(
          context,
          AppI18nText.pick(
            zh: '未读取到图片数据，请重试',
            en: 'No image data was read. Please try again',
          ),
        );
        return;
      }

      final dataUrl = await buildCircularAvatarDataUrl(bytes: bytes, size: 240);
      if (!context.mounted || isClosed) {
        return;
      }
      if (dataUrl.isEmpty) {
        _showToast(
          context,
          AppI18nText.pick(
            zh: '图片处理失败，请更换一张图片',
            en: 'Image processing failed. Please try another image',
          ),
        );
        return;
      }

      avatarController.text = dataUrl;
      update();
      _showToast(
        context,
        AppI18nText.pick(
          zh: '已完成圆形裁剪，点击保存后生效',
          en: 'Circular crop completed. Tap save to apply it',
        ),
      );
    } on PlatformException catch (error) {
      if (!context.mounted || isClosed) {
        return;
      }
      _showToast(
        context,
        mediaAccessErrorText(source: ImageSource.gallery, error: error),
      );
    } catch (error) {
      if (!context.mounted || isClosed) {
        return;
      }
      ToastUtils.instance.showError(context, error);
    }
  }

  void clearAvatar() {
    avatarController.clear();
    update();
  }

  String _normalizeGenderForUi(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'male') {
      return 'male';
    }
    if (normalized == 'female') {
      return 'female';
    }
    return 'other';
  }

  void _showToast(BuildContext context, String message) {
    ToastUtils.instance.show(context, message);
  }
}
