import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/agent_viewer/presentation/pages/agent_viewer_page.dart';
import '../features/printer_setup/presentation/pages/printer_setup_page.dart';
import '../features/server_setup/presentation/pages/server_setup_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const setup = '/setup';
  static const pos = '/pos';
  static const printerSetup = '/printer-setup';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.setup,
        builder: (context, state) => const ServerSetupPage(),
      ),
      GoRoute(
        path: AppRoutes.pos,
        builder: (context, state) => const AgentViewerPage(),
      ),
      GoRoute(
        path: AppRoutes.printerSetup,
        builder: (context, state) => const PrinterSetupPage(),
      ),
    ],
  );
});
