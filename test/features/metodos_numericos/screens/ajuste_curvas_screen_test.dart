import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/metodos_numericos/screens/ajuste_curvas_screen.dart';
import 'package:graficacion_ai/features/metodos_numericos/screens/regresion_lineal_screen.dart';
import 'package:graficacion_ai/features/metodos_numericos/screens/lagrange_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: AjusteCurvasScreen(),
    );
  }

  group('Pruebas de AjusteCurvasScreen', () {
    
    testWidgets('Debe mostrar la AppBar, los Tabs y los Botones Flotantes', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos el título del AppBar
      expect(find.text('Ajuste de Curvas'), findsOneWidget);

      // Verificamos que existan los títulos de los Tabs
      expect(find.text('Regresión Lineal'), findsOneWidget);
      expect(find.text('Interpolación (Lagrange)'), findsOneWidget);

      // Verificamos que los botones flotantes estén presentes buscando sus íconos
      expect(find.byIcon(Icons.document_scanner), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy_rounded), findsOneWidget);
      
      // Verificamos el texto del botón del escáner
      expect(find.text('Escanear Función'), findsOneWidget);
    });

    testWidgets('Debe cambiar entre Regresión Lineal y Lagrange al tocar los Tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 1. Por defecto, la pestaña inicial es Regresión Lineal.
      // Verificamos buscando el widget interno y un botón específico de esa pantalla.
      expect(find.byType(RegresionLinealScreen), findsOneWidget);
      expect(find.text('Calcular Regresión'), findsOneWidget);

      // 2. Tocamos el Tab de Lagrange
      await tester.tap(find.text('Interpolación (Lagrange)'));
      await tester.pumpAndSettle(); // Esperamos a que termine la animación de deslizamiento

      // 3. Verificamos que ahora se muestre la pantalla de Lagrange
      expect(find.byType(LagrangeScreen), findsOneWidget);
      expect(find.text('Interpolar Valor'), findsOneWidget);
      
      // Y que el botón de regresión lineal ya no esté en pantalla
      expect(find.text('Calcular Regresión'), findsNothing);
    });
  });
}