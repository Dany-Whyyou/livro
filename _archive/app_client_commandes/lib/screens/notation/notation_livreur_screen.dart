import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/course.dart';

class NotationLivreurScreen extends ConsumerStatefulWidget {
  final Course course;
  const NotationLivreurScreen({super.key, required this.course});

  @override
  ConsumerState<NotationLivreurScreen> createState() => _NotationLivreurScreenState();
}

class _NotationLivreurScreenState extends ConsumerState<NotationLivreurScreen> {
  int _note = 0;
  final _commentCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _soumettre() {
    setState(() => _submitted = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F5),
        body: SafeArea(
          child: _submitted ? _SuccessView() : _FormView(
            course: widget.course,
            note: _note,
            commentCtrl: _commentCtrl,
            onNoteChanged: (n) => setState(() => _note = n),
            onSoumettre: _note > 0 ? _soumettre : null,
            onPasser: () => context.go('/home'),
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final Course course;
  final int note;
  final TextEditingController commentCtrl;
  final ValueChanged<int> onNoteChanged;
  final VoidCallback? onSoumettre;
  final VoidCallback onPasser;

  const _FormView({required this.course, required this.note, required this.commentCtrl, required this.onNoteChanged, required this.onSoumettre, required this.onPasser});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.local_shipping, size: 44, color: AppTheme.secondary),
                ),
                const SizedBox(height: 16),
                const Text('Livraison reçue !', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Comment s\'est passée votre livraison avec ${course.livreurNom} ?', style: const TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                _StarSelector(note: note, onChanged: onNoteChanged),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                  child: TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Commentaire (optionnel)...', border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Info(Icons.location_on, course.adresseDestination),
                      Container(width: 1, height: 30, color: Colors.grey.shade200),
                      _Info(Icons.monetization_on, '${course.prix} FCFA'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: onSoumettre,
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('Envoyer mon avis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              TextButton(onPressed: onPasser, child: const Text('Passer', style: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Info(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        SizedBox(width: 100, child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _StarSelector extends StatelessWidget {
  final int note;
  final ValueChanged<int> onChanged;
  const _StarSelector({required this.note, required this.onChanged});

  static const _labels = ['', 'Très mauvais', 'Mauvais', 'Correct', 'Bien', 'Excellent'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final filled = i < note;
            return GestureDetector(
              onTap: () => onChanged(i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(filled ? Icons.star_rounded : Icons.star_outline_rounded, size: 48, color: filled ? AppTheme.secondary : Colors.grey.shade300),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(note > 0 ? _labels[note] : 'Touchez une étoile', key: ValueKey(note), style: TextStyle(fontSize: 14, color: note > 0 ? AppTheme.primary : Colors.grey, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎉', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text('Merci pour votre avis !', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Cela aide les autres clients à choisir.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
