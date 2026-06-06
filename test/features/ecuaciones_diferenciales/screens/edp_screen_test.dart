import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/ecuaciones_diferenciales/screens/edp_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: EdpScreen(),
    );
  }

  group('Pruebas de EdpScreen', () {
    
    testWidgets('Debe iniciar con 2 campos de texto, teclado virtual y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 2 TextFields (EDP y Condiciones)
      expect(find.byType(TextField), findsNWidgets(2));

      // Verificamos que exista el botón principal
      expect(find.text('Plantear Separación'), findsOneWidget);

      // Verificamos que el teclado matemático esté presente
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(InkWell), findsAtLeastNWidgets(10));

      // Al inicio no debe existir la sección de resultados
      expect(find.text('Método de Separación de Variables:'), findsNothing);
    });

    testWidgets('Debe mostrar un SnackBar de error si la EDP está vacía', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final botonCalcular = find.text('Plantear Separación');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pump(); // Renderizar el SnackBar

      // Verificamos que el mensaje de error aparezca en pantalla
      expect(find.text('Es necesario ingresar la Ecuación en Derivadas Parciales.'), findsOneWidget);
      
      // La sección de resultados no debe generarse
      expect(find.text('Método de Separación de Variables:'), findsNothing);
    });

    testWidgets('Muestra el procedimiento al ingresar la EDP correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Simulamos que el usuario ingresa la EDP y las condiciones
      await tester.enterText(textFields.at(0), r'\frac{\partial u}{\partial t} = \alpha^2 \frac{\partial^2 u}{\partial x^2}');
      await tester.enterText(textFields.at(1), 'u(0,t)=0, u(L,t)=0');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.text('Plantear Separación');
      
      // Scroll y tap al botón
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Hacemos scroll al resultado
      await tester.ensureVisible(find.text('Método de Separación de Variables:'));

      // Verificamos que las tarjetas con los pasos de EDP aparezcan
      expect(find.text('Método de Separación de Variables:'), findsOneWidget);
      expect(find.text('1. Proponer solución producto'), findsOneWidget);
      expect(find.text('2. Derivar y sustituir en la EDP'), findsOneWidget);
    });
  });
}