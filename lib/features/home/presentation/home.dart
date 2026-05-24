import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/responsive_quick_grid.dart';
import 'package:luminous/components/shared_quick_entry_card.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/components/tinted_status_chip.dart';
import 'package:luminous/features/scan/presentation/scan.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/pages/Picker/medicine_picker.dart';
import 'package:luminous/stores/reminder_local_gateway.dart';
import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/home.dart';
import 'package:luminous/viewmodels/medicine.dart';

import 'controllers/home_controller.dart';

export 'controllers/home_controller.dart';

part 'pages/home_page.dart';
part 'support/home_demo_data.dart';
part 'support/home_health_tips_sheet.dart';
part 'widgets/home_check_in_record_section.dart';
part 'widgets/home_feature_section.dart';
part 'widgets/home_reminder_section.dart';
part 'widgets/home_shared_widgets.dart';
part 'widgets/home_top_section.dart';
