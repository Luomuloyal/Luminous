import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/features/today/presentation/widgets/today_dashboard_view.dart';

/// 今日页。
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(todayDashboardProvider);
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            brightness == Brightness.dark
                ? const Color(0xFF101312)
                : const Color(0xFFF8FDFB),
            surface.canvasSoft,
            surface.canvasSoft,
          ],
        ),
      ),
      child: Stack(
        children: [
          const _TodayBackdrop(),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth < AppBreakpoints.mobile
                    ? constraints.maxWidth
                    : math.min(constraints.maxWidth, 460.0);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: dashboardAsync.when(
                      data: (dashboard) =>
                          TodayDashboardView(dashboard: dashboard),
                      loading: () => const TodayLoadingView(),
                      error: (_, __) => TodayErrorView(
                        onRetry: () => ref.invalidate(todayDashboardProvider),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayBackdrop extends StatelessWidget {
  const _TodayBackdrop();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -48,
            top: 52,
            child: _GlowOrb(
              size: 148,
              color: brightness == Brightness.dark
                  ? const Color(0x2215BA9B)
                  : const Color(0x3315BA9B),
            ),
          ),
          Positioned(
            right: -36,
            top: 132,
            child: _GlowOrb(
              size: 132,
              color: brightness == Brightness.dark
                  ? const Color(0x18FFD59E)
                  : const Color(0x28FFD59E),
            ),
          ),
          Positioned(
            right: 28,
            top: 360,
            child: _GlowOrb(
              size: 96,
              color: brightness == Brightness.dark
                  ? const Color(0x167D8CFF)
                  : const Color(0x227D8CFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
