import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/ecuaciones_diferenciales/screens/lineales_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: LinealesScreen(),
    );
  }

  group('Pruebas de LinealesScreen', () {
    
    testWidgets('Debe iniciar con 2 campos de texto, teclado virtual y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 2 TextFields (P(x) y Q(x))
      expect(find.byType(TextField), findsNWidgets(2));

      // Verificamos que exista el botón principal
      expect(find.text('Plantear Solución'), findsOneWidget);

      // Verificamos que el teclado matemático esté presente
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(InkWell), findsAtLeastNWidgets(10));

      // Al inicio no debe existir la sección de procedimiento
      expect(find.text('Procedimiento analítico:'), findsNothing);
    });

    testWidgets('Debe mostrar un SnackBar de error si los campos están vacíos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final botonCalcular = find.text('Plantear Solución');
      
      // Scroll hacia el botón
      await tester.ensureVisible(botonCalcular);
      
      // Presionamos el botón sin ingresar datos
      await tester.tap(botonCalcular);
      await tester.pump(); // Renderizar el SnackBar

      // Verificamos que el mensaje de error aparezca en pantalla
      expect(find.text('Por favor, ingresa P(x) y Q(x).'), findsOneWidget);
      
      // La sección de resultados no debe generarse
      expect(find.text('Procedimiento analítico:'), findsNothing);
    });

    testWidgets('Muestra el procedimiento al ingresar P y Q correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Simulamos que el usuario ingresa P(x) = 2/x y Q(x) = x^2
      await tester.enterText(textFields.at(0), '2/x');
      await tester.enterText(textFields.at(1), 'x^2');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.text('Plantear Solución');
      
      // Scroll y tap al botón
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      
      // Esperamos a que terminen las animaciones
      await tester.pumpAndSettle();

      // Hacemos scroll al resultado
      await tester.ensureVisible(find.text('Procedimiento analítico:'));

      // Verificamos que las tarjetas con el procedimiento matemático (Factor Integrante) aparezcan
      expect(find.text('Procedimiento analítico:'), findsOneWidget);
      expect(find.text('1. Calcular Factor Integrante'), findsOneWidget);
      expect(find.text('2. Plantear Integral General'), findsOneWidget);
    });
  });
}