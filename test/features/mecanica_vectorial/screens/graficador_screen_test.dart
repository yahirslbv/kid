import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Importaciones usando el nombre real de tu proyecto
import 'package:graficacion_ai/features/mecanica_vectorial/logic/mecanica_provider.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/screens/graficador_screen.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/models/estado_canvas.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/models/vector_fuerza.dart';

void main() {
  // Función auxiliar para inyectar el Provider y MaterialApp necesarios en las pruebas
  Widget crearPantallaDePrueba(MecanicaProvider provider) {
    return MaterialApp(
      home: ChangeNotifierProvider<MecanicaProvider>.value(
        value: provider,
        child: const GraficadorScreen(),
      ),
    );
  }

  group('Pruebas Visuales de GraficadorScreen', () {
    testWidgets('1. Prueba de Estado Inicial (Marca de Agua de "Lienzo Vacío")', (WidgetTester tester) async {
      final provider = MecanicaProvider(); // Por defecto inicia vacío
      await tester.pumpWidget(crearPantallaDePrueba(provider));

      // Verificamos que el texto y el icono de la marca de agua existan
      expect(find.text('Lienzo Vacío'), findsOneWidget);
      expect(find.byIcon(Icons.architecture), findsOneWidget);
    });

    testWidgets('2. Prueba del Menú Flotante Lateral', (WidgetTester tester) async {
      final provider = MecanicaProvider();
      await tester.pumpWidget(crearPantallaDePrueba(provider));

      // Verificamos que existan los dos botones principales
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byIcon(Icons.arrow_outward), findsOneWidget);
    });

    testWidgets('3. Prueba del Modal para Ingresar Vectores', (WidgetTester tester) async {
      final provider = MecanicaProvider();
      await tester.pumpWidget(crearPantallaDePrueba(provider));

      // 1. Simulamos un toque en el botón de agregar vector
      await tester.tap(find.byIcon(Icons.arrow_outward));
      
      // 2. Esperamos a que termine la animación de abrir el cuadro de diálogo
      await tester.pumpAndSettle();

      // 3. Verificamos que aparezca el formulario
      expect(find.text('Agregar Vector'), findsOneWidget);
      expect(find.text('Magnitud (ej. 500 N)'), findsOneWidget);
      expect(find.text('Ángulo (0° a 360°)'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Trazar'), findsOneWidget);
    });

    testWidgets('4. Prueba del Indicador de Carga', (WidgetTester tester) async {
      final provider = MecanicaProvider();
      
      // Forzamos el estado a calculando para simular que la API está trabajando
      provider.estadoCanvas = EstadoCanvas.calculando; 
      
      await tester.pumpWidget(crearPantallaDePrueba(provider));

      // Verificamos que aparezca la "ruedita" de carga
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('5. Prueba del Botón Flotante del Tutor IA', (WidgetTester tester) async {
      final provider = MecanicaProvider();
      await tester.pumpWidget(crearPantallaDePrueba(provider));

      // Verificamos que el botón azul para llamar a la IA exista en pantalla
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('6. Prueba de Transmisión de Datos al Lienzo (Ocultar marca de agua)', (WidgetTester tester) async {
      final provider = MecanicaProvider();
      
      // Alimentamos el estado con un vector simulado
      provider.vectores.add(VectorFuerza(id: 'v1', magnitud: 100, anguloGrados: 45));
      
      await tester.pumpWidget(crearPantallaDePrueba(provider));

      // Si hay vectores, el CustomPaint está trabajando y la marca de agua NO debe existir
      expect(find.text('Lienzo Vacío'), findsNothing);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}