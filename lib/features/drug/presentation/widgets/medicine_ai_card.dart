import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/models/medicine.dart';

import 'medicine_support_cards.dart';
import '../pages/medicine_detail_page.dart';

/// 详情页"AI 智能解读"卡片。
class MedicineAiCard extends StatelessWidget {
  /// 创建详情页"AI 智能解读"卡片。
  const MedicineAiCard({
    super.key,
    required this.hasIdentity,
    required this.loading,
    required this.result,
    required this.onFetch,
    required this.onCancel,
  });

  /// 是否具备身份字段（用于决定按钮是否可点击）。
  final bool hasIdentity;

  /// 是否正在加载 AI 解读内容。
  final bool loading;

  /// AI 解读结果。
  final MedicineAiDetailResult? result;

  /// 点击"获取更详细信息"回调。
  final VoidCallback onFetch;

  /// 点击"取消"回调。
  final VoidCallback onCancel;

  /// 构建 AI 解读卡片 UI。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasFetched = result != null;
    final scheme = Theme.of(context).colorScheme;
    final entries = result == null
        ? const <String>[]
        : _splitAiEntries(result!.text);
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    final isZh = locale.startsWith('zh');
    final cachedTime = formatAiTimestamp(context, result?.cachedAt);

    return MedicineSurfaceCard(
      title: l10n?.medicineDetailAiTitle ?? 'AI 智能解读',
      accentColor: Color.lerp(scheme.secondary, scheme.primary, 0.5)!,
      secondaryColor: scheme.tertiary,
      ornamentKey: 'medicine.ai',
      titleFontSize: 20,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: !hasIdentity || loading ? null : onFetch,
            style: FilledButton.styleFrom(
              minimumSize: const Size(110, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                : Text(
                    hasFetched
                        ? (isZh ? '重新分析' : 'Analyze again')
                        : (l10n?.medicineDetailAiFetch ?? '获取更详细信息'),
                  ),
          ),
          if (loading) ...[
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: onCancel,
              style: FilledButton.styleFrom(
                minimumSize: const Size(72, 40),
                backgroundColor: const Color(
                  0xFFEF4444,
                ).withValues(alpha: 0.12),
                foregroundColor: const Color(0xFFB91C1C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                ),
              ),
              child: Text(l10n?.reminderDeleteCancel ?? '取消'),
            ),
          ],
        ],
      ),
      child: entries.isEmpty
          ? Text(
              l10n?.medicineDetailAiPlaceholder ??
                  '点击"获取更详细信息"后，后端会调用 AI 模型补充数据库里未保存的说明书信息，例如成分、禁忌、注意事项等。',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result?.isCached == true)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: appTintedSurface(
                        context,
                        scheme.primary,
                        lightAlpha: 0.06,
                        darkAlpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: appTintedBorder(
                          context,
                          scheme.primary,
                          lightAlpha: 0.12,
                          darkAlpha: 0.22,
                        ),
                      ),
                    ),
                    child: Text(
                      cachedTime.isEmpty
                          ? (isZh
                                ? '上次 AI 分析结果'
                                : 'Previous AI analysis result')
                          : (isZh
                                ? '上次 AI 分析结果 · $cachedTime'
                                : 'Previous AI analysis result · $cachedTime'),
                      style: TextStyle(
                        fontSize: 12.6,
                        height: 1.45,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                for (var i = 0; i < entries.length; i++) ...[
                  MedicineAiDetailEntryCard(
                    index: i + 1,
                    text: entries[i],
                    isHeading: _looksLikeAiHeading(entries[i]),
                  ),
                  if (i != entries.length - 1) const SizedBox(height: 9),
                ],
              ],
            ),
    );
  }

  List<String> _splitAiEntries(String raw) {
    var text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    if (text.isEmpty) {
      return const <String>[];
    }

    const sectionMarkers = <String>[
      '一、',
      '二、',
      '三、',
      '四、',
      '五、',
      '六、',
      '七、',
      '八、',
      '九、',
      '十、',
      '常见用途',
      '禁忌',
      '注意事项',
      '用药建议',
    ];

    for (final marker in sectionMarkers) {
      final escaped = RegExp.escape(marker);
      text = text.replaceAllMapped(
        RegExp('(?<!\\n)($escaped)'),
        (match) => '\n${match.group(1)}',
      );
    }

    var lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    if (lines.length <= 1) {
      final sentences = text
          .split(RegExp(r'(?<=[。！？])\s*'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
      if (sentences.length > 1) {
        lines = sentences;
      }
    }

    return lines;
  }

  bool _looksLikeAiHeading(String text) {
    final line = text.trim();
    if (line.isEmpty || line.length > 28) {
      return false;
    }
    final headingPattern = RegExp(
      r'^(第[一二三四五六七八九十]+[章节部分]|[一二三四五六七八九十]+[、.．]|\d+[、.．])',
    );
    if (headingPattern.hasMatch(line)) {
      return true;
    }
    return line.endsWith('建议') || line.endsWith('事项') || line.endsWith('人群');
  }
}

/// AI 解读结果中的单条条目卡片。
class MedicineAiDetailEntryCard extends StatelessWidget {
  const MedicineAiDetailEntryCard({
    super.key,
    required this.index,
    required this.text,
    required this.isHeading,
  });

  final int index;
  final String text;
  final bool isHeading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = isHeading
        ? Color.lerp(scheme.secondary, scheme.primary, 0.4)!
        : scheme.primary;
    final headingColor = isDark ? scheme.onSurface : const Color(0xFF0F172A);
    final bodyColor = isDark
        ? scheme.onSurface.withValues(alpha: 0.92)
        : const Color(0xFF334155);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: appTintedSurface(
          context,
          accent,
          lightAlpha: isHeading ? 0.09 : 0.05,
          darkAlpha: isHeading ? 0.18 : 0.12,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appTintedBorder(
            context,
            accent,
            lightAlpha: 0.14,
            darkAlpha: 0.24,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 1),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isHeading ? 19 : 16,
                height: 1.55,
                color: isHeading ? headingColor : bodyColor,
                fontWeight: isHeading ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
