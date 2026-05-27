import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/drug/presentation/drug.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/shared/models/medicine.dart';
import 'package:luminous/features/search/presentation/models/search.dart';

import 'providers/search_provider.dart';
import 'widgets/search_cards.dart';

export 'providers/search_provider.dart';

part 'pages/search_page.dart';
part 'support/search_prompt_slivers.dart';
part 'support/search_state_slivers.dart';
part 'widgets/search_tip_row.dart';
