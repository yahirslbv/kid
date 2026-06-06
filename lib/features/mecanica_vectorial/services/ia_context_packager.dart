import 'dart:convert';
import '../models/vector_fuerza.dart';
import '../models/motor_resultados.dart';

class IaContextPackager {
  /// Retorna un JSON de un solo renglón ultracompacto para ahorrar tokens
  static String empaquetar(List<VectorFuerza> vectores, MotorResultados resultados) {
    
    // Mapeamos los vectores a una estructura mínima
    final fuerzasCompresas = vectores.map((v) => {
      "id": v.id, // Opcional, pero útil si la IA debe referirse a un vector
      "mag": v.magnitud,
      "ang": v.anguloGrados,
      "sal": v.esSaliente ? 1 : 0 // 1 para Tensión, 0 para compresión
    }).toList();

    // Mapeamos los resultados de tu API matemática
    final resultadosCompresos = {
      "fx": resultados.sumatoriaFx,
      "fy": resultados.sumatoriaFy,
      "eq": resultados.enEquilibrio,
      "reac": resultados.incognitasResueltas // ej. {"Reaccion_Ay": 500.0}
    };

    final payloadIA = {
      "ctx": "Estática - Partícula",
      "f": fuerzasCompresas,
      "res": resultadosCompresos
    };

    // jsonEncode en Dart sin indentación genera un JSON minificado por defecto
    return jsonEncode(payloadIA);
  }
}