import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class ClientOtpScreen extends ConsumerStatefulWidget {
  final String telephone;
  const ClientOtpScreen({super.key, required this.telephone});

  @override
  ConsumerState<ClientOtpScreen> createState() => _ClientOtpScreenState();
}

class _ClientOtpScreenState extends ConsumerState<ClientOtpScreen> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());
  bool _loading = false;

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _valider() async {
    if (_code.length < 4) return;
    setState(() => _loading = true);
    await ref.read(clientAuthProvider.notifier).verifierOtp(widget.telephone, _code);
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/home');
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) _focusNodes[index + 1].requestFocus();
    if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
    if (_code.length == 4) _valider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(backgroundColor: AppTheme.primary, elevation: 0, leading: BackButton(onPressed: () => context.pop(), color: Colors.white)),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Container(width: 72, height: 72, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle), child: const Icon(Icons.sms_outlined, size: 36, color: Colors.white)),
          const SizedBox(height: 16),
          const Text('Code de vérification', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text('Envoyé au ${widget.telephone}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const Text('[MOCK] N\'importe quel code à 4 chiffres', style: TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) => _OtpBox(controller: _controllers[i], focusNode: _focusNodes[i], onChanged: (v) => _onDigitChanged(i, v))),
                    ),
                    const SizedBox(height: 32),
                    _loading
                        ? const CircularProgressIndicator(color: AppTheme.primary)
                        : SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _code.length == 4 ? _valider : null,
                              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              child: const Text('Valider', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                    const SizedBox(height: 16),
                    TextButton.icon(onPressed: () {}, icon: const Icon(Icons.refresh, size: 16, color: AppTheme.primary), label: const Text('Renvoyer le code', style: TextStyle(color: AppTheme.primary))),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    return Container(
      width: 62, height: 68,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      child: TextField(
        controller: controller, focusNode: focusNode,
        keyboardType: TextInputType.number, textAlign: TextAlign.center, maxLength: 1,
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '', filled: true, fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
