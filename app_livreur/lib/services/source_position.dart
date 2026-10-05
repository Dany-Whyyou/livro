import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Résultat de la demande d'accès à la position.
enum AccesPosition { accorde, refuse, bloque, gpsCoupe }

/// Accès au GPS du téléphone. Interface séparée pour pouvoir la simuler dans les tests.
abstract class SourcePosition {
  Future<AccesPosition> demanderAcces();
  Stream<(double, double)> suivre();
  Future<void> ouvrirReglages();
}

class SourcePositionGps implements SourcePosition {
  const SourcePositionGps();

  @override
  Future<AccesPosition> demanderAcces() async {
    if (!await Geolocator.isLocationServiceEnabled()) return AccesPosition.gpsCoupe;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    return switch (permission) {
      LocationPermission.always || LocationPermission.whileInUse => AccesPosition.accorde,
      LocationPermission.deniedForever => AccesPosition.bloque,
      _ => AccesPosition.refuse,
    };
  }

  /// Positions en continu, y compris app en arrière-plan ou écran éteint :
  /// service de premier plan sur Android (notification permanente), mode arrière-plan sur iPhone.
  /// L'écrémage (100 m ou 10 minutes) est fait par SuiviPositionNotifier.
  @override
  Stream<(double, double)> suivre() {
    final LocationSettings reglages = switch (defaultTargetPlatform) {
      TargetPlatform.android => AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          intervalDuration: const Duration(minutes: 1),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'Livro Pro partage votre position',
            notificationText: 'Les clients proches de vous vous voient en premier.',
            notificationChannelName: 'Localisation',
            notificationIcon: AndroidResource(name: 'ic_notification'),
            enableWakeLock: true,
            setOngoing: true,
          ),
        ),
      TargetPlatform.iOS => AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          activityType: ActivityType.otherNavigation,
          pauseLocationUpdatesAutomatically: false,
          allowBackgroundLocationUpdates: true,
          showBackgroundLocationIndicator: true,
        ),
      _ => const LocationSettings(accuracy: LocationAccuracy.high),
    };
    return Geolocator.getPositionStream(locationSettings: reglages).map((p) => (p.latitude, p.longitude));
  }

  @override
  Future<void> ouvrirReglages() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }
}
