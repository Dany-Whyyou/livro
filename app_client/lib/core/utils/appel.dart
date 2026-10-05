import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'format.dart';

/// Ouvre le clavier d'appel sur le numéro du livreur.
Future<bool> appeler(BuildContext context, String telephone) async {
  final messenger = ScaffoldMessenger.of(context);
  var ouvert = false;
  try {
    ouvert = await launchUrl(Uri(scheme: 'tel', path: telephone));
  } catch (_) {
    ouvert = false;
  }
  if (!ouvert) {
    messenger.showSnackBar(
      SnackBar(content: Text('Appel impossible depuis cet appareil. Composez le ${formatTelephone(telephone)}')),
    );
  }
  return ouvert;
}

/// Ouvre la conversation WhatsApp du livreur, d'où le client lance l'appel WhatsApp.
/// (WhatsApp ne permet pas de démarrer un appel directement depuis un lien.)
Future<bool> ouvrirWhatsApp(BuildContext context, String telephone) async {
  final messenger = ScaffoldMessenger.of(context);
  var ouvert = false;
  try {
    ouvert = await launchUrl(Uri.parse('https://wa.me/${telephone.replaceAll('+', '')}'), mode: LaunchMode.externalApplication);
  } catch (_) {
    ouvert = false;
  }
  if (!ouvert) {
    messenger.showSnackBar(const SnackBar(content: Text('WhatsApp n\'est pas disponible sur cet appareil')));
  }
  return ouvert;
}
