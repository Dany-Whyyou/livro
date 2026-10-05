import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/app_icons.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _fullNumber => '+241${_ctrl.text.replaceAll(' ', '')}';

  Future<void> _continuer() async {
    if (!_formKey.currentState!.validate()) return;
    if (!ref.read(authProvider.notifier).estAdmin(_fullNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ce numéro n\'a pas d\'accès administrateur')));
      return;
    }
    setState(() => _loading = true);
    ref.read(authProvider.notifier).envoyerOtp(_fullNumber);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _loading = false);
      context.push('/otp', extra: _fullNumber);
    }
  }

  void _onIndicatifTap() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Seul le Gabon (+241) est disponible pour le moment'), duration: Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        body: SafeArea(
          // Défilable : évite le débordement sur petit écran quand le clavier est ouvert
          child: CustomScrollView(slivers: [SliverFillRemaining(hasScrollBody: false, child: _contenu())]),
        ),
      ),
    );
  }

  Widget _contenu() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const SizedBox(height: 48),
            const Text(
              'Votre numéro\nde téléphone',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppTheme.ink, height: 1.15, letterSpacing: -0.8),
            ),
            const SizedBox(height: 12),
            const Text(
              'Accès réservé aux administrateurs. Un code de vérification vous sera envoyé par SMS.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.45),
            ),
            const SizedBox(height: 32),
            _PhoneField(ctrl: _ctrl, focusNode: _focusNode, onIndicatifTap: _onIndicatifTap),
            const SizedBox(height: 12),
            const Text(
              'Mode démo : 077 00 00 01',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkFaint),
            ),
            const Spacer(),
            _ContinuerButton(loading: _loading, onPressed: _continuer),
            const SizedBox(height: 14),
            const Center(
              child: Text(
                'En continuant, vous acceptez nos CGU',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkFaint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        BrandMark(size: 44),
        SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Livro Admin',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.3, height: 1.2),
              ),
              SizedBox(height: 2),
              Text(
                'Gestion des livreurs',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkFaint, height: 1.2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focusNode;
  final VoidCallback onIndicatifTap;

  const _PhoneField({required this.ctrl, required this.focusNode, required this.onIndicatifTap});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      focusNode: focusNode,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, _GabonPhoneFormatter()],
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: AppTheme.ink),
      decoration: InputDecoration(
        hintText: '077 12 34 56',
        hintStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: Color(0xFFC3CBC8)),
        fillColor: AppTheme.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        // Indicatif (verrouillé sur Gabon)
        prefixIcon: GestureDetector(
          onTap: onIndicatifTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppTheme.line)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GabonFlag(),
                SizedBox(width: 8),
                Text(
                  '+241',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink),
                ),
                SizedBox(width: 4),
                Icon(AppIcons.caretDownBold, size: 12, color: AppTheme.inkFaint),
              ],
            ),
          ),
        ),
      ),
      validator: (v) {
        final digits = v?.replaceAll(' ', '') ?? '';
        if (digits.isEmpty) return 'Veuillez entrer votre numéro';
        if (digits.length < 9) return 'Numéro trop court (9 chiffres)';
        return null;
      },
    );
  }
}

// Format: 077 12 34 56 (9 chiffres, groupes 3-2-2-2)
class _GabonPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    if (digits.length > 9) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 5 || i == 7) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ContinuerButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _ContinuerButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(disabledBackgroundColor: AppTheme.primary),
      child: loading
          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Continuer'), SizedBox(width: 8), Icon(AppIcons.arrowRightBold, size: 18)]),
    );
  }
}
