import 'package:go_router/go_router.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/phone_screen.dart';
import '../../screens/auth/otp_screen.dart';
import '../../screens/shell/main_shell.dart';
import '../../screens/livreurs/livreurs_screen.dart';
import '../../screens/livreurs/livreur_form_screen.dart';
import '../../screens/signalements/signalements_screen.dart';
import '../../screens/signalements/signalement_detail_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/reglages/reglages_screen.dart';
import '../../screens/villes/villes_screen.dart';
import '../../screens/admins/admins_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/phone', builder: (_, _) => const PhoneScreen()),
    GoRoute(
      path: '/otp',
      builder: (context, state) => OtpScreen(telephone: state.extra as String),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/livreurs', builder: (_, _) => const LivreursScreen()),
        GoRoute(path: '/signalements', builder: (_, _) => const SignalementsScreen()),
        GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
        GoRoute(path: '/reglages', builder: (_, _) => const ReglagesScreen()),
      ],
    ),
    // Écrans plein écran, au-dessus de la barre d'onglets
    GoRoute(path: '/livreur/nouveau', builder: (_, _) => const LivreurFormScreen()),
    GoRoute(
      path: '/livreur/:id',
      builder: (_, state) => LivreurFormScreen(livreurId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/signalement/:id',
      builder: (_, state) => SignalementDetailScreen(signalementId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/villes', builder: (_, _) => const VillesScreen()),
    GoRoute(path: '/admins', builder: (_, _) => const AdminsScreen()),
  ],
);
