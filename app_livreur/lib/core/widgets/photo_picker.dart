import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../icons/app_icons.dart';
import '../theme/app_theme.dart';

/// Propose de prendre ou choisir une photo (ou de la retirer) et renvoie le chemin choisi.
/// Renvoie '' si l'utilisateur retire sa photo, null s'il annule.
Future<String?> choisirPhoto(BuildContext context, {required bool aDejaUnePhoto}) async {
  final source = await showModalBottomSheet<Object>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.line, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 12),
            _Option(icon: AppIcons.camera, label: 'Prendre une photo', onTap: () => Navigator.of(ctx).pop(ImageSource.camera)),
            _Option(icon: AppIcons.image, label: 'Choisir dans la galerie', onTap: () => Navigator.of(ctx).pop(ImageSource.gallery)),
            if (aDejaUnePhoto) _Option(icon: AppIcons.trash, label: 'Retirer la photo', color: AppTheme.danger, onTap: () => Navigator.of(ctx).pop('retirer')),
          ],
        ),
      ),
    ),
  );
  if (source == null) return null;
  if (source == 'retirer') return '';
  try {
    final fichier = await ImagePicker().pickImage(source: source as ImageSource, maxWidth: 800, imageQuality: 80);
    return fichier?.path;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir l\'appareil photo ou la galerie')),
      );
    }
    return null;
  }
}

class _Option extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Option({required this.icon, required this.label, required this.onTap, this.color = AppTheme.ink});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 22, color: color),
      title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
