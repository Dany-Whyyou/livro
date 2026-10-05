import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'services/notifications.dart';
import 'core/theme/app_theme.dart';

class GabonLivreurApp extends StatelessWidget {
  const GabonLivreurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Livro Pro',
      theme: AppTheme.theme,
      routerConfig: appRouter,
      scaffoldMessengerKey: messengerKey,
      debugShowCheckedModeBanner: false,
    );
  }
}
