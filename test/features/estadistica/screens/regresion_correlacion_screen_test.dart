import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:graficacion_ai/features/estadistica/screens/regresion_correlacion_screen.dart';
import 'package:graficacion_ai/features/chat/logic/chat_provider.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()), 
      ],
      child: const MaterialApp(
        home: RegresionCorrelacionScreen(),
      ),
    );
  }

  group('Pruebas de la Pantalla Regresión y Correlación', () {
    
    testWidgets('Debe iniciar con los campos vacíos y sin gráficos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan exactamente 2 campos de texto (X e Y)
      expect(find.byType(TextField), findsNWidgets(2));
      
      // Validamos que el botón de calcular esté presente
      expect(find.text('Calcular y Graficar'), findsOneWidget);

      // Verificamos que los resultados NO estén visibles al inicio
      expect(find.text('Ecuación de la Recta (Modelo)'), findsNothing);
      expect(find.text('Gráfico de Dispersión y Ajuste Lineal'), findsNothing);
    });

    testWidgets('Calcula una regresión perfecta y muestra los resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos datos con una correlación perfecta positiva (y = 2x)
      await tester.enterText(textFields.at(0), '1, 2, 3, 4, 5'); // Datos X
      await tester.enterText(textFields.at(1), '2, 4, 6, 8, 10'); // Datos Y
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Ejecutamos el cálculo
      final botonCalcular = find.text('Calcular y Graficar');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos que aparezca la sección de la ecuación
      expect(find.text('Ecuación de la Recta (Modelo)'), findsOneWidget);
      
      // La correlación r debe ser 1.0000 y r2 debe ser 1.0000
      expect(find.text('1.0000'), findsWidgets);
      
      // Debe mostrar la interpretación correcta
      expect(find.textContaining('La correlación es muy fuerte y positiva'), findsOneWidget);
      
      // Debe aparecer el título del gráfico
      expect(find.text('Gráfico de Dispersión y Ajuste Lineal'), findsOneWidget);
    });

    testWidgets('Debe mostrar error si hay diferente cantidad de datos en X e Y', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos 3 datos en X pero solo 2 datos en Y
      await tester.enterText(textFields.at(0), '1, 2, 3'); 
      await tester.enterText(textFields.at(1), '4, 5'); 
      
      final botonCalcular = find.text('Calcular y Graficar');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pump(); // Usamos pump() para capturar el SnackBar

      // Verificamos el mensaje de error exacto
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Error: Los conjuntos X e Y deben tener la misma cantidad de datos'), findsOneWidget);
    });

    testWidgets('Debe mostrar error si se ingresan menos de 2 pares de datos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos solo 1 dato en cada campo
      await tester.enterText(textFields.at(0), '10'); 
      await tester.enterText(textFields.at(1), '20'); 
      
      final botonCalcular = find.text('Calcular y Graficar');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pump(); 

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Error: Se requieren al menos 2 pares de datos.'), findsOneWidget);
    });
  });
}