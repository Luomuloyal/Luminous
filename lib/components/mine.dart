import 'package:flutter/material.dart';
import 'package:luminous/viewmodels/auth.dart';

class MineProfileCard extends StatelessWidget {
  const MineProfileCard({
    super.key,
    required this.user,
    required this.onTapProfile,
    required this.onTapAction,
  });

  final UserSafe? user;
  final VoidCallback onTapProfile;
  final VoidCallback onTapAction;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = user?.hasData ?? false;
    final displayUser = user;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTapProfile,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.22),
              ),
              child: Icon(
                isLoggedIn
                    ? Icons.verified_user_rounded
                    : Icons.person_outline_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: onTapProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoggedIn ? displayUser!.displayTitle : '立即登录',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLoggedIn
                        ? displayUser!.displaySubtitle
                        : '登录后可管理账号信息与同步个人数据',
                    style: const TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: onTapAction,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F766E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              minimumSize: const Size(88, 40),
            ),
            child: Text(isLoggedIn ? '退出登录' : '去登录'),
          ),
        ],
      ),
    );
  }
}
