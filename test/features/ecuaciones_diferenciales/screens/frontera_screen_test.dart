import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/ecuaciones_diferenciales/screens/frontera_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: FronteraScreen(),
    );
  }

  group('Pruebas de FronteraScreen', () {
    
    testWidgets('Debe iniciar con 2 campos de texto, teclado virtual y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 2 TextFields (f(x) y L)
      expect(find.byType(TextField), findsNWidgets(2));

      // Verificamos que exista el botón principal
      expect(find.text('Plantear Coeficientes'), findsOneWidget);

      // Verificamos que el teclado matemático esté presente
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(InkWell), findsAtLeastNWidgets(10));

      // Al inicio no debe existir la sección de resultados
      expect(find.text('Integrales definidas de los coeficientes:'), findsNothing);
    });

    testWidgets('Debe mostrar un SnackBar de error si los campos están vacíos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final botonCalcular = find.text('Plantear Coeficientes');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pump(); // Renderizar el SnackBar

      // Verificamos que el mensaje de error aparezca en pantalla
      expect(find.text('Es necesario ingresar la función f(x) y el valor de L.'), findsOneWidget);
      
      // La sección de resultados no debe generarse
      expect(find.text('Integrales definidas de los coeficientes:'), findsNothing);
    });

    testWidgets('Muestra el procedimiento al ingresar f(x) y L correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Simulamos que el usuario ingresa f(x) = x^2 y L = \pi
      await tester.enterText(textFields.at(0), 'x^2');
      await tester.enterText(textFields.at(1), '\\pi');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.text('Plantear Coeficientes');
      
      // Scroll y tap al botón
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Hacemos scroll al resultado
      await tester.ensureVisible(find.text('Integrales definidas de los coeficientes:'));

      // Verificamos que las tarjetas con las integrales de Fourier aparezcan
      expect(find.text('Integrales definidas de los coeficientes:'), findsOneWidget);
      expect(find.text('Coeficiente a\u2080'), findsOneWidget); // a_0
      expect(find.text('Coeficiente a\u2099'), findsOneWidget); // a_n
      expect(find.text('Coeficiente b\u2099'), findsOneWidget); // b_n
    });
  });
}