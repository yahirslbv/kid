import 'package:flutter_test/flutter_test.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/logic/mecanica_provider.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/models/estado_canvas.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/models/vector_fuerza.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/models/motor_resultados.dart';

void main() {
  group('Pruebas de MecanicaProvider', () {
    late MecanicaProvider provider;

    setUp(() {
      // setUp se ejecuta antes de cada test para darnos un provider fresco y limpio
      provider = MecanicaProvider();
    });

    test('El estado inicial debe estar completamente vacío', () {
      expect(provider.vectores, isEmpty);
      expect(provider.estadoCanvas, EstadoCanvas.vacio);
      expect(provider.resultados, isNull);
      expect(provider.isCanvasEmpty, isTrue);
    });

    test('limpiarLienzo debe reiniciar todas las variables de estado', () {
      // 1. Ensuciamos el estado simulando que el usuario usó la app
      provider.vectores.add(VectorFuerza(id: 'v1'));
      provider.estadoCanvas = EstadoCanvas.verificado;
      provider.resultados = MotorResultados(
        sumatoriaFx: 0, sumatoriaFy: 0, enEquilibrio: true, incognitasResueltas: {}
      );

      // 2. Ejecutamos el método del botón de la papelera
      provider.limpiarLienzo();

      // 3. Verificamos que todo volvió al estado de fábrica
      expect(provider.vectores, isEmpty);
      expect(provider.estadoCanvas, EstadoCanvas.vacio);
      expect(provider.resultados, isNull);
      expect(provider.isCanvasEmpty, isTrue);
    });

    test('obtenerContextoParaIA debe devolver advertencia de lienzo vacío si no hay cálculos', () {
      // Como acabamos de instanciar el provider, está vacío
      final contexto = provider.obtenerContextoParaIA();
      expect(contexto, '{"ctx":"Lienzo vacío o sin calcular"}');
    });
  });
}