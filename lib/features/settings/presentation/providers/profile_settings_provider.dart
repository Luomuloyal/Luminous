import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/api/user_api.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:luminous/utils/dio_request.dart';

final profileSettingsProvider =
    NotifierProvider<ProfileSettingsNotifier, ProfileSettingsState>(
      ProfileSettingsNotifier.new,
    );

class ProfileSettingsState {
  final bool loading;
  final bool saving;
  final bool deleting;
  final String gender;

  const ProfileSettingsState({
    this.loading = true,
    this.saving = false,
    this.deleting = false,
    this.gender = 'other',
  });

  ProfileSettingsState copyWith({
    bool? loading, bool? saving, bool? deleting, String? gender,
  }) => ProfileSettingsState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    deleting: deleting ?? this.deleting,
    gender: gender ?? this.gender,
  );
}

class ProfileSettingsNotifier extends Notifier<ProfileSettingsState> {
  static String _normalizeGenderForUi(String value) {
    final lowered = value.trim().toLowerCase();
    if (lowered == 'male' || lowered == 'm') return 'male';
    if (lowered == 'female' || lowered == 'f') return 'female';
    return 'other';
  }

  static String _normalizeGenderForApi(String ui) {
    if (ui == 'male') return 'male';
    if (ui == 'female') return 'female';
    return 'other';
  }

  @override
  ProfileSettingsState build() => const ProfileSettingsState();

  void setGender(String value) {
    if (state.gender == value) return;
    state = state.copyWith(gender: value);
  }

  Future<void> loadProfile(
    UserSafe? user,
    UserApi userApi,
    TextEditingController avatarCtrl,
    TextEditingController nicknameCtrl,
    TextEditingController birthdayCtrl,
    TextEditingController professionCtrl,
  ) async {
    if (user == null || user.id.trim().isEmpty) {
      state = state.copyWith(loading: false);
      return;
    }

    _fillControllers(user, avatarCtrl, nicknameCtrl, birthdayCtrl, professionCtrl);
    state = state.copyWith(gender: _normalizeGenderForUi(user.gender));

    try {
      final response = await userApi.getProfile(userId: user.id);
      final fetched = response.result;
      _fillControllers(fetched, avatarCtrl, nicknameCtrl, birthdayCtrl, professionCtrl);
      state = state.copyWith(gender: _normalizeGenderForUi(fetched.gender));
    } catch (_) {
      // Keep local data on error
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  void _fillControllers(
    UserSafe user,
    TextEditingController avatarCtrl,
    TextEditingController nicknameCtrl,
    TextEditingController birthdayCtrl,
    TextEditingController professionCtrl,
  ) {
    avatarCtrl.text = user.avatar;
    nicknameCtrl.text = user.nickname.isNotEmpty ? user.nickname : user.name;
    birthdayCtrl.text = user.birthday;
    professionCtrl.text = user.profession;
  }

  Future<bool> saveProfile({
    required UserSafe? user,
    required UserApi userApi,
    required TextEditingController avatarCtrl,
    required TextEditingController nicknameCtrl,
    required TextEditingController birthdayCtrl,
    required TextEditingController professionCtrl,
    required void Function(UserSafe) onUserUpdate,
  }) async {
    if (user == null || user.id.trim().isEmpty) return false;
    if (state.saving) return false;

    final nickname = nicknameCtrl.text.trim();
    if (nickname.isNotEmpty && (nickname.length < 2 || nickname.length > 30)) return false;
    final birthday = birthdayCtrl.text.trim();
    if (birthday.isNotEmpty && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthday)) return false;

    state = state.copyWith(saving: true);
    try {
      final response = await userApi.updateProfile(
        userId: user.id,
        avatar: avatarCtrl.text,
        nickname: nickname,
        gender: _normalizeGenderForApi(state.gender),
        birthday: birthday,
        profession: professionCtrl.text.trim(),
        provinceCode: '',
        cityCode: '',
      );
      onUserUpdate(response.result);
      return true;
    } finally {
      state = state.copyWith(saving: false);
    }
  }

  Future<bool> deleteAccount({
    required String userId,
    required UserApi userApi,
  }) async {
    if (userId.trim().isEmpty || state.deleting) return false;
    state = state.copyWith(deleting: true);
    try {
      await userApi.deleteAccount(userId: userId);
      return true;
    } on ApiException {
      rethrow;
    } finally {
      state = state.copyWith(deleting: false);
    }
  }

  Future<void> pickAvatarFromGallery(
    BuildContext context,
    ImagePicker picker,
    TextEditingController avatarCtrl,
  ) async {
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null || !context.mounted) return;
    final bytes = await file.readAsBytes();
    final base64 = base64Encode(bytes);
    avatarCtrl.text = base64;
  }

  void clearAvatar(TextEditingController avatarCtrl) {
    avatarCtrl.text = '';
  }
}
