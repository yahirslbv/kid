import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/app_imports.dart';

class DistribucionesContinuasScreen extends StatefulWidget {
  const DistribucionesContinuasScreen({super.key});

  @override
  State<DistribucionesContinuasScreen> createState() => _DistribucionesContinuasScreenState();
}

class _DistribucionesContinuasScreenState extends State<DistribucionesContinuasScreen> {
  String _selectedDist = 'Normal';
  String _tipoCalculo = 'Menor o igual P(X ≤ x)'; // Opciones: Menor, Mayor
  
  // Controladores Normal
  final _muController = TextEditingController(); // Media (μ)
  final _sigmaController = TextEditingController(); // Desviación (σ)
  final _xController = TextEditingController(); // Valor a evaluar (x)
  
  // Controladores Exponencial
  final _lambdaController = TextEditingController(); // Tasa (λ)

  double? _probabilidadCalc;
  List<FlSpot> _curvaCompleta = [];
  List<FlSpot> _areaSombreada = [];
  double _minX = 0, _maxX = 0, _maxY = 0;

  @override
  void dispose() {
    _muController.dispose();
    _sigmaController.dispose();
    _xController.dispose();
    _lambdaController.dispose();
    super.dispose();
  }

  // --- MATEMÁTICA AVANZADA ---
  
  // PDF Normal (Para dibujar la curva)
  double _normalPDF(double x, double mu, double sigma) {
    double exponente = -pow(x - mu, 2) / (2 * pow(sigma, 2));
    return (1 / (sigma * sqrt(2 * pi))) * exp(exponente);
  }

  // CDF Normal - Aproximación de Abramowitz & Stegun (Error < 1.5 * 10^-7)
  double _normalCDF(double x, double mu, double sigma) {
    double z = (x - mu) / sigma;
    bool isNegative = z < 0;
    z = z.abs();

    double p = 0.2316419;
    double b1 = 0.319381530, b2 = -0.356563782, b3 = 1.781477937, b4 = -1.821255978, b5 = 1.330274429;
    
    double t = 1.0 / (1.0 + p * z);
    double pdfZ = (1.0 / sqrt(2 * pi)) * exp(-0.5 * z * z);
    double cdf = 1.0 - pdfZ * (b1 * t + b2 * pow(t, 2) + b3 * pow(t, 3) + b4 * pow(t, 4) + b5 * pow(t, 5));

    return isNegative ? 1.0 - cdf : cdf;
  }

  // PDF Exponencial (Para dibujar)
  double _expPDF(double x, double lambda) {
    if (x < 0) return 0.0;
    return lambda * exp(-lambda * x);
  }

  // CDF Exponencial
  double _expCDF(double x, double lambda) {
    if (x < 0) return 0.0;
    return 1.0 - exp(-lambda * x);
  }

