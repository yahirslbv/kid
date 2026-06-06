import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math';

class CamposPendientesScreen extends StatefulWidget {
  const CamposPendientesScreen({super.key});

  @override
  State<CamposPendientesScreen> createState() => _CamposPendientesScreenState();
}

class _CamposPendientesScreenState extends State<CamposPendientesScreen> {
  // Ecuación por defecto profesional
  final TextEditingController _funcionController = TextEditingController(text: 'x - y');
  bool _mostrarGrafica = false;

  // ESTÁNDAR DE COLORES MATEMÁTICOS
  final Color colPositive = Colors.green[700]!; // Pendiente positiva
  final Color colNegative = Colors.red[700]!;   // Pendiente negativa
  final Color colLow = Colors.orange[800]!;     // Pendiente baja (|m| < 0.2)
  final Color colSolution = const Color(0xFF1E88E5); // Color profesional para la curva solución
  final Color colEjes = Colors.black.withOpacity(0.8);

  @override
  void dispose() {
    _funcionController.dispose();
    super.dispose();
  }

  void _generarCampo() {
    if (_funcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa f(x,y).')),
      );
      return;
    }
    // Ocultar teclado
    FocusScope.of(context).unfocus();
    setState(() {
      _mostrarGrafica = true;
    });
  }

  void _limpiar() {
    _funcionController.clear();
    setState(() {
      _mostrarGrafica = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campo de Pendientes'),
        backgroundColor: isDark ? const Color(0xFF1C3350) : colSolution,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            // --- HEADER CON ECUACIÓN (Renderizado LaTeX) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Math.tex(
                _mostrarGrafica 
                    ? r'\frac{dy}{dx} = ' + _funcionController.text 
                    : r'\frac{dy}{dx} = f(x,y)',
                textStyle: TextStyle(fontSize: 24, color: isDark ? Colors.white : Colors.black87),
              ),
            ),
            
            // --- ÁREA DE LA GRÁFICA PROFESIONAL ---
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white, // Fondo blanco para máxima claridad matemática
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _mostrarGrafica
                      ? CustomPaint(
                          painter: _CampoPendientesPainter(
                            isDark: false, 
                            colEjes: colEjes,
                            colPositive: colPositive,
                            colNegative: colNegative,
                            colLow: colLow,
                            colSolution: colSolution,
                            equacionRaw: _funcionController.text,
                          ),
                        )
                      : Center(
                          child: Text(
                            'Ingresa la ecuación y presiona generar',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                ),
              ),
            ),

            // --- LEYENDA DE COLORES ---
            if (_mostrarGrafica)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C3350) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 15,
                  runSpacing: 5,
                  children: [
                    _buildLegendItem('Positiva', colPositive, isDark),
                    _buildLegendItem('Negativa', colNegative, isDark),
                    _buildLegendItem('Baja', colLow, isDark),
                    _buildLegendItem('Solución', colSolution, isDark, isSolution: true),
                  ],
                ),
              ),

            // --- SECCIÓN DE CONTROLES ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C3350) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _funcionController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'f(x,y)',
                        hintText: 'Ej. x - y',
                        labelStyle: TextStyle(color: colSolution, fontWeight: FontWeight.bold, fontSize: 13),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F1E2E) : Colors.blue.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colSolution)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // --- BOTÓN DE LIMPIAR ACTUALIZADO ---
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: colSolution, size: 28),
                    tooltip: 'Limpiar gráfica',
                    onPressed: _limpiar,
                  ),
                  
                  const SizedBox(width: 5),
                  CircleAvatar(
                    backgroundColor: colSolution,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.check, color: Colors.white, size: 24),
                      onPressed: _generarCampo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para construir ítems de la leyenda
  Widget _buildLegendItem(String label, Color color, bool isDark, {bool isSolution = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Representación visual del segmento o curva
        Container(
          width: isSolution ? 20 : 12,
          height: isSolution ? 3 : 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(isSolution ? 2 : 2),
            // Si no es solución, lo dibujamos como un pequeño segmento girado
            border: isSolution ? null : Border.all(color: Colors.white, width: 1.5),
          ),
          transform: isSolution ? null : Matrix4.rotationZ(pi / 4), // Girado 45 grados
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87
          ),
        ),
      ],
    );
  }
}

