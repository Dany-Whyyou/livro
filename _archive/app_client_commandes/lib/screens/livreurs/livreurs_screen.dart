import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/livreur.dart';
import '../../providers/livreurs_provider.dart';
import '../../core/theme/app_theme.dart';

class LivreursScreen extends ConsumerWidget {
  final String depart;
  final String destination;
  final double poids;

  const LivreursScreen({
    super.key,
    required this.depart,
    required this.destination,
    required this.poids,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livreurs = ref.watch(livreursProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livreurs disponibles'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          _CourseInfo(depart: depart, destination: destination, poids: poids),
          Expanded(
            child: livreurs.isEmpty
                ? const Center(child: Text('Aucun livreur disponible dans cette zone'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: livreurs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _LivreurCard(
                      livreur: livreurs[i],
                      poids: poids,
                      onTap: () => context.push('/livreur/${livreurs[i].id}', extra: livreurs[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CourseInfo extends StatelessWidget {
  final String depart;
  final String destination;
  final double poids;

  const _CourseInfo({required this.depart, required this.destination, required this.poids});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _Row(icon: Icons.location_on, color: AppTheme.primary, label: depart),
          const SizedBox(height: 8),
          _Row(icon: Icons.flag, color: AppTheme.secondary, label: destination),
          const SizedBox(height: 8),
          _Row(icon: Icons.scale, color: Colors.grey, label: '${poids.toStringAsFixed(1)} kg'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _Row({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}

class _LivreurCard extends StatelessWidget {
  final Livreur livreur;
  final double poids;
  final VoidCallback onTap;

  const _LivreurCard({required this.livreur, required this.poids, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prix = livreur.prixEstime(3.0);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                radius: 28,
                child: Text(livreur.vehiculeEmoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(livreur.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text('${livreur.note}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        Text('(${livreur.nombreAvis} avis)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: Colors.grey),
                        Text(' ${livreur.distanceKm} km · ${livreur.zone}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('~$prix FCFA', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary)),
                  const SizedBox(height: 4),
                  Text(livreur.vehiculeLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
