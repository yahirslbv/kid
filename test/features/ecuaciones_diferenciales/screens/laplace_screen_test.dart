import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graficacion_ai/features/ecuaciones_diferenciales/screens/laplace_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: LaplaceScreen(),
    );
  }

  group('Pruebas de LaplaceScreen', () {
    
    testWidgets('Debe iniciar en modo Directa con 1 campo, teclado y sin resultados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificamos que exista 1 solo TextField
      expect(find.byType(TextField), findsOneWidget);

      // Verificamos el estado inicial (Transformada Directa)
      expect(find.text('Aplicar Transformada'), findsOneWidget);
      expect(find.text('Planteamiento de la Transformada Directa:'), findsOneWidget);

      // Verificamos que el teclado matemático esté presente
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(InkWell), findsAtLeastNWidgets(10));

      // Al inicio no debe existir la sección de resultados
      expect(find.text('Operación a realizar:'), findsNothing);
    });

    testWidgets('Debe mostrar un SnackBar pidiendo términos de "t" si está vacía (Directa)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final botonCalcular = find.text('Aplicar Transformada');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pump(); // Renderizar el SnackBar

      // Validamos el mensaje específico para la directa (variable t)
      expect(find.text('Por favor, ingresa una función en términos de t.'), findsOneWidget);
    });

    testWidgets('Cambia la UI a modo Inversa al tocar el Toggle', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Buscamos y tocamos el botón del toggle que dice "Inversa..."
      await tester.tap(find.textContaining('Inversa'));
      await tester.pumpAndSettle(); // Esperamos que la UI se reconstruya

      // Verificamos que los textos del botón y títulos hayan cambiado
      expect(find.text('Evaluar Inversa'), findsOneWidget);
      expect(find.text('Planteamiento de la Transformada Inversa:'), findsOneWidget);

      // Probamos que la validación cambie a pedir términos de "s"
      final botonCalcular = find.text('Evaluar Inversa');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pump();

      expect(find.text('Por favor, ingresa una función en términos de s.'), findsOneWidget);
    });

    testWidgets('Muestra el procedimiento al ingresar la función correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Simulamos que el usuario ingresa f(t) = t^2
      await tester.enterText(find.byType(TextField), 't^2');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      final botonCalcular = find.text('Aplicar Transformada');
      await tester.ensureVisible(botonCalcular);
      await tester.tap(botonCalcular);
      await tester.pumpAndSettle();

      // Hacemos scroll al resultado
      await tester.ensureVisible(find.text('Operación a realizar:'));

      // Verificamos que la tarjeta de resultados aparezca
      expect(find.text('Operación a realizar:'), findsOneWidget);
      expect(find.text('Notación formal'), findsOneWidget);
    });
  });
}