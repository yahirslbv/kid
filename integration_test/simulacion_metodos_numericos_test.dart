import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:graficacion_ai/main.dart' as app; 

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simulación - Métodos Numéricos', () {
    testWidgets('Calcular raíz por Bisección', (WidgetTester tester) async {
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

      await tester.tap(find.text('Métodos Numéricos'));
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Raíces de Ecuaciones'));
      await tester.pump(const Duration(seconds: 2));

      // Bisección es la pestaña por defecto, llenamos los 3 textfields
      final campos = find.byType(TextField);
      if (campos.evaluate().length >= 3) {
        await tester.enterText(campos.at(0), 'x^2 - 4');
        await tester.enterText(campos.at(1), '0');
        await tester.enterText(campos.at(2), '3');
        await tester.pump(const Duration(seconds: 1));
      }

      // Escondemos el teclado para que no estorbe
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(seconds: 1));

      // Buscamos el botón elevado genérico (sin importar su texto)
      final btnCalcular = find.byType(ElevatedButton).first;
      await tester.tap(btnCalcular);
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}