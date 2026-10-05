import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Coordonnees {
  final double lat;
  final double lng;
  const Coordonnees(this.lat, this.lng);
}

/// Distance à vol d'oiseau en kilomètres (formule de haversine).
double distanceKm(Coordonnees a, Coordonnees b) {
  const rayonTerre = 6371.0;
  double rad(double deg) => deg * math.pi / 180;
  final dLat = rad(b.lat - a.lat);
  final dLng = rad(b.lng - a.lng);
  final h = math.pow(math.sin(dLat / 2), 2) + math.cos(rad(a.lat)) * math.cos(rad(b.lat)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * rayonTerre * math.asin(math.sqrt(h));
}

// Seuils des niveaux de proximité
const seuilProcheKm = 2.0;
const seuilParagesKm = 5.0;

enum Proximite { proche, parages, loin, inconnue }

Proximite proximitePour(double? km) {
  if (km == null) return Proximite.inconnue;
  if (km <= seuilProcheKm) return Proximite.proche;
  if (km <= seuilParagesKm) return Proximite.parages;
  return Proximite.loin;
}

extension ProximiteX on Proximite {
  String get label => switch (this) {
        Proximite.proche => 'Proche',
        Proximite.parages => 'Dans les parages',
        Proximite.loin => 'Loin',
        Proximite.inconnue => 'Position inconnue',
      };

  Color get couleur => switch (this) {
        Proximite.proche => AppTheme.proche,
        Proximite.parages => AppTheme.parages,
        Proximite.loin => AppTheme.loin,
        Proximite.inconnue => AppTheme.inkFaint,
      };

  Color get fond => switch (this) {
        Proximite.proche => AppTheme.procheSoft,
        Proximite.parages => AppTheme.paragesSoft,
        Proximite.loin => AppTheme.loinSoft,
        Proximite.inconnue => const Color(0xFFEDF0F4),
      };
}

/// 0.8 -> "800 m", 1.24 -> "1,2 km", 12.6 -> "13 km"
String formatDistance(double km) {
  final metres = (km * 1000 / 50).round() * 50;
  if (metres < 1000) return '$metres\u00A0m';
  if (km < 10) return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
  return '${km.round()} km';
}
