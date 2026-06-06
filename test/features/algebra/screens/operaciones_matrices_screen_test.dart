import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/algebra/screens/operaciones_matrices_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: OperacionesMatricesScreen(),
    );
  }

  group('Pruebas de OperacionesMatricesScreen', () {
    
    testWidgets('Debe iniciar con matrices 2x2 (8 campos de texto) y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 2 matrices de 2x2 = 8 campos de texto en total
      expect(find.byType(TextField), findsNWidgets(8));

      // Verificamos que los títulos de operación no estén visibles
      expect(find.text('A + B ='), findsNothing);
      expect(find.text('A × B ='), findsNothing);
    });

    testWidgets('Debe cambiar a matrices 3x3 (18 campos de texto) al seleccionar el Radio', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Buscamos el Radio button con valor 3 (que corresponde a 3x3)
      final radio3x3 = find.byWidgetPredicate((widget) => widget is Radio<int> && widget.value == 3);
      await tester.tap(radio3x3);
      await tester.pumpAndSettle();

      // 2 matrices de 3x3 = 18 campos de texto en total
      expect(find.byType(TextField), findsNWidgets(18));
    });

    testWidgets('Calcula la suma de matrices 2x2 correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Llenamos la Matriz A con 1s (Índices 0 al 3)
      for (int i = 0; i < 4; i++) {
        await tester.enterText(textFields.at(i), '1');
      }
      
      // Llenamos la Matriz B con 2s (Índices 4 al 7)
      for (int i = 4; i < 8; i++) {
        await tester.enterText(textFields.at(i), '2');
      }
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Presionamos el botón de Sumar
      final botonSumar = find.widgetWithText(ElevatedButton, '+ Sumar');
      await tester.tap(botonSumar);
      await tester.pumpAndSettle();

      // Verificamos que aparezca el título de la suma
      expect(find.text('A + B ='), findsOneWidget);

      // 1 + 2 = 3. Deberíamos encontrar el número '3' en los resultados.
      // Como son 4 celdas de resultado, el texto '3' debe aparecer múltiples veces.
      expect(find.text('3'), findsWidgets); 
    });

    testWidgets('Calcula la multiplicación de matrices 2x2 correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Matriz A:
      // [ 1  2 ]
      // [ 3  4 ]
      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '2');
      await tester.enterText(textFields.at(2), '3');
      await tester.enterText(textFields.at(3), '4');

      // Matriz B:
      // [ 2  0 ]
      // [ 1  2 ]
      await tester.enterText(textFields.at(4), '2');
      await tester.enterText(textFields.at(5), '0');
      await tester.enterText(textFields.at(6), '1');
      await tester.enterText(textFields.at(7), '2');
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Presionamos el botón de Multiplicar
      final botonMulti = find.widgetWithText(ElevatedButton, '× Multiplicar');
      await tester.tap(botonMulti);
      await tester.pumpAndSettle();

      expect(find.text('A × B ='), findsOneWidget);

      // Resultados esperados de la multiplicación:
      // C11 = (1*2) + (2*1) = 4
      // C12 = (1*0) + (2*2) = 4
      // C21 = (3*2) + (4*1) = 10
      // C22 = (3*0) + (4*2) = 8
      
      expect(find.text('4'), findsWidgets);  // Aparece en C11 y C12
      expect(find.text('10'), findsOneWidget); // Aparece en C21
      expect(find.text('8'), findsOneWidget);  // Aparece en C22
    });
  });
}