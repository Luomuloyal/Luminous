import 'dart:convert';

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
    bool? loading,
    bool? saving,
    bool? deleting,
    String? gender,
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

  Future<UserSafe?> loadProfile(UserSafe? user, UserApi userApi) async {
    if (user == null || user.id.trim().isEmpty) {
      state = state.copyWith(loading: false);
      return null;
    }

    state = state.copyWith(loading: true);
    state = state.copyWith(gender: _normalizeGenderForUi(user.gender));

    try {
      final response = await userApi.getProfile(userId: user.id);
      final fetched = response.result;
      state = state.copyWith(gender: _normalizeGenderForUi(fetched.gender));
      return fetched;
    } catch (_) {
      return user;
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<bool> saveProfile({
    required UserSafe? user,
    required UserApi userApi,
    required String avatar,
    required String nickname,
    required String birthday,
    required String profession,
    required Future<void> Function(UserSafe) onUserUpdate,
  }) async {
    if (user == null || user.id.trim().isEmpty) return false;
    if (state.saving) return false;

    final trimmedNickname = nickname.trim();
    if (trimmedNickname.isNotEmpty &&
        (trimmedNickname.length < 2 || trimmedNickname.length > 30)) {
      return false;
    }
    final trimmedBirthday = birthday.trim();
    if (trimmedBirthday.isNotEmpty &&
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmedBirthday)) {
      return false;
    }

    state = state.copyWith(saving: true);
    try {
      final response = await userApi.updateProfile(
        userId: user.id,
        avatar: avatar,
        nickname: trimmedNickname,
        gender: _normalizeGenderForApi(state.gender),
        birthday: trimmedBirthday,
        profession: profession.trim(),
        provinceCode: '',
        cityCode: '',
      );
      await onUserUpdate(response.result);
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

  Future<String?> pickAvatarFromGallery(ImagePicker picker) async {
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }
}
