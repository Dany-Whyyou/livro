import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/localisation_provider.dart';
import '../icons/app_icons.dart';
import '../theme/app_theme.dart';

/// Interrupteur de partage de position : demande l'accès au GPS, puis montre ce qui se passe
/// (recherche, envoi, pause quand le livreur est indisponible, accès refusé, GPS coupé).
class LocalisationCard extends ConsumerWidget {
  const LocalisationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(localisationActiveProvider);
    final suivi = ref.watch(suiviPositionProvider);
    final notifier = ref.read(suiviPositionProvider.notifier);
    final probleme = switch (suivi.statut) {
      StatutSuivi.permissionRefusee || StatutSuivi.permissionBloquee || StatutSuivi.gpsCoupe => true,
      _ => false,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color: probleme ? AppTheme.danger : (active ? AppTheme.primary : AppTheme.line),
          width: active || probleme ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: active ? AppTheme.primary : AppTheme.primarySoft, borderRadius: BorderRadius.circular(12)),
                child: Icon(active ? AppIcons.mapPinFill : AppIcons.mapPin, size: 20, color: active ? Colors.white : AppTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      active ? 'Localisation activée' : 'Localisation désactivée',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 4),
                    _Detail(suivi: suivi),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: active,
                onChanged: (v) => v ? notifier.activer() : notifier.desactiver(),
              ),
            ],
          ),
          if (probleme) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: suivi.statut == StatutSuivi.permissionRefusee
                  ? TextButton(onPressed: notifier.activer, child: const Text('Réessayer'))
                  : TextButton(
                      onPressed: notifier.ouvrirReglages,
                      child: Text(suivi.statut == StatutSuivi.gpsCoupe ? 'Activer la localisation du téléphone' : 'Ouvrir les réglages'),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final SuiviPosition suivi;
  const _Detail({required this.suivi});

  @override
  Widget build(BuildContext context) {
    const normal = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.45);
    const erreur = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.danger, height: 1.45);
    return switch (suivi.statut) {
      StatutSuivi.arrete => const Text('Activez-la pour apparaître en tête chez les clients proches de vous.', style: normal),
      StatutSuivi.recherche => const Text('Recherche de votre position…', style: normal),
      StatutSuivi.enPause => const Text('En pause : vous êtes indisponible. Elle reprendra quand vous serez disponible.', style: normal),
      StatutSuivi.permissionRefusee => const Text('Autorisez l\'accès à votre position pour l\'activer.', style: erreur),
      StatutSuivi.permissionBloquee =>
        const Text('L\'accès à la position est bloqué pour Livro Pro. Autorisez-le dans les réglages du téléphone.', style: erreur),
      StatutSuivi.gpsCoupe => const Text('La localisation de votre téléphone est coupée.', style: erreur),
      StatutSuivi.actif => StreamBuilder<void>(
          // Rafraîchit « il y a X min »
          stream: Stream<void>.periodic(const Duration(seconds: 30)),
          builder: (context, _) => Text(
            'Les clients proches vous voient en premier. Position envoyée ${_ilYa(suivi.dernierEnvoi)}.',
            style: normal,
          ),
        ),
    };
  }

  static String _ilYa(DateTime? date) {
    if (date == null) return 'à l\'instant';
    final minutes = DateTime.now().difference(date).inMinutes;
    if (minutes < 1) return 'à l\'instant';
    return 'il y a $minutes min';
  }
}
