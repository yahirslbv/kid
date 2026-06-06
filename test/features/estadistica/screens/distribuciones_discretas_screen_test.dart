import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:graficacion_ai/features/estadistica/screens/distribuciones_discretas_screen.dart';
import 'package:graficacion_ai/features/chat/logic/chat_provider.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()), 
      ],
      child: const MaterialApp(
        home: DistribucionesDiscretasScreen(),
      ),
    );
  }

  group('Pruebas de Distribuciones Discretas', () {
    
    testWidgets('Debe iniciar en Binomial con 3 campos y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos el valor por defecto del menú
      expect(find.text('Binomial'), findsOneWidget);

      // La Binomial necesita n, p, y x (3 campos de texto)
      expect(find.byType(TextField), findsNWidgets(3));
      
      // Verificamos que las cajas de resultados no existan todavía
      expect(find.textContaining('P(X ='), findsNothing);
    });

    testWidgets('Debe cambiar a 2 campos al seleccionar Distribución de Poisson', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Abrimos el dropdown
      await tester.tap(find.text('Binomial'));
      await tester.pumpAndSettle();

      // Elegimos Poisson
      await tester.tap(find.text('Poisson').last);
      await tester.pumpAndSettle();

      // Poisson solo usa lambda y x (2 campos de texto)
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.textContaining('Tasa media (λ)'), findsOneWidget);
    });

    testWidgets('Calcula probabilidad Binomial correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Prueba clásica: Lanzar moneda 10 veces, probabilidad 0.5, buscar exactamente 5 éxitos
      await tester.enterText(textFields.at(0), '10');  // n
      await tester.enterText(textFields.at(1), '0.5'); // p
      await tester.enterText(textFields.at(2), '5');   // x
      
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.text('Calcular y Graficar');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // La probabilidad exacta (10C5 * 0.5^10) debe ser ~0.24609 (24.61%)
      expect(find.textContaining('24.61%'), findsOneWidget);
      
      // Debe aparecer el título del gráfico
      expect(find.textContaining('Gráfico de Probabilidad'), findsOneWidget);
    });

    testWidgets('Debe mostrar error si los parámetros de la Binomial son inválidos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textFields = find.byType(TextField);

      // Ingresamos datos matemáticamente imposibles (probabilidad p mayor a 1)
      await tester.enterText(textFields.at(0), '10'); 
      await tester.enterText(textFields.at(1), '1.5'); // Error: p no puede ser > 1
      await tester.enterText(textFields.at(2), '5'); 
      
      final botonCalcular = find.text('Calcular y Graficar');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pump(); // Usamos pump para ver el SnackBar rápido

      // Verificamos que se muestre la alerta roja
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Error: Verifica que n>0, 0≤p≤1, y 0≤x≤n.'), findsOneWidget);
    });
  });
}