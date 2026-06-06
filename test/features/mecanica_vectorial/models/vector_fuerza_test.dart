import 'package:flutter_test/flutter_test.dart';
import 'package:graficacion_ai/features/mecanica_vectorial/models/vector_fuerza.dart';

void main() {
  group('Pruebas del modelo VectorFuerza', () {
    
    test('Debe inicializarse con los valores por defecto esperados si solo se pasa el id', () {
      // 1. Creamos el vector solo con el parámetro obligatorio (id)
      final vector = VectorFuerza(id: 'vec_001');
      
      // 2. Verificamos que el resto de variables adopten los valores por defecto correctos
      expect(vector.id, 'vec_001');
      expect(vector.etiqueta, 'Fuerza');
      expect(vector.magnitud, 0.0);
      expect(vector.anguloGrados, 0.0);
      expect(vector.esSaliente, true);
    });

    test('Debe inicializarse correctamente con valores personalizados', () {
      // 1. Creamos un vector dándole todos los valores posibles
      final vector = VectorFuerza(
        id: 'vec_002',
        etiqueta: 'Tensión Cuerda',
        magnitud: 450.5,
        anguloGrados: 120.0,
        esSaliente: false,
      );
      
      // 2. Verificamos que se hayan guardado exactamente esos valores
      expect(vector.id, 'vec_002');
      expect(vector.etiqueta, 'Tensión Cuerda');
      expect(vector.magnitud, 450.5);
      expect(vector.anguloGrados, 120.0);
      expect(vector.esSaliente, false);
    });

    test('toJson debe serializar correctamente los datos para la API en Python', () {
      // 1. Preparamos un vector estándar
      final vector = VectorFuerza(
        id: 'vec_003',
        magnitud: 100.0,
        anguloGrados: 45.0,
        esSaliente: true,
      );
      
      // 2. Ejecutamos la conversión, simulando que pertenece a un "Nodo_A"
      final json = vector.toJson('Nodo_A');
      
      // 3. Verificamos que el mapa (Map) devuelto tenga exactamente 
      // las llaves (snake_case) y valores que espera el servidor de FastAPI
      expect(json, {
        "id": "vec_003",
        "etiqueta": "Fuerza",
        "nodo_origen_id": "Nodo_A", // Este es el parámetro inyectado
        "magnitud": 100.0,
        "angulo_grados": 45.0,
        "es_saliente": true
      });
    });

  });
}