import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/metodos_numericos/screens/secante_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: SecanteScreen(),
    );
  }

  group('Pruebas de SecanteScreen', () {
    
    testWidgets('Debe iniciar con 4 campos, valores por defecto y sin tabla', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 4 TextFields (Función, x_i-1, x_i, tol)
      expect(find.byType(TextField), findsNWidgets(4));

      // Verificamos los valores por defecto (x^2 - 4, x0=0, x1=3)
      expect(find.text('x^2 - 4'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('0.001'), findsOneWidget);

      // Al inicio no debe haber tabla ni resultados
      expect(find.byType(DataTable), findsNothing);
      expect(find.textContaining('Raíz aproximada:'), findsNothing);
    });

    testWidgets('Calcula la raíz de x^2 - 4 partiendo de 0 y 3 correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Usamos los valores por defecto para calcular
      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Raíz');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // La raíz de x^2 - 4 entre 0 y 3 es 2.
      expect(find.textContaining('Raíz aproximada:'), findsOneWidget);
      
      // Usamos findsWidgets porque el valor '2.000' aparecerá en la tabla varias veces al acercarse a la raíz
      expect(find.textContaining('2.000'), findsWidgets); 
      
      // Verificamos que la tabla se haya dibujado
      expect(find.byType(DataTable), findsOneWidget);
    });

    testWidgets('Debe mostrar error si f(x_i) y f(x_i-1) son iguales (División por cero)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Si f(x) = x^2 - 4
      // Si evaluamos en x = -2, f(-2) = 0. Si evaluamos en x = 2, f(2) = 0.
      // Como 0 - 0 = 0, esto provocará una división por cero en el método de la secante.
      await tester.enterText(textFields.at(1), '-2'); // x_i-1
      await tester.enterText(textFields.at(2), '2');  // x_i
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Raíz');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos que aparezca la alerta roja del error
      expect(find.text('Error: f(x_i) y f(x_i-1) son iguales. División por cero.'), findsOneWidget);
      
      // La tabla no debe dibujarse
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Debe mostrar error de sintaxis si la función es inválida', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos una función matemáticamente inválida
      await tester.enterText(textFields.at(0), '(x^2 - 4');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Raíz');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos el catch() del código
      expect(find.text('Error al evaluar. Verifica la sintaxis (ej: x^2 - 4).'), findsOneWidget);
    });
  });
}