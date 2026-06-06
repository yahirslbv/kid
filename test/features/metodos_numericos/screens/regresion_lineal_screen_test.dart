import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/metodos_numericos/screens/regresion_lineal_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold( // Envolvemos en Scaffold porque el widget raíz es Padding
        body: RegresionLinealScreen(),
      ),
    );
  }

  group('Pruebas de RegresionLinealScreen', () {
    
    testWidgets('Debe iniciar con 2 campos, valores por defecto y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 2 TextFields (X y Y)
      expect(find.byType(TextField), findsNWidgets(2));

      // Verificamos los valores por defecto
      expect(find.text('1, 2, 3, 4, 5'), findsOneWidget);
      expect(find.text('2.1, 4.0, 6.2, 8.1, 9.9'), findsOneWidget);

      // Al inicio no debe haber resultados en pantalla
      expect(find.text('Ecuación de la Recta'), findsNothing);
      expect(find.text('Sumatorias (Paso a paso)'), findsNothing);
    });

    testWidgets('Calcula la regresión con los valores por defecto correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Evaluamos con los valores por defecto
      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Regresión');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos que las tarjetas de resultados se hayan dibujado
      expect(find.text('Ecuación de la Recta'), findsOneWidget);
      expect(find.text('Sumatorias (Paso a paso)'), findsOneWidget);
      
      // Verificamos que se muestren las etiquetas de correlación y puntos
      expect(find.text('Correlación (r)'), findsOneWidget);
      expect(find.text('Puntos (n)'), findsOneWidget);
    });

    testWidgets('Debe mostrar error si X y Y no tienen la misma cantidad de datos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Cambiamos X a 3 elementos, mientras Y sigue teniendo 5
      await tester.enterText(textFields.at(0), '1, 2, 3'); 
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Regresión');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos la alerta roja
      expect(find.text('Error: Debe haber la misma cantidad de valores en X y en Y.'), findsOneWidget);
      expect(find.text('Ecuación de la Recta'), findsNothing);
    });

    testWidgets('Debe mostrar error si se ingresa un solo punto', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos solo 1 valor en X y 1 en Y
      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '2.1');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Regresión');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Para una recta (m, b) necesitamos al menos 2 puntos
      expect(find.text('Error: Se necesitan al menos 2 puntos.'), findsOneWidget);
    });

    testWidgets('Debe mostrar error de formato si se ingresan letras', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos letras en lugar de números
      await tester.enterText(textFields.at(0), 'a, b, c');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Calcular Regresión');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos el catch() del código
      expect(find.text('Error de formato. Usa solo números separados por comas (ej: 1, 2.5, 3).'), findsOneWidget);
    });
  });
} 