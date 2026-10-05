import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Panneau de saisie qui monte du bas, au-dessus de la barre d'onglets et du clavier.
Future<T?> showFormSheet<T>(BuildContext context, {required String titre, required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppTheme.line, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                titre,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.5),
              ),
              const SizedBox(height: 20),
              builder(ctx),
            ],
          ),
        ),
      ),
    ),
  );
}
