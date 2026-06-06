import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:graficacion_ai/features/algebra/screens/tabulador_screen.dart';
import 'package:graficacion_ai/features/chat/logic/chat_provider.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MaterialApp(
        home: TabuladorScreen(),
      ),
    );
  }

  group('Pruebas de TabuladorScreen', () {
    
    testWidgets('Debe iniciar con 4 campos, valores por defecto y sin tabla', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan los 4 TextFields
      expect(find.byType(TextField), findsNWidgets(4));

      // Verificamos los textos iniciales (x^2 - 4, -5, 5, 1)
      expect(find.text('x^2 - 4'), findsOneWidget);
      expect(find.text('-5'), findsOneWidget);
      
      // La tabla no se debe renderizar aún
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Calcula f(x) = x^2 - 4 correctamente con los valores por defecto', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final botonGenerar = find.widgetWithText(ElevatedButton, 'Generar Tabla');
      await tester.tap(botonGenerar);
      
      // pumpAndSettle para esperar a que termine de procesar el ciclo while
      await tester.pumpAndSettle();

      // Debe aparecer la DataTable
      expect(find.byType(DataTable), findsOneWidget);

      // Verificamos algunos valores clave de f(x) = x^2 - 4
      // Si x = 0, f(0) = -4.0000
      expect(find.text('-4.0000'), findsWidgets);
      
      // Si x = 2, f(2) = 0.0000
      expect(find.text('0.0000'), findsWidgets);
      
      // Si x = 5, f(5) = 21.0000
      expect(find.text('21.0000'), findsWidgets);
    });

    testWidgets('Debe mostrar error si el paso es menor o igual a 0', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Modificamos el campo del "Paso" (es el índice 3)
      await tester.enterText(textFields.at(3), '0');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonGenerar = find.widgetWithText(ElevatedButton, 'Generar Tabla');
      await tester.ensureVisible(botonGenerar);
      await tester.tap(botonGenerar);
      await tester.pump();

      // Verificamos el mensaje de error exacto
      expect(find.text('El paso debe ser mayor a 0.'), findsOneWidget);
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Debe mostrar error si x inicial es mayor a x final', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Modificamos el campo "x inicial" a 10 (mayor que x final que es 5)
      await tester.enterText(textFields.at(1), '10');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonGenerar = find.widgetWithText(ElevatedButton, 'Generar Tabla');
      await tester.ensureVisible(botonGenerar);
      await tester.tap(botonGenerar);
      await tester.pump();

      // Verificamos el mensaje de error exacto
      expect(find.text('x inicial no puede ser mayor a x final.'), findsOneWidget);
    });

testWidgets('Debe atrapar errores de sintaxis en la función matemática', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos una función matemáticamente inválida que la librería NO pueda procesar
      // (ej. un paréntesis sin cerrar o símbolos sin sentido)
      await tester.enterText(textFields.at(0), '(x + 2'); 
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonGenerar = find.widgetWithText(ElevatedButton, 'Generar Tabla');
      await tester.ensureVisible(botonGenerar);
      await tester.tap(botonGenerar);
      
      // Usamos pumpAndSettle para asegurarnos de que la interfaz se actualice tras el setState
      await tester.pumpAndSettle(); 

      // Verificamos que el parser atrape el error y muestre el mensaje
      expect(find.text('Error de sintaxis. Usa "x" como variable.'), findsOneWidget);
    });
  });
}