import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:graficacion_ai/main.dart' as app; 

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simulación de Flujo - Mecánica Vectorial', () {
    testWidgets('Abrir menú, navegar a Mecánica y verificar renderizado', (WidgetTester tester) async {
      app.main();
      await tester.pump(const Duration(seconds: 4)); 

      final btnInvitado = find.text('Continuar como invitado');
      if (btnInvitado.evaluate().isNotEmpty) {
        await tester.tap(btnInvitado);
        await tester.pump(const Duration(seconds: 4));
      }

      // Abrir menú lateral
      tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      // Animamos la apertura del menú cuadro por cuadro
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Mecánica Vectorial Estática'));
      await tester.pump(const Duration(seconds: 2));

      final Finder botonAgregar = find.byIcon(Icons.arrow_outward);
      expect(botonAgregar, findsOneWidget);
      await tester.tap(botonAgregar);
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Cancelar'));
      await tester.pump(const Duration(seconds: 2));
      
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}