  // --- LÓGICA DE PROCESAMIENTO Y GRÁFICOS ---
  void _calcular() {
    setState(() {
      _probabilidadCalc = null;
      _curvaCompleta = [];
      _areaSombreada = [];
    });

    double xVal = double.tryParse(_xController.text) ?? 0.0;

    if (_selectedDist == 'Normal') {
      double mu = double.tryParse(_muController.text) ?? 0.0;
      double sigma = double.tryParse(_sigmaController.text) ?? 1.0;
      if (sigma <= 0) return;

      // 1. Calcular Probabilidad
      double probMenor = _normalCDF(xVal, mu, sigma);
      _probabilidadCalc = _tipoCalculo.contains('Menor') ? probMenor : 1.0 - probMenor;

      // 2. Generar Puntos para la Curva (De μ-4σ a μ+4σ)
      _minX = mu - 4 * sigma;
      _maxX = mu + 4 * sigma;
      _maxY = _normalPDF(mu, mu, sigma); // El pico está en la media

      double step = (_maxX - _minX) / 100;
      for (double i = _minX; i <= _maxX; i += step) {
        double y = _normalPDF(i, mu, sigma);
        _curvaCompleta.add(FlSpot(i, y));
        
        // Agregar a sombreado si cumple la condición
        if (_tipoCalculo.contains('Menor') && i <= xVal) {
          _areaSombreada.add(FlSpot(i, y));
        } else if (_tipoCalculo.contains('Mayor') && i >= xVal) {
          _areaSombreada.add(FlSpot(i, y));
        }
      }
    } 
    else if (_selectedDist == 'Exponencial') {
      double lambda = double.tryParse(_lambdaController.text) ?? 0.0;
      if (lambda <= 0 || xVal < 0) return;

      double probMenor = _expCDF(xVal, lambda);
      _probabilidadCalc = _tipoCalculo.contains('Menor') ? probMenor : 1.0 - probMenor;

      _minX = 0;
      _maxX = 5 / lambda; // Mostramos hasta donde la cola ya es casi cero
      _maxY = lambda; // El pico máximo es λ en x=0

      double step = (_maxX - _minX) / 100;
      for (double i = _minX; i <= _maxX; i += step) {
        double y = _expPDF(i, lambda);
        _curvaCompleta.add(FlSpot(i, y));
        
        if (_tipoCalculo.contains('Menor') && i <= xVal) {
          _areaSombreada.add(FlSpot(i, y));
        } else if (_tipoCalculo.contains('Mayor') && i >= xVal) {
          _areaSombreada.add(FlSpot(i, y));
        }
      }
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFFF9800); 
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text('Distribuciones Continuas', style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: _selectedDist,
                    items: ['Normal', 'Exponencial'],
                    onChanged: (val) => setState(() { _selectedDist = val!; _probabilidadCalc = null; }),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown(
                    value: _tipoCalculo,
                    items: ['Menor o igual P(X ≤ x)', 'Mayor que P(X > x)'],
                    onChanged: (val) => setState(() { _tipoCalculo = val!; _probabilidadCalc = null; }),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (_selectedDist == 'Normal') ...[
              _buildInput(_muController, 'Media poblacional (μ)', isDark),
              _buildInput(_sigmaController, 'Desviación estándar (σ)', isDark),
              _buildInput(_xController, 'Valor a evaluar (x)', isDark),
            ] else if (_selectedDist == 'Exponencial') ...[
              _buildInput(_lambdaController, 'Tasa de ocurrencia (λ)', isDark),
              _buildInput(_xController, 'Tiempo o valor a evaluar (x)', isDark),
            ],
            
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, 
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: _calcular,
              icon: const Icon(Icons.area_chart_rounded, color: Colors.white),
              label: const Text('Calcular Área Sombreada', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            if (_probabilidadCalc != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C3350) : Colors.white, 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 2)
                ),
                child: Column(
                  children: [
                    Text('Probabilidad Calculada', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      '${(_probabilidadCalc! * 100).toStringAsFixed(4)}%', 
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: primaryColor)
                    ),
                    Text(
                      'P = ${_probabilidadCalc!.toStringAsFixed(6)}', 
                      style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.grey),
                    ),
                  ]
                )
              ),
              const SizedBox(height: 24),
              
              Text('Área bajo la curva (Integral)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              
              Container(
                height: 250,
                padding: const EdgeInsets.only(top: 20, right: 16, left: 8, bottom: 10),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white12 : Colors.black12)),
                child: LineChart(
                  LineChartData(
                    minX: _minX, maxX: _maxX, minY: 0, maxY: _maxY * 1.1,
                    lineTouchData: const LineTouchData(enabled: false), 
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (val, meta) {
                            if (val == _minX || val == _maxX || val == (_minX + _maxX)/2) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(val.toStringAsFixed(1), style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54)),
                              );
                            }
                            return const SizedBox.shrink();
                          }
                        )
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true, 
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white12 : Colors.black12, strokeWidth: 1, dashArray: [5, 5]),
                      getDrawingVerticalLine: (value) => FlLine(color: isDark ? Colors.white12 : Colors.black12, strokeWidth: 1, dashArray: [5, 5]),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _curvaCompleta,
                        isCurved: true,
                        color: primaryColor.withValues(alpha: 0.8),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                      ),
                      if (_areaSombreada.isNotEmpty)
                        LineChartBarData(
                          spots: _areaSombreada,
                          isCurved: true,
                          color: Colors.transparent, 
                          barWidth: 0,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: primaryColor.withValues(alpha: 0.4), 
                          ),
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
            heroTag: 'btn_scan_distribuciones_continuas', // Tag único
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Le mandamos el tema 'descriptiva' a Python
                  builder: (context) => const ScanProblemScreen(tema: 'distribuciones_continuas'), 
                ),
              );
            },
            backgroundColor: const Color(0xFF5B9BD5),
            icon: const Icon(Icons.document_scanner, color: Colors.white),
            label: const Text('Escanear Datos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          // 2. Botón del Asistente de IA (el que ya tenías)
          FloatingActionButton(
            heroTag: 'btn_asistente_distribuciones_continuas',
            onPressed: () => _showAssistant(context, primaryColor), // <--- SOLUCIONADO
            backgroundColor: const Color(0xFF6B8CAE),
            elevation: 4,
            child: const Icon(Icons.psychology_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required Function(String?) onChanged, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFFFCC80)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87), overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), border: InputBorder.none),
        dropdownColor: isDark ? const Color(0xFF1C3350) : Colors.white,
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          filled: true,
          fillColor: isDark ? const Color(0xFF152840) : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  void _showAssistant(BuildContext context, Color color) {
    String contexto = "Distribución $_selectedDist. Cálculo: $_tipoCalculo. ";
    if (_selectedDist == 'Normal') {
      contexto += "Media μ=${_muController.text}, Desviación σ=${_sigmaController.text}, x=${_xController.text}";
    } else if (_selectedDist == 'Exponencial') {
      contexto += "Tasa λ=${_lambdaController.text}, x=${_xController.text}";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MiniChatAssistantContinuas(contextoDatos: contexto, distribucion: _selectedDist, colorTema: color),
    );
  }
}

