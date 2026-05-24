part of 'auth.dart';

/// 登录页底部的协议提示文本。
class AuthLegalHint extends StatelessWidget {
  const AuthLegalHint({
    super.key,
    required this.onTapAgreement,
    required this.onTapPrivacy,
  });

  final VoidCallback onTapAgreement;
  final VoidCallback onTapPrivacy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final linkColor = Color.lerp(scheme.primary, scheme.secondary, 0.20)!;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n.authLegalPrefix,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
            height: 1.45,
          ),
        ),
        GestureDetector(
          onTap: onTapAgreement,
          child: Text(
            l10n.authUserAgreementTitle,
            style: TextStyle(
              fontSize: 11.5,
              color: linkColor,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ),
        Text(
          l10n.authLegalAnd,
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),
        GestureDetector(
          onTap: onTapPrivacy,
          child: Text(
            l10n.authPrivacyPolicyTitle,
            style: TextStyle(
              fontSize: 11.5,
              color: linkColor,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

/// 协议与隐私政策勾选行。
///
/// 用于登录/注册页底部，统一实现“勾选 + 文本跳转”的交互。
class AuthAgreementRow extends StatelessWidget {
  /// 创建一个协议勾选行组件。
  const AuthAgreementRow({
    super.key,
    required this.agreed,
    required this.onChanged,
    required this.onTapAgreement,
    required this.onTapPrivacy,
  });

  /// 当前是否已勾选同意。
  final bool agreed;

  /// 勾选状态变更回调。
  final ValueChanged<bool> onChanged;

  /// 点击“用户协议”回调。
  final VoidCallback onTapAgreement;

  /// 点击“隐私政策”回调。
  final VoidCallback onTapPrivacy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final linkColor = Color.lerp(scheme.primary, scheme.secondary, 0.20)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: agreed,
          onChanged: (value) => onChanged(value ?? false),
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        ),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onChanged(!agreed),
                child: Text(
                  l10n.authAgreementPrefix,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTapAgreement,
                child: Text(
                  l10n.authUserAgreementTitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: linkColor,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(!agreed),
                child: Text(
                  l10n.authLegalAnd,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTapPrivacy,
                child: Text(
                  l10n.authPrivacyPolicyTitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: linkColor,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
