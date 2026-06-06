import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:graficacion_ai/features/estadistica/screens/distribuciones_continuas_screen.dart';
import 'package:graficacion_ai/features/chat/logic/chat_provider.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()), 
      ],
      child: const MaterialApp(
        home: DistribucionesContinuasScreen(),
      ),
    );
  }

  group('Pruebas de Distribuciones Continuas', () {
    
    testWidgets('Debe iniciar en Distribución Normal con 3 campos y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que esté en Normal por defecto
      expect(find.text('Normal'), findsOneWidget);

      // Verificamos que existan 3 campos (mu, sigma, x)
      expect(find.byType(TextField), findsNWidgets(3));
      
      // Verificamos que no se muestre la probabilidad aún
      expect(find.text('Probabilidad Calculada'), findsNothing);
      expect(find.text('Área bajo la curva (Integral)'), findsNothing);
    });

    testWidgets('Debe cambiar a 2 campos al seleccionar Distribución Exponencial', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Abrimos el menú desplegable tocando 'Normal'
      await tester.tap(find.text('Normal'));
      await tester.pumpAndSettle();

      // Seleccionamos 'Exponencial' (usamos .last por cómo Flutter renderiza los menús en el árbol de widgets)
      await tester.tap(find.text('Exponencial').last);
      await tester.pumpAndSettle();

      // Verificamos que ahora solo haya 2 campos de texto (lambda, x)
      expect(find.byType(TextField), findsNWidgets(2));
      
      // Verificamos que el texto del campo haya cambiado
      expect(find.textContaining('Tasa de ocurrencia (λ)'), findsOneWidget);
    });

    testWidgets('Calcula Distribución Normal Estándar correctamente (50% en x=0)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Normal estándar: media = 0, desviación = 1. Si buscamos menor o igual a 0, debe dar 50%
      await tester.enterText(textFields.at(0), '0'); // Media (μ)
      await tester.enterText(textFields.at(1), '1'); // Desviación (σ)
      await tester.enterText(textFields.at(2), '0'); // x
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.text('Calcular Área Sombreada');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Verificamos que aparezca la sección de resultados
      expect(find.text('Probabilidad Calculada'), findsOneWidget);
      
      // El resultado debe ser aproximadamente 50.0000%
      expect(find.textContaining('50.000'), findsOneWidget);
      
      // Verificamos que el gráfico se haya dibujado
      expect(find.text('Área bajo la curva (Integral)'), findsOneWidget);
    });

    testWidgets('Calcula Distribución Exponencial correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Cambiamos a Exponencial
      await tester.tap(find.text('Normal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exponencial').last);
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);

      // Exponencial: lambda = 1, x = 1. Probabilidad debe ser 1 - e^(-1) ≈ 0.63212 (63.21%)
      await tester.enterText(textFields.at(0), '1'); // lambda
      await tester.enterText(textFields.at(1), '1'); // x
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.text('Calcular Área Sombreada');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // El resultado debe contener '63.21'
      expect(find.textContaining('63.21'), findsOneWidget);
    });
  });
}