import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/metodos_numericos/screens/jacobi_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold( // Envolvemos en Scaffold porque el widget raíz es Padding
        body: JacobiScreen(),
      ),
    );
  }

  group('Pruebas de JacobiScreen', () {
    
    testWidgets('Debe iniciar con matriz 3x3 (12 campos + 1 tol = 13) y sin tabla', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextField), findsNWidgets(13));
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Debe cambiar la matriz a 2x2 (6 campos + 1 tol = 7) al usar el Dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('3x3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2x2').last);
      await tester.pumpAndSettle();

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

      // Ingresamos un sistema diagonalmente dominante (4x + 1y = 5, 1x + 3y = 4)
      await tester.enterText(textFields.at(1), '4');
      await tester.enterText(textFields.at(2), '1');
      await tester.enterText(textFields.at(3), '5');
      
      await tester.enterText(textFields.at(4), '1');
      await tester.enterText(textFields.at(5), '3');
      await tester.enterText(textFields.at(6), '4');

      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonResolver = find.widgetWithText(ElevatedButton, 'Resolver (Jacobi)');
      await tester.tap(botonResolver);
      await tester.pumpAndSettle();

      expect(find.textContaining('Sistema convergido'), findsOneWidget);
      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('1.0000'), findsWidgets); // La solución es x=1, y=1
    });

    testWidgets('Muestra error si hay un cero en la diagonal principal', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('3x3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2x2').last);
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);

      // Ingresamos un cero en A11
      await tester.enterText(textFields.at(1), '0');
      await tester.enterText(textFields.at(2), '1');
      await tester.enterText(textFields.at(3), '2');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonResolver = find.widgetWithText(ElevatedButton, 'Resolver (Jacobi)');
      await tester.tap(botonResolver);
      await tester.pumpAndSettle();

      expect(find.textContaining('Cero en la diagonal principal'), findsOneWidget);
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Muestra error si se ingresan valores inválidos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      await tester.enterText(textFields.at(1), 'hola');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonResolver = find.widgetWithText(ElevatedButton, 'Resolver (Jacobi)');
      await tester.tap(botonResolver);
      await tester.pump();

      expect(find.text('Ingresa solo números válidos.'), findsOneWidget);
    });
  });
}