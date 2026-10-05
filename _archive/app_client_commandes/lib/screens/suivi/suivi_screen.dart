import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/course.dart';
import '../../providers/course_provider.dart';
import '../../core/theme/app_theme.dart';

class SuiviScreen extends ConsumerWidget {
  const SuiviScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseNotifierProvider);

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Suivi de course')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Aucune course en cours'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Retour à l\'accueil')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de course'),
        leading: BackButton(onPressed: () => context.go('/home')),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatutBanner(statut: course.statut),
                  const SizedBox(height: 20),
                  _Timeline(statut: course.statut),
                  const SizedBox(height: 20),
                  _CourseDetails(course: course),
                  const SizedBox(height: 20),
                  _LivreurContact(course: course),
                ],
              ),
            ),
          ),
          _SimulationBar(ref: ref, course: course),
        ],
      ),
    );
  }
}

class _StatutBanner extends StatelessWidget {
  final StatutCourse statut;
  const _StatutBanner({required this.statut});

  Color get _color {
    switch (statut) {
      case StatutCourse.enAttente:
        return Colors.orange;
      case StatutCourse.acceptee:
        return Colors.blue;
      case StatutCourse.enCours:
        return AppTheme.primary;
      case StatutCourse.livree:
        return AppTheme.primary;
      case StatutCourse.annulee:
        return Colors.red;
    }
  }

  IconData get _icon {
    switch (statut) {
      case StatutCourse.enAttente:
        return Icons.hourglass_empty;
      case StatutCourse.acceptee:
        return Icons.thumb_up;
      case StatutCourse.enCours:
        return Icons.delivery_dining;
      case StatutCourse.livree:
        return Icons.check_circle;
      case StatutCourse.annulee:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Statut actuel', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                _label(statut),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _label(StatutCourse s) {
    switch (s) {
      case StatutCourse.enAttente:
        return 'En attente du livreur';
      case StatutCourse.acceptee:
        return 'Livreur en route';
      case StatutCourse.enCours:
        return 'Livraison en cours';
      case StatutCourse.livree:
        return 'Livraison effectuée !';
      case StatutCourse.annulee:
        return 'Course annulée';
    }
  }
}

class _Timeline extends StatelessWidget {
  final StatutCourse statut;
  const _Timeline({required this.statut});

  int get _step {
    switch (statut) {
      case StatutCourse.enAttente:
        return 0;
      case StatutCourse.acceptee:
        return 1;
      case StatutCourse.enCours:
        return 2;
      case StatutCourse.livree:
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['En attente', 'Acceptée', 'En cours', 'Livrée'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Progression', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ...List.generate(steps.length, (i) {
              final done = i <= _step;
              final active = i == _step;
              return Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done ? AppTheme.primary : Colors.grey.shade200,
                          border: active ? Border.all(color: AppTheme.primary, width: 3) : null,
                        ),
                        child: done
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                      if (i < steps.length - 1)
                        Container(width: 2, height: 24, color: done ? AppTheme.primary : Colors.grey.shade200),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      steps[i],
                      style: TextStyle(
                        fontWeight: active ? FontWeight.bold : FontWeight.normal,
                        color: done ? AppTheme.primary : Colors.grey,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CourseDetails extends StatelessWidget {
  final Course course;
  const _CourseDetails({required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Détails', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 20),
            _Row(Icons.location_on, 'Départ', course.adresseDepart, AppTheme.primary),
            const SizedBox(height: 8),
            _Row(Icons.flag, 'Destination', course.adresseDestination, AppTheme.secondary),
            const SizedBox(height: 8),
            _Row(Icons.monetization_on, 'Prix', '${course.prix} FCFA', Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _Row(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text('$label : ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
      ],
    );
  }
}

class _LivreurContact extends StatelessWidget {
  final Course course;
  const _LivreurContact({required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Votre livreur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 20),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(course.livreurNom, style: const TextStyle(fontWeight: FontWeight.w600))),
                IconButton(
                  onPressed: () async {
                    final uri = Uri(scheme: 'tel', path: course.livreurTelephone);
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                  icon: const Icon(Icons.phone, color: AppTheme.primary),
                ),
                IconButton(
                  onPressed: () async {
                    final phone = course.livreurTelephone.replaceAll('+', '');
                    final uri = Uri.parse('https://wa.me/$phone');
                    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Pour annuler, contactez directement le livreur.',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimulationBar extends StatelessWidget {
  final WidgetRef ref;
  final Course course;
  const _SimulationBar({required this.ref, required this.course});

  @override
  Widget build(BuildContext context) {
    if (course.statut == StatutCourse.livree) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => context.go('/notation-livreur', extra: course),
            icon: const Icon(Icons.star_outline),
            label: const Text('Noter le livreur'),
          ),
        ),
      );
    }
    if (course.statut == StatutCourse.annulee) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Retour à l\'accueil'),
          ),
        ),
      );
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('[MOCK] Simuler le prochain statut', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => ref.read(courseNotifierProvider.notifier).avancerStatut(),
              icon: const Icon(Icons.skip_next),
              label: const Text('Avancer le statut'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
