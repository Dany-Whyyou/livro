import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isNewUser;
  final String? telephone;

  const AuthState({
    this.isAuthenticated = false,
    this.isNewUser = false,
    this.telephone,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  // Numéros mock déjà enregistrés en base
  static const _registeredPhones = {'+241077000001', '+241062000002'};

  void envoyerOtp(String telephone) {
    // mock : simule l'envoi SMS
  }

  Future<bool> verifierOtpEtCheck(String telephone, String code) async {
    // Simule la vérification OTP + check DB (800ms)
    await Future.delayed(const Duration(milliseconds: 800));
    final isNew = !_registeredPhones.contains(telephone);
    state = AuthState(
      isAuthenticated: true,
      isNewUser: isNew,
      telephone: telephone,
    );
    return isNew;
  }

  void logout() => state = const AuthState();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
