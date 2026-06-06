import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/app_imports.dart';

class RegresionCorrelacionScreen extends StatefulWidget {
  const RegresionCorrelacionScreen({super.key});

  @override
  State<RegresionCorrelacionScreen> createState() => _RegresionCorrelacionScreenState();
}

class _RegresionCorrelacionScreenState extends State<RegresionCorrelacionScreen> {
  final _xController = TextEditingController();
  final _yController = TextEditingController();

  List<double> _xData = [];
  List<double> _yData = [];

  double? _beta0; // Intersección (a)
  double? _beta1; // Pendiente (b)
  double? _r;     // Correlación de Pearson
  double? _r2;    // Coeficiente de determinación

  double _minX = 0, _maxX = 0, _minY = 0, _maxY = 0;

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  void _calcular() {
    setState(() {
      _beta0 = null; _beta1 = null; _r = null; _r2 = null;
      _xData = []; _yData = []; // Limpiamos para que no dibuje basura si hay error
    });

    final rawX = _xController.text.split(RegExp(r'[,\s]+'));
    final rawY = _yController.text.split(RegExp(r'[,\s]+'));

    // 1. Guardamos en listas temporales primero
    List<double> tempX = rawX.map((s) => double.tryParse(s.replaceAll(',', '.'))).where((n) => n != null).cast<double>().toList();
    List<double> tempY = rawY.map((s) => double.tryParse(s.replaceAll(',', '.'))).where((n) => n != null).cast<double>().toList();

    int n = tempX.length;

    // 2. Hacemos las validaciones con las temporales
    if (n < 2) {
      _mostrarError('Error: Se requieren al menos 2 pares de datos.');
      return;
    }
    if (n != tempY.length) {
      _mostrarError('Error: Los conjuntos X e Y deben tener la misma cantidad de datos (X tiene $n, Y tiene ${tempY.length}).');
      return;
    }

    // 3. ¡Todo está bien! Ahora sí pasamos los datos a las variables que usa el gráfico
    _xData = tempX;
    _yData = tempY;

    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;

    for (int i = 0; i < n; i++) {
      sumX += _xData[i];
      sumY += _yData[i];
      sumXY += _xData[i] * _yData[i];
      sumX2 += _xData[i] * _xData[i];
      sumY2 += _yData[i] * _yData[i];
    }

    double ssXY = sumXY - ((sumX * sumY) / n);
    double ssXX = sumX2 - ((sumX * sumX) / n);
    double ssYY = sumY2 - ((sumY * sumY) / n);

    if (ssXX == 0) {
      _mostrarError('Error: La varianza de X es 0. No se puede calcular la regresión.');
      return;
    }

    double b1 = ssXY / ssXX;
    double b0 = (sumY / n) - (b1 * (sumX / n));
    double rCalc = ssYY == 0 ? 0 : ssXY / sqrt(ssXX * ssYY);

    _minX = _xData.reduce(min);
    _maxX = _xData.reduce(max);
    _minY = _yData.reduce(min);
    _maxY = _yData.reduce(max);

    double paddingX = (_maxX - _minX) == 0 ? 1 : (_maxX - _minX) * 0.1;
    double paddingY = (_maxY - _minY) == 0 ? 1 : (_maxY - _minY) * 0.1;
    
    _minX -= paddingX; _maxX += paddingX;
    _minY -= paddingY; _maxY += paddingY;

    setState(() {
      _beta1 = b1;
      _beta0 = b0;
      _r = rCalc;
      _r2 = rCalc * rCalc;
    });
  }

  String _interpretarCorrelacion(double r) {
    String direccion = r > 0 ? "positiva (directa)" : "negativa (inversa)";
    double absR = r.abs();
    String fuerza = "";
    
    if (absR >= 0.9) {
      fuerza = "muy fuerte";
    } else if (absR >= 0.7) fuerza = "fuerte";
    else if (absR >= 0.4) fuerza = "moderada";
    else if (absR >= 0.2) fuerza = "débil";
    else fuerza = "prácticamente nula";

    return "La correlación es $fuerza y $direccion.";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF009688); 
    
    List<FlSpot> scatterSpots = [];
    for (int i = 0; i < _xData.length; i++) {
      scatterSpots.add(FlSpot(_xData[i], _yData[i]));
    }
    
