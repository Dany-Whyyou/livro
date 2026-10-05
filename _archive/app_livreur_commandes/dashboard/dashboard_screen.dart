import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/itineraire.dart';
import '../../providers/disponibilite_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/profil_provider.dart';
import '../../data/models/course.dart';
import 'widgets/nouvelle_course_dialog.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disponible = ref.watch(disponibleProvider);
    final courseActive = ref.watch(courseActiveProvider);
    final nouvelles = ref.watch(nouvellesCoursesMockProvider);
    final profil = ref.watch(profilProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _Header(nom: profil.nom),
            const SizedBox(height: 24),
            _DisponibiliteCard(disponible: disponible, onChanged: (v) {
              ref.read(disponibleProvider.notifier).state = v;
            }),
            const SizedBox(height: 12),
            const _StatsRow(),
            const SizedBox(height: 28),
            if (courseActive != null) ...[
              const SectionTitle('Course en cours'),
              _CourseActiveCard(course: courseActive),
            ],
            if (disponible && courseActive == null) ...[
              SectionTitle(
                'Nouvelles demandes',
                trailing: StatusPill(
                  label: '${nouvelles.length}',
                  color: AppTheme.secondaryInk,
                  background: AppTheme.secondarySoft,
                ),
              ),
              ...nouvelles.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NouvelleDemandeCard(
                  course: c,
                  onVoir: () => _voirDemande(context, ref, c),
                ),
              )),
            ],
            if (!disponible && courseActive == null)
              const _HorsLigneCard(),
          ],
        ),
      ),
    );
  }

  void _voirDemande(BuildContext context, WidgetRef ref, Course course) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) => NouvelleCourseSheet(
        course: course,
        onAccepter: () {
          ref.read(courseActiveProvider.notifier).accepter(course);
          Navigator.of(sheetContext).pop();
        },
        onRefuser: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String nom;
  const _Header({required this.nom});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());
    final prenom = nom.trim().split(' ').first;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date[0].toUpperCase() + date.substring(1),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkFaint),
              ),
              const SizedBox(height: 4),
              Text(
                'Bonjour, $prenom',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.6, height: 1.2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => context.go('/profil'),
          child: InitialesAvatar(texte: initiales(nom), size: 48),
        ),
      ],
    );
  }
}

class _DisponibiliteCard extends StatelessWidget {
  final bool disponible;
  final ValueChanged<bool> onChanged;

  const _DisponibiliteCard({required this.disponible, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final fg = disponible ? Colors.white : AppTheme.ink;
    final fgMuted = disponible ? Colors.white.withValues(alpha: 0.75) : AppTheme.inkMuted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
      decoration: BoxDecoration(
        color: disponible ? AppTheme.primary : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: disponible ? AppTheme.primary : AppTheme.line),
      ),
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
                  disponible ? 'En ligne' : 'Hors ligne',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: fg, letterSpacing: -0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  disponible ? 'Vous recevez des demandes' : 'Vous ne recevez pas de demandes',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: fgMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: disponible,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFCBD3D0),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: _StatCard(label: 'Courses aujourd\'hui', value: '3', icon: AppIcons.package),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(label: 'Gains du jour', value: formatNombre(4500), unit: 'FCFA', icon: AppIcons.wallet),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon, this.unit});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, size: 36),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.5, height: 1.2),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(unit!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.inkFaint)),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkMuted)),
        ],
      ),
    );
  }
}

class _NouvelleDemandeCard extends StatelessWidget {
  final Course course;
  final VoidCallback onVoir;

  const _NouvelleDemandeCard({required this.course, required this.onVoir});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialesAvatar(texte: initiales(course.clientNom), size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.clientNom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Colis de ${formatPoids(course.poids)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatFcfa(course.prix),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -0.3),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider()),
          Itineraire(depart: course.adresseDepart, destination: course.adresseDestination),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onVoir,
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            child: const Text('Voir la demande'),
          ),
        ],
      ),
    );
  }
}

class _CourseActiveCard extends StatelessWidget {
  final Course course;
  const _CourseActiveCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: AppTheme.primary,
      onTap: () => context.go('/course'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(label: course.statutLabel),
              const Spacer(),
              Text(
                formatFcfa(course.prix),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Itineraire(depart: course.adresseDepart, destination: course.adresseDestination),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider()),
          const Row(
            children: [
              Expanded(
                child: Text('Reprendre la course', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ),
              Icon(AppIcons.arrowRightBold, size: 18, color: AppTheme.primary),
            ],
          ),
        ],
      ),
    );
  }
}

class _HorsLigneCard extends StatelessWidget {
  const _HorsLigneCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          IconBadge(icon: AppIcons.wifiSlash, size: 64, color: AppTheme.inkFaint, background: Color(0xFFEAEEEC)),
          SizedBox(height: 16),
          Text('Vous êtes hors ligne', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
          SizedBox(height: 6),
          Text(
            'Activez votre disponibilité pour recevoir des demandes',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
