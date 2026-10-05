import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _departCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  double _poids = 1.0;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _departCtrl.dispose();
    _destinationCtrl.dispose();
    super.dispose();
  }

  void _chercher() {
    if (!_formKey.currentState!.validate()) return;
    context.push('/livreurs', extra: {
      'depart': _departCtrl.text.trim(),
      'destination': _destinationCtrl.text.trim(),
      'poids': _poids,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gabon Livreur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Banner(),
              const SizedBox(height: 24),
              const Text('Où récupérer votre colis ?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _departCtrl,
                decoration: const InputDecoration(
                  hintText: 'Adresse ou lieu de départ',
                  prefixIcon: Icon(Icons.location_on, color: AppTheme.primary),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              const Text('Où livrer ?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _destinationCtrl,
                decoration: const InputDecoration(
                  hintText: 'Adresse ou lieu de destination',
                  prefixIcon: Icon(Icons.flag, color: AppTheme.secondary),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 24),
              _PoidsSelector(
                poids: _poids,
                onChanged: (v) => setState(() => _poids = v),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _chercher,
                icon: const Icon(Icons.search),
                label: const Text('Trouver un livreur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Livraison rapide', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Livreurs disponibles près de vous', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.delivery_dining, color: Colors.white, size: 48),
        ],
      ),
    );
  }
}

class _PoidsSelector extends StatelessWidget {
  final double poids;
  final ValueChanged<double> onChanged;

  const _PoidsSelector({required this.poids, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Poids du colis', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${poids.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
            ),
          ],
        ),
        Slider(
          value: poids,
          min: 0.5,
          max: 30.0,
          divisions: 59,
          activeColor: AppTheme.primary,
          onChanged: onChanged,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0.5 kg', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('30 kg', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
