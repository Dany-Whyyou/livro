enum StatutCourse { enAttente, acceptee, enCours, livree, annulee }

class Course {
  final String id;
  final String adresseDepart;
  final String adresseDestination;
  final double poids;
  final int prix;
  final StatutCourse statut;
  final String livreurNom;
  final String livreurTelephone;
  final DateTime createdAt;

  const Course({
    required this.id,
    required this.adresseDepart,
    required this.adresseDestination,
    required this.poids,
    required this.prix,
    required this.statut,
    required this.livreurNom,
    required this.livreurTelephone,
    required this.createdAt,
  });

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
