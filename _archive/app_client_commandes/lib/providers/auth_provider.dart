import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientAuthState {
  final bool isAuthenticated;
  final String? telephone;

  const ClientAuthState({this.isAuthenticated = false, this.telephone});
}

class ClientAuthNotifier extends StateNotifier<ClientAuthState> {
  ClientAuthNotifier() : super(const ClientAuthState());

  void envoyerOtp(String telephone) {}

  Future<void> verifierOtp(String telephone, String code) async {
    await Future.delayed(const Duration(milliseconds: 800));
    state = ClientAuthState(isAuthenticated: true, telephone: telephone);
  }

  void logout() => state = const ClientAuthState();
}

final clientAuthProvider = StateNotifierProvider<ClientAuthNotifier, ClientAuthState>(
  (ref) => ClientAuthNotifier(),
);
