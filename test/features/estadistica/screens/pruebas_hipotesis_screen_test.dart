import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:graficacion_ai/features/estadistica/screens/pruebas_hipotesis_screen.dart';
import 'package:graficacion_ai/features/chat/logic/chat_provider.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()), 
      ],
      child: const MaterialApp(
        home: PruebasHipotesisScreen(),
      ),
    );
  }

  group('Pruebas de la Pantalla Pruebas de Hipótesis', () {
    
    testWidgets('Debe iniciar con Prueba Z para Medias y sus 4 campos por defecto', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que el título principal de la prueba por defecto esté visible
      expect(find.text('Media Poblacional (Z)'), findsOneWidget);

      // Verificamos que existan exactamente 4 campos de texto (n, mu0, xBar, sigma)
      expect(find.byType(TextField), findsNWidgets(4));
      
      // Validamos que el botón de calcular esté presente
      expect(find.text('Ejecutar Prueba'), findsOneWidget);
    });

    testWidgets('Debe cambiar los campos de texto al seleccionar Prueba de Proporciones', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 1. Abrimos el menú desplegable principal tocando su valor actual
      await tester.tap(find.text('Media Poblacional (Z)'));
      await tester.pumpAndSettle(); // Esperamos la animación del menú

      // 2. Seleccionamos 'Proporción Poblacional (Z)' de la lista
      // Usamos .last porque a veces Flutter renderiza el texto en el menú original y en la lista desplegada
      await tester.tap(find.text('Proporción Poblacional (Z)').last);
      await tester.pumpAndSettle(); 

      // 3. Verificamos que ahora los campos sean diferentes (n, p0, éxitos)
      // Solo deben existir 3 campos de texto para proporciones
      expect(find.byType(TextField), findsNWidgets(3));
      
      // Verificamos que exista el texto específico del nuevo campo
      expect(find.textContaining('Proporción Nula (p0)'), findsOneWidget);
    });

    testWidgets('Calcula Prueba Z Bilateral correctamente y muestra resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // En la prueba Z por defecto, los campos son: [0] = n, [1] = mu0, [2] = media, [3] = desviacion
      final textFields = find.byType(TextField);

      // Ingresamos datos que rechazan la hipótesis nula (una diferencia muy obvia)
      await tester.enterText(textFields.at(0), '30'); // n = 30
      await tester.enterText(textFields.at(1), '50'); // mu0 = 50
      await tester.enterText(textFields.at(2), '60'); // xBar = 60
      await tester.enterText(textFields.at(3), '5');  // sigma = 5
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Ejecutamos la prueba
      final botonEjecutar = find.text('Ejecutar Prueba');
      await tester.ensureVisible(botonEjecutar);
      await tester.tap(botonEjecutar);
      await tester.pumpAndSettle();

      // Verificaciones
      expect(find.textContaining('Conclusión Técnica'), findsOneWidget);
      // Con una Z tan alta, p-value será ~0.000, por lo que se rechaza H0
      expect(find.textContaining('SE RECHAZA H₀'), findsOneWidget);
      expect(find.text('Estadístico Z'), findsOneWidget);
    });

    testWidgets('Debe mostrar un error si la muestra (n) es menor o igual a 1', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos un valor inválido para n
      await tester.enterText(textFields.at(0), '1'); 
      
      // Ejecutamos
      final botonEjecutar = find.text('Ejecutar Prueba');
      await tester.ensureVisible(botonEjecutar);
      await tester.tap(botonEjecutar);
      
      // Usamos pump() simple para capturar el SnackBar sin quedarnos esperando su timer
      await tester.pump();

      // Verificamos que arroje el error correcto
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Error: El tamaño de la muestra n debe ser > 1.'), findsOneWidget);
    });
  });
}