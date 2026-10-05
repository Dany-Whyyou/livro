import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/champ_telephone.dart';
import '../../core/widgets/sheet.dart';
import '../../data/models/admin.dart';
import '../../providers/admins_provider.dart';
import '../../providers/auth_provider.dart';

/// Gestion des administrateurs : seuls ces numéros peuvent se connecter à Livro Admin.
class AdminsScreen extends ConsumerWidget {
  const AdminsScreen({super.key});

  void _retirer(BuildContext context, WidgetRef ref, Admin admin) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retirer cet administrateur'),
        content: Text('${admin.nom} ne pourra plus se connecter à Livro Admin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(adminsProvider.notifier).retirer(admin.id);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Administrateur retiré')));
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admins = ref.watch(adminsProvider);
    final moi = ref.watch(authProvider).telephone;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrateurs'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(AppIcons.arrowLeft, size: 22)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFormSheet(context, titre: 'Nouvel administrateur', builder: (_) => const _AdminForm()),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(AppIcons.plusBold, size: 18),
        label: const Text(
          'Ajouter un admin',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 104),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 4, 20),
            child: Text(
              'Seuls ces numéros peuvent se connecter à Livro Admin.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.45),
            ),
          ),
          for (final admin in admins)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Row(
                  children: [
                    InitialesAvatar(texte: initiales(admin.nom)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            admin.nom,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            formatTelephone(admin.telephone),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // On ne peut pas se retirer soi-même : il reste donc toujours au moins un admin.
                    if (admin.telephone == moi)
                      const StatusPill(label: 'Vous', color: AppTheme.secondaryInk, background: AppTheme.primarySoft)
                    else
                      IconButton(
                        onPressed: () => _retirer(context, ref, admin),
                        tooltip: 'Retirer',
                        icon: const Icon(AppIcons.trash, size: 20, color: AppTheme.danger),
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

class _AdminForm extends ConsumerStatefulWidget {
  const _AdminForm();

  @override
  ConsumerState<_AdminForm> createState() => _AdminFormState();
}

class _AdminFormState extends ConsumerState<_AdminForm> {
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  String? _erreurNom;
  String? _erreurTel;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  void _ajouter() {
    final nom = _nomCtrl.text.trim();
    final telephone = ChampTelephone.numeroComplet(_telCtrl);
    final notifier = ref.read(adminsProvider.notifier);

    setState(() {
      _erreurNom = nom.isEmpty ? 'Entrez le nom de l\'administrateur' : null;
      if (!ChampTelephone.estComplet(_telCtrl)) {
        _erreurTel = 'Le numéro doit avoir 9 chiffres';
      } else if (notifier.numeroDejaPris(telephone)) {
        _erreurTel = 'Ce numéro est déjà administrateur';
      } else {
        _erreurTel = null;
      }
    });
    if (_erreurNom != null || _erreurTel != null) return;

    final messenger = ScaffoldMessenger.of(context);
    notifier.ajouter(nom: nom, telephone: telephone);
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('Administrateur ajouté')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Nom complet'),
        TextField(
          controller: _nomCtrl,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) {
            if (_erreurNom != null) setState(() => _erreurNom = null);
          },
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.ink),
          decoration: InputDecoration(
            hintText: 'Nom de l\'administrateur',
            errorText: _erreurNom,
            prefixIcon: const Icon(AppIcons.user, color: AppTheme.inkMuted, size: 20),
          ),
        ),
        const SizedBox(height: 20),
        const SectionTitle('Téléphone'),
        ChampTelephone(
          controller: _telCtrl,
          errorText: _erreurTel,
          onChanged: (_) {
            if (_erreurTel != null) setState(() => _erreurTel = null);
          },
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: _ajouter, child: const Text('Ajouter l\'administrateur')),
      ],
    );
  }
}
