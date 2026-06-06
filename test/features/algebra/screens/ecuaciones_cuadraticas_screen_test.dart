import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/algebra/screens/ecuaciones_cuadraticas_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: EcuacionesCuadraticasScreen(),
    );
  }

  group('Pruebas de EcuacionesCuadraticasScreen', () {
    
    testWidgets('Debe iniciar con los valores por defecto (A=1, B=0, C=-4) y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 3 campos de texto (A, B, C)
      expect(find.byType(TextField), findsNWidgets(3));

      // Verificamos que los resultados NO estén visibles al inicio
      expect(find.textContaining('x₁ ='), findsNothing);
      expect(find.textContaining('x₂ ='), findsNothing);
    });

    testWidgets('Calcula raíces reales y distintas (Valores por defecto: x² - 4 = 0)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Presionamos el botón "Resolver" directamente usando los valores por defecto
      final botonResolver = find.text('Resolver');
      await tester.tap(botonResolver);
      await tester.pumpAndSettle();

      // Las raíces de x² - 4 = 0 son 2 y -2. El discriminante es 16.
      expect(find.text('Raíces reales y distintas'), findsOneWidget);
      expect(find.text('Δ = 16.00'), findsOneWidget);
      expect(find.text('x₁ = 2.0000'), findsOneWidget);
      expect(find.text('x₂ = -2.0000'), findsOneWidget);
    });

    testWidgets('Calcula raíces reales e iguales (Ejemplo: x² - 2x + 1 = 0)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos A=1, B=-2, C=1
      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '-2');
      await tester.enterText(textFields.at(2), '1');
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonResolver = find.text('Resolver');
      await tester.tap(botonResolver);
      await tester.pumpAndSettle();

      // Las raíces de (x-1)² = 0 son 1 y 1. El discriminante es 0.
      expect(find.text('Raíces reales e iguales'), findsOneWidget);
      expect(find.text('Δ = 0.00'), findsOneWidget);
      expect(find.text('x₁ = 1.0000'), findsOneWidget);
      expect(find.text('x₂ = 1.0000'), findsOneWidget);
    });

    testWidgets('Calcula raíces complejas/imaginarias (Ejemplo: x² + x + 1 = 0)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos A=1, B=1, C=1
      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '1');
      await tester.enterText(textFields.at(2), '1');
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonResolver = find.text('Resolver');
      await tester.tap(botonResolver);
      await tester.pumpAndSettle();

      // El discriminante es negativo (-3), debe mostrar la letra 'i'
      expect(find.text('Raíces complejas / imaginarias'), findsOneWidget);
      expect(find.text('Δ = -3.00'), findsOneWidget);
      
      // Verificamos que los resultados contengan la letra 'i'
      expect(find.textContaining('i'), findsWidgets);
    });

    testWidgets('Debe mostrar error si el valor de A es 0', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos A=0
      await tester.enterText(textFields.at(0), '0');
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonResolver = find.text('Resolver');
      await tester.tap(botonResolver);
      await tester.pumpAndSettle();

      // Debe aparecer el mensaje de error para proteger la división entre cero
      expect(find.text('No es una ecuación cuadrática (A no puede ser 0)'), findsOneWidget);
    });
  });
}