import 'package:flutter/material.dart';

import '../icons/app_icons.dart';
import '../theme/app_theme.dart';

const _vehicules = [('moto', 'Moto', AppIcons.motorcycle), ('velo', 'Vélo', AppIcons.bicycle), ('voiture', 'Voiture', AppIcons.car)];

IconData vehiculeIcon(String vehicule) => _vehicules.firstWhere((v) => v.$1 == vehicule, orElse: () => _vehicules.last).$3;

String vehiculeLabel(String vehicule) => _vehicules.firstWhere((v) => v.$1 == vehicule, orElse: () => _vehicules.last).$2;

class VehiculeSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const VehiculeSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _vehicules.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _Option(icon: _vehicules[i].$3, label: _vehicules[i].$2, selected: value == _vehicules[i].$1, onTap: () => onChanged(_vehicules[i].$1)),
          ),
        ],
      ],
    );
  }
}

class _Option extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Option({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primarySoft : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.line, width: selected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: selected ? AppTheme.primary : AppTheme.inkMuted),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? AppTheme.primary : AppTheme.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
