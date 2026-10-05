import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vrai quand plusieurs clients ont dit ne pas avoir pu joindre le livreur dans la
/// journée : le système l'a repassé en indisponible. Mock : décidé par le backend.
final injoignableProvider = StateProvider<bool>((ref) => false);
