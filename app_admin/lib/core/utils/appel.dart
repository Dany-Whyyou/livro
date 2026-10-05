import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'format.dart';

/// Ouvre le clavier d'appel sur le numéro du livreur.
Future<void> appeler(BuildContext context, String telephone) async {
  final messenger = ScaffoldMessenger.of(context);
  var ouvert = false;
  try {
    ouvert = await launchUrl(Uri(scheme: 'tel', path: telephone));
  } catch (_) {
    ouvert = false;
  }
  if (!ouvert) {
    messenger.showSnackBar(SnackBar(content: Text('Appel impossible depuis cet appareil. Composez le ${formatTelephone(telephone)}')));
  }
}
