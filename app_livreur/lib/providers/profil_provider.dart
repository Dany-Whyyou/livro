import 'package:flutter_riverpod/flutter_riverpod.dart';

class LivreurProfil {
  final String nom;
  final String telephone;
  final String vehicule;
  final String ville;

  /// Joignable aussi en appel WhatsApp, sur le même numéro.
  final bool whatsapp;

  /// Quartier de base, utilisé quand la localisation est désactivée.
  final String? quartier;

  const LivreurProfil({
    required this.nom,
    required this.telephone,
    required this.vehicule,
    required this.ville,
    this.whatsapp = false,
    this.quartier,
  });

  LivreurProfil copyWith({
    String? nom,
    String? telephone,
    String? vehicule,
    String? ville,
    bool? whatsapp,
    String? quartier,
    bool retirerQuartier = false,
  }) =>
      LivreurProfil(
        nom: nom ?? this.nom,
        telephone: telephone ?? this.telephone,
        vehicule: vehicule ?? this.vehicule,
        ville: ville ?? this.ville,
        whatsapp: whatsapp ?? this.whatsapp,
        quartier: retirerQuartier ? null : quartier ?? this.quartier,
      );
}

class ProfilNotifier extends StateNotifier<LivreurProfil> {
  ProfilNotifier()
      : super(const LivreurProfil(
          nom: 'Jean-Pierre Moussavou',
          telephone: '+241077000001',
          vehicule: 'moto',
          ville: 'Libreville',
          whatsapp: true,
        ));

  void update(LivreurProfil profil) => state = profil;
}

final profilProvider = StateNotifierProvider<ProfilNotifier, LivreurProfil>(
  (ref) => ProfilNotifier(),
);
