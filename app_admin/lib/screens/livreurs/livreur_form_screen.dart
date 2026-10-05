import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/appel.dart';
import '../../core/utils/gabon_phone_formatter.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/choix.dart';
import '../../core/widgets/livreur_avatar.dart';
import '../../core/widgets/vehicule.dart';
import '../../data/models/livreur.dart';
import '../../data/quartiers.dart';
import '../../providers/livreurs_provider.dart';
import '../../providers/villes_provider.dart';
import 'livreurs_screen.dart';

/// Ajout d'un livreur (sans [livreurId]) ou modification d'une fiche existante.
class LivreurFormScreen extends ConsumerStatefulWidget {
  final String? livreurId;
  const LivreurFormScreen({super.key, this.livreurId});

  @override
  ConsumerState<LivreurFormScreen> createState() => _LivreurFormScreenState();
}

class _LivreurFormScreenState extends ConsumerState<LivreurFormScreen> {
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  String? _vehicule;
  String? _ville;
  String? _quartier;
  ModeDisponibilite _mode = ModeDisponibilite.auto;
  bool _whatsapp = false;
  String? _erreurNom;
  String? _erreurTel;

  bool get _edition => widget.livreurId != null;

  Livreur? get _livreur {
    for (final l in ref.read(livreursProvider)) {
      if (l.id == widget.livreurId) return l;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final l = _livreur;
    if (l != null) {
      _nomCtrl.text = l.nom;
      _telCtrl.text = GabonPhoneFormatter.formatLocal(l.telephone.replaceFirst('+241', ''));
      _vehicule = l.vehicule;
      _ville = l.ville;
      _quartier = l.quartier;
      _mode = l.mode;
      _whatsapp = l.whatsapp;
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  String get _telephone => '+241${_telCtrl.text.replaceAll(' ', '')}';

  void _enregistrer() {
    final nom = _nomCtrl.text.trim();
    final chiffres = _telCtrl.text.replaceAll(' ', '');
    final notifier = ref.read(livreursProvider.notifier);

    setState(() {
      _erreurNom = nom.isEmpty ? 'Entrez le nom du livreur' : null;
      if (chiffres.length < 9) {
        _erreurTel = 'Le numéro doit avoir 9 chiffres';
      } else if (notifier.numeroDejaPris(_telephone, saufId: widget.livreurId)) {
        _erreurTel = 'Un livreur utilise déjà ce numéro';
      } else {
        _erreurTel = null;
      }
    });
    if (_erreurNom != null || _erreurTel != null) return;

    if (_vehicule == null || _ville == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_vehicule == null ? 'Choisissez un véhicule' : 'Choisissez une ville')));
      return;
    }

    final actuel = _livreur;
    if (actuel != null) {
      notifier.modifier(
        actuel.copyWith(
          nom: nom,
          telephone: _telephone,
          vehicule: _vehicule,
          ville: _ville,
          mode: _mode,
          whatsapp: _whatsapp,
          quartier: _quartier,
          retirerQuartier: _quartier == null,
        ),
      );
    } else {
      notifier.ajouter(nom: nom, telephone: _telephone, vehicule: _vehicule!, ville: _ville!, mode: _mode, whatsapp: _whatsapp, quartier: _quartier);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(actuel != null ? 'Fiche mise à jour' : 'Livreur ajouté')));
    context.pop();
  }

  void _basculerSuspension(Livreur livreur) {
    final suspendre = !livreur.suspendu;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(suspendre ? 'Suspendre ce livreur' : 'Réactiver ce livreur'),
        content: Text(
          suspendre
              ? '${livreur.nom} ne sera plus affiché aux clients tant que vous ne le réactivez pas.'
              : '${livreur.nom} sera de nouveau affiché aux clients selon sa disponibilité.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(livreursProvider.notifier).modifier(livreur.copyWith(suspendu: suspendre));
            },
            style: TextButton.styleFrom(foregroundColor: suspendre ? AppTheme.danger : AppTheme.success),
            child: Text(suspendre ? 'Suspendre' : 'Réactiver'),
          ),
        ],
      ),
    );
  }

  /// Valide ou refuse un compte créé depuis Livro Pro.
  void _decider(Livreur livreur, StatutCompte statut) {
    final valider = statut == StatutCompte.valide;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(valider ? 'Valider ce compte' : 'Refuser ce compte'),
        content: Text(
          valider
              ? '${livreur.nom} sera affiché aux clients selon sa disponibilité.'
              : '${livreur.nom} ne sera pas affiché aux clients. Vous pourrez valider son compte plus tard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(livreursProvider.notifier).modifier(livreur.copyWith(statut: statut));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(valider ? 'Compte validé' : 'Compte refusé')));
            },
            style: TextButton.styleFrom(foregroundColor: valider ? AppTheme.success : AppTheme.danger),
            child: Text(valider ? 'Valider' : 'Refuser'),
          ),
        ],
      ),
    );
  }

  void _deciderPhoto(Livreur livreur, StatutPhoto statut) {
    ref.read(livreursProvider.notifier).modifier(livreur.copyWith(statutPhoto: statut));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(statut == StatutPhoto.validee ? 'Photo validée' : 'Photo refusée')));
  }

  void _retirerPhoto(Livreur livreur) {
    ref.read(livreursProvider.notifier).modifier(livreur.copyWith(retirerPhoto: true));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo retirée')));
  }

  void _supprimer(Livreur livreur) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce livreur'),
        content: Text('La fiche de ${livreur.nom} sera supprimée définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(livreursProvider.notifier).supprimer(livreur.id);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Livreur supprimé')));
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Suit la fiche en direct (suspension) ; null si elle vient d'être supprimée.
    final livreur = _edition ? ref.watch(livreursProvider.select((liste) => liste.where((l) => l.id == widget.livreurId).firstOrNull)) : null;
    // La ville actuelle du livreur reste proposée même si elle a été retirée de la liste.
    final nomsVilles = [
      for (final v in ref.watch(villesProvider)) v.nom,
      if (_ville != null && !ref.watch(villesProvider).any((v) => v.nom == _ville)) _ville!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_edition ? 'Fiche livreur' : 'Nouveau livreur'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(AppIcons.arrowLeft, size: 22)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (livreur != null) ...[
            _Entete(livreur: livreur),
            const SizedBox(height: 24),
            const SectionTitle('Photo'),
            _PhotoCard(livreur: livreur, onDecider: (statut) => _deciderPhoto(livreur, statut), onRetirer: () => _retirerPhoto(livreur)),
            if (livreur.statut == StatutCompte.enAttente) ...[
              const SizedBox(height: 12),
              _ValidationCard(onValider: () => _decider(livreur, StatutCompte.valide), onRefuser: () => _decider(livreur, StatutCompte.refuse)),
            ],
            const SizedBox(height: 24),
          ] else if (!_edition) ...[
            const _InfoSansSmartphone(),
            const SizedBox(height: 24),
          ],
          const SectionTitle('Nom complet'),
          TextField(
            controller: _nomCtrl,
            onChanged: (_) {
              if (_erreurNom != null) setState(() => _erreurNom = null);
            },
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.ink),
            decoration: InputDecoration(
              hintText: 'Jean-Pierre Moussavou',
              errorText: _erreurNom,
              prefixIcon: const Icon(AppIcons.user, color: AppTheme.inkMuted, size: 20),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Téléphone'),
          TextField(
            controller: _telCtrl,
            onChanged: (_) {
              if (_erreurTel != null) setState(() => _erreurTel = null);
            },
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, GabonPhoneFormatter()],
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppTheme.ink),
            decoration: InputDecoration(
              hintText: '077 12 34 56',
              errorText: _erreurTel,
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppTheme.line)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GabonFlag(),
                    SizedBox(width: 8),
                    Text(
                      '+241',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Véhicule'),
          VehiculeSelector(value: _vehicule, onChanged: (v) => setState(() => _vehicule = v)),
          const SizedBox(height: 24),
          const SectionTitle('Ville'),
          DropdownButtonFormField<String>(
            initialValue: _ville,
            hint: const Text(
              'Sélectionnez la ville',
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.inkFaint),
            ),
            icon: const Icon(AppIcons.caretDownBold, size: 14, color: AppTheme.inkFaint),
            style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.ink),
            dropdownColor: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            decoration: const InputDecoration(prefixIcon: Icon(AppIcons.buildings, color: AppTheme.inkMuted, size: 20)),
            items: nomsVilles.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() {
              if (v != _ville) _quartier = null;
              _ville = v;
            }),
          ),
          if (_ville != null && quartiersParVille.containsKey(_ville)) ...[
            const SizedBox(height: 24),
            const SectionTitle('Quartier de base'),
            DropdownButtonFormField<String?>(
              key: ValueKey(_ville),
              initialValue: _quartier,
              icon: const Icon(AppIcons.caretDownBold, size: 14, color: AppTheme.inkFaint),
              style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.ink),
              dropdownColor: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              decoration: const InputDecoration(prefixIcon: Icon(AppIcons.mapPin, color: AppTheme.inkMuted, size: 20)),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Aucun')),
                for (final q in quartiersParVille[_ville]!) DropdownMenuItem<String?>(value: q, child: Text(q)),
              ],
              onChanged: (q) => setState(() => _quartier = q),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Text(
                'Sans localisation en direct, le livreur est situé (approximativement) au centre de ce quartier, et les clients le voient comme tel.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkFaint, height: 1.4),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const SectionTitle('WhatsApp'),
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
            child: Row(
              children: [
                const Icon(AppIcons.whatsappLogo, size: 22, color: AppTheme.whatsapp),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Joignable en appel WhatsApp sur ce numéro',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.ink, height: 1.35),
                  ),
                ),
                Switch(value: _whatsapp, activeThumbColor: Colors.white, activeTrackColor: AppTheme.success, onChanged: (v) => setState(() => _whatsapp = v)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Disponibilité'),
          ChoixSegments<ModeDisponibilite>(
            options: const [(ModeDisponibilite.disponible, 'Disponible'), (ModeDisponibilite.auto, 'Auto'), (ModeDisponibilite.indisponible, 'Indisponible')],
            valeur: _mode,
            onChanged: (m) => setState(() => _mode = m),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 10, 4, 0),
            child: Text(
              'En mode Auto, le livreur est disponible de ${heureDebutAuto}h à ${heureFinAuto}h.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkFaint),
            ),
          ),
          if (livreur != null) ...[
            const SizedBox(height: 28),
            const SectionTitle('Actions'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _Action(icon: AppIcons.phone, label: 'Appeler le livreur', onTap: () => appeler(context, livreur.telephone)),
                  if (livreur.statut == StatutCompte.refuse) ...[
                    const Divider(),
                    _Action(icon: AppIcons.checkBold, label: 'Valider le compte', color: AppTheme.success, onTap: () => _decider(livreur, StatutCompte.valide)),
                  ],
                  const Divider(),
                  _Action(
                    icon: livreur.suspendu ? AppIcons.checkBold : AppIcons.prohibit,
                    label: livreur.suspendu ? 'Réactiver le livreur' : 'Suspendre le livreur',
                    color: livreur.suspendu ? AppTheme.success : AppTheme.ink,
                    onTap: () => _basculerSuspension(livreur),
                  ),
                  const Divider(),
                  _Action(icon: AppIcons.trash, label: 'Supprimer la fiche', color: AppTheme.danger, onTap: () => _supprimer(livreur)),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.line)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: FilledButton(onPressed: _enregistrer, child: Text(_edition ? 'Enregistrer les modifications' : 'Ajouter le livreur')),
          ),
        ),
      ),
    );
  }
}

