class VectorFuerza {
  final String id;
  String etiqueta;
  double magnitud;
  double anguloGrados;
  bool esSaliente; 

  VectorFuerza({
    required this.id,
    this.etiqueta = 'Fuerza',
    this.magnitud = 0.0,
    this.anguloGrados = 0.0,
    this.esSaliente = true,
  });

  // Método para convertir este objeto a JSON para tu API en Python
  Map<String, dynamic> toJson(String nodoId) {
    return {
      "id": id,
      "etiqueta": etiqueta,
      "nodo_origen_id": nodoId,
      "magnitud": magnitud,
      "angulo_grados": anguloGrados,
      "es_saliente": esSaliente
    };
  }
}