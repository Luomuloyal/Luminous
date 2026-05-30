import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/main_shell/presentation/main_shell.dart';
import 'package:luminous/utils/loading_utils.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: LoadingUtils.navigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [GoRoute(path: '/', builder: (context, state) => const MainPage())],
  );
});
