enum EstadoCanvas {
  vacio,       // 0 vectores
  calculando,  // Petición HTTP en vuelo hacia la API
  verificado,  // Resultados de la API cargados exitosamente
  error        // Falló la conexión con la API
}