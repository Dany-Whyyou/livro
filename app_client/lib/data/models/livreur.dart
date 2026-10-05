import 'package:flutter/widgets.dart';
import '../../core/icons/app_icons.dart';
import '../../core/utils/distance.dart';

enum TypeVehicule { moto, velo, voiture }

extension TypeVehiculeX on TypeVehicule {
  String get label => switch (this) {
        TypeVehicule.moto => 'Moto',
        TypeVehicule.velo => 'Vélo',
        TypeVehicule.voiture => 'Voiture',
      };

  IconData get icon => switch (this) {
        TypeVehicule.moto => AppIcons.motorcycle,
        TypeVehicule.velo => AppIcons.bicycle,
        TypeVehicule.voiture => AppIcons.car,
      };
}

class Livreur {
  final String id;
  final String nom;
  final String telephone;
  final TypeVehicule vehicule;
  final String ville;
  final bool disponible;

  /// Joignable aussi en appel WhatsApp, sur le même numéro.
  final bool whatsapp;

  /// Photo validée par l'admin (facultative). Mock : chemin d'un asset de démo.
  final String? photo;

  /// null si le livreur n'a pas activé sa localisation (ou n'a pas de smartphone).
  final Coordonnees? position;

  /// Quartier de base : situe approximativement un livreur sans localisation en direct.
  final String? quartier;

  const Livreur({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.vehicule,
    required this.ville,
    required this.disponible,
    this.whatsapp = false,
    this.photo,
    this.position,
    this.quartier,
  });
}

/// Un livreur de la liste, avec sa distance au client (null si position inconnue).
class LivreurProche {
  final Livreur livreur;
  final double? distanceKm;

  /// Distance calculée depuis le quartier de base, pas depuis une position en direct.
  final bool approximatif;

  const LivreurProche(this.livreur, this.distanceKm, {this.approximatif = false});

  Proximite get proximite => proximitePour(distanceKm);
}
