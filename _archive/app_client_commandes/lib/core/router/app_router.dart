import 'package:go_router/go_router.dart';
import '../../data/models/course.dart';
import '../../data/models/livreur.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/welcome/welcome_screen.dart';
import '../../screens/auth/phone_screen.dart';
import '../../screens/auth/otp_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/livreurs/livreurs_screen.dart';
import '../../screens/livreurs/detail_livreur_screen.dart';
import '../../screens/suivi/suivi_screen.dart';
import '../../screens/historique/historique_screen.dart';
import '../../screens/notation/notation_livreur_screen.dart';
import '../../screens/shell/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/auth/phone', builder: (_, __) => const ClientPhoneScreen()),
    GoRoute(path: '/auth/otp', builder: (_, state) => ClientOtpScreen(telephone: state.extra as String)),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/historique', builder: (_, __) => const HistoriqueScreen()),
      ],
    ),
    GoRoute(
      path: '/livreurs',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LivreursScreen(depart: extra['depart'] as String, destination: extra['destination'] as String, poids: extra['poids'] as double);
      },
    ),
    GoRoute(path: '/livreur/:id', builder: (_, state) => DetailLivreurScreen(livreur: state.extra as Livreur)),
    GoRoute(path: '/suivi', builder: (_, __) => const SuiviScreen()),
    GoRoute(path: '/notation-livreur', builder: (_, state) => NotationLivreurScreen(course: state.extra as Course)),
  ],
);
