import 'package:flutter/material.dart' show ChangeNotifier;
import '../models/vector_fuerza.dart';
import '../models/motor_resultados.dart';
import '../models/estado_canvas.dart'; // enum: vacio, calculando, verificado...
import '../services/motor_api_service.dart';
import '../services/ia_context_packager.dart';

class MecanicaProvider extends ChangeNotifier {
  // 1. ESTADO DE LA UI
  List<VectorFuerza> vectores = [];
  EstadoCanvas estadoCanvas = EstadoCanvas.vacio;
  MotorResultados? resultados;

  bool get isCanvasEmpty => vectores.isEmpty;

  // 2. ESCUCHA DE LA UI (Métodos invocados por botones en la pantalla)
  void agregarVector(VectorFuerza vector) async {
    vectores.add(vector);
    
    // Actualizamos UI a modo carga
    estadoCanvas = EstadoCanvas.calculando;
    notifyListeners();

    // 3. DELEGACIÓN DE NEGOCIO AL SERVICIO API
    final calculo = await MotorApiService.calcularSistema(vectores);

    if (calculo != null) {
      resultados = calculo;
      estadoCanvas = EstadoCanvas.verificado;
    } else {
      estadoCanvas = EstadoCanvas.error;
    }
    
    // Avisar a la UI que el cálculo terminó
    notifyListeners();
  }

  void limpiarLienzo() {
    vectores.clear();
    resultados = null;
    estadoCanvas = EstadoCanvas.vacio;
    notifyListeners();
  }

  // 4. DELEGACIÓN PARA EL CHAT IA
  String obtenerContextoParaIA() {
    if (resultados == null || vectores.isEmpty) {
      return '{"ctx":"Lienzo vacío o sin calcular"}';
    }
    // Llama al servicio empaquetador
    return IaContextPackager.empaquetar(vectores, resultados!);
  }
}