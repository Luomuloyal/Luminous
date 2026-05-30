import 'package:go_router/go_router.dart';
import 'package:luminous/features/shell/presentation/shell_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [GoRoute(path: '/', builder: (context, state) => const ShellPage())],
);
