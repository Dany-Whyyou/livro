import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/choix.dart';
import '../../data/models/notification.dart';
import '../../providers/notifications_provider.dart';

/// Envoi d'une notification à tout le monde, aux clients, aux livreurs ou aux admins.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _titreCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  CibleNotification _cible = CibleNotification.tous;
  String? _erreurTitre;
  String? _erreurMessage;
  bool _envoi = false;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  String get _destinataires => switch (_cible) {
    CibleNotification.tous => 'tous les utilisateurs (clients, livreurs et admins)',
    CibleNotification.clients => 'tous les clients',
    CibleNotification.livreurs => 'tous les livreurs',
    CibleNotification.admins => 'tous les administrateurs',
  };

  void _confirmer() {
    final titre = _titreCtrl.text.trim();
    final message = _messageCtrl.text.trim();
    setState(() {
      _erreurTitre = titre.isEmpty ? 'Entrez un titre' : null;
      _erreurMessage = message.isEmpty ? 'Entrez le message' : null;
    });
    if (_erreurTitre != null || _erreurMessage != null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Envoyer la notification'),
        content: Text('« $titre » sera envoyée à $_destinataires. Un envoi ne peut pas être annulé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _envoyer(titre, message);
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  Future<void> _envoyer(String titre, String message) async {
    FocusScope.of(context).unfocus();
    setState(() => _envoi = true);
    await ref.read(notificationsProvider.notifier).envoyer(cible: _cible, titre: titre, message: message);
    if (!mounted) return;
    _titreCtrl.clear();
    _messageCtrl.clear();
    setState(() => _envoi = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification envoyée')));
  }

  @override
  Widget build(BuildContext context) {
    final historique = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const SectionTitle('Destinataires'),
          ChoixSegments<CibleNotification>(
            options: [
              (CibleNotification.tous, 'Tous'),
              for (final c in const [CibleNotification.clients, CibleNotification.livreurs, CibleNotification.admins]) (c, c.label),
            ],
            valeur: _cible,
            onChanged: (c) => setState(() => _cible = c),
          ),
          const SizedBox(height: 20),
          const SectionTitle('Titre'),
          TextField(
            controller: _titreCtrl,
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) {
              if (_erreurTitre != null) setState(() => _erreurTitre = null);
            },
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink),
            decoration: InputDecoration(hintText: 'Ex. : Nouveau à Port-Gentil', errorText: _erreurTitre),
          ),
          const SizedBox(height: 8),
          const SectionTitle('Message'),
          TextField(
            controller: _messageCtrl,
            minLines: 3,
            maxLines: 6,
            maxLength: 240,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) {
              if (_erreurMessage != null) setState(() => _erreurMessage = null);
            },
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.ink, height: 1.45),
            decoration: InputDecoration(hintText: 'Le texte de la notification', errorText: _erreurMessage),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _envoi ? null : _confirmer,
            style: FilledButton.styleFrom(disabledBackgroundColor: AppTheme.primary),
            child: _envoi
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Envoyer la notification'),
          ),
          const SizedBox(height: 32),
          const SectionTitle('Déjà envoyées'),
          if (historique.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Aucune notification envoyée pour le moment.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.inkMuted),
              ),
            )
          else
            for (final n in historique)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n.titre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
                            ),
                          ),
                          const SizedBox(width: 10),
                          StatusPill(label: n.cible.label, color: AppTheme.secondaryInk, background: AppTheme.primarySoft),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        n.message,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.ink, height: 1.45),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Envoyée le ${formatDate(n.envoyeeLe)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkFaint),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
