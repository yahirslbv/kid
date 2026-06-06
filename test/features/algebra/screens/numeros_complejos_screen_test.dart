import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/algebra/screens/numeros_complejos_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: NumerosComplejosScreen(),
    );
  }

  group('Pruebas de NumerosComplejosScreen', () {
    
    testWidgets('Debe iniciar con 4 campos de texto y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 4 campos de texto (Real e Imag para Z1 y Z2)
      expect(find.byType(TextField), findsNWidgets(4));

      // Verificamos los valores iniciales por defecto (Z1 = 3 + 2i, Z2 = 1 - 4i)
      expect(find.text('3'), findsOneWidget); // Z1 Real
      expect(find.text('2'), findsOneWidget); // Z1 Imag
      expect(find.text('1'), findsOneWidget); // Z2 Real
      expect(find.text('-4'), findsOneWidget); // Z2 Imag

      // No debe haber ningún resultado al iniciar
      expect(find.text('Z₁ + Z₂'), findsNothing);
    });

    testWidgets('Calcula la suma correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // --- CORRECCIÓN AQUÍ --- Buscamos específicamente un ElevatedButton que tenga el texto '+'
      final botonSuma = find.widgetWithText(ElevatedButton, '+');
      await tester.tap(botonSuma);
      await tester.pumpAndSettle();

      // Verificamos el título de la operación y el resultado
      expect(find.text('Z₁ + Z₂'), findsOneWidget);
      expect(find.text('4 - 2i'), findsOneWidget);
    });

    testWidgets('Calcula la multiplicación correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // --- CORRECCIÓN AQUÍ ---
      final botonMulti = find.widgetWithText(ElevatedButton, '×');
      await tester.tap(botonMulti);
      await tester.pumpAndSettle();

      expect(find.text('Z₁ × Z₂'), findsOneWidget);
      expect(find.text('11 - 10i'), findsOneWidget);
    });

    testWidgets('Debe mostrar error al intentar dividir entre cero', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Cambiamos Z2 a 0 + 0i para forzar la división por cero
      await tester.enterText(textFields.at(2), '0'); // Z2 Real
      await tester.enterText(textFields.at(3), '0'); // Z2 Imag
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // --- CORRECCIÓN AQUÍ ---
      final botonDiv = find.widgetWithText(ElevatedButton, '÷');
      await tester.tap(botonDiv);
      await tester.pumpAndSettle();

      // Debe mostrar el mensaje de error definido en el código
      expect(find.text('Error: División por 0'), findsOneWidget);
    });
  });
}