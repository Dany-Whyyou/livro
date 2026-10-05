import '../../core/utils/distance.dart';
import '../models/livreur.dart';

/// Centre de chaque ville. Mock : sert de position du client tant que le GPS n'est pas branché.
const centresVilles = {
  'Libreville': Coordonnees(0.3925, 9.4536),
  'Owendo': Coordonnees(0.2850, 9.5000),
  'Ntoum': Coordonnees(0.3906, 9.7611),
  'Port-Gentil': Coordonnees(-0.7193, 8.7815),
  'Franceville': Coordonnees(-1.6333, 13.5833),
  'Lambaréné': Coordonnees(-0.7000, 10.2333),
  'Oyem': Coordonnees(1.5995, 11.5793),
  'Mouila': Coordonnees(-1.8667, 11.0556),
};

const mockLivreurs = [
  Livreur(
    id: '1',
    nom: 'Jean-Pierre Moussavou',
    whatsapp: true,
    photo: 'assets/demo/livreur-demo-1.jpg',
    telephone: '+241077000001',
    vehicule: TypeVehicule.moto,
    ville: 'Libreville',
    disponible: true,
    position: Coordonnees(0.4005, 9.4576), // ~1 km du centre
  ),
  Livreur(
    id: '2',
    nom: 'Rodrigue Nzamba',
    whatsapp: true,
    telephone: '+241066223344',
    vehicule: TypeVehicule.moto,
    ville: 'Libreville',
    disponible: true,
    position: Coordonnees(0.4175, 9.4436), // ~3 km
  ),
  Livreur(
    id: '3',
    nom: 'Christian Ondo',
    photo: 'assets/demo/livreur-demo-2.jpg',
    telephone: '+241077334455',
    vehicule: TypeVehicule.voiture,
    ville: 'Libreville',
    disponible: true,
    position: Coordonnees(0.4525, 9.4836), // ~7,5 km
  ),
  Livreur(
    id: '4',
    nom: 'Patrick Mba',
    telephone: '+241062445566',
    vehicule: TypeVehicule.velo,
    ville: 'Libreville',
    disponible: true, // sans smartphone : situé par son quartier de base
    quartier: 'Akébé',
  ),
  Livreur(
    id: '9',
    nom: 'Laurent Ella',
    whatsapp: true,
    photo: 'assets/demo/livreur-demo-3.jpg',
    telephone: '+241074220011',
    vehicule: TypeVehicule.moto,
    ville: 'Libreville',
    disponible: true,
    position: Coordonnees(0.3805, 9.4596), // ~1,5 km
  ),
  Livreur(
    id: '5',
    nom: 'Aline Ondo',
    whatsapp: true,
    telephone: '+241066123456',
    vehicule: TypeVehicule.voiture,
    ville: 'Owendo',
    disponible: true,
    position: Coordonnees(0.3150, 9.5000), // ~3,3 km
  ),
  Livreur(
    id: '6',
    nom: 'Brice Nzoghe',
    telephone: '+241074556677',
    vehicule: TypeVehicule.moto,
    ville: 'Owendo',
    disponible: true, // sans smartphone : situé par son quartier de base
    quartier: 'Akournam',
  ),
  Livreur(
    id: '7',
    nom: 'Sophie Mba',
    telephone: '+241077889900',
    vehicule: TypeVehicule.moto,
    ville: 'Owendo',
    disponible: false,
    position: Coordonnees(0.2900, 9.5050),
  ),
  Livreur(
    id: '8',
    nom: 'Paul Obame',
    telephone: '+241076112233',
    vehicule: TypeVehicule.moto,
    ville: 'Ntoum',
    disponible: true,
    position: Coordonnees(0.3956, 9.7631), // ~600 m
  ),
];
