import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    int selectedIndex = 0;
    if (location == '/historique') selectedIndex = 1;
    if (location == '/profil') selectedIndex = 2;

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.line))),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (i) {
            if (i == 0) context.go('/dashboard');
            if (i == 1) context.go('/historique');
            if (i == 2) context.go('/profil');
          },
          destinations: const [
            NavigationDestination(icon: Icon(AppIcons.house), selectedIcon: Icon(AppIcons.houseFill), label: 'Accueil'),
            NavigationDestination(icon: Icon(AppIcons.clockCounterClockwise), selectedIcon: Icon(AppIcons.clockCounterClockwiseBold), label: 'Historique'),
            NavigationDestination(icon: Icon(AppIcons.user), selectedIcon: Icon(AppIcons.userFill), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
