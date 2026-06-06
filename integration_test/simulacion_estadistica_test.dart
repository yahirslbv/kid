import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:graficacion_ai/main.dart' as app; 

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simulación - Estadística', () {
    testWidgets('Calcular Media y Desviación', (WidgetTester tester) async {
      app.main();
      await tester.pump(const Duration(seconds: 4));

      final btnInvitado = find.text('Continuar como invitado');
      if (btnInvitado.evaluate().isNotEmpty) {
        await tester.tap(btnInvitado);
        await tester.pump(const Duration(seconds: 4));
      }

      tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Probabilidad y Estadística'));
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Estadística Descriptiva'));
      await tester.pump(const Duration(seconds: 2));

      await tester.enterText(find.byType(TextField).first, '10, 20, 30, 40, 50');
      await tester.pump(const Duration(seconds: 1));

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(seconds: 1));

      // Tocamos el texto exacto que vi en tu código
      await tester.tap(find.text('Procesar Datos'));
      await tester.pump(const Duration(seconds: 3));

      // Verificamos el texto exacto que se genera
      expect(find.text('Histograma de Frecuencias'), findsOneWidget);
    });
  });
}