import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/metodos_numericos/screens/gauss_seidel_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold( // Envolvemos en Scaffold porque el widget raíz es Padding
        body: GaussSeidelScreen(),
      ),
    );
  }

  group('Pruebas de GaussSeidelScreen', () {
    
    testWidgets('Debe iniciar con matriz 3x3 (12 campos + 1 tol = 13) y sin tabla', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 3x3 implica 3 filas y 4 columnas = 12 campos de la matriz.
      // Más 1 campo para la Tolerancia = 13 TextFields en total.
      expect(find.byType(TextField), findsNWidgets(13));

      // No debe haber tabla de iteraciones al inicio
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Debe cambiar la matriz a 2x2 (6 campos + 1 tol = 7) al usar el Dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Buscamos el Dropdown que dice '3x3' y lo tocamos
      await tester.tap(find.text('3x3'));
      await tester.pumpAndSettle();

      // Seleccionamos '2x2'
      await tester.tap(find.text('2x2').last);
      await tester.pumpAndSettle();

      // 2 filas x 3 columnas = 6 campos. Más 1 de tolerancia = 7 TextFields.
      expect(find.byType(TextField), findsNWidgets(7));
    });

    testWidgets('Resuelve un sistema 2x2 convergente correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 1. Cambiamos a 2x2
      await tester.tap(find.text('3x3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2x2').last);
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);

      // OJO: El TextField de la tolerancia está ANTES de la matriz en el árbol de widgets.
      // Por lo tanto:
      // textFields.at(0) = Tolerancia
      // textFields.at(1 al 6) = Matriz

      // 2. Ingresamos un sistema diagonalmente dominante:
      // 4x + 1y = 5
      // 1x + 3y = 4
      // Solución: x = 1, y = 1
      
      // Fila 1
      await tester.enterText(textFields.at(1), '4');
      await tester.enterText(textFields.at(2), '1');
      await tester.enterText(textFields.at(3), '5');
      
      // Fila 2
      await tester.enterText(textFields.at(4), '1');
      await tester.enterText(textFields.at(5), '3');
      await tester.enterText(textFields.at(6), '4');

      await tester.testTextInput.receiveAction(TextInputAction.done);

      // 3. Calculamos
      final botonResolver = find.widgetWithText(ElevatedButton, 'Resolver (Gauss-Seidel)');
      await tester.tap(botonResolver);
      await tester.pumpAndSettle();

      // 4. Verificamos los resultados
      expect(find.textContaining('Sistema convergido'), findsOneWidget);
      expect(find.byType(DataTable), findsOneWidget);
      
      // Como sabemos que la solución es x=1, y=1, buscamos '1.0000'
      expect(find.text('1.0000'), findsWidgets);
    });

    testWidgets('Muestra error si hay un cero en la diagonal principal', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Cambiamos a 2x2
      await tester.tap(find.text('3x3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2x2').last);
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);

      // Ingresamos un sistema con 0 en A11:
      // 0x + 1y = 2
      // 1x + 3y = 4
      await tester.enterText(textFields.at(1), '0'); // Diagonal principal
      await tester.enterText(textFields.at(2), '1');
      await tester.enterText(textFields.at(3), '2');
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonResolver = find.widgetWithText(ElevatedButton, 'Resolver (Gauss-Seidel)');
      await tester.tap(botonResolver);
      await tester.pumpAndSettle();

      // Debe saltar la alerta roja del error
      expect(find.text('Error: Cero en la diagonal principal. Intenta reordenar las filas.'), findsOneWidget);
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Muestra error si se ingresan valores inválidos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos letras en lugar de números en el primer campo de la matriz
      await tester.enterText(textFields.at(1), 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonResolver = find.widgetWithText(ElevatedButton, 'Resolver (Gauss-Seidel)');
      await tester.tap(botonResolver);
      await tester.pump();

      // Verificamos que el catch() capture el error de parseo
      expect(find.text('Ingresa solo números válidos.'), findsOneWidget);
    });
  });
}