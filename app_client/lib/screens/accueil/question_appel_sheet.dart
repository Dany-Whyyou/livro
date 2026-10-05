import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/livreur_avatar.dart';
import '../../data/models/livreur.dart';
import '../../providers/appel_provider.dart';

/// Après un appel, une seule question : le livreur a-t-il répondu ?
/// Les « non » servent à repasser en indisponible un livreur injoignable.
void demanderSiReponse(BuildContext context, WidgetRef ref, Livreur livreur) {
  showModalBottomSheet(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.line, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 20),
            LivreurAvatar(nom: livreur.nom, photo: livreur.photo, size: 56, fonce: true),
            const SizedBox(height: 14),
            Text(
              'Avez-vous pu joindre ${livreur.nom}\u00A0?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.3, height: 1.25),
            ),
            const SizedBox(height: 6),
            const Text(
              'Votre réponse nous aide à n\'afficher que les livreurs vraiment disponibles.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(nonReponsesProvider.notifier).signaler(livreur);
                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Merci, c\'est noté. Essayez un autre livreur proche.')),
                      );
                    },
                    child: const Text('Non'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Oui'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