class _MiniChatAssistantContinuas extends StatefulWidget {
  final String contextoDatos;
  final String distribucion;
  final Color colorTema;
  const _MiniChatAssistantContinuas({required this.contextoDatos, required this.distribucion, required this.colorTema});

  @override
  State<_MiniChatAssistantContinuas> createState() => _MiniChatAssistantContinuasState();
}

class _MiniChatAssistantContinuasState extends State<_MiniChatAssistantContinuas> {
  final _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.70 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))),
            child: Row(
              children: [
                Icon(Icons.school_rounded, color: widget.colorTema),
                const SizedBox(width: 8),
                Text("Tutor IA - Curva ${widget.distribucion}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))),
                const Spacer(),
                IconButton(icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54), onPressed: () => Navigator.pop(context))
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final msg = chatProvider.messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: msg.isUser ? widget.colorTema : (isDark ? const Color(0xFF234060) : const Color(0xFFFFF3E0)),
                      borderRadius: BorderRadius.circular(16).copyWith(bottomRight: msg.isUser ? const Radius.circular(0) : null, bottomLeft: !msg.isUser ? const Radius.circular(0) : null),
                    ),
                    child: Text(msg.text, style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A2D4A)))),
                  ),
                );
              },
            ),
          ),
          if (chatProvider.isLoading)
            Padding(padding: const EdgeInsets.all(8.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: widget.colorTema))),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "¿Dudas sobre Z, integrales o colas?",
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: widget.colorTema,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        chatProvider.sendMessage(
                          _controller.text, 
                          currentEquation: widget.contextoDatos 
                        );
                        _controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}