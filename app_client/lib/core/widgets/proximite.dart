import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/distance.dart';

/// Distance du livreur, ou un tiret si sa position est inconnue.
class DistanceTexte extends StatelessWidget {
  final double? distanceKm;
  final bool approximatif;
  const DistanceTexte({super.key, required this.distanceKm, this.approximatif = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      distanceKm == null ? '—' : '${approximatif ? '~\u00A0' : ''}${formatDistance(distanceKm!)}',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: distanceKm == null ? AppTheme.inkFaint : (approximatif ? AppTheme.inkMuted : AppTheme.ink),
        letterSpacing: -0.3,
      ),
    );
  }
}

/// Niveau de proximité. Approximatif (quartier de base) : pastille en contour seulement,
/// pour ne pas la confondre avec une position en direct.
class ProximitePill extends StatelessWidget {
  final Proximite proximite;
  final bool approximatif;
  const ProximitePill({super.key, required this.proximite, this.approximatif = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(approximatif ? 7 : 8, approximatif ? 3 : 4, approximatif ? 9 : 10, approximatif ? 3 : 4),
      decoration: BoxDecoration(
        color: approximatif ? AppTheme.surface : proximite.fond,
        borderRadius: BorderRadius.circular(20),
        border: approximatif ? Border.all(color: proximite.couleur.withValues(alpha: 0.6)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: approximatif ? Colors.transparent : proximite.couleur,
              shape: BoxShape.circle,
              border: approximatif ? Border.all(color: proximite.couleur, width: 1.5) : null,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              proximite.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: proximite == Proximite.inconnue ? AppTheme.inkMuted : proximite.couleur,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Légende des trois niveaux, avec leurs seuils.
class ProximiteLegende extends StatelessWidget {
  final bool avecApproximatif;
  const ProximiteLegende({super.key, this.avecApproximatif = false});

  @override
  Widget build(BuildContext context) {
    String km(double v) => formatDistance(v).replaceAll(',0', '');
    final items = [
      (Proximite.proche, '< ${km(seuilProcheKm)}'),
      (Proximite.parages, '${km(seuilProcheKm)} à ${km(seuilParagesKm)}'),
      (Proximite.loin, '> ${km(seuilParagesKm)}'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            for (final (p, seuil) in items)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: p.couleur, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${p.label} ($seuil)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (avecApproximatif) ...[
          const SizedBox(height: 6),
          const Text(
            'Pastille en contour et « ~ » : position approximative, d\'après le quartier de base du livreur (pas de localisation en direct)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkMuted, height: 1.4),
          ),
        ],
      ],
    );
  }
}
