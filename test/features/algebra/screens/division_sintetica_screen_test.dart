import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/algebra/screens/division_sintetica_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: DivisionSinteticaScreen(),
    );
  }

  group('Pruebas de DivisionSinteticaScreen (Ruffini)', () {
    
    testWidgets('Debe iniciar con los valores por defecto y sin resultados visibles', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 2 campos de texto
      expect(find.byType(TextField), findsNWidgets(2));

      // Verificamos que contengan los valores por defecto
      expect(find.text('1, -3, 2, 5'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Raíz por defecto

      // Los resultados no deben estar visibles al iniciar
      expect(find.textContaining('Cociente Q(x)'), findsNothing);
      expect(find.textContaining('Residuo:'), findsNothing);
    });

    testWidgets('Calcula Ruffini con los valores por defecto correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Presionamos calcular directamente (usando los valores 1, -3, 2, 5 y raíz 2)
      final botonCalcular = find.text('Calcular');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // El residuo debe ser 5
      expect(find.text('Residuo: 5'), findsOneWidget);
      
      // El cociente debe ser 1x^2 - 1x
      expect(find.text('Cociente Q(x) = 1x^2 - 1x'), findsOneWidget);
    });

    testWidgets('Calcula una división exacta (residuo 0) con datos personalizados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Limpiamos e ingresamos el polinomio: 2x^3 + 0x^2 - 5x + 3
      await tester.enterText(textFields.at(0), '2, 0, -5, 3');
      
      // Evaluamos la raíz c = 1
      await tester.enterText(textFields.at(1), '1');
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.text('Calcular');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // El residuo debe ser exactamente 0
      expect(find.text('Residuo: 0'), findsOneWidget);
      
      // El cociente debe ser 2x^2 + 2x - 3
      expect(find.text('Cociente Q(x) = 2x^2 + 2x - 3'), findsOneWidget);
    });

    testWidgets('Muestra error si los coeficientes son inválidos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos letras en lugar de números
      await tester.enterText(textFields.at(0), 'hola, mundo');
      await tester.enterText(textFields.at(1), '1');
      
      final botonCalcular = find.text('Calcular');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pump(); // Usamos pump() simple para ver el texto de error

      // Verificamos que el texto de error aparezca en pantalla
      expect(find.text('Ingresa al menos un coeficiente válido.'), findsOneWidget);
      
      // Las cajas de resultado no deben renderizarse
      expect(find.textContaining('Cociente Q(x)'), findsNothing);
    });
  });
}