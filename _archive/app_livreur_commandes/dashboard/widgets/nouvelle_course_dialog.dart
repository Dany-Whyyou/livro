import 'package:flutter/material.dart';
import '../../../data/models/course.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/itineraire.dart';

class NouvelleCourseSheet extends StatelessWidget {
  final Course course;
  final VoidCallback onAccepter;
  final VoidCallback onRefuser;

  const NouvelleCourseSheet({
    super.key,
    required this.course,
    required this.onAccepter,
    required this.onRefuser,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
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
            const Text(
              'Nouvelle demande',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.5),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                InitialesAvatar(texte: initiales(course.clientNom), size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Client', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkFaint)),
                      const SizedBox(height: 2),
                      Text(
                        course.clientNom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
            Itineraire(depart: course.adresseDepart, destination: course.adresseDestination),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Expanded(child: _Chiffre(label: 'Poids', value: formatPoids(course.poids))),
                  Container(width: 1, height: 36, color: AppTheme.line),
                  const SizedBox(width: 16),
                  Expanded(child: _Chiffre(label: 'Prix proposé', value: formatFcfa(course.prix), accent: true)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRefuser,
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(onPressed: onAccepter, child: const Text('Accepter')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chiffre extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;
  const _Chiffre({required this.label, required this.value, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkFaint)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: accent ? AppTheme.primary : AppTheme.ink,
          ),
        ),
      ],
    );
  }
}
