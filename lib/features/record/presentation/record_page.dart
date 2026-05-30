import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/core/widgets/placeholder_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PageScaffoldShell(
      title: l10n?.tabRecord ?? 'Record',
      description:
          l10n?.recordPageDescription ??
          'Calendar, timeline, and multi-type daily records will grow here.',
      children: [
        PageSectionCard(
          title: l10n?.recordSectionTitle ?? 'Daily timeline',
          subtitle:
              l10n?.recordSectionSubtitle ??
              'The first rebuild step for Record is structure, not logic.',
          child: PlaceholderPage(label: '记录'),
        ),
      ],
    );
  }
}
