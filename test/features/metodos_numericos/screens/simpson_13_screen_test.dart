import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/metodos_numericos/screens/simpson_13_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold( // Envolvemos en Scaffold porque el widget raíz es Padding
        body: Simpson13Screen(),
      ),
    );
  }

  group('Pruebas de Simpson13Screen', () {
    
    testWidgets('Debe iniciar con 4 campos, valores por defecto y sin tabla', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 4 TextFields (Función, a, b, n)
      expect(find.byType(TextField), findsNWidgets(4));

      // Verificamos los valores por defecto (x^2, a=0, b=2, n=4)
      expect(find.text('x^2'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);

      // Al inicio no debe haber tabla ni resultado final
      expect(find.byType(DataTable), findsNothing);
      expect(find.textContaining('I ≈'), findsNothing);
    });

    testWidgets('Calcula la integral de x^2 en [0, 2] con n=4 correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Evaluamos con los valores por defecto
      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Integral');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // El valor exacto analítico de integral(x^2) de 0 a 2 es 8/3 (2.66666...).
      // La regla de Simpson 1/3 es exacta para polinomios de grado 2, así que dará el valor preciso.
      expect(find.textContaining('I ≈ 2.666667'), findsOneWidget);
      
      // Verificamos que la tabla se haya dibujado
      expect(find.byType(DataTable), findsOneWidget);

      // Verificamos que los multiplicadores característicos de Simpson 1/3 (x 4 y x 2) estén en la tabla
      expect(find.text('x 4'), findsWidgets);
      expect(find.text('x 2'), findsWidgets);
    });

    testWidgets('Debe mostrar error si n es un número IMPAR', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Cambiamos 'n' a 3 (un número impar, lo cual rompe la regla de Simpson 1/3)
      await tester.enterText(textFields.at(3), '3'); 
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Integral');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos que la alerta de validación detenga el cálculo
      expect(find.text('Para Simpson 1/3, el número de intervalos (n) debe ser par y mayor a 0.'), findsOneWidget);
      
      // La tabla no debe generarse
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Debe mostrar error de sintaxis si la función es inválida', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos una función mal escrita 
      await tester.enterText(textFields.at(0), '(x^2 *');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Integral');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos el catch() del código
      expect(find.text('Error al evaluar la función. Verifica la sintaxis.'), findsOneWidget);
    });
  });
}