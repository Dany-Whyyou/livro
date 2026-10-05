import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/mock_data.dart';
import '../data/models/notification.dart';

class NotificationsNotifier extends StateNotifier<List<NotificationEnvoyee>> {
  NotificationsNotifier() : super(mockNotifications);

  int _prochainId = mockNotifications.length + 1;

  Future<void> envoyer({required CibleNotification cible, required String titre, required String message}) async {
    // mock : simule l'envoi push (à brancher sur OneSignal)
    await Future.delayed(const Duration(milliseconds: 800));
    state = [NotificationEnvoyee(id: '${_prochainId++}', cible: cible, titre: titre, message: message, envoyeeLe: DateTime.now()), ...state];
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationEnvoyee>>((ref) => NotificationsNotifier());
