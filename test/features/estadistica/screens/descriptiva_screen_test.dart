import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:graficacion_ai/features/estadistica/screens/descriptiva_screen.dart';
import 'package:graficacion_ai/features/chat/logic/chat_provider.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()), 
      ],
      child: const MaterialApp(
        home: DescriptivaScreen(),
      ),
    );
  }

  group('Pruebas de la Pantalla Estadística Descriptiva', () {
    
    testWidgets('Debe iniciar con el campo de texto vacío y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que exista el campo de texto principal
      expect(find.byType(TextField), findsOneWidget);
      
      // Verificamos que el botón de procesar exista
      expect(find.text('Procesar Datos'), findsOneWidget);

      // Verificamos que NO se esté mostrando el histograma ni las tarjetas aún
      expect(find.text('Histograma de Frecuencias'), findsNothing);
    });

    testWidgets('Calcula y muestra resultados descriptivos correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textField = find.byType(TextField);

      // Ingresamos un conjunto de datos controlados (Media: 24, Mediana: 20, Moda: 20)
      await tester.enterText(textField, '10, 20, 20, 30, 40');    
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Buscamos y presionamos el botón
      final botonProcesar = find.text('Procesar Datos');
      await tester.ensureVisible(botonProcesar);
      await tester.tap(botonProcesar);
      
      // Esperamos a que se dibujen los resultados
      await tester.pumpAndSettle();

      // 1. Verificamos que apareció la sección del histograma
      expect(find.text('Histograma de Frecuencias'), findsOneWidget);

      // 2. Verificamos que se renderizaron las tarjetas de estadísticas con los cálculos exactos
      expect(find.text('24.000'), findsWidgets); // La Media es 24
      expect(find.text('20.000'), findsWidgets); // La Mediana y Moda son 20
      expect(find.text('5'), findsOneWidget);    // n (Muestra) es 5
    });

    testWidgets('Debe ignorar caracteres no numéricos y procesar solo números válidos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textField = find.byType(TextField);

      // Ingresamos datos combinados con letras o símbolos extraños
      await tester.enterText(textField, '10, hola, 20, 30, error, 40');    
      
      final botonProcesar = find.text('Procesar Datos');
      await tester.tap(botonProcesar);
      await tester.pumpAndSettle();

      // Como tu código usa `double.tryParse`, debería ignorar "hola" y "error"
      // Procesará solo: 10, 20, 30, 40. La media de eso es 25.
      expect(find.text('Histograma de Frecuencias'), findsOneWidget);
      expect(find.text('25.000'), findsWidgets); // Media debe ser 25
      expect(find.text('4'), findsOneWidget);    // n debe ser 4, ignoró las letras
    });

    testWidgets('Muestra "Amodal" si ninguna frecuencia se repite', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textField = find.byType(TextField);

      // Ingresamos datos sin repetir
      await tester.enterText(textField, '1, 2, 3, 4, 5');    
      
      final botonProcesar = find.text('Procesar Datos');
      await tester.tap(botonProcesar);
      await tester.pumpAndSettle();

      // Verificamos que el texto "Amodal" aparece en la tarjeta correspondiente
      expect(find.text('Amodal'), findsOneWidget);
    });
  });
}