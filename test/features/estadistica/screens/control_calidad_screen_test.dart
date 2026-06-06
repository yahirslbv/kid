import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:graficacion_ai/features/estadistica/screens/control_calidad_screen.dart';
import 'package:graficacion_ai/features/chat/logic/chat_provider.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()), 
      ],
      child: const MaterialApp(
        home: ControlCalidadScreen(),
      ),
    );
  }

  group('Pruebas de la Pantalla de Control de Calidad (X-Bar, R)', () {
    
    testWidgets('Debe iniciar con 3 muestras por defecto y sin gráficos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que existan exactamente 3 campos de texto para muestras
      expect(find.byType(TextField), findsNWidgets(3));
      
      // Verificamos que no haya resultados visibles aún
      expect(find.text('Estado del Proceso'), findsNothing);
    });

    testWidgets('Debe agregar una muestra extra al presionar el botón', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final botonAgregar = find.text('Agregar Muestra');
      await tester.tap(botonAgregar);
      await tester.pumpAndSettle(); 

      // Ahora deberían ser 4 muestras
      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('Proceso ESTABLE: Calcula y muestra BAJO CONTROL ESTADÍSTICO', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos datos muy parecidos (poca variación)
      await tester.enterText(textFields.at(0), '10, 10.2, 9.8'); 
      await tester.enterText(textFields.at(1), '10.1, 9.9, 10'); 
      await tester.enterText(textFields.at(2), '9.8, 10.1, 10.2'); 
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonGenerar = find.text('Generar Gráficos de Control');
      await tester.ensureVisible(botonGenerar);
      await tester.tap(botonGenerar);
      await tester.pumpAndSettle();

      // Verificamos que apruebe el control de calidad
      expect(find.textContaining('BAJO CONTROL ESTADÍSTICO'), findsOneWidget);
      expect(find.text('LCS'), findsOneWidget);
      expect(find.text('LCI'), findsOneWidget);
    });

    testWidgets('Proceso INESTABLE: Calcula y detecta FUERA DE CONTROL', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos datos donde una muestra se dispara por completo
      await tester.enterText(textFields.at(0), '10, 10, 10'); 
      await tester.enterText(textFields.at(1), '10, 10, 10'); 
      await tester.enterText(textFields.at(2), '30, 35, 40'); // Esta muestra es un error de producción masivo
      
      final botonGenerar = find.text('Generar Gráficos de Control');
      await tester.ensureVisible(botonGenerar);
      await tester.tap(botonGenerar);
      await tester.pumpAndSettle();

      // Verificamos que detecte la anomalía
      expect(find.textContaining('FUERA DE CONTROL'), findsOneWidget);
      expect(find.textContaining('Alerta: Existen puntos que sobrepasan los límites'), findsOneWidget);
    });

    testWidgets('Debe mostrar error si las muestras tienen diferente tamaño (n)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos 3 datos en la Muestra 1, pero solo 2 en la Muestra 2
      await tester.enterText(textFields.at(0), '10, 11, 12'); 
      await tester.enterText(textFields.at(1), '10, 11'); 
      
      final botonGenerar = find.text('Generar Gráficos de Control');
      await tester.ensureVisible(botonGenerar);
      await tester.tap(botonGenerar);
      await tester.pump(); 

      // Verificamos el SnackBar de error
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Error: Todos los subgrupos deben tener el mismo número de observaciones (n)'), findsOneWidget);
    });
  });
}