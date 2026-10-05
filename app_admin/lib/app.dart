import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'services/notifications.dart';
import 'core/theme/app_theme.dart';

class LivroAdminApp extends StatelessWidget {
  const LivroAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Livro Admin',
      theme: AppTheme.theme,
      routerConfig: appRouter,
      scaffoldMessengerKey: messengerKey,
      debugShowCheckedModeBanner: false,
    );
  }
}
