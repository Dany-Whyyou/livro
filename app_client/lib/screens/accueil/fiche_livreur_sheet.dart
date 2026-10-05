import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/appel_provider.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/livreur_avatar.dart';
import '../../core/utils/distance.dart';
import '../../data/models/livreur.dart';

void afficherFicheLivreur(BuildContext context, LivreurProche item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FicheLivreurSheet(item: item),
  );
}

class _FicheLivreurSheet extends ConsumerWidget {
  final LivreurProche item;
  const _FicheLivreurSheet({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livreur = item.livreur;
    final proximite = item.proximite;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppTheme.line, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                LivreurAvatar(nom: livreur.nom, photo: livreur.photo, size: 56, fonce: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        livreur.nom,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.4, height: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(livreur.vehicule.icon, size: 16, color: AppTheme.inkMuted),
                          const SizedBox(width: 6),
                          Text(
                            '${livreur.vehicule.label} · ${livreur.ville}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (item.distanceKm != null) ...[
              const SectionTitle('Distance'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: item.approximatif ? AppTheme.surface : proximite.fond,
                  borderRadius: BorderRadius.circular(14),
                  border: item.approximatif ? Border.all(color: proximite.couleur.withValues(alpha: 0.6)) : null,
                ),
                child: Row(
                  children: [
                    Icon(item.approximatif ? AppIcons.mapPin : AppIcons.mapPinFill, size: 22, color: proximite.couleur),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.approximatif ? 'Environ ${formatDistance(item.distanceKm!)} de vous' : 'À ${formatDistance(item.distanceKm!)} de vous',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.3),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            proximite.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: proximite.couleur,
                            ),
                          ),
                          if (item.approximatif) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Ce livreur n\'a pas de localisation en direct. Distance calculée depuis son quartier de base : ${livreur.quartier}.',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.4),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const SectionTitle('Numéro'),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: SelectableText(
                  formatTelephone(livreur.telephone),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => lancerAppel(context, ref, livreur),
              icon: const Icon(AppIcons.phoneFill, size: 20),
              label: const Text('Appeler'),
            ),
            if (livreur.whatsapp) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => lancerAppel(context, ref, livreur, whatsapp: true),
                icon: const Icon(AppIcons.whatsappLogo, size: 20),
                label: const Text('Appeler sur WhatsApp'),
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.whatsapp),
              ),
            ],
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Le prix se règle directement avec le livreur.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkFaint),
              ),
            ),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  router.push('/signaler', extra: livreur.telephone);
                },
                icon: const Icon(AppIcons.flag, size: 16),
                label: const Text('Signaler ce livreur'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
