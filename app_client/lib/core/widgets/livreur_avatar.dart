import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'app_card.dart';

/// Photo du livreur si elle a été validée, sinon ses initiales.
class LivreurAvatar extends StatelessWidget {
  final String nom;
  final String? photo;
  final double size;
  final bool fonce;

  const LivreurAvatar({super.key, required this.nom, this.photo, this.size = 44, this.fonce = false});

  @override
  Widget build(BuildContext context) {
    if (photo == null) {
      return InitialesAvatar(
        texte: initiales(nom),
        size: size,
        color: fonce ? Colors.white : AppTheme.primary,
        background: fonce ? AppTheme.primary : AppTheme.primarySoft,
      );
    }
    return ClipOval(
      child: Image.asset(photo!, width: size, height: size, fit: BoxFit.cover),
    );
  }
}