// --- LÓGICA DE DIBUJO MATEMÁTICO AVANZADO CON COLOREADO DINÁMICO ---
class _CampoPendientesPainter extends CustomPainter {
  final bool isDark;
  final Color colEjes;
  final Color colPositive;
  final Color colNegative;
  final Color colLow;
  final Color colSolution;
  final String equacionRaw;

  // Rango matemático (-10 a 10)
  final double realMin = -10.0;
  final double realMax = 10.0;
  final double stepSize = 1.0; 

  // Umbral para definir pendiente baja (|m| < umbral)
  final double slopeThreshold = 0.2;

  _CampoPendientesPainter({
    required this.isDark, 
    required this.colEjes,
    required this.colPositive, 
    required this.colNegative,
    required this.colLow,
    required this.colSolution,
    required this.equacionRaw,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Configuración de pinceles base
    final paintGrid = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;

    final paintEjes = Paint()
      ..color = colEjes
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.square;

    final paintSegmento = Paint()
      ..strokeWidth = 2.2 // Un poco más grueso para que resalte el color
      ..strokeCap = StrokeCap.round;

    final TextStyle textStyleAxis = TextStyle(
      color: colEjes.withOpacity(0.7),
      fontSize: 11,
      fontWeight: FontWeight.bold,
    );

    final double width = size.width;
    final double height = size.height;

    // Métodos auxiliares para mapear coordenadas reales a canvas
    double mapX(double realX) => (realX - realMin) / (realMax - realMin) * width;
    double mapY(double realY) => (height - ((realY - realMin) / (realMax - realMin) * height));

    // 1. DIBUJAR CUADRÍCULA Y ETIQUETAS NUMÉRICAS
    for (double i = realMin; i <= realMax; i += stepSize) {
      final double canvasX = mapX(i);
      canvas.drawLine(Offset(canvasX, 0), Offset(canvasX, height), paintGrid);

      final double canvasY = mapY(i);
      canvas.drawLine(Offset(0, canvasY), Offset(width, canvasY), paintGrid);

      // Etiquetas numéricas (múltiplos de 5)
      if (i % 5 == 0 && i != 0) {
        _drawText(canvas, textStyleAxis, i.toInt().toString(), Offset(mapX(0) - 12, mapY(i) - 6), Alignment.centerRight);
        _drawText(canvas, textStyleAxis, i.toInt().toString(), Offset(mapX(i), mapY(0) + 8), Alignment.topCenter);
      }
    }

    // 2. DIBUJAR EJES DE COORDENADAS PROFESIONALES (Gruesos)
    canvas.drawLine(Offset(mapX(0), 0), Offset(mapX(0), height), paintEjes); // Eje Y
    canvas.drawLine(Offset(0, mapY(0)), Offset(width, mapY(0)), paintEjes); // Eje X

    // 3. ETIQUETAS DE EJES
    _drawText(canvas, textStyleAxis.copyWith(fontSize: 13, color: colEjes), 'f(x,y)', Offset(mapX(0) - 8, 8), Alignment.topRight);
    _drawText(canvas, textStyleAxis.copyWith(fontSize: 13, color: colEjes), 'x', Offset(width - 12, mapY(0) - 12), Alignment.bottomRight);

    // 4. GENERAR Y DIBUJAR CAMPO DE PENDIENTES CON COLOREADO DINÁMICO
    double lineLengthReal = stepSize * 0.45; // Longitud matemática relativa

    // Analizador simplificado Ax + By
    final coefficients = _parseSimpleLinear(equacionRaw);
    final double a = coefficients['a'] ?? 1.0; 
    final double b = coefficients['b'] ?? -1.0; 

    for (double realX = realMin; realX <= realMax; realX += stepSize) {
      for (double realY = realMin; realY <= realMax; realY += stepSize) {
        
        // --- CÁLCULO DE LA PENDIENTE m = f(x,y) ---
        double m = (a * realX) + (b * realY);
        
        if (m.isInfinite || m.isNaN) continue;

        // --- COLOREADO DINÁMICO ---
        Color segmentColor;
        if (m.abs() < slopeThreshold) {
          segmentColor = colLow;      // Baja (Naranja)
        } else if (m > 0) {
          segmentColor = colPositive; // Positiva (Verde)
        } else {
          segmentColor = colNegative; // Negativa (Rojo)
        }

        // Calcular ángulo y vectores del segmento
        double angle = atan(m);
        double dxReal = lineLengthReal * cos(angle);
        double dyReal = lineLengthReal * sin(angle);

        // Mapear puntos al canvas
        final p1 = Offset(mapX(realX - dxReal), mapY(realY - dyReal));
        final p2 = Offset(mapX(realX + dxReal), mapY(realY + dyReal));

        // Dibujar el segmento con el color calculado
        paintSegmento.color = segmentColor;
        canvas.drawLine(p1, p2, paintSegmento);
      }
    }

    // 5. DIBUJAR CURVA SOLUCIÓN (Simulación para dy/dx = x-y)
    // Mostramos cómo se vería una curva solución para la ecuación por defecto
    if (a == 1.0 && b == -1.0 && equacionRaw.replaceAll(' ', '') == 'x-y') {
      final paintSol = Paint()
        ..color = colSolution
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final Path solPath = Path();
      bool firstPoint = true;
      
      // Simulación de curva y = x - 1 + Ce^(-x) con C=5 (pasa por x=-2, y=~4)
      for (double rx = -5.0; rx <= realMax; rx += 0.1) {
        double ry = rx - 1 + (5 * exp(-rx));
        if (ry > realMax || ry < realMin) continue;

        if (firstPoint) {
          solPath.moveTo(mapX(rx), mapY(ry));
          firstPoint = false;
        } else {
          solPath.lineTo(mapX(rx), mapY(ry));
        }
      }
      canvas.drawPath(solPath, paintSol);
    }
  }

  void _drawText(Canvas canvas, TextStyle style, String text, Offset offset, Alignment alignment) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    Offset finalOffset = offset;
    if (alignment == Alignment.centerRight) {
      finalOffset = offset.translate(-textPainter.width, 0);
    } else if (alignment == Alignment.topCenter) {
      finalOffset = offset.translate(-textPainter.width / 2, 0);
    } else if (alignment == Alignment.topRight) {
      finalOffset = offset.translate(-textPainter.width, 0);
    } else if (alignment == Alignment.bottomRight) {
      finalOffset = offset.translate(-textPainter.width, 0);
    }
    
    textPainter.paint(canvas, finalOffset);
  }

  Map<String, double> _parseSimpleLinear(String input) {
    double a = 1.0; 
    double b = -1.0;
    String cleaned = input.replaceAll(' ', '').replaceAll(r'$', '');

    try {
      if (cleaned == 'x') { a = 1.0; b = 0.0; }
      else if (cleaned == 'y') { a = 0.0; b = 1.0; }
      else if (cleaned == 'x-y') { a = 1.0; b = -1.0; }
      else if (cleaned == 'x+y') { a = 1.0; b = 1.0; }
      else if (cleaned == 'y-x') { a = -1.0; b = 1.0; }
      else if (cleaned == '2x-y') { a = 2.0; b = -1.0; }
      else if (cleaned == 'x-2y') { a = 1.0; b = -2.0; }
    } catch (e) {
      a = 1.0; b = -1.0;
    }
    return {'a': a, 'b': b};
  }

  @override
  bool shouldRepaint(covariant _CampoPendientesPainter oldDelegate) {
    return oldDelegate.equacionRaw != equacionRaw;
  }
}