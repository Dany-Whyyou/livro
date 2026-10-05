import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class ClientPhoneScreen extends ConsumerStatefulWidget {
  const ClientPhoneScreen({super.key});

  @override
  ConsumerState<ClientPhoneScreen> createState() => _ClientPhoneScreenState();
}

class _ClientPhoneScreenState extends ConsumerState<ClientPhoneScreen> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _fullNumber => '+241${_ctrl.text.trim().replaceAll(' ', '')}';

  Future<void> _continuer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    ref.read(clientAuthProvider.notifier).envoyerOtp(_fullNumber);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _loading = false);
      context.push('/auth/otp', extra: _fullNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop(), color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Icon(Icons.person_add_outlined, size: 56, color: Colors.white),
          const SizedBox(height: 12),
          const Text('Mon compte', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          const Text('Suivez vos livraisons et retrouvez votre historique', style: TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 28),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Numéro de téléphone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE0E0E0)), color: const Color(0xFFFAFAFA)),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seul le Gabon (+241) est disponible'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2))),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                              decoration: const BoxDecoration(border: Border(right: BorderSide(color: Color(0xFFE0E0E0)))),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Text('🇬🇦', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 6),
                                const Text('+241', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade400),
                              ]),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _ctrl,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, _GabonPhoneFormatter()],
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, letterSpacing: 1.2),
                              decoration: const InputDecoration(hintText: '077 12 34 56', hintStyle: TextStyle(color: Color(0xFFBDBDBD)), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                              validator: (v) {
                                final d = v?.replaceAll(' ', '') ?? '';
                                if (d.isEmpty) return 'Requis';
                                if (d.length < 9) return 'Numéro invalide (9 chiffres)';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Ex : 077 12 34 56', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _continuer,
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                        child: _loading
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text('Continuer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                              ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(child: Text('En continuant, vous acceptez nos CGU', style: TextStyle(fontSize: 11, color: Colors.grey))),
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
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
