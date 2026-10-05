import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Le livreur partage sa position : les clients proches le voient en premier.
/// Mock : pas encore de GPS réel, seul le choix du livreur est mémorisé.
final localisationActiveProvider = StateProvider<bool>((ref) => false);
