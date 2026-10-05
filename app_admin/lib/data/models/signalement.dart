enum StatutSignalement { nouveau, traite, classe }

/// Signalement d'un livreur envoyé par un client depuis Livro.
class Signalement {
  final String id;
  final String telephoneLivreur;
  final String message;
  final DateTime creeLe;
  final StatutSignalement statut;

  const Signalement({required this.id, required this.telephoneLivreur, required this.message, required this.creeLe, this.statut = StatutSignalement.nouveau});

  bool get aTraiter => statut == StatutSignalement.nouveau;

  Signalement copyWith({StatutSignalement? statut}) =>
      Signalement(id: id, telephoneLivreur: telephoneLivreur, message: message, creeLe: creeLe, statut: statut ?? this.statut);
}
