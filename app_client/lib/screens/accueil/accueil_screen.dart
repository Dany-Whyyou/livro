import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/livreur_avatar.dart';
import '../../core/widgets/proximite.dart';
import '../../data/models/livreur.dart';
import '../../providers/appel_provider.dart';
import '../../providers/livreurs_provider.dart';
import 'question_appel_sheet.dart';
import 'fiche_livreur_sheet.dart';

// Écran unique de l'app : la liste des livreurs disponibles, avec leur numéro
// du plus proche au plus lointain. Le client appelle directement, sans commande dans l'app.
class AccueilScreen extends ConsumerStatefulWidget {
  const AccueilScreen({super.key});

  @override
  ConsumerState<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends ConsumerState<AccueilScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Au retour dans l'app après un appel, demande au client si le livreur a répondu.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final appel = ref.read(appelEnAttenteProvider);
    if (appel == null) return;
    ref.read(appelEnAttenteProvider.notifier).state = null;
    demanderSiReponse(context, ref, appel.livreur);
  }

  @override
  Widget build(BuildContext context) {
    final ville = ref.watch(villeProvider);
    final vehicule = ref.watch(vehiculeFiltreProvider);
    final livreurs = ref.watch(livreursProvider);
    final positionActive = ref.watch(positionActiveProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Row(
              children: [
                BrandMark(size: 36),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Livro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.4)),
                ),
                _SignalerButton(),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Trouvez un livreur',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.7, height: 1.15),
            ),
            const SizedBox(height: 8),
            const Text(
              'Appelez-le directement et convenez du prix avec lui.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.45),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: ville,
              icon: const Icon(AppIcons.caretDownBold, size: 14, color: AppTheme.inkFaint),
              style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink),
              dropdownColor: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              decoration: const InputDecoration(
                prefixIcon: Icon(AppIcons.buildings, color: AppTheme.primary, size: 20),
              ),
              items: villes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) {
                if (v != null) ref.read(villeProvider.notifier).state = v;
              },
            ),
            const SizedBox(height: 12),
            _PositionCard(
              active: positionActive,
              ville: ville,
              onChanged: (v) => ref.read(positionActiveProvider.notifier).state = v,
            ),
            const SizedBox(height: 20),
            const SectionTitle('Véhicule'),
            _Choix<TypeVehicule?>(
              options: [
                (null, 'Tous', null),
                for (final v in TypeVehicule.values) (v, v.label, v.icon),
              ],
              valeur: vehicule,
              onChanged: (v) => ref.read(vehiculeFiltreProvider.notifier).state = v,
            ),
            const SizedBox(height: 28),
            SectionTitle(
              livreurs.length > 1 ? '${livreurs.length} livreurs disponibles' : '${livreurs.length} livreur disponible',
            ),
            if (livreurs.isNotEmpty && positionActive)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
                child: ProximiteLegende(avecApproximatif: livreurs.any((l) => l.approximatif)),
              ),
            if (livreurs.isEmpty)
              _Vide(ville: ville)
            else
              for (final item in livreurs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LivreurCard(
                    item: item,
                    onTap: () => afficherFicheLivreur(context, item),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _SignalerButton extends StatelessWidget {
  const _SignalerButton();

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => context.push('/signaler'),
      icon: const Icon(AppIcons.flag, size: 18),
      label: const Text('Signaler'),
      style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
    );
  }
}

class _WhatsAppButton extends ConsumerWidget {
  final Livreur livreur;
  const _WhatsAppButton({required this.livreur});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () => lancerAppel(context, ref, livreur, whatsapp: true),
      tooltip: 'Appeler sur WhatsApp',
      icon: const Icon(AppIcons.whatsappLogo, size: 22),
      style: IconButton.styleFrom(
        foregroundColor: AppTheme.whatsapp,
        backgroundColor: const Color(0xFFE5F6EB),
        fixedSize: const Size(44, 44),
      ),
    );
  }
}

/// Invite à activer sa position ; une fois activée, les livreurs sont triés par distance.
class _PositionCard extends StatelessWidget {
  final bool active;
  final String ville;
  final ValueChanged<bool> onChanged;

  const _PositionCard({required this.active, required this.ville, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            const Icon(AppIcons.mapPinFill, size: 16, color: AppTheme.proche),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Position activée (démo : centre de $ville)',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
              ),
            ),
            TextButton(
              onPressed: () => onChanged(false),
              style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted, visualDensity: VisualDensity.compact),
              child: const Text('Désactiver'),
            ),
          ],
        ),
      );
    }
    return AppCard(
      child: Row(
        children: [
          const IconBadge(icon: AppIcons.crosshair, size: 40),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Activez votre position pour voir les livreurs les plus proches de vous.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink, height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => onChanged(true),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700),
            ),
            child: const Text('Activer'),
          ),
        ],
      ),
    );
  }
}

/// Rangée de pastilles à choix unique, défilable horizontalement.
class _Choix<T> extends StatelessWidget {
  final List<(T, String, IconData?)> options;
  final T valeur;
  final ValueChanged<T> onChanged;

  const _Choix({required this.options, required this.valeur, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final (option, label, icon) in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: option == valeur ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(color: option == valeur ? AppTheme.primary : AppTheme.line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: option == valeur ? Colors.white : AppTheme.inkMuted),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: option == valeur ? Colors.white : AppTheme.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LivreurCard extends ConsumerWidget {
  final LivreurProche item;
  final VoidCallback onTap;

  const _LivreurCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livreur = item.livreur;

    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              LivreurAvatar(nom: livreur.nom, photo: livreur.photo),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      livreur.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(livreur.vehicule.icon, size: 16, color: AppTheme.inkMuted),
                            const SizedBox(width: 6),
                            Text(
                              livreur.vehicule.label,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
                            ),
                          ],
                        ),
                        if (item.distanceKm != null) ProximitePill(proximite: item.proximite, approximatif: item.approximatif),
                      ],
                    ),
                    if (item.approximatif) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Basé à ${livreur.quartier} · position approximative',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.distanceKm != null) ...[
                const SizedBox(width: 12),
                DistanceTexte(distanceKm: item.distanceKm, approximatif: item.approximatif),
              ],
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider()),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatTelephone(livreur.telephone),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: 0.2),
                  ),
                ),
              ),
              if (livreur.whatsapp) ...[
                const SizedBox(width: 8),
                _WhatsAppButton(livreur: livreur),
              ],
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => lancerAppel(context, ref, livreur),
                icon: const Icon(AppIcons.phoneFill, size: 18),
                label: const Text('Appeler'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Vide extends StatelessWidget {
  final String ville;
  const _Vide({required this.ville});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          const IconBadge(icon: AppIcons.motorcycle, size: 64, color: AppTheme.inkFaint, background: Color(0xFFE9EDF2)),
          const SizedBox(height: 16),
          const Text('Aucun livreur disponible', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
          const SizedBox(height: 6),
          Text(
            'Pas de livreur disponible à $ville pour le moment. Essayez un autre véhicule ou revenez plus tard.',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
