import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/metodos_numericos/screens/gauss_jordan_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold( // Envolvemos en Scaffold porque devuelve Padding
        body: GaussJordanScreen(),
      ),
    );
  }

  group('Pruebas de GaussJordanScreen', () {
    
    testWidgets('Debe iniciar con matriz 3x3 (12 campos de texto)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Una matriz 3x3 para sistemas de ecuaciones tiene 3 filas y 4 columnas (la de resultados).
      // Total = 3 * 4 = 12 TextFields.
      expect(find.byType(TextField), findsNWidgets(12));

      // No deben existir resultados visibles al inicio
      expect(find.text('Solución Exacta:'), findsNothing);
    });

    testWidgets('Debe cambiar la matriz a 2x2 (6 campos) al usar el Dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Buscamos el Dropdown que dice '3 x 3' y lo tocamos
      await tester.tap(find.text('3 x 3'));
      await tester.pumpAndSettle();

      // Seleccionamos '2 x 2' de la lista desplegable
      await tester.tap(find.text('2 x 2').last);
      await tester.pumpAndSettle();

      // Una matriz 2x2 tiene 2 filas y 3 columnas = 6 TextFields
      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('Calcula un sistema de ecuaciones 2x2 correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 1. Cambiamos a 2x2
      await tester.tap(find.text('3 x 3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2 x 2').last);
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);

      // 2. Ingresamos el sistema:
      // 2x + 1y = 5
      // 1x - 3y = -1
      // Solución esperada: x = 2, y = 1

      // Fila 1
      await tester.enterText(textFields.at(0), '2');
      await tester.enterText(textFields.at(1), '1');
      await tester.enterText(textFields.at(2), '5');
      
      // Fila 2
      await tester.enterText(textFields.at(3), '1');
      await tester.enterText(textFields.at(4), '-3');
      await tester.enterText(textFields.at(5), '-1');

      await tester.testTextInput.receiveAction(TextInputAction.done);

      // 3. Calculamos
      final botonResolver = find.widgetWithText(ElevatedButton, 'Resolver Sistema');
      await tester.tap(botonResolver);
      await tester.pumpAndSettle();

      // 4. Verificamos los resultados en los Chips
      expect(find.text('Solución Exacta:'), findsOneWidget);
      expect(find.text('x = 2.0000'), findsOneWidget);
      expect(find.text('y = 1.0000'), findsOneWidget);
    });

    testWidgets('Muestra error si la matriz es singular (Sistemas sin solución única)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Cambiamos a 2x2
      await tester.tap(find.text('3 x 3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2 x 2').last);
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);

      // Ingresamos un sistema paralelo (sin solución única):
      // 1x + 1y = 2
      // 1x + 1y = 3
      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '1');
      await tester.enterText(textFields.at(2), '2');
      
      await tester.enterText(textFields.at(3), '1');
      await tester.enterText(textFields.at(4), '1');
      await tester.enterText(textFields.at(5), '3');

      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonResolver = find.widgetWithText(ElevatedButton, 'Resolver Sistema');
      await tester.tap(botonResolver);
      await tester.pumpAndSettle();

      // Debe proteger el sistema contra división por cero
      expect(find.text('El sistema no tiene solución única (matriz singular).'), findsOneWidget);
    });
  });
}