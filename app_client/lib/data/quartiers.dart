import '../core/utils/distance.dart';

/// Quartiers de rattachement par ville, avec leur point central (coordonnées approximatives,
/// à vérifier sur le terrain). Sert à situer les livreurs sans localisation en direct.
const quartiersParVille = {
  'Libreville': {
    'Centre-ville': Coordonnees(0.3920, 9.4540),
    'Louis': Coordonnees(0.4080, 9.4430),
    'Glass': Coordonnees(0.3800, 9.4460),
    'Akébé': Coordonnees(0.3800, 9.4700),
    'Lalala': Coordonnees(0.3650, 9.4600),
    'Nzeng-Ayong': Coordonnees(0.4150, 9.4900),
    'Okala': Coordonnees(0.4880, 9.4880),
    'Angondjé': Coordonnees(0.5300, 9.4500),
  },
  'Owendo': {
    'Owendo Centre': Coordonnees(0.2850, 9.5000),
    'Akournam': Coordonnees(0.2950, 9.5050),
    'Alénakiri': Coordonnees(0.3050, 9.5150),
    'Barracuda': Coordonnees(0.2750, 9.4950),
  },
  'Ntoum': {
    'Ntoum Centre': Coordonnees(0.3906, 9.7611),
    'Bikélé': Coordonnees(0.4100, 9.6200),
  },
};

Coordonnees? centreQuartier(String ville, String? quartier) => quartier == null ? null : quartiersParVille[ville]?[quartier];
