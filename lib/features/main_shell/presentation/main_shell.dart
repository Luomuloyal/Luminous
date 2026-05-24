import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_ornaments.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/core/theme/ornaments/ornament_provider.dart';
import 'package:luminous/features/settings/presentation/settings.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Album/album.dart';
import 'package:luminous/pages/Drug/drug.dart';
import 'package:luminous/pages/Home/home.dart';
import 'package:luminous/pages/Mine/mine.dart';
import 'package:luminous/pages/Safety/safety_assist.dart';
import 'package:luminous/pages/Search/search.dart';
import 'package:luminous/pages/Settings/profile_settings.dart';

import 'controllers/main_controller.dart';

export 'controllers/main_controller.dart';

part 'pages/main_page.dart';
part 'support/main_bottom_bar_ornaments.dart';
part 'support/main_tab_item.dart';
part 'widgets/main_bottom_bar.dart';
