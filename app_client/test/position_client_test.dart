import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_client/core/theme/app_theme.dart';
import 'package:app_client/providers/position_provider.dart';
import 'package:app_client/screens/accueil/accueil_screen.dart';
import 'package:app_client/services/source_position.dart';

class FausseSource implements SourcePosition {
  AccesPosition acces;
  (double, double) position;
  int lectures = 0;
  FausseSource(this.acces, this.position);

  @override
  Future<AccesPosition> demanderAcces() async => acces;
  @override
  Future<(double, double)> positionActuelle() async {
    lectures++;
    return position;
  }

  @override
  Future<void> ouvrirReglages() async {}
}

Future<void> afficher(WidgetTester t, FausseSource source) async {
  t.view.physicalSize = const Size(780, 4000);
  t.view.devicePixelRatio = 2;
  await t.pumpWidget(ProviderScope(
    overrides: [sourcePositionProvider.overrideWithValue(source)],
    child: MaterialApp(theme: AppTheme.theme, home: const AccueilScreen()),
  ));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('position réelle : tri par distance depuis là où est le client', (t) async {
    // Client à Glass (sud de Libreville) : Laurent Ella (~1 km) passe devant Jean-Pierre (~2 km)
    final source = FausseSource(AccesPosition.accorde, (0.3800, 9.4460));
    await afficher(t, source);
    expect(find.text('Proche'), findsNothing);
    await t.tap(find.text('Activer'));
    await t.pumpAndSettle();
    expect(find.text('Position activée'), findsOneWidget);
    final yLaurent = t.getTopLeft(find.text('Laurent Ella')).dy;
    final yJp = t.getTopLeft(find.text('Jean-Pierre Moussavou')).dy;
    expect(yLaurent < yJp, isTrue);
    // Retour dans l'app : la position est relue
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await t.pumpAndSettle();
    expect(source.lectures, 2);
  });

  testWidgets('accès refusé puis bloqué : message et bouton adaptés, pas de distance', (t) async {
    final source = FausseSource(AccesPosition.refuse, (0, 0));
    await afficher(t, source);
    await t.tap(find.text('Activer'));
    await t.pumpAndSettle();
    expect(find.text('Position refusée.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.text('Proche'), findsNothing);
    source.acces = AccesPosition.bloque;
    await t.tap(find.text('Réessayer'));
    await t.pumpAndSettle();
    expect(find.text('Accès à la position bloqué.'), findsOneWidget);
    expect(find.text('Réglages'), findsOneWidget);
  });
}
