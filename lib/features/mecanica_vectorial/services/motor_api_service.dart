import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vector_fuerza.dart';
import '../models/motor_resultados.dart'; // Una clase simple con fx, fy, equilibrio y reacciones

class MotorApiService {
  // Cambia esto a tu IP de producción después
  static const String _apiUrl = "https://api-motor-matematico.onrender.com/calcular";

  static Future<MotorResultados?> calcularSistema(List<VectorFuerza> vectores) async {
    try {
      // 1. Empaquetar el payload exacto para FastAPI
      final payload = {
        "bloque_contexto": {"contexto_ingresado_por_usuario": "Móvil"},
        "unidades": {"unidad_medida_distancia": "m", "unidad_medida_fuerza": "N"},
        "bloque_fisico": {
          "nodos": [{"id": "Nodo_A", "x": 0.0, "y": 0.0}],
          "vectores_fuerza": vectores.map((v) => v.toJson("Nodo_A")).toList()
        },
        "parametros_asumidos": {}
      };

      // 2. Enviar a la API
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      // 3. Devolver los resultados crudos parseados
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["bloque_resultados"];
        return MotorResultados.fromJson(data);
      }
      return null;
    } catch (e) {
      print("Error en MotorApiService: $e");
      return null;
    }
  }
}