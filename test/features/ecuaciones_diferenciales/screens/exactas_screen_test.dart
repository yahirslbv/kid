import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/ecuaciones_diferenciales/screens/exactas_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: ExactasScreen(),
    );
  }

  group('Pruebas de ExactasScreen', () {
    
    testWidgets('Debe iniciar con 2 campos de texto, teclado virtual y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 2 TextFields (M(x,y) y N(x,y))
      expect(find.byType(TextField), findsNWidgets(2));

      // Verificamos que exista el botón principal
      expect(find.text('Comprobar Exactitud'), findsOneWidget);

      // Verificamos que el teclado matemático esté presente buscando su contenedor Wrap
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(InkWell), findsAtLeastNWidgets(10));

      // Al inicio no debe existir la sección de procedimiento
      expect(find.text('Verificación de derivadas cruzadas:'), findsNothing);
    });

    testWidgets('Debe mostrar un SnackBar de error si los campos están vacíos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final botonCalcular = find.text('Comprobar Exactitud');
      
      // Scroll hacia el botón
      await tester.ensureVisible(botonCalcular);
      
      // Presionamos el botón sin ingresar datos
      await tester.tap(botonCalcular);
      await tester.pump(); // Para la animación del SnackBar

      // Verificamos que el mensaje de error aparezca en pantalla
      expect(find.text('Por favor, ingresa M(x,y) y N(x,y).'), findsOneWidget);
      
      // La sección de resultados no debe generarse
      expect(find.text('Verificación de derivadas cruzadas:'), findsNothing);
    });

    testWidgets('Muestra el procedimiento al ingresar M y N correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Simulamos que el usuario ingresa M(x,y) = 2xy y N(x,y) = x^2
      await tester.enterText(textFields.at(0), '2xy');
      await tester.enterText(textFields.at(1), 'x^2');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.text('Comprobar Exactitud');
      
      // Scroll y tap al botón
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      
      // Esperamos a que terminen las animaciones de la UI
      await tester.pumpAndSettle();

      // Hacemos scroll al resultado para asegurar que esté en pantalla
      await tester.ensureVisible(find.text('Verificación de derivadas cruzadas:'));

      // Verificamos que las tarjetas con el procedimiento matemático aparezcan
      expect(find.text('Verificación de derivadas cruzadas:'), findsOneWidget);
      expect(find.text('1. Derivada de M respecto a y'), findsOneWidget);
      expect(find.text('2. Derivada de N respecto a x'), findsOneWidget);
    });
  });
}