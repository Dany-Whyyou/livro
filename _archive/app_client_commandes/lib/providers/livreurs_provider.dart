import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/livreur.dart';
import '../data/mock/mock_data.dart';

final livreursProvider = Provider<List<Livreur>>((ref) {
  return mockLivreurs.where((l) => l.disponible).toList()
    ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
});
