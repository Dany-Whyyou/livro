import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/app_icons.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String telephone;
  const OtpScreen({super.key, required this.telephone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _longueur = 6;

  final _controllers = List.generate(_longueur, (_) => TextEditingController());
  final _focusNodes = List.generate(_longueur, (_) => FocusNode());
  bool _loading = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _valider() async {
    if (_code.length < _longueur) return;
    setState(() => _loading = true);

    await ref.read(authProvider.notifier).verifierOtp(widget.telephone, _code);

    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/livreurs');
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _longueur - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
    if (_code.length == _longueur) _valider();
  }

  void _renvoyer() {
    ref.read(authProvider.notifier).envoyerOtp(widget.telephone);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Un nouveau code a été envoyé'), duration: Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(AppIcons.arrowLeft, size: 22)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Code de\nvérification',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppTheme.ink, height: 1.15, letterSpacing: -0.8),
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  text: 'Saisissez le code envoyé au\n',
                  children: [
                    TextSpan(
                      text: formatTelephone(widget.telephone),
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.inkMuted, height: 1.45),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  for (int i = 0; i < _longueur; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _OtpBox(controller: _controllers[i], focusNode: _focusNodes[i], onChanged: (v) => _onDigitChanged(i, v)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Mode démo : n\'importe quel code à $_longueur chiffres',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.inkFaint),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _loading || _code.length < _longueur ? null : _valider,
                style: _loading ? FilledButton.styleFrom(disabledBackgroundColor: AppTheme.primary) : null,
                child: _loading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Valider'),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _loading ? null : _renvoyer,
                  icon: const Icon(AppIcons.arrowClockwiseBold, size: 16),
                  label: const Text('Renvoyer le code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 1,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.ink),
      decoration: const InputDecoration(counterText: '', fillColor: AppTheme.background, contentPadding: EdgeInsets.symmetric(vertical: 18)),
      onChanged: onChanged,
    );
  }
}
