import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/mock_data.dart';
import '../data/models/admin.dart';

class AdminsNotifier extends StateNotifier<List<Admin>> {
  AdminsNotifier() : super(mockAdmins);

  int _prochainId = mockAdmins.length + 1;

  bool numeroDejaPris(String telephone) => state.any((a) => a.telephone == telephone);

  void ajouter({required String nom, required String telephone}) {
    state = [...state, Admin(id: '${_prochainId++}', nom: nom, telephone: telephone)];
  }

  void retirer(String id) {
    state = state.where((a) => a.id != id).toList();
  }
}

final adminsProvider = StateNotifierProvider<AdminsNotifier, List<Admin>>((ref) => AdminsNotifier());
