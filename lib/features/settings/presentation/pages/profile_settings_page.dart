import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/features/auth/providers/auth_service_provider.dart';
import 'package:luminous/features/settings/presentation/controllers/profile_settings_controller.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';

/// 个人设置页。
///
/// 支持编辑头像、昵称、性别、生日、职业和地区编码，并同步到后端与本地用户态。
class ProfileSettingsPage extends ConsumerStatefulWidget {
  const ProfileSettingsPage({super.key, this.controller});

  final ProfileSettingsController? controller;

  @override
  ConsumerState<ProfileSettingsPage> createState() =>
      _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<ProfileSettingsPage> {
  late final ProfileSettingsController _controller =
      widget.controller ??
      ProfileSettingsController(
        onLogout: () => ref.read(authServiceProvider).logout(),
        onPurgeAccount: (userId) =>
            ref.read(authServiceProvider).purgeDeletedAccountData(userId),
        onUserUpdate: (user) =>
            ref.read(authServiceProvider).loginSuccess(user),
      );

  TextEditingController get _avatarController => _controller.avatarController;
  TextEditingController get _nicknameController =>
      _controller.nicknameController;
  TextEditingController get _birthdayController =>
      _controller.birthdayController;
  TextEditingController get _professionController =>
      _controller.professionController;
  TextEditingController get _provinceCodeController =>
      _controller.provinceCodeController;
  TextEditingController get _cityCodeController =>
      _controller.cityCodeController;
  bool get _loading => _controller.loading;
  bool get _saving => _controller.saving;
  bool get _deleting => _controller.deleting;
  String get _gender => _controller.gender;
  UserSafe? get _currentUser => _controller.currentUser;

  Future<void> _pickBirthday() async {
    await _controller.pickBirthday(context);
  }

  Future<void> _saveProfile() async {
    await _controller.saveProfile(context);
  }

  Future<void> _deleteAccount() async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('注销账户'),
        content: const Text(
          '注销后会删除你的个人资料、我的药品、提醒与扫描记录，本地缓存也会一并清空，且无法恢复。确认继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            child: const Text('确认注销'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) {
      return;
    }

    final deleted = await _controller.deleteAccount(context);
    if (!mounted || !deleted) {
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  ImageProvider<Object>? _avatarProviderFromText(String text) {
    final raw = text.trim();
    if (raw.isEmpty) {
      return null;
    }
    return _controller.avatarProviderFromText(raw);
  }

  Future<void> _pickAvatarFromGallery() async {
    await _controller.pickAvatarFromGallery(context);
  }

  void _clearAvatar() {
    _controller.clearAvatar();
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: scheme.surface.withValues(alpha: 0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileSettingsController>(
      init: _controller,
      global: false,
      builder: (_) {
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
                      backgroundColor: appTintedSurface(
                        context,
                        scheme.primary,
                      ),
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
                            user.account.isNotEmpty
                                ? user.account
                                : user.username,
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
                      context,
                      controller: _nicknameController,
                      label: '昵称',
                      hint: '2-30 字符，可留空',
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: InputDecoration(
                        labelText: '性别',
                        filled: true,
                        fillColor: scheme.surface.withValues(alpha: 0.5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: scheme.outline.withValues(alpha: 0.15),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: scheme.primary.withValues(alpha: 0.4),
                          ),
                        ),
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
                        _controller.setGender(value);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      context,
                      controller: _birthdayController,
                      label: '生日',
                      hint: 'YYYY-MM-DD',
                      readOnly: true,
                      onTap: _pickBirthday,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      context,
                      controller: _professionController,
                      label: '职业',
                      hint: '例如：工程师、学生',
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            context,
                            controller: _provinceCodeController,
                            label: '省份编码',
                            hint: '如 110000',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            context,
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
              const SizedBox(height: 12),
              AppSectionCard(
                accentColor: scheme.error,
                secondaryColor: scheme.errorContainer,
                ornamentKey: 'settings.profile.danger',
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '危险操作',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '注销账户会永久删除当前账号及其相关云端数据，本地缓存也会一并清空，请谨慎操作。',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12.8,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _deleting ? null : _deleteAccount,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.error,
                          side: BorderSide(
                            color: scheme.error.withValues(alpha: 0.45),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: _deleting
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    scheme.error,
                                  ),
                                ),
                              )
                            : const Icon(Icons.delete_forever_rounded),
                        label: Text(_deleting ? '注销中...' : '注销账户'),
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
            title: Text(
              AppLocalizations.of(context)?.settingsProfileTitle ?? '个人设置',
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          child: body,
        );
      },
    );
  }
}
