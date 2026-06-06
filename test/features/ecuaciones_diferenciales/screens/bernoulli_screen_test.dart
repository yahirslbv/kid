import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/ecuaciones_diferenciales/screens/bernoulli_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: BernoulliScreen(),
    );
  }

  group('Pruebas de BernoulliScreen', () {
    
    testWidgets('Debe iniciar con 3 campos de texto, teclado virtual y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 3 TextFields (P(x), Q(x) y n)
      expect(find.byType(TextField), findsNWidgets(3));

      // Verificamos que exista el botón principal
      expect(find.text('Plantear Sustitución'), findsOneWidget);

      // Verificamos que el teclado matemático esté presente
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(InkWell), findsAtLeastNWidgets(10));

      // Al inicio no debe existir la sección de procedimiento
      expect(find.text('Procedimiento inicial:'), findsNothing);
    });

    testWidgets('Debe mostrar un SnackBar de error si algún campo está vacío', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final botonCalcular = find.text('Plantear Sustitución');
      
      // Scroll hacia el botón
      await tester.ensureVisible(botonCalcular);
      
      // Presionamos el botón sin ingresar datos
      await tester.tap(botonCalcular);
      await tester.pump(); // Renderizar el SnackBar

      // Verificamos que el mensaje de error de Bernoulli aparezca en pantalla
      expect(find.text('Por favor, ingresa P(x), Q(x) y el valor de n.'), findsOneWidget);
      
      // La sección de resultados no debe generarse
      expect(find.text('Procedimiento inicial:'), findsNothing);
    });

    testWidgets('Muestra el procedimiento al ingresar P, Q y n correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Simulamos que el usuario ingresa P(x) = 1/x, Q(x) = x, n = 2
      await tester.enterText(textFields.at(0), '1/x');
      await tester.enterText(textFields.at(1), 'x');
      await tester.enterText(textFields.at(2), '2');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.text('Plantear Sustitución');
      
      // Scroll y tap al botón
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      
      // Esperamos a que terminen las animaciones
      await tester.pumpAndSettle();

      // Hacemos scroll al resultado
      await tester.ensureVisible(find.text('Procedimiento inicial:'));

      // Verificamos que las tarjetas con el procedimiento matemático aparezcan
      expect(find.text('Procedimiento inicial:'), findsOneWidget);
      expect(find.text('1. Definir la sustitución u'), findsOneWidget);
      expect(find.text('2. Ecuación Lineal Resultante'), findsOneWidget);
    });
  });
}