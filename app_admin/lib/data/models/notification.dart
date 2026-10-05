enum CibleNotification { tous, clients, livreurs, admins }

extension CibleNotificationX on CibleNotification {
  String get label => switch (this) {
    CibleNotification.tous => 'Tout le monde',
    CibleNotification.clients => 'Clients',
    CibleNotification.livreurs => 'Livreurs',
    CibleNotification.admins => 'Admins',
  };
}

class NotificationEnvoyee {
  final String id;
  final CibleNotification cible;
  final String titre;
  final String message;
  final DateTime envoyeeLe;

  const NotificationEnvoyee({required this.id, required this.cible, required this.titre, required this.message, required this.envoyeeLe});
}
