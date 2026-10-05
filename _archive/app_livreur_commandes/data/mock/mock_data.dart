import '../models/course.dart';

final mockNouvellesCourses = [
  Course(
    id: 'c100',
    clientNom: 'Marie Nguema',
    clientTelephone: '+24177889900',
    adresseDepart: 'Marché d\'Owendo, Stand 12',
    adresseDestination: 'Quartier Louis, Owendo',
    poids: 3.0,
    prix: 1500,
    statut: StatutCourse.enAttente,
    createdAt: DateTime.now(),
  ),
];

final mockHistoriqueLivreur = [
  Course(
    id: 'c200',
    clientNom: 'Paul Obame',
    clientTelephone: '+24166112233',
    adresseDepart: 'Shell Ntoum',
    adresseDestination: 'PK12, Route de Ntoum',
    poids: 1.5,
    prix: 1200,
    statut: StatutCourse.livree,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Course(
    id: 'c201',
    clientNom: 'Sophie Mba',
    clientTelephone: '+24177334455',
    adresseDepart: 'Pharmacie Owendo Centre',
    adresseDestination: 'Cité Palmeraie, Bâtiment C',
    poids: 0.5,
    prix: 800,
    statut: StatutCourse.livree,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Course(
    id: 'c202',
    clientNom: 'Brice Nzoghe',
    clientTelephone: '+24166556677',
    adresseDepart: 'Total Owendo',
    adresseDestination: 'Zone Industrielle, Entrepôt 4',
    poids: 8.0,
    prix: 2500,
    statut: StatutCourse.livree,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
