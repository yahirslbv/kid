import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/metodos_numericos/screens/euler_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold( // Envolvemos en Scaffold porque el widget devuelve un Padding directo
        body: EulerScreen(),
      ),
    );
  }

  group('Pruebas de EulerScreen', () {
    
    testWidgets('Debe iniciar con 5 campos, valores por defecto y sin tabla', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 5 TextFields (Función, x0, y0, xf, h)
      expect(find.byType(TextField), findsNWidgets(5));

      // Verificamos los valores por defecto (x - y, x0=0, y0=2, xf=1, h=0.25)
      expect(find.text('x - y'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0.25'), findsOneWidget);

      // Al inicio no debe haber tabla ni resultado final
      expect(find.byType(DataTable), findsNothing);
      expect(find.textContaining('y(1.00) ≈'), findsNothing);
    });

    testWidgets('Calcula el método de Euler con los valores por defecto correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Evaluamos con los valores por defecto
      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Euler');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos que se muestre el resultado aproximado
      expect(find.textContaining('y(1.00) ≈'), findsOneWidget);
      
      // Verificamos que la tabla de iteraciones se haya dibujado
      expect(find.byType(DataTable), findsOneWidget);
    });

    testWidgets('Debe mostrar error si el paso (h) es menor o igual a 0', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Cambiamos 'h' a 0 (es el 5to TextField, índice 4)
      await tester.enterText(textFields.at(4), '0'); 
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Euler');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos que aparezca la alerta roja del error
      expect(find.text('El tamaño de paso (h) debe ser mayor a 0.'), findsOneWidget);
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Debe mostrar error de sintaxis si la función es inválida', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos una función con variables que el parser no conoce (ej. 'z')
      await tester.enterText(textFields.at(0), 'x - z');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Euler');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos el catch() del código
      expect(find.text('Error en la función. Usa variables x e y (ej: 2*x + y).'), findsOneWidget);
    });
  });
}