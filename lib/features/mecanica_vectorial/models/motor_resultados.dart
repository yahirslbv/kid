class MotorResultados {
  final double sumatoriaFx;
  final double sumatoriaFy;
  final bool enEquilibrio;
  final Map<String, dynamic> incognitasResueltas;

  MotorResultados({
    required this.sumatoriaFx,
    required this.sumatoriaFy,
    required this.enEquilibrio,
    required this.incognitasResueltas,
  });

  // Factory para parsear el JSON anidado que manda FastAPI
  factory MotorResultados.fromJson(Map<String, dynamic> json) {
    return MotorResultados(
      sumatoriaFx: (json['sumatoria_fuerzas_x']['valor'] as num).toDouble(),
      sumatoriaFy: (json['sumatoria_fuerzas_y']['valor'] as num).toDouble(),
      enEquilibrio: json['sistema_en_equilibrio'] ?? false,
      incognitasResueltas: json['incognitas_resueltas'] ?? {},
    );
  }
}