import 'package:geolocator/geolocator.dart';

/// Résultat de la demande d'accès à la position.
enum AccesPosition { accorde, refuse, bloque, gpsCoupe }

/// Position du client, lue au moment où il ouvre l'app (pas de suivi en continu).
/// Interface séparée pour pouvoir la simuler dans les tests.
abstract class SourcePosition {
  Future<AccesPosition> demanderAcces();
  Future<(double, double)> positionActuelle();
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

  @override
  Future<(double, double)> positionActuelle() async {
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)),
    );
    return (p.latitude, p.longitude);
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
