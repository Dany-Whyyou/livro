import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/livreur.dart';
import '../../providers/livreurs_provider.dart';
import '../../providers/signalements_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _routes = ['/livreurs', '/signalements', '/notifications', '/reglages'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final index = _routes.indexOf(location);

    // Comptes et photos en attente de validation
    final aValider = ref.watch(livreursProvider).where((l) => l.statut == StatutCompte.enAttente || l.photoAValider).length;
    final signalements = ref.watch(signalementsProvider).where((s) => s.aTraiter).length;

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.line)),
        ),
        child: NavigationBar(
          selectedIndex: index < 0 ? 0 : index,
          onDestinationSelected: (i) => context.go(_routes[i]),
          destinations: [
            NavigationDestination(
              icon: _AvecCompteur(compteur: aValider, child: const Icon(AppIcons.users)),
              selectedIcon: _AvecCompteur(compteur: aValider, child: const Icon(AppIcons.usersFill)),
              label: 'Livreurs',
            ),
            NavigationDestination(
              icon: _AvecCompteur(compteur: signalements, child: const Icon(AppIcons.flag)),
              selectedIcon: _AvecCompteur(compteur: signalements, child: const Icon(AppIcons.flagFill)),
              label: 'Signalements',
            ),
            const NavigationDestination(icon: Icon(AppIcons.bell), selectedIcon: Icon(AppIcons.bellFill), label: 'Notifications'),
            const NavigationDestination(icon: Icon(AppIcons.gearSix), selectedIcon: Icon(AppIcons.gearSixFill), label: 'Réglages'),
          ],
        ),
      ),
    );
  }
}

class _AvecCompteur extends StatelessWidget {
  final int compteur;
  final Widget child;
  const _AvecCompteur({required this.compteur, required this.child});

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: compteur > 0,
      label: Text('$compteur'),
      backgroundColor: AppTheme.danger,
      textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w700),
      child: child,
    );
  }
}
