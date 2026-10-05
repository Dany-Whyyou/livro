import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rangée de pastilles à choix unique, défilable horizontalement.
class ChoixPastilles<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T valeur;
  final ValueChanged<T> onChanged;

  const ChoixPastilles({super.key, required this.options, required this.valeur, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final (option, label) in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 40,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: option == valeur ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: option == valeur ? AppTheme.primary : AppTheme.line),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: option == valeur ? Colors.white : AppTheme.inkMuted),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Sélecteur segmenté à largeur égale (ex. mode de disponibilité).
class ChoixSegments<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T valeur;
  final ValueChanged<T> onChanged;

  const ChoixSegments({super.key, required this.options, required this.valeur, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          for (final (option, label) in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: option == valeur ? AppTheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: option == valeur ? Colors.white : AppTheme.inkMuted),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
