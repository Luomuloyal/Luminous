import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/core/widgets/placeholder_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PageScaffoldShell(
      title: l10n?.tabMine ?? 'Mine',
      description:
          l10n?.minePageDescription ??
          'Profile, goals, privacy, and account settings will be rebuilt here.',
      children: [
        PageSectionCard(
          title: l10n?.mineSectionTitle ?? 'Personal workspace',
          subtitle:
              l10n?.mineSectionSubtitle ??
              'Identity, goals, and privacy controls will share one calm surface here.',
          child: PlaceholderPage(label: '我的'),
        ),
      ],
    );
  }
}
