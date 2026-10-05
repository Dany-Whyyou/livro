import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/itineraire.dart';
import '../../data/models/course.dart';
import '../../providers/course_provider.dart';

class HistoriqueScreen extends ConsumerWidget {
  const HistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(historiqueLivreurProvider);
    final gainTotal = courses
        .where((c) => c.statut == StatutCourse.livree)
        .fold(0, (sum, c) => sum + c.prix);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _GainsCard(gainTotal: gainTotal, nbCourses: courses.length),
          const SizedBox(height: 28),
          if (courses.isEmpty)
            const _Vide()
          else ...[
            const SectionTitle('Courses effectuées'),
            for (final course in courses)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CourseCard(course: course),
              ),
          ],
        ],
      ),
    );
  }
}

class _GainsCard extends StatelessWidget {
  final int gainTotal;
  final int nbCourses;

  const _GainsCard({required this.gainTotal, required this.nbCourses});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gains totaux',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatNombre(gainTotal),
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1, height: 1.1),
              ),
              const SizedBox(width: 6),
              Text(
                'FCFA',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.75)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppIcons.package, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  nbCourses > 1 ? '$nbCourses courses livrées' : '$nbCourses course livrée',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM', 'fr_FR').format(course.createdAt);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                      '$date · ${formatPoids(course.poids)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatFcfa(course.prix),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primary),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider()),
          Itineraire(depart: course.adresseDepart, destination: course.adresseDestination),
        ],
      ),
    );
  }
}

class _Vide extends StatelessWidget {
  const _Vide();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          IconBadge(icon: AppIcons.clockCounterClockwise, size: 64, color: AppTheme.inkFaint, background: Color(0xFFEAEEEC)),
          SizedBox(height: 16),
          Text('Aucune course effectuée', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        ],
      ),
    );
  }
}
