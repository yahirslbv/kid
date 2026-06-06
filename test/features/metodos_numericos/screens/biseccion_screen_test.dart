import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/metodos_numericos/screens/biseccion_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: BiseccionScreen(),
    );
  }

  group('Pruebas de BiseccionScreen', () {
    
    testWidgets('Debe iniciar con valores por defecto y sin tabla/resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan los 4 TextFields (Función, a, b, tol)
      expect(find.byType(TextField), findsNWidgets(4));

      // Verificamos los valores por defecto (x^2 - 4, en intervalo [0, 3])
      expect(find.text('x^2 - 4'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('0.001'), findsOneWidget);

      // Al inicio no debe haber tabla ni mensaje de raíz
      expect(find.byType(DataTable), findsNothing);
      expect(find.textContaining('Raíz aproximada:'), findsNothing);
    });

    testWidgets('Calcula la raíz de x^2 - 4 en [0, 3] correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Evaluamos con los valores por defecto
      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Raíz');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // La raíz de x^2 - 4 en el intervalo [0, 3] es exactamente 2.
      expect(find.textContaining('Raíz aproximada:'), findsOneWidget);
      
      // --- CORRECCIÓN AQUÍ ---
      // Usamos findsWidgets porque el valor 2.000 se repetirá en las últimas iteraciones de la tabla
      expect(find.textContaining('2.000'), findsWidgets); 
      
      // Verificamos que la tabla de iteraciones se haya dibujado
      expect(find.byType(DataTable), findsOneWidget);
    });

    testWidgets('Debe mostrar error si f(a) y f(b) NO tienen signos opuestos (Teorema de Bolzano)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Evaluaremos x^2 - 4 en el intervalo [0, 1]. 
      // f(0) = -4 y f(1) = -3. Ambos son negativos, así que la bisección fallará.
      await tester.enterText(textFields.at(2), '1'); // Cambiamos b=3 a b=1
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Raíz');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos que aparezca la alerta roja del error
      expect(find.textContaining('f(a) y f(b) deben tener signos opuestos'), findsOneWidget);
      
      // La tabla no debe dibujarse
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Debe mostrar error de sintaxis si la función es inválida', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos una función con un paréntesis sin cerrar para forzar el fallo del parser
      await tester.enterText(textFields.at(0), '(x^2 - 4');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Raíz');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos el catch() del código
      expect(find.textContaining('Error al evaluar la función. Verifica la sintaxis'), findsOneWidget);
    });
  });
}