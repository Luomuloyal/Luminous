import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthMethodItem {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AuthMethodItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });
}

class AuthHeroCard extends StatelessWidget {
  const AuthHeroCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0EA5E9),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthMethodSwitcher extends StatelessWidget {
  const AuthMethodSwitcher({super.key, required this.items});

  final List<AuthMethodItem> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: items
              .asMap()
              .entries
              .map(
                (entry) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: entry.key == items.length - 1 ? 0 : 8,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: entry.value.onTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 38,
                        decoration: BoxDecoration(
                          color: entry.value.selected
                              ? const Color(0xFF0EA5E9)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            entry.value.label,
                            style: TextStyle(
                              color: entry.value.selected
                                  ? Colors.white
                                  : const Color(0xFF334155),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class AuthSvgCaptchaCard extends StatelessWidget {
  const AuthSvgCaptchaCard({
    super.key,
    required this.isLoading,
    required this.onRefresh,
    required this.svgContent,
    this.emptyText = '点击右侧刷新获取SVG验证码',
  });

  final bool isLoading;
  final VoidCallback onRefresh;
  final String? svgContent;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : svgContent == null || svgContent!.isEmpty
                    ? Text(
                        emptyText,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : SvgPicture.string(svgContent!),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.tonalIcon(
            onPressed: isLoading ? null : onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('刷新'),
            style: FilledButton.styleFrom(
              foregroundColor: const Color(0xFF0369A1),
              backgroundColor: const Color(0xFFE0F2FE),
              minimumSize: const Size(80, 42),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthAgreementRow extends StatelessWidget {
  const AuthAgreementRow({
    super.key,
    required this.agreed,
    required this.onChanged,
    required this.onTapAgreement,
    required this.onTapPrivacy,
  });

  final bool agreed;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTapAgreement;
  final VoidCallback onTapPrivacy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: agreed,
          onChanged: (value) => onChanged(value ?? false),
        ),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onChanged(!agreed),
                child: const Text(
                  '我已阅读并同意',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTapAgreement,
                child: const Text(
                  '《用户协议》',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0284C7),
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(!agreed),
                child: const Text(
                  '和',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTapPrivacy,
                child: const Text(
                  '《隐私政策》',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0284C7),
                    fontWeight: FontWeight.w700,
                    height: 1.4,
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
