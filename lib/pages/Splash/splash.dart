// This page and it controller is deprecated. Do not reference or modify it.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:luminous/stores/user_controller.dart';

/// 启动屏页面。
///
/// 展示约 2 秒后自动跳转：
/// - 已登录 → 主页 `/`
/// - 未登录 → 登录页 `/login`
///
/// 风格参考：全屏纯色背景 + 大标题 + 装饰图标浮动 + 底部品牌信息。
/// 如需替换图片素材，请参考文件底部的【素材替换指南】注释。
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 2 秒后跳转
    Future.delayed(const Duration(milliseconds: 2200), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final userController = Get.find<UserController>();
    final isLoggedIn = (userController.user.value?.id ?? '').trim().isNotEmpty;
    Navigator.of(context).pushReplacementNamed(isLoggedIn ? '/' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF5B9BD5), // 主题蓝色背景
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 背景渐变 ──────────────────────────────────────────────
          const _SplashBackground(),

          // ── 浮动装饰圆点 ──────────────────────────────────────────
          const _FloatingDots(),

          // ── 主内容 ────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.10),
                const _SplashTitle(),
                SizedBox(height: size.height * 0.06),
                const _SplashMascot(),
                const Spacer(),
                _SplashFooter(bottomPadding: bottomPadding),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 背景渐变
// ─────────────────────────────────────────────────────────────────────────────

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A90D9), // 顶部深蓝
            Color(0xFF6BB8F0), // 中部天蓝
            Color(0xFF9DD4F5), // 底部浅蓝
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 浮动装饰圆点
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingDots extends StatelessWidget {
  const _FloatingDots();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _DotsPainter()));
  }
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final dots = [
      _Dot(0.08, 0.18, 28, const Color(0x33FFFFFF)),
      _Dot(0.88, 0.12, 18, const Color(0x22FFFFFF)),
      _Dot(0.92, 0.42, 40, const Color(0x18FFFFFF)),
      _Dot(0.05, 0.62, 22, const Color(0x28FFFFFF)),
      _Dot(0.78, 0.72, 14, const Color(0x33FFFFFF)),
      _Dot(0.15, 0.85, 32, const Color(0x1AFFFFFF)),
      _Dot(0.60, 0.90, 20, const Color(0x22FFFFFF)),
    ];
    for (final d in dots) {
      paint.color = d.color;
      canvas.drawCircle(
        Offset(size.width * d.x, size.height * d.y),
        d.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Dot {
  const _Dot(this.x, this.y, this.r, this.color);
  final double x, y, r;
  final Color color;
}

// ─────────────────────────────────────────────────────────────────────────────
// 大标题
// ─────────────────────────────────────────────────────────────────────────────

class _SplashTitle extends StatelessWidget {
  const _SplashTitle();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 如需替换为图片 Logo，将下方 Text 替换为 Image.asset(...) ──
          Text(
            l10n?.splashTitleMain ?? '智慧用药',
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -1,
              shadows: [
                Shadow(
                  color: Color(0x40000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n?.splashTitleSubtitle ?? 'Luminous · 健康守护',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 中央吉祥物 / 图标区
// ─────────────────────────────────────────────────────────────────────────────

class _SplashMascot extends StatelessWidget {
  const _SplashMascot();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // ── 【素材替换指南】────────────────────────────────────────────────────
    // 当你准备好图片素材后，将整个 _SplashMascot 的 build 方法替换为：
    //
    //   return Image.asset(
    //     'lib/assets/splash_mascot.png',   // ← 把图片放到这个路径
    //     width: 280,
    //     fit: BoxFit.contain,
    //   );
    //
    // 同时在 pubspec.yaml 的 flutter > assets 下添加：
    //   - lib/assets/splash_mascot.png
    // ─────────────────────────────────────────────────────────────────────────

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 外圈光晕
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          // 内圈白色卡片
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.92),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90D9).withValues(alpha: 0.35),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              Icons.medication_rounded,
              size: 80,
              color: Color(0xFF4A90D9),
            ),
          ),
          // 右上角浮动标签 - AI
          Positioned(
            top: 28,
            right: 20,
            child: _FloatingBadge(
              label: 'AI',
              color: const Color(0xFF7C3AED),
              icon: Icons.auto_awesome_rounded,
            ),
          ),
          // 左下角浮动标签 - 扫描
          Positioned(
            bottom: 32,
            left: 16,
            child: _FloatingBadge(
              label: l10n?.splashBadgeScan ?? '扫描',
              color: const Color(0xFF0891B2),
              icon: Icons.qr_code_scanner_rounded,
            ),
          ),
          // 右下角浮动标签 - 提醒
          Positioned(
            bottom: 20,
            right: 10,
            child: _FloatingBadge(
              label: l10n?.splashBadgeReminder ?? '提醒',
              color: const Color(0xFF059669),
              icon: Icons.alarm_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 底部品牌信息
// ─────────────────────────────────────────────────────────────────────────────

class _SplashFooter extends StatelessWidget {
  const _SplashFooter({required this.bottomPadding});

  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: math.max(bottomPadding, 24) + 8),
      child: Column(
        children: [
          Text(
            l10n?.splashFooterBrand ?? 'Luminous 智慧用药助手',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n?.splashFooterSlogan ?? '安全 · 便捷 · 智能',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.60),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
