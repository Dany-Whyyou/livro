import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/tarif_slider.dart';
import '../../core/widgets/vehicule.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profil_provider.dart';

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  late TextEditingController _nomCtrl;
  late String _vehicule;
  late String _ville;
  late Map<String, int> _tarifs;
  bool _saving = false;

  static const _villes = ['Libreville', 'Owendo', 'Ntoum', 'Port-Gentil', 'Franceville', 'Lambaréné', 'Oyem', 'Mouila'];
  bool get _isLibreville => _ville == 'Libreville';

  @override
  void initState() {
    super.initState();
    final p = ref.read(profilProvider);
    _nomCtrl = TextEditingController(text: p.nom);
    _vehicule = p.vehicule;
    _ville = p.ville;
    _tarifs = Map.from(p.tarifs);
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final current = ref.read(profilProvider);
    ref.read(profilProvider.notifier).update(
          current.copyWith(nom: _nomCtrl.text.trim(), vehicule: _vehicule, ville: _ville, tarifs: _tarifs),
        );
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mis à jour')),
    );
  }

  void _deconnecter() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Vous ne recevrez plus de demandes de livraison.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _saving ? null : _sauvegarder,
              child: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IdentiteCard(profil: profil),
            const SizedBox(height: 28),
            const SectionTitle('Informations'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _FieldRow(label: 'Téléphone', value: formatTelephone(profil.telephone), editable: false),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        const Text('Nom', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.inkMuted)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _nomCtrl,
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
                ],
              ),
            ),
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
                  _ville = v;
                  if (v == 'Libreville' && !_tarifs.containsKey('Libreville')) {
                    _tarifs = {'Libreville': 1000, 'Owendo': 800, 'Akanda': 1200};
                  } else if (v != 'Libreville' && !_tarifs.containsKey('general')) {
                    _tarifs = {'general': 800};
                  }
                });
              },
            ),
            const SizedBox(height: 28),
            const SectionTitle('Tarifs'),
            _TarifsSection(
              isLibreville: _isLibreville,
              tarifs: _tarifs,
              onChanged: (key, val) => setState(() => _tarifs[key] = val),
            ),
            const SizedBox(height: 28),
            const SectionTitle('Compte'),
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
    );
  }
}

class _IdentiteCard extends StatelessWidget {
  final LivreurProfil profil;
  const _IdentiteCard({required this.profil});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          InitialesAvatar(
            texte: initiales(profil.nom),
            size: 60,
            color: Colors.white,
            background: AppTheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profil.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.3),
                ),
                const SizedBox(height: 6),
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
    );
  }
}

class _TarifsSection extends StatelessWidget {
  final bool isLibreville;
  final Map<String, int> tarifs;
  final void Function(String, int) onChanged;

  const _TarifsSection({required this.isLibreville, required this.tarifs, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (isLibreville) {
      return Column(
        children: [
          _TarifTile(label: 'Libreville', subtitle: 'Centre, Montagne Sainte...', tarifKey: 'Libreville', tarifs: tarifs, onChanged: onChanged),
          const SizedBox(height: 12),
          _TarifTile(label: 'Owendo', subtitle: 'Zone industrielle...', tarifKey: 'Owendo', tarifs: tarifs, onChanged: onChanged),
          const SizedBox(height: 12),
          _TarifTile(label: 'Akanda', subtitle: 'Angondjé, PK8...', tarifKey: 'Akanda', tarifs: tarifs, onChanged: onChanged),
        ],
      );
    }
    return _TarifTile(label: 'Prise en charge', subtitle: 'Tarif pour toute livraison', tarifKey: 'general', tarifs: tarifs, onChanged: onChanged);
  }
}

class _TarifTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final String tarifKey;
  final Map<String, int> tarifs;
  final void Function(String, int) onChanged;

  const _TarifTile({required this.label, required this.subtitle, required this.tarifKey, required this.tarifs, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkMuted)),
          const SizedBox(height: 14),
          TarifSlider(
            value: tarifs[tarifKey] ?? 500,
            onChanged: (v) => onChanged(tarifKey, v),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final bool editable;
  const _FieldRow({required this.label, required this.value, this.editable = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.inkMuted)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: editable ? AppTheme.ink : AppTheme.inkMuted),
          ),
          if (!editable) ...[
            const SizedBox(width: 8),
            const Icon(AppIcons.lockSimple, size: 16, color: AppTheme.inkFaint),
          ],
        ],
      ),
    );
  }
}
