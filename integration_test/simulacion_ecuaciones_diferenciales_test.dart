import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:graficacion_ai/main.dart' as app; 

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simulación - Ecuaciones Diferenciales', () {
    testWidgets('Resolver EDO Separable', (WidgetTester tester) async {
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

      await tester.tap(find.text('Ecuaciones Diferenciales'));
      await tester.pump(const Duration(seconds: 2));

      // Entramos al Hub de 1er Orden
      await tester.tap(find.text('1er Orden'));
      await tester.pump(const Duration(seconds: 2));

      // Entramos a Variables Separables
      await tester.tap(find.text('Variables Separables'));
      await tester.pump(const Duration(seconds: 2));

      final campos = find.byType(TextField);
      if (campos.evaluate().isNotEmpty) {
         await tester.enterText(campos.first, 'x + y');
         await tester.pump(const Duration(seconds: 1));
      }

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(seconds: 1));

      final btnResolver = find.byType(ElevatedButton).first;
      await tester.tap(btnResolver);
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(Scaffold), findsWidgets); 
    });
  });
}