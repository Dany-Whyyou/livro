import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/course.dart';
import '../../providers/course_provider.dart';
import '../../core/theme/app_theme.dart';

class HistoriqueScreen extends ConsumerWidget {
  const HistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(historiqueProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes livraisons')),
      body: courses.isEmpty
          ? const Center(child: Text('Aucune livraison pour le moment'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _CourseCard(course: courses[i]),
            ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  const _CourseCard({required this.course});

  Color get _statutColor {
    switch (course.statut) {
      case StatutCourse.livree:
        return AppTheme.primary;
      case StatutCourse.annulee:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(course.livreurNom, style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statutColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(course.statutLabel, style: TextStyle(fontSize: 12, color: _statutColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const Divider(height: 16),
            _Row(Icons.location_on, course.adresseDepart, AppTheme.primary),
            const SizedBox(height: 4),
            _Row(Icons.flag, course.adresseDestination, AppTheme.secondary),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${course.prix} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                if (course.statut == StatutCourse.livree)
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < 5 ? Icons.star : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    )),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Row(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
