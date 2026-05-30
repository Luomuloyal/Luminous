import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/core/widgets/placeholder_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PageScaffoldShell(
      title: l10n?.tabMore ?? 'More',
      description:
          l10n?.morePageDescription ??
          'Utility tools, emergency help, device management, and lower-frequency features belong here.',
      children: [
        PageSectionCard(
          title: l10n?.moreSectionTitle ?? 'Utility hub',
          subtitle:
              l10n?.moreSectionSubtitle ??
              'This tab will gather the lower-frequency but still important workflows.',
          child: PlaceholderPage(label: '更多'),
        ),
      ],
    );
  }
}