    // Generación de recta con alta resolución (Fluidez táctil)
    List<FlSpot> lineSpots = [];
    if (_beta0 != null && _beta1 != null) {
      Set<double> xValues = {_minX, _maxX};
      xValues.addAll(_xData); // Aseguramos que los puntos de los datos existan en la recta
      
      double step = (_maxX - _minX) / 50; // 50 puntos intermedios
      for (double i = _minX; i <= _maxX; i += step) {
        xValues.add(i);
      }
      
      List<double> sortedXs = xValues.toList()..sort();
      for (double x in sortedXs) {
        lineSpots.add(FlSpot(x, _beta0! + _beta1! * x));
      }
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFE0F2F1),
      appBar: AppBar(title: const Text('Regresión y Correlación', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: primaryColor, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInput(_xController, 'Datos de Variable Independiente (X)', 'Ej: 1, 2, 3, 4, 5', isDark),
            _buildInput(_yController, 'Datos de Variable Dependiente (Y)', 'Ej: 2.1, 4.0, 6.2, 8.5, 9.9', isDark),
            
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _calcular, icon: const Icon(Icons.show_chart_rounded, color: Colors.white), label: const Text('Calcular y Graficar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            if (_beta0 != null) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 2)),
                child: Column(
                  children: [
                    Text('Ecuación de la Recta (Modelo)', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                    const SizedBox(height: 12),
                    Text(
                      'ŷ = ${_beta0!.toStringAsFixed(4)} ${_beta1! >= 0 ? '+' : '-'} ${_beta1!.abs().toStringAsFixed(4)} x', 
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primaryColor)
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: isDark ? Colors.black26 : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '💡 Interpretación:\n${_interpretarCorrelacion(_r!)}\n\n👉 El ${(_r2! * 100).toStringAsFixed(1)}% de la variación en Y se explica por la variable X.', 
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, height: 1.4), textAlign: TextAlign.left
                      ),
                    ),
                    
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatText('Correlación (r)', _r!.toStringAsFixed(4), isDark),
                        _StatText('Determinación (r²)', _r2!.toStringAsFixed(4), isDark),
                      ],
                    )
                  ]
                )
              ),
              const SizedBox(height: 24),
              
              Text('Gráfico de Dispersión y Ajuste Lineal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              
              Container(
                height: 300,
                padding: const EdgeInsets.only(top: 20, right: 20, left: 10, bottom: 10),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white12 : Colors.black12)),
                child: LineChart(
                  LineChartData(
                    minX: _minX, maxX: _maxX, minY: _minY, maxY: _maxY,
                    
                    // --- CONTROLADOR TÁCTIL MEJORADO ---
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            if (spot.barIndex == 0) {
                              // Dato Original (Naranja)
                              return LineTooltipItem(
                                'Dato Real\nX: ${spot.x.toStringAsFixed(1)}\nY: ${spot.y.toStringAsFixed(2)}',
                                const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                              );
                            } else {
                              // Recta de Regresión (Blanca)
                              return LineTooltipItem(
                                'Modelo\nX: ${spot.x.toStringAsFixed(1)}\nŷ: ${spot.y.toStringAsFixed(2)}',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              );
                            }
                          }).toList();
                        },
                      ),
                    ),
                    // ------------------------------------

                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (val, meta) => Padding(padding: const EdgeInsets.only(top: 6.0), child: Text(val.toStringAsFixed(1), style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54))))),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (val, meta) => Text(val.toStringAsFixed(1), style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54)))),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: true, drawVerticalLine: true, getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white12 : Colors.black12, strokeWidth: 1, dashArray: [5, 5]), getDrawingVerticalLine: (value) => FlLine(color: isDark ? Colors.white12 : Colors.black12, strokeWidth: 1, dashArray: [5, 5])),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Indice 0: Puntos de dispersión
                      LineChartBarData(
                        spots: scatterSpots..sort((a, b) => a.x.compareTo(b.x)),
                        isCurved: false,
                        color: Colors.transparent, // Transparente para no mostrar la línea uniéndolos
                        barWidth: 0,
                        dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 5, color: Colors.orange, strokeWidth: 1.5, strokeColor: Colors.white)),
                      ),
                      // Indice 1: Línea de regresión (fluida)
                      LineChartBarData(
                        spots: lineSpots,
                        isCurved: false,
                        color: primaryColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ]
          ],
        ),
      ),
      // --- MODIFICADO: COLUMNA CON ESCÁNER Y ASISTENTE ---
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 1. Botón del Escáner
          FloatingActionButton.extended(
            heroTag: 'btn_scan_regresion_correlacion', // Tag único
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Le mandamos el tema 'pruebas_hipotesis' a Python
                  builder: (context) => const ScanProblemScreen(tema: 'regresion_correlacion'), 
                ),
              );
            },
            backgroundColor: const Color(0xFF5B9BD5), // Azul clásico para el escáner
            icon: const Icon(Icons.document_scanner, color: Colors.white),
            label: const Text('Escanear Datos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          // 2. Botón del Asistente (El que ya tenías)
          FloatingActionButton(
            heroTag: 'btn_asistente_regresion_correlacion',
            onPressed: () => _showAssistant(context, primaryColor),
            backgroundColor: primaryColor, // Rosa/Magenta para combinar con la pantalla
            elevation: 4,
            child: const Icon(Icons.psychology_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, String hint, bool isDark) {
    return Padding(padding: const EdgeInsets.only(bottom: 12.0), child: TextField(controller: controller, maxLines: 2, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: label, hintText: hint, hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38), labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54), filled: true, fillColor: isDark ? const Color(0xFF152840) : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))));
  }

  void _showAssistant(BuildContext context, Color color) {
    String contexto = _beta0 != null 
      ? "Regresión Lineal Simple calculada. Ecuación: y = ${_beta0!.toStringAsFixed(4)} + ${_beta1!.toStringAsFixed(4)}x. Pearson r = ${_r!.toStringAsFixed(4)}, r^2 = ${_r2!.toStringAsFixed(4)}. Datos X: [${_xController.text}], Datos Y: [${_yController.text}]." 
      : "El usuario aún no calcula la regresión.";
    
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => _MiniChatAssistantReg(contextoDatos: contexto, colorTema: color));
  }
}

