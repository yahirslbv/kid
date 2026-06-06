import 'package:flutter_test/flutter_test.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/models/motor_resultados.dart';

void main() {
  group('Pruebas del modelo MotorResultados', () {
    
    test('Debe deserializar correctamente desde un JSON válido proveniente de la API', () {
      // 1. JSON simulado idéntico al que te enviaría FastAPI
      final jsonApi = {
        "sumatoria_fuerzas_x": {"valor": 150.5},
        "sumatoria_fuerzas_y": {"valor": -45.2},
        "sistema_en_equilibrio": true,
        "incognitas_resueltas": {
          "Reaccion_Ay": 250.0,
          "Reaccion_Bx": 0.0
        }
      };

      // 2. Ejecutamos el método fromJson
      final resultados = MotorResultados.fromJson(jsonApi);

      // 3. Verificamos que los datos se hayan mapeado correctamente
      expect(resultados.sumatoriaFx, 150.5);
      expect(resultados.sumatoriaFy, -45.2);
      expect(resultados.enEquilibrio, true);
      expect(resultados.incognitasResueltas.length, 2);
      expect(resultados.incognitasResueltas["Reaccion_Ay"], 250.0);
    });

    test('Debe manejar valores nulos en el JSON asignando los valores por defecto', () {
      // 1. JSON donde faltan campos opcionales (equilibrio e incognitas)
      final jsonApiIncompleto = {
        "sumatoria_fuerzas_x": {"valor": 0.0},
        "sumatoria_fuerzas_y": {"valor": 0.0},
      };

      // 2. Ejecutamos el método fromJson
      final resultados = MotorResultados.fromJson(jsonApiIncompleto);

      // 3. Verificamos los valores por defecto (enEquilibrio: false, y mapa vacío)
      expect(resultados.sumatoriaFx, 0.0);
      expect(resultados.sumatoriaFy, 0.0);
      expect(resultados.enEquilibrio, false); 
      expect(resultados.incognitasResueltas, isEmpty);
    });
  });
}