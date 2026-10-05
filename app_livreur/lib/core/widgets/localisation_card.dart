import 'package:flutter/material.dart';
import '../icons/app_icons.dart';
import '../theme/app_theme.dart';

/// Interrupteur de partage de position, avec l'explication de ce que ça change pour le livreur.
class LocalisationCard extends StatelessWidget {
  final bool active;
  final ValueChanged<bool> onChanged;

  const LocalisationCard({super.key, required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: active ? AppTheme.primary : AppTheme.line, width: active ? 1.5 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: active ? AppTheme.primary : AppTheme.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              active ? AppIcons.mapPinFill : AppIcons.mapPin,
              size: 20,
              color: active ? Colors.white : AppTheme.primary,
            ),
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
                Text(
                  active
                      ? 'Les clients proches de vous vous voient en premier et peuvent vous appeler.'
                      : 'Activez-la pour apparaître en tête chez les clients proches de vous.',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: active, onChanged: onChanged),
        ],
      ),
    );
  }
}
