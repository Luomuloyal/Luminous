import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/core/theme/ornaments/ornament_provider.dart';
import 'package:luminous/features/auth/providers/auth_service_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/providers/locale_provider.dart';
import 'package:luminous/core/providers/theme_provider.dart';

export 'pages/profile_settings_page.dart';
export 'providers/profile_settings_provider.dart';

part 'pages/settings_pages.dart';
part 'support/settings_labels.dart';
part 'widgets/language_widgets.dart';
part 'widgets/ornament_preview_card.dart';
part 'widgets/settings_section_widgets.dart';
part 'widgets/settings_hero_card.dart';
part 'widgets/theme_style_card.dart';
part 'widgets/theme_widgets.dart';
