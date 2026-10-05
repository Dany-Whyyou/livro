enum ModeDisponibilite { disponible, auto, indisponible }

/// D'où vient la fiche : le livreur s'est inscrit dans Livro Pro, ou un admin
/// l'a créée pour lui (livreur sans smartphone).
enum OrigineFiche { app, admin }

/// Un compte créé dans Livro Pro doit être validé par un admin avant d'être
/// affiché aux clients. Les fiches créées par un admin sont validées d'office.
enum StatutCompte { enAttente, valide, refuse }

/// Photo facultative envoyée depuis Livro Pro : montrée aux clients une fois validée.
enum StatutPhoto { enAttente, validee, refusee }

// Plage du mode auto : disponible de 8h à 20h
const heureDebutAuto = 8;
const heureFinAuto = 20;

class Livreur {
  final String id;
  final String nom;
  final String telephone;
  final String vehicule;
  final String ville;
  final ModeDisponibilite mode;
  final bool suspendu;
  final OrigineFiche origine;
  final StatutCompte statut;

  /// Le livreur partage sa position depuis Livro Pro (jamais pour une fiche sans smartphone).
  final bool localisationActive;

  /// Quartier de base : position approximative quand il n'y a pas de localisation en direct.
  final String? quartier;

  /// Clients qui ont dit ne pas avoir pu joindre le livreur ces 7 derniers jours.
  final int nonReponses7j;

  /// Joignable aussi en appel WhatsApp, sur le même numéro.
  final bool whatsapp;

  /// Mock : chemin d'un asset de démo, en attendant le stockage des photos.
  final String? photo;
  final StatutPhoto? statutPhoto;

  bool get photoAValider => photo != null && statutPhoto == StatutPhoto.enAttente;

  const Livreur({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.vehicule,
    required this.ville,
    this.mode = ModeDisponibilite.indisponible,
    this.suspendu = false,
    this.origine = OrigineFiche.app,
    this.statut = StatutCompte.valide,
    this.localisationActive = false,
    this.quartier,
    this.nonReponses7j = 0,
    this.whatsapp = false,
    this.photo,
    this.statutPhoto,
  });

  Livreur copyWith({
    String? nom,
    String? telephone,
    String? vehicule,
    String? ville,
    ModeDisponibilite? mode,
    bool? suspendu,
    OrigineFiche? origine,
    StatutCompte? statut,
    bool? whatsapp,
    StatutPhoto? statutPhoto,
    bool retirerPhoto = false,
    String? quartier,
    bool retirerQuartier = false,
  }) => Livreur(
    id: id,
    nom: nom ?? this.nom,
    telephone: telephone ?? this.telephone,
    vehicule: vehicule ?? this.vehicule,
    ville: ville ?? this.ville,
    mode: mode ?? this.mode,
    suspendu: suspendu ?? this.suspendu,
    origine: origine ?? this.origine,
    statut: statut ?? this.statut,
    localisationActive: localisationActive,
    quartier: retirerQuartier ? null : quartier ?? this.quartier,
    nonReponses7j: nonReponses7j,
    whatsapp: whatsapp ?? this.whatsapp,
    photo: retirerPhoto ? null : photo,
    statutPhoto: retirerPhoto ? null : statutPhoto ?? this.statutPhoto,
  );

  /// Vrai si les clients voient ce livreur à l'heure donnée.
  bool estDisponible(DateTime maintenant) {
    if (suspendu || statut != StatutCompte.valide) return false;
    switch (mode) {
      case ModeDisponibilite.disponible:
        return true;
      case ModeDisponibilite.indisponible:
        return false;
      case ModeDisponibilite.auto:
        return maintenant.hour >= heureDebutAuto && maintenant.hour < heureFinAuto;
    }
  }
}
