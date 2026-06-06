import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:graficacion_ai/main.dart' as app; 

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simulación de Flujo - Tutor IA (Gemini)', () {
    testWidgets('Abrir chat desde NavBar', (WidgetTester tester) async {
      app.main();
      await tester.pump(const Duration(seconds: 4)); 

      final btnInvitado = find.text('Continuar como invitado');
      if (btnInvitado.evaluate().isNotEmpty) {
        await tester.tap(btnInvitado);
        await tester.pump(const Duration(seconds: 4));
      }

      // Tu ícono en la barra inferior para el bot de IA
      final Finder botonChat = find.byIcon(Icons.psychology_rounded); 
      expect(botonChat, findsOneWidget);
      await tester.tap(botonChat);
      await tester.pump(const Duration(seconds: 2)); 

      // Verifica que exista un campo de texto para escribir
      expect(find.byType(TextField), findsWidgets);
    });
  });
}