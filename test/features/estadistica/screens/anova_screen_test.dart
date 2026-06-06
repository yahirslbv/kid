import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:graficacion_ai/features/estadistica/screens/anova_screen.dart';
import 'package:graficacion_ai/features/chat/logic/chat_provider.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()), 
      ],
      child: const MaterialApp(
        home: AnovaScreen(),
      ),
    );
  }

  group('Pruebas de la Pantalla ANOVA', () {
    
    testWidgets('Debe iniciar con 3 grupos por defecto', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(3));
    });

    testWidgets('Debe agregar un nuevo grupo al presionar "Agregar Grupo"', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      final botonAgregar = find.text('Agregar Grupo');
      await tester.tap(botonAgregar);
      await tester.pumpAndSettle(); 
      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('Calcula ANOVA correctamente y muestra resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      await tester.enterText(textFields.at(0), '4, 5, 6');    
      await tester.enterText(textFields.at(1), '14, 15, 16'); 
      await tester.enterText(textFields.at(2), '24, 25, 26'); 
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // --- CORRECCIÓN AQUÍ --- Buscamos directamente el texto del botón
      final botonCalcular = find.text('Generar Tabla ANOVA');
      
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      expect(find.textContaining('Conclusión Técnica'), findsOneWidget);
      expect(find.textContaining('SE RECHAZA H₀'), findsOneWidget);
      expect(find.text('Tabla ANOVA'), findsOneWidget);
    });

    testWidgets('Debe mostrar error si los datos son insuficientes', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '4');
      
      // --- CORRECCIÓN AQUÍ TAMBIÉN ---
      final botonCalcular = find.text('Generar Tabla ANOVA');
      
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pump(); 

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Error: Debes ingresar datos válidos'), findsOneWidget);
    });
  });
}