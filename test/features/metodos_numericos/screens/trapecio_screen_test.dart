import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/metodos_numericos/screens/trapecio_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold( // Envolvemos en Scaffold porque el widget raíz es Padding
        body: TrapecioScreen(),
      ),
    );
  }

  group('Pruebas de TrapecioScreen', () {
    
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

    testWidgets('Calcula la integral de x^2 en [0, 2] con 4 intervalos correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Evaluamos con los valores por defecto
      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Integral');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos que se muestre el resultado aproximado
      // El valor exacto analítico es 8/3 (2.666...), por trapecio con n=4 da 2.750000
      expect(find.textContaining('I ≈ 2.750000'), findsOneWidget);
      
      // Verificamos que la tabla se haya dibujado
      expect(find.byType(DataTable), findsOneWidget);
    });

    testWidgets('Debe mostrar error si el número de intervalos (n) es menor o igual a 0', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Cambiamos 'n' a 0 (es el 4to TextField, índice 3)
      await tester.enterText(textFields.at(3), '0'); 
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Integral');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos que aparezca la alerta roja del error
      expect(find.text('El número de intervalos (n) debe ser mayor a 0.'), findsOneWidget);
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Debe mostrar error de sintaxis si la función es inválida', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos una función mal escrita (ej. un paréntesis sin cerrar)
      await tester.enterText(textFields.at(0), '(x^2 + 1');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Integral');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos el catch() del código
      expect(find.text('Error al evaluar la función. Verifica la sintaxis.'), findsOneWidget);
    });
  });
}