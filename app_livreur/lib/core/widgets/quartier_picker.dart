import 'package:flutter/material.dart';
import '../../data/quartiers.dart';
import '../icons/app_icons.dart';
import '../theme/app_theme.dart';

/// Choix du quartier de base : sans localisation en direct, les clients voient
/// le livreur à une distance approximative calculée depuis ce quartier.
class QuartierPicker extends StatelessWidget {
  final String ville;
  final String? valeur;
  final ValueChanged<String?> onChanged;

  const QuartierPicker({super.key, required this.ville, required this.valeur, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final quartiers = quartiersParVille[ville];
    if (quartiers == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String?>(
          key: ValueKey(ville),
          initialValue: quartiers.contains(valeur) ? valeur : null,
          icon: const Icon(AppIcons.caretDownBold, size: 14, color: AppTheme.inkFaint),
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
          dropdownColor: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          decoration: const InputDecoration(prefixIcon: Icon(AppIcons.mapPin, color: AppTheme.primary, size: 20)),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('Aucun quartier')),
            for (final q in quartiers) DropdownMenuItem<String?>(value: q, child: Text(q)),
          ],
          onChanged: onChanged,
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Text(
            'Sans localisation, les clients vous voient à une distance approximative, calculée depuis ce quartier. Elle est signalée comme approximative.',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.4),
          ),
        ),
      ],
    );
  }
}
