import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/features/scan/presentation/providers/medicine_scan_provider.dart';
import 'package:luminous/features/scan/presentation/models/selected_scan_image.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/utils/media_access_error_text.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:permission_handler/permission_handler.dart';

export 'providers/medicine_scan_provider.dart';
export 'models/selected_scan_image.dart';

part 'pages/medicine_scan_page.dart';
part 'support/medicine_scan_image_flow.dart';
part 'support/medicine_scan_labels.dart';
part 'widgets/medicine_scan_actions.dart';
part 'widgets/medicine_scan_photo_area.dart';
part 'widgets/medicine_scan_result_section.dart';
part 'widgets/medicine_scan_sheet.dart';
