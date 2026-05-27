import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/api/user_api.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:luminous/features/auth/providers/auth_service_provider.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/utils/toast_utils.dart';

import '../providers/profile_settings_provider.dart';

class ProfileSettingsPage extends ConsumerStatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  ConsumerState<ProfileSettingsPage> createState() =>
      _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<ProfileSettingsPage> {
  final _avatarCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _birthdayCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _avatarCtrl.dispose();
    _nicknameCtrl.dispose();
    _birthdayCtrl.dispose();
    _professionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = ref.read(currentUserProvider);
    final loadedUser = await ref
        .read(profileSettingsProvider.notifier)
        .loadProfile(user, const UserApi());
    if (!mounted || loadedUser == null) {
      return;
    }
    _fillControllers(loadedUser);
  }

  void _fillControllers(UserSafe user) {
    _avatarCtrl.text = user.avatar;
    _nicknameCtrl.text = user.nickname.isNotEmpty ? user.nickname : user.name;
    _birthdayCtrl.text = user.birthday;
    _professionCtrl.text = user.profession;
  }

  Future<void> _pickBirthday() async {
    final text = _birthdayCtrl.text.trim();
    DateTime initial = DateTime(DateTime.now().year - 20);
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
      final p = DateTime.tryParse(text);
      if (p != null) initial = p;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && mounted) {
      _birthdayCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _saveProfile() async {
    final user = ref.read(currentUserProvider);
    final ok = await ref
        .read(profileSettingsProvider.notifier)
        .saveProfile(
          user: user,
          userApi: const UserApi(),
          avatar: _avatarCtrl.text,
          nickname: _nicknameCtrl.text,
          birthday: _birthdayCtrl.text,
          profession: _professionCtrl.text,
          onUserUpdate: (u) => ref.read(authServiceProvider).loginSuccess(u),
        );
    if (ok && mounted) ToastUtils.instance.show(context, '保存成功');
  }

  Future<void> _deleteAccount() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('注销账户'),
        content: const Text('注销后数据不可恢复，确定继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认注销'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final ok = await ref
          .read(profileSettingsProvider.notifier)
          .deleteAccount(userId: user.id, userApi: const UserApi());
      if (ok && mounted) {
        ref.read(authServiceProvider).purgeDeletedAccountData(user.id);
        ToastUtils.instance.show(context, '账户已注销');
      }
    } on ApiException catch (e) {
      if (mounted) {
        ToastUtils.instance.show(
          context,
          e.message.isNotEmpty ? e.message : '注销失败',
        );
      }
    }
  }

  Future<void> _pickAvatar() async {
    final base64 = await ref
        .read(profileSettingsProvider.notifier)
        .pickAvatarFromGallery(ImagePicker());
    if (!mounted || base64 == null) {
      return;
    }
    setState(() {
      _avatarCtrl.text = base64;
    });
  }

  void _clearAvatar() {
    setState(() {
      _avatarCtrl.text = '';
    });
  }

  Future<void> _logout() async {
    ref.read(authServiceProvider).logout();
    if (mounted) Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(profileSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人设置'),
        centerTitle: true,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: formState.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 16),
                _buildField('昵称', _nicknameCtrl),
                const SizedBox(height: 14),
                _buildGenderRow(formState.gender),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        '生日',
                        _birthdayCtrl,
                        readOnly: true,
                        onTap: _pickBirthday,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildField('职业', _professionCtrl),
                const SizedBox(height: 24),
                _buildSaveButton(formState),
                const SizedBox(height: 10),
                _buildLogoutButton(),
                const SizedBox(height: 10),
                _buildDeleteButton(formState),
              ],
            ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: GestureDetector(
        onTap: _pickAvatar,
        onLongPress: _clearAvatar,
        child: CircleAvatar(
          radius: 48,
          backgroundImage: _avatarCtrl.text.isNotEmpty
              ? MemoryImage(base64Decode(_avatarCtrl.text))
              : null,
          child: _avatarCtrl.text.isEmpty
              ? const Icon(Icons.person, size: 48)
              : null,
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildGenderRow(String gender) {
    return Row(
      children: [
        const Text('性别', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 12),
        ChoiceChip(
          label: const Text('男'),
          selected: gender == 'male',
          onSelected: (_) =>
              ref.read(profileSettingsProvider.notifier).setGender('male'),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('女'),
          selected: gender == 'female',
          onSelected: (_) =>
              ref.read(profileSettingsProvider.notifier).setGender('female'),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('其他'),
          selected: gender == 'other',
          onSelected: (_) =>
              ref.read(profileSettingsProvider.notifier).setGender('other'),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ProfileSettingsState form) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: form.saving ? null : _saveProfile,
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: form.saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('保存'),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _logout,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text('退出登录'),
      ),
    );
  }

  Widget _buildDeleteButton(ProfileSettingsState form) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: form.deleting ? null : _deleteAccount,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 46),
          foregroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: Colors.red),
        ),
        child: form.deleting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('注销账户'),
      ),
    );
  }
}
