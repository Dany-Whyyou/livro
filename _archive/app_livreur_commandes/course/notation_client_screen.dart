import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/models/course.dart';
import '../../providers/course_provider.dart';

class NotationClientScreen extends ConsumerStatefulWidget {
  final Course course;
  const NotationClientScreen({super.key, required this.course});

  @override
  ConsumerState<NotationClientScreen> createState() => _NotationClientScreenState();
}

class _NotationClientScreenState extends ConsumerState<NotationClientScreen> {
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
      if (mounted) {
        ref.read(courseActiveProvider.notifier).terminer();
        context.go('/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _submitted ? const _SuccessView() : _FormView(
          course: widget.course,
          note: _note,
          commentCtrl: _commentCtrl,
          onNoteChanged: (n) => setState(() => _note = n),
          onSoumettre: _note > 0 ? _soumettre : null,
          onPasser: () {
            ref.read(courseActiveProvider.notifier).terminer();
            context.go('/dashboard');
          },
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

  const _FormView({
    required this.course,
    required this.note,
    required this.commentCtrl,
    required this.onNoteChanged,
    required this.onSoumettre,
    required this.onPasser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                  child: const Icon(AppIcons.checkBold, size: 34, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Livraison effectuée',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  '${formatFcfa(course.prix)} encaissés · ${formatPoids(course.poids)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
                ),
                const SizedBox(height: 36),
                Text(
                  'Comment s\'est comporté ${course.clientNom} ?',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.ink),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _StarSelector(note: note, onChanged: onNoteChanged),
                const SizedBox(height: 28),
                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.ink),
                  decoration: const InputDecoration(hintText: 'Commentaire (optionnel)'),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Column(
            children: [
              FilledButton(onPressed: onSoumettre, child: const Text('Envoyer')),
              const SizedBox(height: 4),
              TextButton(
                onPressed: onPasser,
                style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
                child: const Text('Passer'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StarSelector extends StatelessWidget {
  final int note;
  final ValueChanged<int> onChanged;
  const _StarSelector({required this.note, required this.onChanged});

  static const _labels = ['', 'Mauvais', 'Passable', 'Bien', 'Très bien', 'Excellent'];

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
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Icon(
                  filled ? AppIcons.starFill : AppIcons.star,
                  size: 40,
                  color: filled ? AppTheme.secondary : const Color(0xFFC3CBC8),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            note > 0 ? _labels[note] : 'Touchez une étoile',
            key: ValueKey(note),
            style: TextStyle(
              fontSize: 14,
              fontWeight: note > 0 ? FontWeight.w700 : FontWeight.w500,
              color: note > 0 ? AppTheme.primary : AppTheme.inkFaint,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(color: AppTheme.primarySoft, shape: BoxShape.circle),
            child: const Icon(AppIcons.thumbsUpFill, size: 36, color: AppTheme.primary),
          ),
          const SizedBox(height: 20),
          const Text('Merci', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.6)),
          const SizedBox(height: 6),
          const Text('Votre avis a été envoyé.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.inkMuted)),
        ],
      ),
    );
  }
}
