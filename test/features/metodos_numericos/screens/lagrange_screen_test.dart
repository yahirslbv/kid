import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/metodos_numericos/screens/lagrange_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold( // Envolvemos en Scaffold porque el widget raíz es Padding
        body: LagrangeScreen(),
      ),
    );
  }

  group('Pruebas de LagrangeScreen', () {
    
    testWidgets('Debe iniciar con 3 campos, valores por defecto y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 3 TextFields (X, Y, xInt)
      expect(find.byType(TextField), findsNWidgets(3));

      // Verificamos los valores por defecto
      expect(find.text('1, 3, 5, 7'), findsOneWidget);
      expect(find.text('2, 4, 8, 12'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);

      // Al inicio no debe haber caja de resultados ni desarrollo
      // CORRECCIÓN: Buscamos solo el símbolo de aproximado
      expect(find.textContaining('≈'), findsNothing); 
      expect(find.text('Desarrollo de Polinomios L(x)'), findsNothing);
    });

    testWidgets('Calcula la interpolación con los valores por defecto correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Evaluamos con los valores por defecto
      final botonCalcular = find.widgetWithText(ElevatedButton, 'Interpolar Valor');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos que se muestre el resultado de la interpolación
      // CORRECCIÓN: Dart convierte el 4 a double, por lo que imprime 4.0
      expect(find.textContaining('f(4.0) ≈'), findsOneWidget); 
      
      // Verificamos que la sección del desarrollo paso a paso se haya dibujado
      expect(find.text('Desarrollo de Polinomios L(x)'), findsOneWidget);
    });

    testWidgets('Debe mostrar error si X y Y no tienen la misma cantidad de datos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Cambiamos la lista X para que tenga solo 2 elementos, mientras que Y tiene 4
      await tester.enterText(textFields.at(0), '1, 3'); 
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Interpolar Valor');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos que aparezca la alerta roja del error de longitud
      expect(find.text('X y Y deben tener la misma cantidad de datos.'), findsOneWidget);
      
      // El desarrollo no debe generarse
      expect(find.text('Desarrollo de Polinomios L(x)'), findsNothing);
    });

    testWidgets('Debe mostrar error de formato si se ingresan letras', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos letras en lugar de números separados por comas
      await tester.enterText(textFields.at(0), 'a, b, c');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.widgetWithText(ElevatedButton, 'Interpolar Valor');
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos el catch() del código
      expect(find.text('Formato inválido. Usa números separados por comas.'), findsOneWidget);
    });
  });
}