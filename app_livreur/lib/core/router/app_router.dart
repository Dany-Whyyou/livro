import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/phone_screen.dart';
import '../../screens/auth/otp_screen.dart';
import '../../screens/accueil/accueil_screen.dart';
import '../../screens/inscription/inscription_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/phone', builder: (_, __) => const PhoneScreen()),
    GoRoute(path: '/otp', builder: (context, state) => OtpScreen(telephone: state.extra as String)),
    GoRoute(path: '/inscription', builder: (_, __) => const InscriptionScreen()),
    GoRoute(path: '/accueil', builder: (_, __) => const AccueilScreen()),
  ],
);
