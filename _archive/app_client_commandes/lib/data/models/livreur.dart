enum TypeVehicule { moto, velo, voiture }

class Livreur {
  final String id;
  final String nom;
  final String telephone;
  final TypeVehicule vehicule;
  final double tarifKm;
  final double tarifBase;
  final String zone;
  final String ville;
  final bool disponible;
  final double note;
  final int nombreAvis;
  final double distanceKm;

  const Livreur({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.vehicule,
    required this.tarifKm,
    required this.tarifBase,
    required this.zone,
    required this.ville,
    required this.disponible,
    required this.note,
    required this.nombreAvis,
    required this.distanceKm,
  });

  String get vehiculeLabel {
    switch (vehicule) {
      case TypeVehicule.moto:
        return 'Moto';
      case TypeVehicule.velo:
        return 'Vélo';
      case TypeVehicule.voiture:
        return 'Voiture';
    }
  }

  String get vehiculeEmoji {
    switch (vehicule) {
      case TypeVehicule.moto:
        return '🏍️';
      case TypeVehicule.velo:
        return '🚲';
      case TypeVehicule.voiture:
        return '🚗';
    }
  }

  int prixEstime(double distanceLivraison) {
    return (tarifBase + tarifKm * distanceLivraison).round();
  }
}
