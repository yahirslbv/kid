import 'package:flutter_test/flutter_test.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/models/vector_fuerza.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/models/motor_resultados.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/services/motor_api_service.dart';

void main() {
  group('Pruebas de MotorApiService', () {
    
    test('calcularSistema debe retornar MotorResultados si se envían vectores válidos', () async {
      // 1. Preparamos un par de vectores de prueba
      final vectoresPrueba = [
        VectorFuerza(
          id: 'v1',
          etiqueta: 'F1',
          magnitud: 100.0,
          anguloGrados: 0.0, // Apunta a la derecha (Fx = 100, Fy = 0)
          esSaliente: true,
        ),
        VectorFuerza(
          id: 'v2',
          etiqueta: 'F2',
          magnitud: 100.0,
          anguloGrados: 180.0, // Apunta a la izquierda (Fx = -100, Fy = 0)
          esSaliente: true,
        ),
      ];

      // 2. Ejecutamos el servicio (Esto hace un ping real a tu API en Render)
      final resultado = await MotorApiService.calcularSistema(vectoresPrueba);

      // 3. Verificamos la respuesta
      // Si el servidor está encendido, no debería ser nulo
      expect(resultado, isNotNull, reason: 'El servidor podría estar apagado o el payload es incorrecto');
      
      // Aseguramos que es del tipo correcto
      expect(resultado, isA<MotorResultados>());

      // Opcional: Como pusimos 100N a la derecha y 100N a la izquierda, 
      // si tu motor físico es exacto, la sumatoria en X debería ser ~0.
      if (resultado != null) {
         expect(resultado.sumatoriaFx, closeTo(0.0, 0.1));
         expect(resultado.sumatoriaFy, closeTo(0.0, 0.1));
      }
    });

test('calcularSistema debe retornar resultados en 0 si se envía una lista vacía', () async {
      // 1. Preparamos una lista vacía
      final vectoresPrueba = <VectorFuerza>[];

      // 2. Ejecutamos el servicio
      final resultado = await MotorApiService.calcularSistema(vectoresPrueba);

      // 3. Tu API maneja bien las listas vacías, así que esperamos que no sea nulo
      expect(resultado, isNotNull);
      
      // 4. Al no haber fuerzas, la sumatoria en X y Y debe ser estrictamente 0
      if (resultado != null) {
        expect(resultado.sumatoriaFx, 0.0);
        expect(resultado.sumatoriaFy, 0.0);
        // Dependiendo de tu lógica en Python, un sistema sin fuerzas podría estar en equilibrio
        expect(resultado.enEquilibrio, true); 
      }
    });
  });
}