import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:graficacion_ai/main.dart' as app; 

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simulación de Flujo - Editor Matemático', () {
    testWidgets('Navegar a Graficación 2D/3D', (WidgetTester tester) async {
      app.main();
      await tester.pump(const Duration(seconds: 4)); 

      final btnInvitado = find.text('Continuar como invitado');
      if (btnInvitado.evaluate().isNotEmpty) {
        await tester.tap(btnInvitado);
        await tester.pump(const Duration(seconds: 4));
      }

      tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Graficación 2D/3D'));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('3D'), findsWidgets);
    });
  });
}