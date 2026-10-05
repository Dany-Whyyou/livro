import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/icons/app_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/itineraire.dart';
import '../../data/models/course.dart';
import '../../providers/course_provider.dart';

class CourseEnCoursScreen extends ConsumerWidget {
  const CourseEnCoursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseActiveProvider);
    final appBar = AppBar(
      title: const Text('Course en cours'),
      leading: IconButton(
        onPressed: () => context.go('/dashboard'),
        icon: const Icon(AppIcons.arrowLeft, size: 22),
      ),
    );

    if (course == null) {
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const IconBadge(icon: AppIcons.package, size: 64),
                const SizedBox(height: 16),
                const Text('Aucune course active', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                const SizedBox(height: 24),
                FilledButton(onPressed: () => context.go('/dashboard'), child: const Text('Retour à l\'accueil')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatutCard(statut: course.statut),
                  const SizedBox(height: 12),
                  _ClientCard(course: course),
                  const SizedBox(height: 12),
                  _CourseInfoCard(course: course),
                ],
              ),
            ),
          ),
          _ActionBar(course: course, ref: ref),
        ],
      ),
    );
  }
}

class _StatutCard extends StatelessWidget {
  final StatutCourse statut;
  const _StatutCard({required this.statut});

  @override
  Widget build(BuildContext context) {
    final (titre, detail, etape) = switch (statut) {
      StatutCourse.acceptee => ('En route vers le colis', 'Rendez-vous au point de retrait', 0),
      StatutCourse.enCours => ('Livraison en cours', 'Remettez le colis au destinataire', 1),
      StatutCourse.livree => ('Livraison effectuée', 'Le colis a bien été remis', 2),
      _ => ('En attente', 'En attente de confirmation', 0),
    };

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.4)),
          const SizedBox(height: 4),
          Text(detail, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.inkMuted)),
          const SizedBox(height: 18),
          _Etapes(etape: etape, terminee: statut == StatutCourse.livree),
        ],
      ),
    );
  }
}

class _Etapes extends StatelessWidget {
  final int etape;
  final bool terminee;
  const _Etapes({required this.etape, required this.terminee});

  static const _labels = ['Retrait', 'Livraison', 'Remis'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= etape ? AppTheme.primary : AppTheme.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: i == etape ? FontWeight.w700 : FontWeight.w600,
                    color: i == etape
                        ? AppTheme.primary
                        : i < etape
                            ? AppTheme.inkMuted
                            : AppTheme.inkFaint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Course course;
  const _ClientCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          InitialesAvatar(texte: initiales(course.clientNom)),
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
                  formatTelephone(course.clientTelephone),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ContactButton(
            icon: AppIcons.phoneFill,
            color: AppTheme.primary,
            background: AppTheme.primarySoft,
            tooltip: 'Appeler',
            onPressed: () async {
              final uri = Uri(scheme: 'tel', path: course.clientTelephone);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
          const SizedBox(width: 8),
          _ContactButton(
            icon: AppIcons.whatsappLogoFill,
            color: AppTheme.whatsapp,
            background: const Color(0xFFE5F6EB),
            tooltip: 'WhatsApp',
            onPressed: () async {
              final phone = course.clientTelephone.replaceAll('+', '');
              final uri = Uri.parse('https://wa.me/$phone');
              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String tooltip;
  final VoidCallback onPressed;

  const _ContactButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: background,
        foregroundColor: color,
        fixedSize: const Size(44, 44),
      ),
    );
  }
}

class _CourseInfoCard extends StatelessWidget {
  final Course course;
  const _CourseInfoCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Itineraire(depart: course.adresseDepart, destination: course.adresseDestination),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider()),
          Row(
            children: [
              const Icon(AppIcons.package, size: 18, color: AppTheme.inkMuted),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Poids du colis', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.inkMuted)),
              ),
              Text(formatPoids(course.poids), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.ink)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider()),
          Row(
            children: [
              const Expanded(
                child: Text('Montant à collecter', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.ink)),
              ),
              Text(
                formatFcfa(course.prix),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -0.4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final Course course;
  final WidgetRef ref;
  const _ActionBar({required this.course, required this.ref});

  @override
  Widget build(BuildContext context) {
    final Widget bouton;
    if (course.statut == StatutCourse.livree) {
      bouton = FilledButton.icon(
        onPressed: () => context.go('/notation-client', extra: course),
        icon: const Icon(AppIcons.starBold, size: 18),
        label: const Text('Noter le client'),
      );
    } else {
      final enRoute = course.statut == StatutCourse.acceptee;
      bouton = FilledButton.icon(
        onPressed: () => ref.read(courseActiveProvider.notifier).avancer(),
        icon: Icon(enRoute ? AppIcons.packageBold : AppIcons.checkBold, size: 18),
        label: Text(enRoute ? 'Colis récupéré' : 'Marquer comme livrée'),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 12), child: bouton),
      ),
    );
  }
}
