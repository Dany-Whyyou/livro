import '../models/admin.dart';
import '../models/livreur.dart';
import '../models/notification.dart';
import '../models/signalement.dart';
import '../models/ville.dart';

const mockLivreurs = [
  Livreur(
    id: '1',
    nom: 'Jean-Pierre Moussavou',
    whatsapp: true,
    photo: 'assets/demo/livreur-demo-1.jpg',
    statutPhoto: StatutPhoto.validee,
    localisationActive: true,
    telephone: '+241077000001',
    vehicule: 'moto',
    ville: 'Libreville',
    mode: ModeDisponibilite.disponible,
  ),
  Livreur(
    id: '2',
    nom: 'Rodrigue Nzamba',
    nonReponses7j: 4,
    whatsapp: true,
    localisationActive: true,
    telephone: '+241066223344',
    vehicule: 'moto',
    ville: 'Libreville',
    mode: ModeDisponibilite.auto,
  ),
  Livreur(
    id: '3',
    nom: 'Christian Ondo',
    nonReponses7j: 1,
    photo: 'assets/demo/livreur-demo-2.jpg',
    statutPhoto: StatutPhoto.validee,
    localisationActive: true,
    telephone: '+241077334455',
    vehicule: 'voiture',
    ville: 'Libreville',
    mode: ModeDisponibilite.disponible,
  ),
  Livreur(
    id: '4',
    nom: 'Patrick Mba',
    quartier: 'Akébé',
    telephone: '+241062445566',
    vehicule: 'velo',
    ville: 'Libreville',
    mode: ModeDisponibilite.disponible,
    origine: OrigineFiche.admin,
  ),
  Livreur(
    id: '5',
    nom: 'Aline Ondo',
    whatsapp: true,
    photo: 'assets/demo/livreur-demo-3.jpg',
    statutPhoto: StatutPhoto.enAttente,
    localisationActive: true,
    telephone: '+241066123456',
    vehicule: 'voiture',
    ville: 'Owendo',
    mode: ModeDisponibilite.disponible,
  ),
  Livreur(
    id: '6',
    nom: 'Brice Nzoghe',
    quartier: 'Akournam',
    telephone: '+241074556677',
    vehicule: 'moto',
    ville: 'Owendo',
    mode: ModeDisponibilite.disponible,
    origine: OrigineFiche.admin,
  ),
  Livreur(id: '7', nom: 'Sophie Mba', telephone: '+241077889900', vehicule: 'moto', ville: 'Owendo', mode: ModeDisponibilite.indisponible),
  Livreur(
    id: '8',
    nom: 'Paul Obame',
    localisationActive: true,
    telephone: '+241076112233',
    vehicule: 'moto',
    ville: 'Ntoum',
    mode: ModeDisponibilite.disponible,
    suspendu: true,
  ),
  Livreur(
    id: '9',
    nom: 'Kevin Mintsa',
    localisationActive: true,
    telephone: '+241074998877',
    vehicule: 'moto',
    ville: 'Libreville',
    mode: ModeDisponibilite.auto,
    statut: StatutCompte.enAttente,
  ),
  Livreur(
    id: '10',
    nom: 'Estelle Bouanga',
    telephone: '+241066554433',
    vehicule: 'voiture',
    ville: 'Port-Gentil',
    mode: ModeDisponibilite.auto,
    statut: StatutCompte.enAttente,
  ),
];

const mockVilles = [
  Ville(id: '1', nom: 'Libreville', province: 'Estuaire'),
  Ville(id: '2', nom: 'Owendo', province: 'Estuaire'),
  Ville(id: '3', nom: 'Ntoum', province: 'Estuaire'),
  Ville(id: '4', nom: 'Port-Gentil', province: 'Ogooué-Maritime'),
  Ville(id: '5', nom: 'Franceville', province: 'Haut-Ogooué'),
  Ville(id: '6', nom: 'Lambaréné', province: 'Moyen-Ogooué'),
  Ville(id: '7', nom: 'Oyem', province: 'Woleu-Ntem'),
  Ville(id: '8', nom: 'Mouila', province: 'Ngounié'),
];

const mockAdmins = [
  Admin(id: '1', nom: 'Administrateur principal', telephone: '+241077000001'),
  Admin(id: '2', nom: 'Sandrine Koumba', telephone: '+241066010203'),
];

final mockSignalements = [
  Signalement(
    id: '1',
    telephoneLivreur: '+241066223344',
    message: 'Le livreur est arrivé avec plus d\'une heure de retard et s\'est montré agressif quand je lui en ai parlé.',
    creeLe: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  Signalement(
    id: '2',
    telephoneLivreur: '+241062001122',
    message: 'Ce numéro se fait passer pour un livreur Livro. Il a pris mon colis et ne répond plus.',
    creeLe: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
  ),
  Signalement(
    id: '3',
    telephoneLivreur: '+241076112233',
    message: 'Colis livré avec deux jours de retard, sans prévenir.',
    creeLe: DateTime.now().subtract(const Duration(days: 6)),
    statut: StatutSignalement.traite,
  ),
];

final mockNotifications = [
  NotificationEnvoyee(
    id: '1',
    cible: CibleNotification.livreurs,
    titre: 'Activez votre localisation',
    message: 'Les clients voient maintenant les livreurs les plus proches en premier. Activez votre localisation dans Livro Pro.',
    envoyeeLe: DateTime.now().subtract(const Duration(days: 2)),
  ),
];
