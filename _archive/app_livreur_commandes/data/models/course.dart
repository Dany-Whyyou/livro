enum StatutCourse { enAttente, acceptee, enCours, livree, annulee }

class Course {
  final String id;
  final String clientNom;
  final String clientTelephone;
  final String adresseDepart;
  final String adresseDestination;
  final double poids;
  final int prix;
  final StatutCourse statut;
  final DateTime createdAt;

  const Course({
    required this.id,
    required this.clientNom,
    required this.clientTelephone,
    required this.adresseDepart,
    required this.adresseDestination,
    required this.poids,
    required this.prix,
    required this.statut,
    required this.createdAt,
  });

  Course copyWith({StatutCourse? statut}) => Course(
        id: id,
        clientNom: clientNom,
        clientTelephone: clientTelephone,
        adresseDepart: adresseDepart,
        adresseDestination: adresseDestination,
        poids: poids,
        prix: prix,
        statut: statut ?? this.statut,
        createdAt: createdAt,
      );

  String get statutLabel {
    switch (statut) {
      case StatutCourse.enAttente:
        return 'En attente';
      case StatutCourse.acceptee:
        return 'Acceptée';
      case StatutCourse.enCours:
        return 'En cours';
      case StatutCourse.livree:
        return 'Livrée';
      case StatutCourse.annulee:
        return 'Annulée';
    }
  }
}
