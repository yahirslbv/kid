import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:graficacion_ai/main.dart' as app; 

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simulación de Flujo - Autenticación', () {
    testWidgets('Verificar pantalla de Login o Home', (WidgetTester tester) async {
      app.main();
      await tester.pump(const Duration(seconds: 4)); 

      // Buscamos el ícono de la pestaña "Estudio" de tu barra personalizada
      final iconoHome = find.byIcon(Icons.show_chart_rounded);
      
      if (iconoHome.evaluate().isNotEmpty) {
        // Ya estábamos logueados
        expect(iconoHome, findsWidgets);
      } else {
        // Estamos en el login, tocamos "Continuar como invitado"
        final Finder btnInvitado = find.text('Continuar como invitado');
        expect(btnInvitado, findsOneWidget);
        await tester.tap(btnInvitado);
        await tester.pump(const Duration(seconds: 4));
        
        // Verificamos que ya cargó el Home
        expect(find.byIcon(Icons.show_chart_rounded), findsWidgets);
      }
    });
  });
}