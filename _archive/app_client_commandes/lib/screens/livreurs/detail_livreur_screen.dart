import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/livreur.dart';
import '../../data/models/course.dart';
import '../../providers/course_provider.dart';
import '../../core/theme/app_theme.dart';

class DetailLivreurScreen extends ConsumerWidget {
  final Livreur livreur;
  const DetailLivreurScreen({super.key, required this.livreur});

  Future<void> _appeler(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: livreur.telephone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _whatsapp(BuildContext context) async {
    final phone = livreur.telephone.replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _selectionner(BuildContext context, WidgetRef ref) {
    final course = Course(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      adresseDepart: 'Votre position',
      adresseDestination: 'Destination',
      poids: 1.0,
      prix: livreur.prixEstime(3.0),
      statut: StatutCourse.enAttente,
      livreurNom: livreur.nom,
      livreurTelephone: livreur.telephone,
      createdAt: DateTime.now(),
    );
    ref.read(courseNotifierProvider.notifier).demarrerCourse(course);
    context.go('/suivi');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail livreur'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Header(livreur: livreur),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoCard(livreur: livreur),
                  const SizedBox(height: 16),
                  _TarifCard(livreur: livreur),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _appeler(context),
                          icon: const Icon(Icons.phone, color: AppTheme.primary),
                          label: const Text('Appeler', style: TextStyle(color: AppTheme.primary)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            side: const BorderSide(color: AppTheme.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _whatsapp(context),
                          icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                          label: const Text('WhatsApp', style: TextStyle(color: Color(0xFF25D366))),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            side: const BorderSide(color: Color(0xFF25D366)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _selectionner(context, ref),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Sélectionner ce livreur'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Livreur livreur;
  const _Header({required this.livreur});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(livreur.vehiculeEmoji, style: const TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 12),
          Text(livreur.nom, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text('${livreur.note} (${livreur.nombreAvis} avis)', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Livreur livreur;
  const _InfoCard({required this.livreur});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 20),
            _InfoRow(Icons.directions_bike, 'Véhicule', '${livreur.vehiculeEmoji} ${livreur.vehiculeLabel}'),
            const SizedBox(height: 8),
            _InfoRow(Icons.location_on, 'Zone', '${livreur.zone} · ${livreur.ville}'),
            const SizedBox(height: 8),
            _InfoRow(Icons.near_me, 'Distance', '${livreur.distanceKm} km de vous'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text('$label : ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }
}

class _TarifCard extends StatelessWidget {
  final Livreur livreur;
  const _TarifCard({required this.livreur});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tarification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Prise en charge', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('${livreur.tarifBase.toInt()} FCFA', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Par kilomètre', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('${livreur.tarifKm.toInt()} FCFA/km', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimation (3 km)', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('~${livreur.prixEstime(3.0)} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Le prix final est négocié directement avec le livreur.', style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
