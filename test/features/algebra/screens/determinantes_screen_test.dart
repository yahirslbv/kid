import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/algebra/screens/determinantes_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: DeterminantesScreen(),
    );
  }

  group('Pruebas de DeterminantesScreen', () {
    
    testWidgets('Debe iniciar con matriz 3x3 (9 campos) y sin resultado', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextField), findsNWidgets(9));
      expect(find.textContaining('|A| ='), findsNothing);
    });

    testWidgets('Debe cambiar la matriz a 2x2 (4 campos) al seleccionar el Radio', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // --- CORRECCIÓN AQUÍ ---
      // Buscamos explícitamente el widget Radio cuyo valor interno sea 2
      final radio2x2 = find.byWidgetPredicate((widget) => widget is Radio<int> && widget.value == 2);
      
      await tester.tap(radio2x2);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('Calcula el determinante de una matriz 2x2 correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // --- CORRECCIÓN AQUÍ TAMBIÉN ---
      final radio2x2 = find.byWidgetPredicate((widget) => widget is Radio<int> && widget.value == 2);
      await tester.tap(radio2x2);
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);

      await tester.enterText(textFields.at(0), '5');
      await tester.enterText(textFields.at(1), '2');
      await tester.enterText(textFields.at(2), '3');
      await tester.enterText(textFields.at(3), '4');
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.text('Calcular |A|');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      expect(find.text('|A| = 14'), findsOneWidget);
    });

    testWidgets('Calcula el determinante de una matriz 3x3 correctamente (Regla de Sarrus)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      await tester.enterText(textFields.at(0), '2'); 
      await tester.enterText(textFields.at(1), '0'); 
      await tester.enterText(textFields.at(2), '0'); 
      
      await tester.enterText(textFields.at(3), '0'); 
      await tester.enterText(textFields.at(4), '3'); 
      await tester.enterText(textFields.at(5), '0'); 
      
      await tester.enterText(textFields.at(6), '0'); 
      await tester.enterText(textFields.at(7), '0'); 
      await tester.enterText(textFields.at(8), '4'); 
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.text('Calcular |A|');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      expect(find.text('|A| = 24'), findsOneWidget);
    });
  });
}