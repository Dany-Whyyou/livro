import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admins_provider.dart';

class AuthState {
  final bool isAuthenticated;
  final String? telephone;

  const AuthState({this.isAuthenticated = false, this.telephone});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthState());

  /// Seuls les numéros de la liste des admins peuvent se connecter.
  bool estAdmin(String telephone) => _ref.read(adminsProvider).any((a) => a.telephone == telephone);

  void envoyerOtp(String telephone) {
    // mock : simule l'envoi SMS
  }

  Future<void> verifierOtp(String telephone, String code) async {
    // Simule la vérification OTP (800ms)
    await Future.delayed(const Duration(milliseconds: 800));
    state = AuthState(isAuthenticated: true, telephone: telephone);
  }

  void logout() => state = const AuthState();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));