class _StatText extends StatelessWidget {
  final String label, value; final bool isDark;
  const _StatText(this.label, this.value, this.isDark);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      ],
    );
  }
}

class _MiniChatAssistantReg extends StatefulWidget {
  final String contextoDatos; final Color colorTema;
  const _MiniChatAssistantReg({required this.contextoDatos, required this.colorTema});
  @override
  State<_MiniChatAssistantReg> createState() => _MiniChatAssistantRegState();
}

class _MiniChatAssistantRegState extends State<_MiniChatAssistantReg> {
  final _controller = TextEditingController();
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.70 + bottomInset, padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))), child: Row(children: [Icon(Icons.school_rounded, color: widget.colorTema), const SizedBox(width: 8), Text("Tutor IA - Regresión", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))), const Spacer(), IconButton(icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54), onPressed: () => Navigator.pop(context))])),
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: chatProvider.messages.length, itemBuilder: (context, index) {
          final msg = chatProvider.messages[index];
          return Align(alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8), decoration: BoxDecoration(color: msg.isUser ? widget.colorTema : (isDark ? const Color(0xFF234060) : const Color(0xFFE0F2F1)), borderRadius: BorderRadius.circular(16).copyWith(bottomRight: msg.isUser ? const Radius.circular(0) : null, bottomLeft: !msg.isUser ? const Radius.circular(0) : null)), child: Text(msg.text, style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A2D4A))))));
        })),
        if (chatProvider.isLoading) Padding(padding: const EdgeInsets.all(8.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: widget.colorTema))),
        Padding(padding: const EdgeInsets.all(12.0), child: Row(children: [
          Expanded(child: TextField(controller: _controller, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(hintText: "¿Preguntas sobre r2 o proyecciones?", hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13), filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF5F5F5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
          const SizedBox(width: 8), CircleAvatar(backgroundColor: widget.colorTema, child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), onPressed: () { if (_controller.text.isNotEmpty) { chatProvider.sendMessage(_controller.text, currentEquation: widget.contextoDatos); _controller.clear(); } })),
        ])),
      ]),
    );
  }
}