import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/sheet.dart';
import '../../data/models/ville.dart';
import '../../providers/livreurs_provider.dart';
import '../../providers/villes_provider.dart';

/// Gestion des villes desservies, rangées par province.
class VillesScreen extends ConsumerWidget {
  const VillesScreen({super.key});

  void _ouvrirFormulaire(BuildContext context, {Ville? ville}) {
    showFormSheet(
      context,
      titre: ville == null ? 'Nouvelle ville' : 'Modifier la ville',
      builder: (_) => _VilleForm(ville: ville),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final villes = ref.watch(villesProvider);
    final livreurs = ref.watch(livreursProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Villes'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(AppIcons.arrowLeft, size: 22)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ouvrirFormulaire(context),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(AppIcons.plusBold, size: 18),
        label: const Text(
          'Ajouter une ville',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 104),
        children: [
          for (final province in provinces)
            if (villes.any((v) => v.province == province)) ...[
              SectionTitle(province),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (final (i, ville) in villes.where((v) => v.province == province).indexed) ...[
                      if (i > 0) const Divider(),
                      _VilleLigne(
                        ville: ville,
                        nbLivreurs: livreurs.where((l) => l.ville == ville.nom).length,
                        onTap: () => _ouvrirFormulaire(context, ville: ville),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
        ],
      ),
    );
  }
}

class _VilleLigne extends StatelessWidget {
  final Ville ville;
  final int nbLivreurs;
  final VoidCallback onTap;
  const _VilleLigne({required this.ville, required this.nbLivreurs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                ville.nom,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
              ),
            ),
            Text(
              nbLivreurs > 1 ? '$nbLivreurs livreurs' : '$nbLivreurs livreur',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
            ),
            const SizedBox(width: 8),
            const Icon(AppIcons.pencilSimple, size: 16, color: AppTheme.inkFaint),
          ],
        ),
      ),
    );
  }
}

class _VilleForm extends ConsumerStatefulWidget {
  final Ville? ville;
  const _VilleForm({this.ville});

  @override
  ConsumerState<_VilleForm> createState() => _VilleFormState();
}

class _VilleFormState extends ConsumerState<_VilleForm> {
  late final TextEditingController _nomCtrl;
  String? _province;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: widget.ville?.nom ?? '');
    _province = widget.ville?.province;
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    super.dispose();
  }

  void _enregistrer() {
    final nom = _nomCtrl.text.trim();
    final notifier = ref.read(villesProvider.notifier);

    String? erreur;
    if (nom.isEmpty) {
      erreur = 'Entrez le nom de la ville';
    } else if (notifier.nomDejaPris(nom, saufId: widget.ville?.id)) {
      erreur = 'Cette ville existe déjà';
    } else if (_province == null) {
      erreur = 'Choisissez une province';
    }
    if (erreur != null) {
      setState(() => _erreur = erreur);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    if (widget.ville == null) {
      notifier.ajouter(nom: nom, province: _province!);
    } else {
      notifier.modifier(widget.ville!, nom: nom, province: _province!);
    }
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(widget.ville == null ? 'Ville ajoutée' : 'Ville mise à jour')));
  }

  void _supprimer() {
    final ville = widget.ville!;
    final messenger = ScaffoldMessenger.of(context);
    final rattaches = ref.read(livreursProvider).where((l) => l.ville == ville.nom).length;
    if (rattaches > 0) {
      setState(() {
        _erreur = rattaches > 1
            ? '$rattaches livreurs sont rattachés à cette ville. Changez leur ville avant de la supprimer.'
            : 'Un livreur est rattaché à cette ville. Changez sa ville avant de la supprimer.';
      });
      return;
    }
    ref.read(villesProvider.notifier).supprimer(ville.id);
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('Ville supprimée')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Nom'),
        TextField(
          controller: _nomCtrl,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) {
            if (_erreur != null) setState(() => _erreur = null);
          },
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.ink),
          decoration: const InputDecoration(
            hintText: 'Ex. : Tchibanga',
            prefixIcon: Icon(AppIcons.buildings, color: AppTheme.inkMuted, size: 20),
          ),
        ),
        const SizedBox(height: 20),
        const SectionTitle('Province'),
        DropdownButtonFormField<String>(
          initialValue: _province,
          hint: const Text(
            'Sélectionnez la province',
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.inkFaint),
          ),
          icon: const Icon(AppIcons.caretDownBold, size: 14, color: AppTheme.inkFaint),
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.ink),
          dropdownColor: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          decoration: const InputDecoration(prefixIcon: Icon(AppIcons.mapPin, color: AppTheme.inkMuted, size: 20)),
          items: provinces.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (p) => setState(() {
            _province = p;
            _erreur = null;
          }),
        ),
        if (_erreur != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
            child: Text(
              _erreur!,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.danger, height: 1.4),
            ),
          ),
        const SizedBox(height: 24),
        FilledButton(onPressed: _enregistrer, child: Text(widget.ville == null ? 'Ajouter la ville' : 'Enregistrer')),
        if (widget.ville != null) ...[
          const SizedBox(height: 4),
          Center(
            child: TextButton.icon(
              onPressed: _supprimer,
              icon: const Icon(AppIcons.trash, size: 16),
              label: const Text('Supprimer la ville'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            ),
          ),
        ],
      ],
    );
  }
}
