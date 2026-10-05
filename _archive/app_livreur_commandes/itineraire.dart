import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Trajet retrait → livraison, relié par une ligne verticale.
class Itineraire extends StatelessWidget {
  final String depart;
  final String destination;

  const Itineraire({super.key, required this.depart, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 12,
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    const _Marqueur(color: AppTheme.primary, plein: false),
                    Expanded(child: Container(width: 1.5, color: AppTheme.line)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _Point(label: 'Retrait', adresse: depart),
                ),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 12,
              child: Column(
                children: [
                  Container(width: 1.5, height: 4, color: AppTheme.line),
                  const _Marqueur(color: AppTheme.secondary, plein: true),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _Point(label: 'Livraison', adresse: destination)),
          ],
        ),
      ],
    );
  }
}

class _Marqueur extends StatelessWidget {
  final Color color;
  final bool plein;
  const _Marqueur({required this.color, required this.plein});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: plein ? color : AppTheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  final String label;
  final String adresse;
  const _Point({required this.label, required this.adresse});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkFaint, height: 1.2)),
        const SizedBox(height: 3),
        Text(
          adresse,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.ink, height: 1.3),
        ),
      ],
    );
  }
}
