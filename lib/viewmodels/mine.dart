import 'package:flutter/material.dart';

/// 我的页（Mine）相关的小型展示模型与卡片组件。
class MineQuickActionData {
  /// 创建一个快捷操作数据对象。
  const MineQuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.id,
  });

  /// 快捷操作图标。
  final IconData icon;

  /// 快捷操作标题。
  final String title;

  /// 快捷操作副标题。
  final String subtitle;

  /// 快捷操作主色。
  final Color color;

  /// 快捷操作唯一标识。
  ///
  /// 页面通常会根据它决定点击后执行什么逻辑。
  final String id;
}

/// 我的页顶部“快捷入口”区域中的单个卡片组件。
class MineQuickActionCard extends StatelessWidget {
  /// 创建一个快捷操作卡片组件。
  const MineQuickActionCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  /// 当前卡片使用的数据对象。
  final MineQuickActionData data;

  /// 点击卡片回调。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(data.icon, color: data.color, size: 38),
              ),
              const SizedBox(height: 12),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
