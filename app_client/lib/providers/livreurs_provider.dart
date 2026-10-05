import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/distance.dart';
import '../data/models/livreur.dart';
import '../data/mock/mock_data.dart';
import '../data/quartiers.dart';
import 'position_provider.dart';

const villes = ['Libreville', 'Owendo', 'Ntoum', 'Port-Gentil', 'Franceville', 'Lambaréné', 'Oyem', 'Mouila'];

final villeProvider = StateProvider<String>((ref) => 'Libreville');

/// null = tous les véhicules
final vehiculeFiltreProvider = StateProvider<TypeVehicule?>((ref) => null);

/// Position du client, ou null s'il ne l'a pas activée.
final positionClientProvider = Provider<Coordonnees?>((ref) => ref.watch(positionProvider).coordonnees);

LivreurProche _avecDistance(Livreur l, Coordonnees? client) {
  if (client == null) return LivreurProche(l, null);
  if (l.position != null) return LivreurProche(l, distanceKm(client, l.position!));
  final quartier = centreQuartier(l.ville, l.quartier);
  if (quartier != null) return LivreurProche(l, distanceKm(client, quartier), approximatif: true);
  return LivreurProche(l, null);
}

/// Livreurs disponibles pour la ville et le véhicule choisis, du plus proche au plus lointain.
/// Ceux dont la position est inconnue viennent en dernier ; sans position du client, ordre alphabétique.
final livreursProvider = Provider<List<LivreurProche>>((ref) {
  final ville = ref.watch(villeProvider);
  final vehicule = ref.watch(vehiculeFiltreProvider);
  final client = ref.watch(positionClientProvider);

  final liste = [
    for (final l in mockLivreurs)
      if (l.disponible && l.ville == ville && (vehicule == null || l.vehicule == vehicule)) _avecDistance(l, client),
  ];
  liste.sort((a, b) {
    final da = a.distanceKm, db = b.distanceKm;
    if (da == null && db == null) return a.livreur.nom.compareTo(b.livreur.nom);
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  });
  return liste;
});
