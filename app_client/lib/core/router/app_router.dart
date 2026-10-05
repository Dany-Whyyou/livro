import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/accueil/accueil_screen.dart';
import '../../screens/signalement/signalement_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/accueil', builder: (_, __) => const AccueilScreen()),
    // extra : numéro du livreur à préremplir (optionnel)
    GoRoute(path: '/signaler', builder: (_, state) => SignalementScreen(telephone: state.extra as String?)),
  ],
);
