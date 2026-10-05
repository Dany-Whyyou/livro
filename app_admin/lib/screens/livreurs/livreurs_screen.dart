import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/choix.dart';
import '../../core/widgets/livreur_avatar.dart';
import '../../core/widgets/vehicule.dart';
import '../../data/models/livreur.dart';
import '../../providers/livreurs_provider.dart';

class LivreursScreen extends ConsumerWidget {
  const LivreursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tous = ref.watch(livreursProvider);
    final livreurs = ref.watch(livreursFiltresProvider);
    final filtre = ref.watch(filtreStatutProvider);
    final maintenant = DateTime.now();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/livreur/nouveau'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(AppIcons.plusBold, size: 18),
        label: const Text(
          'Ajouter un livreur',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
          children: [
            Row(
              children: [
                const BrandMark(size: 36),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Livro Admin',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _Stat(label: 'Inscrits', valeur: tous.length),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Stat(label: 'Disponibles', valeur: tous.where((l) => l.estDisponible(maintenant)).length),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Stat(label: 'À valider', valeur: tous.where((l) => l.statut == StatutCompte.enAttente).length),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (v) => ref.read(rechercheProvider.notifier).state = v,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.ink),
              decoration: const InputDecoration(
                hintText: 'Rechercher un nom ou un numéro',
                prefixIcon: Icon(AppIcons.magnifyingGlass, size: 20, color: AppTheme.inkMuted),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            ChoixPastilles<FiltreStatut>(
              options: const [
                (FiltreStatut.tous, 'Tous'),
                (FiltreStatut.aValider, 'À valider'),
                (FiltreStatut.photosAValider, 'Photos à valider'),
                (FiltreStatut.injoignables, 'Injoignables'),
                (FiltreStatut.disponibles, 'Disponibles'),
                (FiltreStatut.indisponibles, 'Indisponibles'),
                (FiltreStatut.suspendus, 'Suspendus'),
                (FiltreStatut.sansSmartphone, 'Sans smartphone'),
              ],
              valeur: filtre,
              onChanged: (f) => ref.read(filtreStatutProvider.notifier).state = f,
            ),
            const SizedBox(height: 24),
            SectionTitle(livreurs.length > 1 ? '${livreurs.length} livreurs' : '${livreurs.length} livreur'),
            if (livreurs.isEmpty)
              const _Vide()
            else
              for (final livreur in livreurs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _LivreurCard(livreur: livreur, maintenant: maintenant, onTap: () => context.push('/livreur/${livreur.id}')),
                ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int valeur;
  const _Stat({required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$valeur',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.6, height: 1.1),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
          ),
        ],
      ),
    );
  }
}

/// Pastille d'état d'un livreur : à valider, refusé, suspendu, disponible ou indisponible (avec mention du mode auto).
class StatutLivreurPill extends StatelessWidget {
  final Livreur livreur;
  final DateTime maintenant;
  const StatutLivreurPill({super.key, required this.livreur, required this.maintenant});

  @override
  Widget build(BuildContext context) {
    if (livreur.statut == StatutCompte.enAttente) {
      return const StatusPill(label: 'À valider', color: AppTheme.secondaryInk, background: AppTheme.primarySoft);
    }
    if (livreur.statut == StatutCompte.refuse) {
      return const StatusPill(label: 'Refusé', color: AppTheme.danger, background: AppTheme.dangerSoft);
    }
    if (livreur.suspendu) {
      return const StatusPill(label: 'Suspendu', color: AppTheme.danger, background: AppTheme.dangerSoft);
    }
    final auto = livreur.mode == ModeDisponibilite.auto ? ' · auto' : '';
    if (livreur.estDisponible(maintenant)) {
      return StatusPill(label: 'Disponible$auto', color: AppTheme.success, background: AppTheme.successSoft);
    }
    return StatusPill(label: 'Indisponible$auto', color: AppTheme.inkMuted, background: const Color(0xFFEEECE7));
  }
}

class _LivreurCard extends StatelessWidget {
  final Livreur livreur;
  final DateTime maintenant;
  final VoidCallback onTap;

  const _LivreurCard({required this.livreur, required this.maintenant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          LivreurAvatar(livreur: livreur),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        livreur.nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
                      ),
                    ),
                    if (livreur.localisationActive) ...[
                      const SizedBox(width: 6),
                      const Tooltip(
                        message: 'Localisation activée',
                        child: Icon(AppIcons.mapPinFill, size: 16, color: AppTheme.success),
                      ),
                    ],
                    if (livreur.origine == OrigineFiche.admin) ...[
                      const SizedBox(width: 6),
                      const Tooltip(
                        message: 'Sans smartphone — fiche gérée par l\'admin',
                        child: Icon(AppIcons.deviceMobileSlash, size: 16, color: AppTheme.inkFaint),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  formatTelephone(livreur.telephone),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(vehiculeIcon(livreur.vehicule), size: 16, color: AppTheme.inkMuted),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${vehiculeLabel(livreur.vehicule)} · ${livreur.ville}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.inkMuted),
                      ),
                    ),
                  ],
                ),
                if (livreur.nonReponses7j > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(AppIcons.warning, size: 14, color: AppTheme.danger),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          livreur.nonReponses7j > 1 ? '${livreur.nonReponses7j} appels sans réponse (7\u00A0j)' : '1 appel sans réponse (7\u00A0j)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.danger),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          StatutLivreurPill(livreur: livreur, maintenant: maintenant),
        ],
      ),
    );
  }
}

class _Vide extends StatelessWidget {
  const _Vide();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          IconBadge(icon: AppIcons.users, size: 64, color: AppTheme.inkFaint, background: Color(0xFFEEECE7)),
          SizedBox(height: 16),
          Text(
            'Aucun livreur trouvé',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink),
          ),
          SizedBox(height: 6),
          Text(
            'Modifiez la recherche ou le filtre, ou ajoutez un livreur.',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
