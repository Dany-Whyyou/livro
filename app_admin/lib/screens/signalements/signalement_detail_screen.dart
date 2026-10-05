import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/appel.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/livreur_avatar.dart';
import '../../data/models/livreur.dart';
import '../../data/models/signalement.dart';
import '../../providers/livreurs_provider.dart';
import '../../providers/signalements_provider.dart';
import '../livreurs/livreurs_screen.dart';
import 'signalements_screen.dart';

class SignalementDetailScreen extends ConsumerWidget {
  final String signalementId;
  const SignalementDetailScreen({super.key, required this.signalementId});

  void _cloturer(BuildContext context, WidgetRef ref, StatutSignalement statut) {
    ref.read(signalementsProvider.notifier).changerStatut(signalementId, statut);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(statut == StatutSignalement.traite ? 'Signalement marqué comme traité' : 'Signalement classé sans suite')));
    context.pop();
  }

  void _suspendre(BuildContext context, WidgetRef ref, Livreur livreur) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Suspendre ce livreur'),
        content: Text('${livreur.nom} ne sera plus affiché aux clients tant que vous ne le réactivez pas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(livreursProvider.notifier).modifier(livreur.copyWith(suspendu: true));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Livreur suspendu')));
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Suspendre'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signalement = ref.watch(signalementsProvider.select((liste) => liste.where((s) => s.id == signalementId).firstOrNull));
    final appBar = AppBar(
      title: const Text('Signalement'),
      leading: IconButton(onPressed: () => context.pop(), icon: const Icon(AppIcons.arrowLeft, size: 22)),
    );
    if (signalement == null) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: Text('Signalement introuvable')),
      );
    }

    final livreur = livreurPourNumero(ref.watch(livreursProvider), signalement.telephoneLivreur);

    return Scaffold(
      appBar: appBar,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Reçu le ${formatDate(signalement.creeLe)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
                ),
              ),
              StatutSignalementPill(statut: signalement.statut),
            ],
          ),
          const SizedBox(height: 20),
          const SectionTitle('Message du client'),
          AppCard(
            child: Text(
              signalement.message,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.ink, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Livreur signalé'),
          if (livreur != null)
            AppCard(
              onTap: () => context.push('/livreur/${livreur.id}'),
              child: Row(
                children: [
                  LivreurAvatar(livreur: livreur),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          livreur.nom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formatTelephone(livreur.telephone),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  StatutLivreurPill(livreur: livreur, maintenant: DateTime.now()),
                ],
              ),
            )
          else
            AppCard(
              child: Row(
                children: [
                  const IconBadge(icon: AppIcons.warning, color: AppTheme.secondaryInk, background: AppTheme.primarySoft),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatTelephone(signalement.telephoneLivreur),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Ce numéro n\'appartient à aucun livreur inscrit.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          const SectionTitle('Actions'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _Action(icon: AppIcons.phone, label: 'Appeler ce numéro', onTap: () => appeler(context, signalement.telephoneLivreur)),
                if (livreur != null && !livreur.suspendu) ...[
                  const Divider(),
                  _Action(icon: AppIcons.prohibit, label: 'Suspendre le livreur', color: AppTheme.danger, onTap: () => _suspendre(context, ref, livreur)),
                ],
                if (!signalement.aTraiter) ...[
                  const Divider(),
                  _Action(
                    icon: AppIcons.arrowClockwiseBold,
                    label: 'Rouvrir le signalement',
                    onTap: () => ref.read(signalementsProvider.notifier).changerStatut(signalementId, StatutSignalement.nouveau),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: signalement.aTraiter
          ? Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(top: BorderSide(color: AppTheme.line)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(onPressed: () => _cloturer(context, ref, StatutSignalement.classe), child: const Text('Classer')),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(onPressed: () => _cloturer(context, ref, StatutSignalement.traite), child: const Text('Marquer comme traité')),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap, this.color = AppTheme.ink});

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
          ],
        ),
      ),
    );
  }
}