class _Entete extends StatelessWidget {
  final Livreur livreur;
  const _Entete({required this.livreur});

  @override
  Widget build(BuildContext context) {
    final parAdmin = livreur.origine == OrigineFiche.admin;
    const style = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.inkMuted);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(parAdmin ? AppIcons.deviceMobileSlash : AppIcons.deviceMobile, size: 20, color: AppTheme.inkMuted),
                const SizedBox(width: 12),
                Expanded(child: Text(parAdmin ? 'Sans smartphone — fiche gérée par l\'admin' : 'Inscrit via Livro Pro', style: style)),
                const SizedBox(width: 10),
                StatutLivreurPill(livreur: livreur, maintenant: DateTime.now()),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(
                  livreur.localisationActive ? AppIcons.mapPinFill : AppIcons.mapPin,
                  size: 20,
                  color: livreur.localisationActive ? AppTheme.success : AppTheme.inkMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    livreur.localisationActive
                        ? 'Localisation activée'
                        : livreur.quartier != null
                        ? '${parAdmin ? 'Sans smartphone' : 'Localisation désactivée'} : situé approximativement à ${livreur.quartier}'
                        : '${parAdmin ? 'Pas de localisation (sans smartphone)' : 'Localisation désactivée'} et pas de quartier de base : pas de distance affichée',
                    style: style,
                  ),
                ),
              ],
            ),
          ),
          if (livreur.nonReponses7j > 0) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  const Icon(AppIcons.warning, size: 20, color: AppTheme.danger),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${livreur.nonReponses7j} client${livreur.nonReponses7j > 1 ? 's' : ''} n\'${livreur.nonReponses7j > 1 ? 'ont' : 'a'} pas pu le joindre ces 7 derniers jours',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.danger),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  final VoidCallback onValider;
  final VoidCallback onRefuser;
  const _ValidationCard({required this.onValider, required this.onRefuser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.primarySoft, borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(AppIcons.hourglass, size: 20, color: AppTheme.secondaryInk),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Compte en attente de validation',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.secondaryInk),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Ce livreur s\'est inscrit depuis Livro Pro. Il n\'est pas affiché aux clients tant que son compte n\'est pas validé.',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.secondaryInk, height: 1.45),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRefuser,
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger, backgroundColor: AppTheme.surface, minimumSize: const Size(0, 46)),
                  child: const Text('Refuser'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onValider,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 46)),
                  child: const Text('Valider'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSansSmartphone extends StatelessWidget {
  const _InfoSansSmartphone();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.primarySoft, borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.deviceMobileSlash, size: 20, color: AppTheme.secondaryInk),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pour un livreur sans smartphone : il n\'a pas besoin de l\'application, les clients l\'appellent sur son numéro. Vous gérez sa fiche ici.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.secondaryInk, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap, this.color = AppTheme.ink});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final Livreur livreur;
  final ValueChanged<StatutPhoto> onDecider;
  final VoidCallback onRetirer;

  const _PhotoCard({required this.livreur, required this.onDecider, required this.onRetirer});

  @override
  Widget build(BuildContext context) {
    if (livreur.photo == null) {
      return const AppCard(
        child: Row(
          children: [
            Icon(AppIcons.camera, size: 20, color: AppTheme.inkMuted),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pas de photo (facultative). Le livreur peut en ajouter une depuis Livro Pro.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.inkMuted, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }
    final statut = livreur.statutPhoto ?? StatutPhoto.enAttente;
    final pill = switch (statut) {
      StatutPhoto.enAttente => const StatusPill(label: 'À valider', color: AppTheme.secondaryInk, background: AppTheme.primarySoft),
      StatutPhoto.validee => const StatusPill(label: 'Validée', color: AppTheme.success, background: AppTheme.successSoft),
      StatutPhoto.refusee => const StatusPill(label: 'Refusée', color: AppTheme.danger, background: AppTheme.dangerSoft),
    };
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LivreurAvatar(livreur: livreur, size: 72, memeNonValidee: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    pill,
                    const SizedBox(height: 8),
                    Text(
                      statut == StatutPhoto.validee
                          ? 'Visible des clients sur la fiche du livreur.'
                          : 'Non visible des clients tant qu\'elle n\'est pas validée.',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (statut == StatutPhoto.enAttente)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onDecider(StatutPhoto.refusee),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger, minimumSize: const Size(0, 46)),
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => onDecider(StatutPhoto.validee),
                    style: FilledButton.styleFrom(minimumSize: const Size(0, 46)),
                    child: const Text('Valider'),
                  ),
                ),
              ],
            )
          else
            TextButton.icon(
              onPressed: onRetirer,
              icon: const Icon(AppIcons.trash, size: 16),
              label: const Text('Retirer la photo'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            ),
        ],
      ),
    );
  }
}
