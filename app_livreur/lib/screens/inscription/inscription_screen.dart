import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/localisation_card.dart';
import '../../core/widgets/quartier_picker.dart';
import '../../data/quartiers.dart';
import '../../core/widgets/vehicule.dart';
import '../../providers/auth_provider.dart';
import '../../providers/compte_provider.dart';
import '../../providers/localisation_provider.dart';
import '../../providers/profil_provider.dart';

class InscriptionScreen extends ConsumerStatefulWidget {
  const InscriptionScreen({super.key});

  @override
  ConsumerState<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends ConsumerState<InscriptionScreen> {
  final _pageController = PageController();
  int _step = 0;

  // Données collectées
  final _nomCtrl = TextEditingController();
  String? _vehicule;
  String? _ville;
  bool _localisation = false;
  bool _whatsapp = false;
  String? _quartier;

  @override
  void dispose() {
    _pageController.dispose();
    _nomCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _step++);
    } else {
      _creerProfil();
      // Un nouveau compte doit être validé par l'équipe avant d'être visible des clients
      ref.read(statutCompteProvider.notifier).state = StatutCompte.enAttente;
      context.go('/accueil');
    }
  }

  void _creerProfil() {
    final ville = _ville!;
    final telephone = ref.read(authProvider).telephone;
    ref.read(profilProvider.notifier).update(
          ref.read(profilProvider).copyWith(
                nom: _nomCtrl.text.trim(),
                telephone: telephone,
                vehicule: _vehicule,
                ville: ville,
                whatsapp: _whatsapp,
                quartier: _localisation ? null : _quartier,
              ),
        );
    ref.read(localisationActiveProvider.notifier).state = _localisation;
  }

  void _back() {
    if (_step > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _step--);
    }
  }

  bool get _canNext {
    switch (_step) {
      case 0:
        return _nomCtrl.text.trim().isNotEmpty && _vehicule != null;
      case 1:
        return _ville != null;
      case 2:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(step: _step, onBack: _step > 0 ? _back : null),
            _StepIndicator(step: _step),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepProfil(
                    nomCtrl: _nomCtrl,
                    vehicule: _vehicule,
                    onVehiculeChanged: (v) => setState(() => _vehicule = v),
                    onNomChanged: () => setState(() {}),
                    whatsapp: _whatsapp,
                    onWhatsAppChanged: (v) => setState(() => _whatsapp = v),
                  ),
                  _StepZone(
                    ville: _ville,
                    onVilleChanged: (v) => setState(() {
                      if (v != _ville) _quartier = null;
                      _ville = v;
                    }),
                  ),
                  _StepLocalisation(
                    active: _localisation,
                    onChanged: (v) => setState(() => _localisation = v),
                    ville: _ville,
                    quartier: _quartier,
                    onQuartierChanged: (q) => setState(() => _quartier = q),
                  ),
                ],
              ),
            ),
            _BottomBar(step: _step, canNext: _canNext, onNext: _next),
          ],
        ),
      ),
    );
  }
}

// ─── Top bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int step;
  final VoidCallback? onBack;
  const _TopBar({required this.step, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(onBack != null ? AppIcons.arrowLeft : AppIcons.x, size: 22),
            color: AppTheme.ink,
            onPressed: onBack ?? () => context.go('/phone'),
          ),
          const Spacer(),
          Text(
            'Étape ${step + 1} sur 3',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Step indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= step ? AppTheme.primary : AppTheme.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                if (i < 2) const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String titre;
  final String detail;
  const _StepHeader({required this.titre, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.7, height: 1.15),
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.45),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1 : Profil ─────────────────────────────────────────────────────────

class _StepProfil extends StatelessWidget {
  final TextEditingController nomCtrl;
  final String? vehicule;
  final ValueChanged<String> onVehiculeChanged;
  final VoidCallback onNomChanged;
  final bool whatsapp;
  final ValueChanged<bool> onWhatsAppChanged;

  const _StepProfil({
    required this.whatsapp,
    required this.onWhatsAppChanged,
    required this.nomCtrl,
    required this.vehicule,
    required this.onVehiculeChanged,
    required this.onNomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(titre: 'Mon profil', detail: 'Ces informations sont visibles par les clients, avec votre numéro.'),
          const _Label('Nom complet'),
          TextField(
            controller: nomCtrl,
            onChanged: (_) => onNomChanged(),
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.ink),
            decoration: const InputDecoration(
              hintText: 'Jean-Pierre Moussavou',
              prefixIcon: Icon(AppIcons.user, color: AppTheme.inkMuted, size: 20),
            ),
          ),
          const SizedBox(height: 24),
          const _Label('Type de véhicule'),
          VehiculeSelector(value: vehicule, onChanged: onVehiculeChanged),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.line),
            ),
            child: Row(
              children: [
                const Icon(AppIcons.whatsappLogo, size: 22, color: AppTheme.whatsapp),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Je suis joignable en appel WhatsApp sur ce numéro',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.ink, height: 1.35),
                  ),
                ),
                Switch(value: whatsapp, onChanged: onWhatsAppChanged),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2 : Zone ───────────────────────────────────────────────────────────

class _StepZone extends StatelessWidget {
  final String? ville;
  final ValueChanged<String?> onVilleChanged;

  const _StepZone({
    required this.ville,
    required this.onVilleChanged,
  });

  static const _villes = ['Libreville', 'Owendo', 'Ntoum', 'Port-Gentil', 'Franceville', 'Lambaréné', 'Oyem', 'Mouila'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(titre: 'Ma zone', detail: 'Choisissez la ville dans laquelle vous livrez.'),
          const _Label('Ville'),
          DropdownButtonFormField<String>(
            initialValue: ville,
            hint: const Text(
              'Sélectionnez votre ville',
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.inkFaint),
            ),
            icon: const Icon(AppIcons.caretDownBold, size: 14, color: AppTheme.inkFaint),
            style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.ink),
            dropdownColor: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            decoration: const InputDecoration(
              prefixIcon: Icon(AppIcons.buildings, color: AppTheme.inkMuted, size: 20),
            ),
            items: _villes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: onVilleChanged,
          ),
        ],
      ),
    );
  }
}

// ─── Step 3 : Localisation ───────────────────────────────────────────────────

class _StepLocalisation extends StatelessWidget {
  final bool active;
  final ValueChanged<bool> onChanged;
  final String? ville;
  final String? quartier;
  final ValueChanged<String?> onQuartierChanged;

  const _StepLocalisation({
    required this.active,
    required this.onChanged,
    required this.ville,
    required this.quartier,
    required this.onQuartierChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            titre: 'Ma localisation',
            detail: 'Les clients voient d\'abord les livreurs les plus proches d\'eux. C\'est facultatif et modifiable à tout moment.',
          ),
          LocalisationCard(active: active, onChanged: onChanged),
          if (!active && ville != null && quartiersParVille.containsKey(ville)) ...[
            const SizedBox(height: 24),
            const _Label('Quartier de base (facultatif)'),
            QuartierPicker(ville: ville!, valeur: quartier, onChanged: onQuartierChanged),
          ],
        ],
      ),
    );
  }
}

// ─── Bottom bar ──────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int step;
  final bool canNext;
  final VoidCallback onNext;

  const _BottomBar({required this.step, required this.canNext, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final isLast = step == 2;
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
            onPressed: canNext ? onNext : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(isLast ? 'Créer mon compte' : 'Suivant'),
                const SizedBox(width: 8),
                Icon(isLast ? AppIcons.checkBold : AppIcons.arrowRightBold, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared widgets ──────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.ink)),
    );
  }
}
