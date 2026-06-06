import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/ecuaciones_diferenciales/screens/separables_screen.dart';

void main() {
  // Función auxiliar para construir nuestro widget dentro de un MaterialApp
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: SeparablesScreen(),
    );
  }

  group('Pruebas de SeparablesScreen', () {
    
    testWidgets('Debe iniciar con 2 campos de texto, teclado virtual y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan 2 TextFields (f(x) y g(y))
      expect(find.byType(TextField), findsNWidgets(2));

      // Verificamos que exista el botón principal por su texto directamente
      expect(find.text('Plantear Solución'), findsOneWidget);

      // Verificamos que el teclado matemático esté presente buscando su contenedor Wrap
      expect(find.byType(Wrap), findsOneWidget);
      
      // Y confirmamos que haya AL MENOS 10 botones (InkWell) en toda la pantalla
      expect(find.byType(InkWell), findsAtLeastNWidgets(10));

      // Al inicio no debe existir la sección de procedimiento
      expect(find.text('Procedimiento analítico:'), findsNothing);
    });

    testWidgets('Debe mostrar un SnackBar de error si los campos están vacíos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final botonCalcular = find.text('Plantear Solución');
      
      // Hacemos scroll hasta el botón por si está oculto por el tamaño de la pantalla virtual
      await tester.ensureVisible(botonCalcular);
      
      // Presionamos el botón sin ingresar ningún texto en las cajas
      await tester.tap(botonCalcular);
      
      // Hacemos un pump() corto para que Flutter renderice el SnackBar de abajo hacia arriba
      await tester.pump(); 

      // Verificamos que el mensaje de error aparezca en pantalla
      expect(find.text('Por favor, ingresa ambas funciones.'), findsOneWidget);
      
      // La sección de resultados sigue sin aparecer
      expect(find.text('Procedimiento analítico:'), findsNothing);
    });

    testWidgets('Muestra el procedimiento al ingresar las funciones correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Simulamos que el usuario ingresa f(x) = 2x  y  g(y) = y^2
      await tester.enterText(textFields.at(0), '2x');
      await tester.enterText(textFields.at(1), 'y^2');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.text('Plantear Solución');
      
      // Hacemos scroll hasta el botón
      await tester.ensureVisible(botonCalcular);
      
      // Presionamos el botón
      await tester.tap(botonCalcular);
      
      // Esperamos a que terminen todas las animaciones de la UI
      await tester.pumpAndSettle();

      // Hacemos scroll al resultado para asegurar que se puede leer
      await tester.ensureVisible(find.text('Procedimiento analítico:'));

      // Verificamos que las tarjetas con el procedimiento matemático aparezcan
      expect(find.text('Procedimiento analítico:'), findsOneWidget);
      expect(find.text('1. Separar variables'), findsOneWidget);
      expect(find.text('2. Integrar ambos lados'), findsOneWidget);
    });
  });
}