import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../providers/admins_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/villes_provider.dart';
import '../../services/notifications.dart';

class ReglagesScreen extends ConsumerWidget {
  const ReglagesScreen({super.key});

  void _deconnecter(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Vous devrez saisir un nouveau code pour revenir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Notifications.oublier();
              ref.read(authProvider.notifier).logout();
              context.go('/phone');
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final villes = ref.watch(villesProvider).length;
    final admins = ref.watch(adminsProvider).length;
    final telephone = ref.watch(authProvider).telephone;

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const SectionTitle('Plateforme'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _Ligne(icon: AppIcons.buildings, label: 'Villes', detail: '$villes', onTap: () => context.push('/villes')),
                const Divider(),
                _Ligne(icon: AppIcons.shieldCheck, label: 'Administrateurs', detail: '$admins', onTap: () => context.push('/admins')),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const SectionTitle('Mon compte'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                if (telephone != null) ...[_Ligne(icon: AppIcons.phone, label: 'Connecté avec', detail: formatTelephone(telephone)), const Divider()],
                _Ligne(icon: AppIcons.signOut, label: 'Se déconnecter', color: AppTheme.danger, onTap: () => _deconnecter(context, ref)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? detail;
  final Color color;
  final VoidCallback? onTap;

  const _Ligne({required this.icon, required this.label, this.detail, this.color = AppTheme.ink, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
              ),
            ),
            if (detail != null)
              Text(
                detail!,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
              ),
            if (onTap != null && color == AppTheme.ink) ...[const SizedBox(width: 8), const Icon(AppIcons.caretRight, size: 16, color: AppTheme.inkFaint)],
          ],
        ),
      ),
    );
  }
}
