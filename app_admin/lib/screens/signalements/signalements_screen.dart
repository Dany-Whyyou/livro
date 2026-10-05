import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/choix.dart';
import '../../data/models/livreur.dart';
import '../../data/models/signalement.dart';
import '../../providers/livreurs_provider.dart';
import '../../providers/signalements_provider.dart';

/// Signalements de livreurs envoyés par les clients depuis Livro.
class SignalementsScreen extends ConsumerWidget {
  const SignalementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aTraiter = ref.watch(signalementsATraiterProvider);
    final signalements = ref.watch(signalementsFiltresProvider);
    final livreurs = ref.watch(livreursProvider);
    final nbATraiter = ref.watch(signalementsProvider).where((s) => s.aTraiter).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Signalements')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          ChoixSegments<bool>(
            options: [(true, 'À traiter ($nbATraiter)'), (false, 'Traités')],
            valeur: aTraiter,
            onChanged: (v) => ref.read(signalementsATraiterProvider.notifier).state = v,
          ),
          const SizedBox(height: 20),
          if (signalements.isEmpty)
            _Vide(aTraiter: aTraiter)
          else
            for (final signalement in signalements)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SignalementCard(
                  signalement: signalement,
                  livreur: livreurPourNumero(livreurs, signalement.telephoneLivreur),
                  onTap: () => context.push('/signalement/${signalement.id}'),
                ),
              ),
        ],
      ),
    );
  }
}

/// Le livreur inscrit qui porte ce numéro, s'il existe.
Livreur? livreurPourNumero(List<Livreur> livreurs, String telephone) {
  for (final l in livreurs) {
    if (l.telephone == telephone) return l;
  }
  return null;
}

class StatutSignalementPill extends StatelessWidget {
  final StatutSignalement statut;
  const StatutSignalementPill({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    return switch (statut) {
      StatutSignalement.nouveau => const StatusPill(label: 'À traiter', color: AppTheme.danger, background: AppTheme.dangerSoft),
      StatutSignalement.traite => const StatusPill(label: 'Traité', color: AppTheme.success, background: AppTheme.successSoft),
      StatutSignalement.classe => const StatusPill(label: 'Classé sans suite', color: AppTheme.inkMuted, background: Color(0xFFEEECE7)),
    };
  }
}

class _SignalementCard extends StatelessWidget {
  final Signalement signalement;
  final Livreur? livreur;
  final VoidCallback onTap;

  const _SignalementCard({required this.signalement, required this.livreur, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  livreur?.nom ?? 'Numéro non inscrit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
                ),
              ),
              const SizedBox(width: 10),
              StatutSignalementPill(statut: signalement.statut),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${formatTelephone(signalement.telephoneLivreur)} · ${formatDate(signalement.creeLe)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
          ),
          const SizedBox(height: 10),
          Text(
            signalement.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.ink, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _Vide extends StatelessWidget {
  final bool aTraiter;
  const _Vide({required this.aTraiter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const IconBadge(icon: AppIcons.flag, size: 64, color: AppTheme.inkFaint, background: Color(0xFFEEECE7)),
          const SizedBox(height: 16),
          Text(
            aTraiter ? 'Aucun signalement à traiter' : 'Aucun signalement traité',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink),
          ),
        ],
      ),
    );
  }
}
