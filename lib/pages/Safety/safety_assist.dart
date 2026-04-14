import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/auth.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/components/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Picker/medicine_picker.dart';
import 'package:luminous/pages/Safety/controllers/safety_assist_controller.dart';
import 'package:luminous/viewmodels/medicine.dart';

/// 安全辅助页。
///
/// 页面允许用户选择一款或两款药品，并调用 AI 接口生成用药建议或相互作用提示。
class SafetyAssistPage extends StatelessWidget {
  /// 创建安全辅助页组件。
  const SafetyAssistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SafetyAssistController>(
      init: SafetyAssistController(),
      global: false,
      builder: (controller) {
        final l10n = AppLocalizations.of(context);
        final scheme = Theme.of(context).colorScheme;
        final secondaryAccent = Color.lerp(
          scheme.secondary,
          scheme.tertiary,
          0.52,
        )!;
        return AppCanvasPageScaffold(
          appBar: AppBar(
            title: Text(_safetyTitle(l10n)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          appBarSpacing: 20,
          accentColor: scheme.primary,
          secondaryAccentColor: secondaryAccent,
          child: RefreshIndicator(
            onRefresh: controller.refreshResult,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
              children: [
                _buildHeroCard(context, controller, l10n),
                const SizedBox(height: 8),
                _buildModeCard(context, controller, l10n),
                const SizedBox(height: 8),
                _buildPickCard(context, controller, l10n),
                const SizedBox(height: 8),
                _buildActionCard(context, controller, l10n),
                const SizedBox(height: 8),
                _buildResultCard(context, controller, l10n),
                const SizedBox(height: 8),
                const _DisclaimerCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  String _safetyTitle(AppLocalizations? l10n) {
    return l10n?.safetyTitle ?? 'Safety Assist';
  }

  String _heroSubtitle(AppLocalizations? l10n) {
    return l10n?.safetyHeroSubtitle ??
        'Organize single-medicine guidance and two-medicine interaction alerts in a gentler way';
  }

  String _modeSingleText(AppLocalizations? l10n) {
    return l10n?.safetyModeSingle ?? 'Single-medicine guidance';
  }

  String _modePairText(AppLocalizations? l10n) {
    return l10n?.safetyModePair ?? 'Two-medicine interaction';
  }

  String _selectedWaitingText(AppLocalizations? l10n) {
    return l10n?.safetySelectedWaiting ?? 'Waiting for medicine selection';
  }

  String _selectedCountText(AppLocalizations? l10n, int count) {
    return l10n?.safetySelectedCount(count) ?? '$count medicines selected';
  }

  String _cloudWithContextText(AppLocalizations? l10n) {
    return l10n?.safetyCloudWithContext ?? 'Can include account context';
  }

  String _cloudQueryText(AppLocalizations? l10n) {
    return l10n?.safetyCloudQuery ?? 'Cloud AI query';
  }

  String _pickSubtitleText(AppLocalizations? l10n) {
    return l10n?.safetyPickSubtitle ??
        'Select from My Medicines or search library';
  }

  String _pickPlaceholderText(AppLocalizations? l10n, int slot) {
    if (slot == 0) {
      return l10n?.safetyPickPlaceholderA ?? 'Please select Medicine A';
    }
    return l10n?.safetyPickPlaceholderB ?? 'Please select Medicine B';
  }

  String _pickBadgeText(AppLocalizations? l10n, int slot) {
    if (slot == 0) {
      return l10n?.safetyPickBadgeA ?? 'Medicine A';
    }
    return l10n?.safetyPickBadgeB ?? 'Medicine B';
  }

  String _actionQueryText(AppLocalizations? l10n, String mode) {
    if (mode == SafetyAssistController.pairMode) {
      return l10n?.safetyActionQueryPair ?? 'Check Two-medicine Interaction';
    }
    return l10n?.safetyActionQuerySingle ?? 'Check Medication Advice';
  }

  String _resultPlaceholderText(AppLocalizations? l10n) {
    return l10n?.safetyResultPlaceholder ??
        'After selecting medicines, tap "Start Query" and the backend will call AI to return medication advice or interaction alerts.';
  }

  String _pickerTitleText(AppLocalizations? l10n, int slot) {
    if (slot == 0) {
      return l10n?.safetyPickerTitleA ?? 'Select Medicine A';
    }
    return l10n?.safetyPickerTitleB ?? 'Select Medicine B';
  }

  String _cancelActionText(AppLocalizations? l10n) {
    return l10n?.reminderDeleteCancel ?? '取消';
  }

  Widget _buildHeroCard(
    BuildContext context,
    SafetyAssistController controller,
    AppLocalizations? l10n,
  ) {
    final loggedIn = controller.loggedIn;
    final selectedCount = controller.selectedCount;

    return SoftBannerCard(
      palette: SoftBannerPalettes.drugOf(context),
      ornamentKey: 'safety.hero',
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      builder: (context, theme) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.surfaceColor,
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    color: theme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _safetyTitle(l10n),
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _heroSubtitle(l10n),
                        style: TextStyle(
                          color: theme.secondaryTextColor,
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SafetyInfoChip(
                    icon: controller.mode == SafetyAssistController.pairMode
                        ? Icons.compare_arrows_rounded
                        : Icons.auto_awesome_rounded,
                    text: controller.mode == SafetyAssistController.pairMode
                        ? _modePairText(l10n)
                        : _modeSingleText(l10n),
                    backgroundColor: theme.surfaceColor,
                    foregroundColor: theme.surfaceTextColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _SafetyInfoChip(
                    icon: Icons.medication_outlined,
                    text: selectedCount == 0
                        ? _selectedWaitingText(l10n)
                        : _selectedCountText(l10n, selectedCount),
                    backgroundColor: theme.surfaceColor,
                    foregroundColor: theme.surfaceTextColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _SafetyInfoChip(
                    icon: loggedIn
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_outlined,
                    text: loggedIn
                        ? _cloudWithContextText(l10n)
                        : _cloudQueryText(l10n),
                    backgroundColor: theme.surfaceColor,
                    foregroundColor: theme.surfaceTextColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// 构建“查询模式”卡片。
  Widget _buildModeCard(
    BuildContext context,
    SafetyAssistController controller,
    AppLocalizations? l10n,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: l10n?.safetyModeCardTitle ?? 'Query Mode',
      accentColor: scheme.secondary,
      secondaryColor: scheme.tertiary,
      ornamentKey: 'safety.mode',
      child: AuthMethodSwitcher(
        accentColor: scheme.secondary,
        items: [
          AuthMethodItem(
            label: _modeSingleText(l10n),
            selected: controller.mode == SafetyAssistController.singleMode,
            onTap: () => controller.setMode(SafetyAssistController.singleMode),
          ),
          AuthMethodItem(
            label: _modePairText(l10n),
            selected: controller.mode == SafetyAssistController.pairMode,
            onTap: () => controller.setMode(SafetyAssistController.pairMode),
          ),
        ],
      ),
    );
  }

  /// 构建“选择药品”卡片。
  Widget _buildPickCard(
    BuildContext context,
    SafetyAssistController controller,
    AppLocalizations? l10n,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final tileAColor = scheme.primary;
    final tileBColor = Color.lerp(scheme.secondary, scheme.tertiary, 0.35)!;
    return _SectionCard(
      title: l10n?.safetyPickCardTitle ?? 'Select Medicines',
      accentColor: scheme.primary,
      secondaryColor: scheme.secondary,
      ornamentKey: 'safety.pick',
      child: Column(
        children: [
          _pickTile(
            context: context,
            label:
                controller.medicineA?.displayName ??
                _pickPlaceholderText(l10n, 0),
            subtitle:
                controller.medicineA?.displaySubtitle ??
                _pickSubtitleText(l10n),
            color: tileAColor,
            onTap: () => _pickMedicine(context, controller, slot: 0),
            badge: _pickBadgeText(l10n, 0),
            note: controller.medicineA?.displayTips,
          ),
          if (controller.mode == SafetyAssistController.pairMode) ...[
            const SizedBox(height: 8),
            _pickTile(
              context: context,
              label:
                  controller.medicineB?.displayName ??
                  _pickPlaceholderText(l10n, 1),
              subtitle:
                  controller.medicineB?.displaySubtitle ??
                  _pickSubtitleText(l10n),
              color: tileBColor,
              onTap: () => _pickMedicine(context, controller, slot: 1),
              badge: _pickBadgeText(l10n, 1),
              note: controller.medicineB?.displayTips,
            ),
          ],
        ],
      ),
    );
  }

  /// 构建药品选择 tile（A 或 B）。
  Widget _pickTile({
    required BuildContext context,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required String badge,
    String? note,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: appTintedSurface(
            context,
            color,
            lightAlpha: 0.05,
            darkAlpha: 0.11,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: appTintedBorder(
              context,
              color,
              lightAlpha: 0.10,
              darkAlpha: 0.18,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.medication_outlined, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13.8,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: appTintedSurface(
                            context,
                            color,
                            lightAlpha: 0.08,
                            darkAlpha: 0.16,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10.2,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  if (note != null && note.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      note.trim(),
                      style: TextStyle(
                        fontSize: 11.2,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  /// 构建“开始查询”卡片。
  Widget _buildActionCard(
    BuildContext context,
    SafetyAssistController controller,
    AppLocalizations? l10n,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: l10n?.safetyActionCardTitle ?? 'Start Query',
      accentColor: scheme.tertiary,
      secondaryColor: scheme.primary,
      ornamentKey: 'safety.action',
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: controller.loading || !controller.ready
                  ? null
                  : controller.query,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: controller.loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Text(_actionQueryText(l10n, controller.mode)),
            ),
          ),
          if (controller.loading) ...[
            const SizedBox(width: 6),
            FilledButton.tonal(
              onPressed: controller.cancelQuery,
              style: FilledButton.styleFrom(
                minimumSize: const Size(78, 44),
                backgroundColor: const Color(
                  0xFFEF4444,
                ).withValues(alpha: 0.12),
                foregroundColor: const Color(0xFFB91C1C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                ),
              ),
              child: Text(_cancelActionText(l10n)),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建“AI 结果”卡片。
  Widget _buildResultCard(
    BuildContext context,
    SafetyAssistController controller,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final entries = controller.result == null
        ? const <String>[]
        : _splitResultParagraphs(controller.result!.text);
    return _SectionCard(
      title: l10n?.safetyResultCardTitle ?? 'AI Result',
      accentColor: Color.lerp(scheme.secondary, scheme.primary, 0.5)!,
      secondaryColor: scheme.tertiary,
      ornamentKey: 'safety.result',
      titleFontSize: 20,
      child: entries.isEmpty
          ? Text(
              _resultPlaceholderText(l10n),
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
                for (var i = 0; i < entries.length; i++) ...[
                  _AiResultEntryCard(
                    index: i + 1,
                    text: entries[i],
                    isHeading: _looksLikeHeading(entries[i]),
                  ),
                  if (i != entries.length - 1) const SizedBox(height: 9),
                ],
              ],
            ),
    );
  }

  /// 把 AI 长文本拆分成更易读的段落。
  List<String> _splitResultParagraphs(String raw) {
    var text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    if (text.isEmpty) {
      return const <String>[];
    }

    const sectionMarkers = <String>[
      '是否存在相互作用',
      '可能风险',
      '联用建议',
      '何时需要咨询医生或药师',
      '风险提示',
      '用药建议',
    ];

    for (final marker in sectionMarkers) {
      final escaped = RegExp.escape(marker);
      text = text.replaceAllMapped(
        RegExp('(?<!\\n)($escaped[：:])'),
        (match) => '\n${match.group(1)}',
      );
    }

    var parts = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    if (parts.length <= 1) {
      final sentences = text
          .split(RegExp(r'(?<=[。！？])\s*'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
      if (sentences.length > 1) {
        parts = sentences;
      }
    }

    return parts;
  }

  bool _looksLikeHeading(String text) {
    final line = text.trim();
    if (line.isEmpty) {
      return false;
    }
    if (line.length > 28) {
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

  /// 打开药品选择器并把结果写入 A 或 B。
  ///
  /// - slot=0：设置 A
  /// - slot=1：设置 B
  Future<void> _pickMedicine(
    BuildContext context,
    SafetyAssistController controller, {
    required int slot,
  }) async {
    final l10n = AppLocalizations.of(context);
    final item = await Navigator.of(context).push<MedicineItem>(
      MaterialPageRoute<MedicineItem>(
        builder: (_) => MedicinePickerPage(title: _pickerTitleText(l10n, slot)),
      ),
    );
    if (item == null || controller.isClosed) {
      return;
    }
    controller.setMedicine(slot: slot, item: item);
  }
}

/// 安全辅助页统一使用的白色 section 卡片。
///
/// 通过统一容器包裹不同区域，保持“模式/选药/结果/免责声明”视觉一致。
class _SectionCard extends StatelessWidget {
  /// 创建统一风格的白色 section 卡片。
  const _SectionCard({
    required this.title,
    required this.child,
    required this.accentColor,
    required this.secondaryColor,
    required this.ornamentKey,
    this.titleFontSize = 15.5,
  });

  /// 卡片标题。
  final String title;

  /// 卡片主体内容。
  final Widget child;

  final Color accentColor;
  final Color secondaryColor;
  final String ornamentKey;
  final double titleFontSize;

  /// 构建 section 卡片 UI。
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: accentColor,
      secondaryColor: secondaryColor,
      ornamentKey: ornamentKey,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _AiResultEntryCard extends StatelessWidget {
  const _AiResultEntryCard({
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

/// 安全辅助页底部免责声明卡片。
class _DisclaimerCard extends StatelessWidget {
  /// 创建安全辅助页免责声明卡片。
  const _DisclaimerCard();

  /// 构建免责声明卡片 UI。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SectionCard(
      title: l10n?.safetyDisclaimerTitle ?? 'Safety Notice',
      accentColor: Theme.of(context).colorScheme.tertiary,
      secondaryColor: Theme.of(context).colorScheme.secondary,
      ornamentKey: 'safety.disclaimer',
      child: Text(
        l10n?.safetyDisclaimerText ??
            'This feature uses AI-generated content for health education and reference only, '
                'and cannot replace a doctor\'s diagnosis or prescription. '
                'If you feel unwell or are taking medication, follow medical advice and consult professionals.',
        style: TextStyle(
          fontSize: 12.5,
          height: 1.55,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SafetyInfoChip extends StatelessWidget {
  const _SafetyInfoChip({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return TintedStatusChip(
      icon: icon,
      text: text,
      color: foregroundColor,
      backgroundColor: backgroundColor,
      showBorder: false,
      iconSize: 14,
      fontSize: 11.2,
      fontWeight: FontWeight.w700,
      textMaxLines: 2,
      textOverflow: TextOverflow.ellipsis,
      expandText: true,
      mainAxisSize: MainAxisSize.max,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
    );
  }
}
