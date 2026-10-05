import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/gabon_phone_formatter.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand.dart';
import '../../providers/signalements_provider.dart';

/// Signaler un livreur : son numéro, puis un message. [telephone] préremplit le numéro.
class SignalementScreen extends ConsumerStatefulWidget {
  final String? telephone;
  const SignalementScreen({super.key, this.telephone});

  @override
  ConsumerState<SignalementScreen> createState() => _SignalementScreenState();
}

class _SignalementScreenState extends ConsumerState<SignalementScreen> {
  static const _messageMin = 10;

  late final TextEditingController _telCtrl;
  final _messageCtrl = TextEditingController();
  String? _erreurTel;
  String? _erreurMessage;
  bool _envoi = false;
  bool _envoye = false;

  @override
  void initState() {
    super.initState();
    final local = widget.telephone?.replaceFirst('+241', '') ?? '';
    _telCtrl = TextEditingController(text: GabonPhoneFormatter.formatLocal(local));
  }

  @override
  void dispose() {
    _telCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    final chiffres = _telCtrl.text.replaceAll(' ', '');
    final message = _messageCtrl.text.trim();

    setState(() {
      _erreurTel = chiffres.length < 9 ? 'Le numéro doit avoir 9 chiffres' : null;
      _erreurMessage = message.length < _messageMin ? 'Décrivez ce qui s\'est passé (au moins $_messageMin caractères)' : null;
    });
    if (_erreurTel != null || _erreurMessage != null) return;

    FocusScope.of(context).unfocus();
    setState(() => _envoi = true);
    await ref.read(signalementsProvider.notifier).envoyer(telephoneLivreur: '+241$chiffres', message: message);
    if (!mounted) return;
    setState(() {
      _envoi = false;
      _envoye = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signaler un livreur'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(AppIcons.arrowLeft, size: 22),
        ),
      ),
      body: _envoye ? _Confirmation(onRetour: () => context.pop()) : _formulaire(),
      bottomNavigationBar: _envoye
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(top: BorderSide(color: AppTheme.line)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: FilledButton(
                    onPressed: _envoi ? null : _envoyer,
                    style: FilledButton.styleFrom(disabledBackgroundColor: AppTheme.primary),
                    child: _envoi
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Envoyer le signalement'),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _formulaire() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Text(
          'Un problème avec un livreur ? Indiquez son numéro et expliquez ce qui s\'est passé. Notre équipe examine chaque signalement.',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.45),
        ),
        const SizedBox(height: 24),
        const SectionTitle('Numéro du livreur'),
        TextField(
          controller: _telCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, GabonPhoneFormatter()],
          onChanged: (_) {
            if (_erreurTel != null) setState(() => _erreurTel = null);
          },
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppTheme.ink),
          decoration: InputDecoration(
            hintText: '077 12 34 56',
            errorText: _erreurTel,
            prefixIcon: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppTheme.line))),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GabonFlag(),
                  SizedBox(width: 8),
                  Text('+241', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle('Votre message'),
        TextField(
          controller: _messageCtrl,
          minLines: 5,
          maxLines: 8,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            if (_erreurMessage != null) setState(() => _erreurMessage = null);
          },
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.ink, height: 1.45),
          decoration: InputDecoration(
            hintText: 'Ex. : colis non livré, retard important, comportement...',
            hintMaxLines: 3,
            errorText: _erreurMessage,
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}

class _Confirmation extends StatelessWidget {
  final VoidCallback onRetour;
  const _Confirmation({required this.onRetour});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              child: const Icon(AppIcons.checkBold, size: 34, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Signalement envoyé',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Merci. Notre équipe va l\'examiner et prendre les mesures nécessaires.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton(onPressed: onRetour, child: const Text('Retour aux livreurs')),
          ],
        ),
      ),
    );
  }
}
