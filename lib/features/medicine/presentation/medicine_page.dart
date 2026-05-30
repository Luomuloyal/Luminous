import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/core/widgets/placeholder_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicinePage extends StatelessWidget {
  const MedicinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PageScaffoldShell(
      title: l10n?.tabMedicine ?? 'Medicine',
      description:
          l10n?.medicinePageDescription ??
          'Today plans, adherence, refill status, and safety will anchor this tab.',
      children: [
        PageSectionCard(
          title: l10n?.medicineSectionTitle ?? 'Medication workspace',
          subtitle:
              l10n?.medicineSectionSubtitle ??
              'This section will host the rebuilt medication flow on top of Lucent.',
          child: PlaceholderPage(label: '用药'),
        ),
      ],
    );
  }
}
