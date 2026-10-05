import 'package:flutter/material.dart';

import '../../data/models/livreur.dart';
import '../utils/format.dart';
import 'app_card.dart';

/// Photo du livreur si elle a été validée, sinon ses initiales.
class LivreurAvatar extends StatelessWidget {
  final Livreur livreur;
  final double size;
  final bool memeNonValidee;

  const LivreurAvatar({super.key, required this.livreur, this.size = 44, this.memeNonValidee = false});

  @override
  Widget build(BuildContext context) {
    final photo = livreur.photo;
    if (photo == null || (!memeNonValidee && livreur.statutPhoto != StatutPhoto.validee)) {
      return InitialesAvatar(texte: initiales(livreur.nom), size: size);
    }
    return ClipOval(
      child: Image.asset(photo, width: size, height: size, fit: BoxFit.cover),
    );
  }
}
