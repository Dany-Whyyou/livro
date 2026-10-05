import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/localisation_card.dart';
import '../../core/widgets/vehicule.dart';
import '../../providers/auth_provider.dart';
import '../../providers/compte_provider.dart';
import '../../providers/disponibilite_provider.dart';
import '../../providers/localisation_provider.dart';
import '../../providers/injoignable_provider.dart';
import '../../data/quartiers.dart';
import '../../core/widgets/quartier_picker.dart';
import '../../providers/photo_provider.dart';
import '../../core/widgets/photo_picker.dart';
import '../../providers/profil_provider.dart';

// Écran unique de l'app : la fiche du livreur telle que les clients la voient
// (numéro, véhicule, ville, localisation). Les clients appellent directement.
class AccueilScreen extends ConsumerStatefulWidget {
  const AccueilScreen({super.key});

  @override
  ConsumerState<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends ConsumerState<AccueilScreen> {
  late TextEditingController _nomCtrl;
  late String _vehicule;
  late String _ville;
  late bool _whatsapp;
  String? _quartier;
  bool _saving = false;

  static const _villes = ['Libreville', 'Owendo', 'Ntoum', 'Port-Gentil', 'Franceville', 'Lambaréné', 'Oyem', 'Mouila'];

  @override
  void initState() {
    super.initState();
    final p = ref.read(profilProvider);
    _nomCtrl = TextEditingController(text: p.nom);
    _vehicule = p.vehicule;
    _ville = p.ville;
    _whatsapp = p.whatsapp;
    _quartier = p.quartier;
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    super.dispose();
  }

  bool _modifie(LivreurProfil p) =>
      _nomCtrl.text.trim() != p.nom || _vehicule != p.vehicule || _ville != p.ville || _whatsapp != p.whatsapp || _quartier != p.quartier;

  Future<void> _sauvegarder() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final current = ref.read(profilProvider);
    ref.read(profilProvider.notifier).update(
          current.copyWith(
              nom: _nomCtrl.text.trim(), vehicule: _vehicule, ville: _ville, whatsapp: _whatsapp, quartier: _quartier, retirerQuartier: _quartier == null),
        );
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mis à jour')),
    );
  }

  Future<void> _changerPhoto() async {
    final chemin = await choisirPhoto(context, aDejaUnePhoto: ref.read(photoProvider) != null);
    if (chemin == null || !mounted) return;
    // Toute nouvelle photo repasse par la validation de l'équipe
    ref.read(photoProvider.notifier).state = chemin.isEmpty ? null : PhotoProfil(chemin: chemin);
    if (chemin.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo envoyée. Elle sera visible des clients après validation.')),
      );
    }
  }

  void _deconnecter() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Votre numéro ne sera plus affiché aux clients.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(modeDisponibiliteProvider.notifier).state = ModeDisponibilite.indisponible;
              ref.read(suiviPositionProvider.notifier).desactiver();
              ref.read(authProvider.notifier).logout();
              context.go('/phone');
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profil = ref.watch(profilProvider);
    final disponible = ref.watch(disponibleProvider);
    final mode = ref.watch(modeDisponibiliteProvider);
    final statut = ref.watch(statutCompteProvider);
    final modifie = _modifie(profil);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _FicheCard(
              profil: profil,
              valide: statut == StatutCompte.valide,
              photo: ref.watch(photoProvider),
              onPhoto: _changerPhoto,
            ),
            const SizedBox(height: 12),
            if (ref.watch(injoignableProvider)) ...[
              _InjoignableCard(
                onDisponible: () {
                  ref.read(injoignableProvider.notifier).state = false;
                  ref.read(modeDisponibiliteProvider.notifier).state = ModeDisponibilite.disponible;
                },
              ),
              const SizedBox(height: 12),
            ],
            if (statut == StatutCompte.valide)
              _DisponibiliteCard(
                mode: mode,
                disponible: disponible,
                onChanged: (m) => ref.read(modeDisponibiliteProvider.notifier).state = m,
              )
            else
              _ValidationCard(
                statut: statut,
                onSimuler: (s) => ref.read(statutCompteProvider.notifier).state = s,
              ),
            const SizedBox(height: 28),
            const SizedBox(height: 12),
            const LocalisationCard(),
            if (!ref.watch(localisationActiveProvider) && quartiersParVille.containsKey(_ville)) ...[
              const SizedBox(height: 28),
              const SectionTitle('Quartier de base'),
              QuartierPicker(ville: _ville, valeur: _quartier, onChanged: (q) => setState(() => _quartier = q)),
            ],
            const SizedBox(height: 28),
            const SectionTitle('Véhicule'),
            VehiculeSelector(value: _vehicule, onChanged: (v) => setState(() => _vehicule = v)),
            const SizedBox(height: 28),
            const SectionTitle('Ville'),
            DropdownButtonFormField<String>(
              initialValue: _ville,
              icon: const Icon(AppIcons.caretDownBold, size: 14, color: AppTheme.inkFaint),
              style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
              dropdownColor: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              decoration: const InputDecoration(
                prefixIcon: Icon(AppIcons.buildings, color: AppTheme.primary, size: 20),
              ),
              items: _villes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  if (v != _ville) _quartier = null;
                  _ville = v;
                });
              },
            ),
            const SizedBox(height: 28),
            const SectionTitle('Informations'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        const Text('Nom', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.inkMuted)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _nomCtrl,
                            onChanged: (_) => setState(() {}),
                            textAlign: TextAlign.end,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.ink),
                            decoration: const InputDecoration(
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(AppIcons.pencilSimple, size: 16, color: AppTheme.inkFaint),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        const Text('Téléphone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.inkMuted)),
                        const Spacer(),
                        Text(
                          formatTelephone(profil.telephone),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.inkMuted),
                        ),
                        const SizedBox(width: 8),
                        const Icon(AppIcons.lockSimple, size: 16, color: AppTheme.inkFaint),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        const Icon(AppIcons.whatsappLogo, size: 20, color: AppTheme.whatsapp),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Appels WhatsApp', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.ink)),
                              SizedBox(height: 2),
                              Text(
                                'Les clients peuvent aussi vous appeler sur WhatsApp',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkMuted),
                              ),
                            ],
                          ),
                        ),
                        Switch(value: _whatsapp, onChanged: (v) => setState(() => _whatsapp = v)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            AppCard(
              onTap: _deconnecter,
              child: const Row(
                children: [
                  Icon(AppIcons.signOut, size: 20, color: AppTheme.danger),
                  SizedBox(width: 12),
                  Text('Se déconnecter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.danger)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: modifie || _saving ? _SaveBar(saving: _saving, onSave: _sauvegarder) : null,
    );
  }
}

class _FicheCard extends StatelessWidget {
  final LivreurProfil profil;
  final bool valide;
  final PhotoProfil? photo;
  final VoidCallback onPhoto;
  const _FicheCard({required this.profil, required this.valide, required this.photo, required this.onPhoto});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onPhoto,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    photo == null
                        ? InitialesAvatar(texte: initiales(profil.nom), size: 56, color: Colors.white, background: AppTheme.primary)
                        : ClipOval(child: Image.file(File(photo!.chemin), width: 56, height: 56, fit: BoxFit.cover)),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.line),
                        ),
                        child: const Icon(AppIcons.cameraFill, size: 13, color: AppTheme.ink),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profil.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.4),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(vehiculeIcon(profil.vehicule), size: 16, color: AppTheme.inkMuted),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${vehiculeLabel(profil.vehicule)} · ${profil.ville}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatutPhoto(photo: photo, onTap: onPhoto),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(AppIcons.phone, size: 16, color: AppTheme.inkMuted),
                    const SizedBox(width: 6),
                    Text(
                      valide ? 'Numéro affiché aux clients' : 'Numéro affiché après validation',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatTelephone(profil.telephone),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatutPhoto extends StatelessWidget {
  final PhotoProfil? photo;
  final VoidCallback onTap;
  const _StatutPhoto({required this.photo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (texte, couleur, fond) = switch (photo?.statut) {
      null => ('Ajouter une photo (facultatif) : les clients vous font plus confiance', AppTheme.primary, AppTheme.primarySoft),
      StatutPhoto.enAttente => ('Photo en attente de validation par l\'équipe', AppTheme.secondaryInk, AppTheme.secondarySoft),
      StatutPhoto.validee => ('Photo validée, visible des clients', AppTheme.primary, AppTheme.primarySoft),
      StatutPhoto.refusee => ('Photo refusée : choisissez-en une autre', AppTheme.danger, AppTheme.dangerSoft),
    };
    return Material(
      color: fond,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Icon(AppIcons.camera, size: 16, color: couleur),
              const SizedBox(width: 8),
              Expanded(
                child: Text(texte, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: couleur)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InjoignableCard extends StatelessWidget {
  final VoidCallback onDisponible;
  const _InjoignableCard({required this.onDisponible});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.dangerSoft, borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(AppIcons.phone, size: 22, color: AppTheme.danger),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vous êtes passé en indisponible',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.danger, letterSpacing: -0.2),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Plusieurs clients n\'ont pas pu vous joindre aujourd\'hui. Remettez-vous disponible quand vous pouvez répondre.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.danger, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onDisponible,
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 46)),
            child: const Text('Me remettre disponible'),
          ),
        ],
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  final StatutCompte statut;
  final ValueChanged<StatutCompte> onSimuler;

  const _ValidationCard({required this.statut, required this.onSimuler});

  @override
  Widget build(BuildContext context) {
    final refuse = statut == StatutCompte.refuse;
    final couleur = refuse ? AppTheme.danger : AppTheme.secondaryInk;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: refuse ? AppTheme.dangerSoft : AppTheme.secondarySoft,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(refuse ? AppIcons.xCircle : AppIcons.hourglass, size: 22, color: couleur),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      refuse ? 'Compte refusé' : 'Compte en attente de validation',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: couleur, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      refuse
                          ? 'Votre compte n\'a pas été validé. Contactez l\'équipe Livro pour en savoir plus.'
                          : 'Notre équipe vérifie votre compte. Votre numéro sera affiché aux clients dès qu\'il sera validé.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: couleur, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Mock : en attendant le backend, permet de simuler la décision de l'admin
          Row(
            children: [
              const Expanded(
                child: Text('Mode démo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkMuted)),
              ),
              TextButton(
                onPressed: () => onSimuler(StatutCompte.valide),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                child: const Text('Valider'),
              ),
              if (!refuse)
                TextButton(
                  onPressed: () => onSimuler(StatutCompte.refuse),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
                  child: const Text('Refuser'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DisponibiliteCard extends StatelessWidget {
  final ModeDisponibilite mode;
  final bool disponible;
  final ValueChanged<ModeDisponibilite> onChanged;

  const _DisponibiliteCard({required this.mode, required this.disponible, required this.onChanged});

  String get _detail {
    if (mode == ModeDisponibilite.auto) {
      return disponible ? 'Mode auto · jusqu\'à ${heureFinAuto}h' : 'Mode auto · reprise à ${heureDebutAuto}h';
    }
    return disponible ? 'Les clients peuvent vous appeler' : 'Votre numéro est masqué aux clients';
  }

  @override
  Widget build(BuildContext context) {
    final fg = disponible ? Colors.white : AppTheme.ink;
    final fgMuted = disponible ? Colors.white.withValues(alpha: 0.75) : AppTheme.inkMuted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: disponible ? AppTheme.primary : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: disponible ? AppTheme.primary : AppTheme.line),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: disponible ? const Color(0xFF6FE3B4) : AppTheme.inkFaint,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: disponible ? Colors.white.withValues(alpha: 0.25) : AppTheme.line,
                      width: 3,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disponible ? 'Disponible' : 'Indisponible',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: fg, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 2),
                      Text(_detail, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: fgMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ModeSelector(mode: mode, disponible: disponible, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final ModeDisponibilite mode;
  final bool disponible;
  final ValueChanged<ModeDisponibilite> onChanged;

  const _ModeSelector({required this.mode, required this.disponible, required this.onChanged});

  static const _options = [
    (ModeDisponibilite.disponible, 'Disponible'),
    (ModeDisponibilite.auto, 'Auto'),
    (ModeDisponibilite.indisponible, 'Indisponible'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: disponible ? Colors.white.withValues(alpha: 0.14) : AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final (valeur, label) in _options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(valeur),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: valeur == mode ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: valeur == mode && !disponible ? AppTheme.line : Colors.transparent),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: valeur == mode
                            ? (disponible ? AppTheme.primary : AppTheme.ink)
                            : (disponible ? Colors.white.withValues(alpha: 0.85) : AppTheme.inkMuted),
                      ),
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

class _SaveBar extends StatelessWidget {
  final bool saving;
  final VoidCallback onSave;
  const _SaveBar({required this.saving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: FilledButton(
            onPressed: saving ? null : onSave,
            style: FilledButton.styleFrom(disabledBackgroundColor: AppTheme.primary),
            child: saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text('Enregistrer les modifications'),
          ),
        ),
      ),
    );
  }
}
