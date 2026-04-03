import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/api/user_api.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/utils/scan_image_processing.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/auth.dart';

/// 个人设置页。
///
/// 支持编辑头像、昵称、性别、生日、职业和地区编码，并同步到后端与本地用户态。
class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final UserController _userController = Get.find<UserController>();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _avatarController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _provinceCodeController = TextEditingController();
  final TextEditingController _cityCodeController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String _gender = 'other';

  UserSafe? get _currentUser => _userController.user.value;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _nicknameController.dispose();
    _birthdayController.dispose();
    _professionController.dispose();
    _provinceCodeController.dispose();
    _cityCodeController.dispose();
    super.dispose();
  }

  void _fillByUser(UserSafe user) {
    _avatarController.text = user.avatar;
    _nicknameController.text = user.nickname.isNotEmpty
        ? user.nickname
        : user.name;
    _birthdayController.text = user.birthday;
    _professionController.text = user.profession;
    _provinceCodeController.text = user.provinceCode;
    _cityCodeController.text = user.cityCode;
    _gender = _normalizeGenderForUi(user.gender);
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

  Future<void> _loadProfile() async {
    final current = _currentUser;
    if (current == null || current.id.trim().isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
      });
      return;
    }

    _fillByUser(current);

    try {
      final response = await userApi.getProfile(userId: current.id);
      final user = response.result;
      await _userController.setUser(user);
      if (!mounted) {
        return;
      }
      setState(() {
        _fillByUser(user);
      });
    } on ApiException catch (_) {
      // 保留本地缓存资料，接口失败不阻断编辑。
    } catch (_) {
      // 忽略刷新失败，避免影响设置页可用性。
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    DateTime initialDate = DateTime(now.year - 20, now.month, now.day);
    final text = _birthdayController.text.trim();
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
      helpText: '选择生日',
      cancelText: '取消',
      confirmText: '确定',
    );

    if (picked == null || !mounted) {
      return;
    }
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    setState(() {
      _birthdayController.text = '${picked.year}-$month-$day';
    });
  }

  Future<void> _saveProfile() async {
    final user = _currentUser;
    if (user == null || user.id.trim().isEmpty) {
      ToastUtils.instance.show(context, '请先登录');
      return;
    }
    if (_saving) {
      return;
    }

    final nickname = _nicknameController.text.trim();
    if (nickname.isNotEmpty && (nickname.length < 2 || nickname.length > 30)) {
      ToastUtils.instance.show(context, '昵称长度需为2-30个字符');
      return;
    }
    final birthday = _birthdayController.text.trim();
    if (birthday.isNotEmpty &&
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthday)) {
      ToastUtils.instance.show(context, '生日格式应为 YYYY-MM-DD');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final response = await userApi.updateProfile(
        userId: user.id,
        avatar: _avatarController.text,
        nickname: nickname,
        gender: _gender,
        birthday: birthday,
        profession: _professionController.text,
        provinceCode: _provinceCodeController.text,
        cityCode: _cityCodeController.text,
      );
      await _userController.setUser(response.result);
      if (!mounted) {
        return;
      }
      ToastUtils.instance.show(
        context,
        response.msg.trim().isEmpty ? '个人资料已保存' : response.msg,
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.show(context, error.message);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.showError(context, error);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  ImageProvider<Object>? _avatarProviderFromText(String text) {
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

  Future<void> _pickAvatarFromGallery() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );
      if (file == null || !mounted) {
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }
      if (bytes.isEmpty) {
        ToastUtils.instance.show(context, '未读取到图片数据，请重试');
        return;
      }

      final dataUrl = await buildCircularAvatarDataUrl(bytes: bytes, size: 240);
      if (!mounted) {
        return;
      }
      if (dataUrl.isEmpty) {
        ToastUtils.instance.show(context, '图片处理失败，请更换一张图片');
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _avatarController.text = dataUrl;
      });
      ToastUtils.instance.show(context, '已完成圆形裁剪，点击保存后生效');
    } catch (error) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.showError(context, error);
    }
  }

  void _clearAvatar() {
    setState(() {
      _avatarController.clear();
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final user = _currentUser;
    final avatarProvider = _avatarProviderFromText(_avatarController.text);
    Widget body;

    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (user == null) {
      body = Center(
        child: AppSurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('未检测到登录用户，请先登录后再设置个人资料'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('去登录'),
              ),
            ],
          ),
        ),
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: [
          AppSectionCard(
            accentColor: scheme.primary,
            secondaryColor: scheme.secondary,
            ornamentKey: 'settings.profile.summary',
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: appTintedSurface(context, scheme.primary),
                  backgroundImage: avatarProvider,
                  child: avatarProvider == null
                      ? Icon(
                          Icons.person_rounded,
                          color: scheme.primary,
                          size: 32,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayTitle,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.account.isNotEmpty ? user.account : user.username,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppSectionCard(
            accentColor: scheme.secondary,
            secondaryColor: scheme.primary,
            ornamentKey: 'settings.profile.form',
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickAvatarFromGallery,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('从相册选择头像'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _avatarController.text.trim().isEmpty
                          ? null
                          : _clearAvatar,
                      child: const Text('清空'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '选择后会自动圆形裁剪并压缩保存',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _nicknameController,
                  label: '昵称',
                  hint: '2-30 字符，可留空',
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: InputDecoration(
                    labelText: '性别',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'other', child: Text('未设置')),
                    DropdownMenuItem(value: 'male', child: Text('男')),
                    DropdownMenuItem(value: 'female', child: Text('女')),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _birthdayController,
                  label: '生日',
                  hint: 'YYYY-MM-DD',
                  readOnly: true,
                  onTap: _pickBirthday,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _professionController,
                  label: '职业',
                  hint: '例如：工程师、学生',
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _provinceCodeController,
                        label: '省份编码',
                        hint: '如 110000',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        controller: _cityCodeController,
                        label: '城市编码',
                        hint: '如 110100',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _saveProfile,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(_saving ? '保存中...' : '保存个人资料'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return AppCanvasPageScaffold(
      accentColor: const Color(0xFF0EA5E9),
      secondaryAccentColor: const Color(0xFF10B981),
      safeAreaBottom: true,
      appBarSpacing: 30,
      appBar: AppBar(
        title: const Text('个人设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      child: body,
    );
  }
}
