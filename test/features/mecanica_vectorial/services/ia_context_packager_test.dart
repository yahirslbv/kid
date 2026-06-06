import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:graficacion_ai/features/mecanica_vectorial/models/vector_fuerza.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/models/motor_resultados.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/services/ia_context_packager.dart';

void main() {
  group('Pruebas de IaContextPackager', () {
    test('Debe empaquetar vectores y resultados en un JSON minificado y correcto', () {
      // 1. Preparar datos simulados
      final vectores = [
        VectorFuerza(id: 'v1', magnitud: 500, anguloGrados: 45, esSaliente: true),
      ];
      final resultados = MotorResultados(
        sumatoriaFx: 353.5,
        sumatoriaFy: 353.5,
        enEquilibrio: false,
        incognitasResueltas: {"Reaccion_Ax": -353.5},
      );

      // 2. Ejecutar el método empaquetar
      final stringEmpaquetado = IaContextPackager.empaquetar(vectores, resultados);
      
      // 3. Validar que devolvió un String y no está vacío
      expect(stringEmpaquetado, isNotEmpty);

      // 4. Decodificar el JSON de vuelta para verificar que la estructura interna se armó bien
      final jsonDecodificado = jsonDecode(stringEmpaquetado);

      // Validar contexto
      expect(jsonDecodificado['ctx'], 'Estática - Partícula');
      
      // Validar fuerzas (comprobando que mapeó booleanos a 1/0)
      expect(jsonDecodificado['f'].length, 1);
      expect(jsonDecodificado['f'][0]['id'], 'v1');
      expect(jsonDecodificado['f'][0]['mag'], 500.0);
      expect(jsonDecodificado['f'][0]['ang'], 45.0);
      expect(jsonDecodificado['f'][0]['sal'], 1); // True se convirtió en 1
      
      // Validar resultados matemáticos
      expect(jsonDecodificado['res']['fx'], 353.5);
      expect(jsonDecodificado['res']['eq'], false);
      expect(jsonDecodificado['res']['reac']['Reaccion_Ax'], -353.5);
    });
  });
}