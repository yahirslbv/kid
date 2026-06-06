import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/metodos_numericos/screens/newton_raphson_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: NewtonRaphsonScreen(),
    );
  }

  group('Pruebas de NewtonRaphsonScreen', () {
    
    testWidgets('Debe iniciar con 4 campos, valores por defecto y sin tabla', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 4 TextFields (Función, Derivada, x0, tol)
      expect(find.byType(TextField), findsNWidgets(4));

      // Verificamos los valores por defecto (x^2 - 4, derivada 2*x, x0=3)
      expect(find.text('x^2 - 4'), findsOneWidget);
      expect(find.text('2*x'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('0.001'), findsOneWidget);

      // Al inicio no debe haber tabla ni resultados
      expect(find.byType(DataTable), findsNothing);
      expect(find.textContaining('Raíz aproximada:'), findsNothing);
    });

    testWidgets('Calcula la raíz de x^2 - 4 partiendo de x0=3 correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Usamos los valores por defecto para calcular
      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Raíz');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // La raíz de x^2 - 4 más cercana a 3 es 2.
      expect(find.textContaining('Raíz aproximada:'), findsOneWidget);
      
      // Usamos findsWidgets porque el valor '2.000' se repite en la tabla de iteraciones
      expect(find.textContaining('2.000'), findsWidgets); 
      
      // Verificamos que la tabla se haya dibujado
      expect(find.byType(DataTable), findsOneWidget);
    });

    testWidgets('Debe mostrar error si la derivada evalúa a cero (División por cero)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Newton-Raphson falla si f'(x) = 0.
      // Si f(x) = x^2 - 4, su derivada es 2*x. Si el valor inicial x0 es 0, la derivada es 0.
      await tester.enterText(textFields.at(2), '0'); // Cambiamos x0 de 3 a 0
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Raíz');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos que aparezca la alerta roja del error
      expect(find.text('Error: La derivada f\'(x) es cero. División por cero.'), findsOneWidget);
      
      // La tabla no debe dibujarse
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Debe mostrar error de sintaxis si la función o derivada es inválida', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos una derivada matemáticamente inválida
      await tester.enterText(textFields.at(1), '2 * / x');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Raíz');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos el catch() del código
      expect(find.text('Error al evaluar. Verifica la sintaxis (ej: 2*x).'), findsOneWidget);
    });
  });
}