import 'package:flutter_riverpod/flutter_riverpod.dart';

/// La photo est facultative. Elle n'est montrée aux clients qu'une fois validée par un admin.
enum StatutPhoto { enAttente, validee, refusee }

class PhotoProfil {
  final String chemin;
  final StatutPhoto statut;
  const PhotoProfil({required this.chemin, this.statut = StatutPhoto.enAttente});
}

/// null = pas de photo. Mock : fichier local, en attendant l'envoi au backend.
final photoProvider = StateProvider<PhotoProfil?>((ref) => null);
