import 'dart:math';
import 'package:flutter/material.dart';
import '../../../shared/app_imports.dart';

class PruebasHipotesisScreen extends StatefulWidget {
  const PruebasHipotesisScreen({super.key});

  @override
  State<PruebasHipotesisScreen> createState() => _PruebasHipotesisScreenState();
}

class _PruebasHipotesisScreenState extends State<PruebasHipotesisScreen> {
  String _tipoPrueba = 'Media Poblacional (Z)';
  String _tipoCola = 'Bilateral (≠)';
  String _nivelSignificancia = '0.05';
  
  // Controladores Generales
  final _nController = TextEditingController(); 
  
  // Para Medias (Z y T)
  final _mu0Controller = TextEditingController(); 
  final _mediaController = TextEditingController(); 
  final _desviacionController = TextEditingController(); 
  
  // Para proporciones (Z)
  final _p0Controller = TextEditingController(); 
  final _exitosController = TextEditingController(); 

  // Para Varianzas (Chi-cuadrada)
  final _var0Controller = TextEditingController(); 
  final _varMuestralController = TextEditingController();

  double? _estadisticoCalc;
  String _nombreEstadistico = 'Z';
  double? _pValue;
  bool? _rechazarH0;

  @override
  void dispose() {
    _nController.dispose();
    _mu0Controller.dispose();
    _mediaController.dispose();
    _desviacionController.dispose();
    _p0Controller.dispose();
    _exitosController.dispose();
    _var0Controller.dispose();
    _varMuestralController.dispose();
    super.dispose();
  }

  double _parseD(String text) => double.tryParse(text.replaceAll(',', '.')) ?? -1.0;
  int _parseI(String text) => int.tryParse(text.trim()) ?? -1;

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  // --- MATEMÁTICA AVANZADA ---

  // 1. CDF Normal (Abramowitz & Stegun)
  double _normalCDF(double z) {
    bool isNegative = z < 0;
    z = z.abs();
    double p = 0.2316419;
    double b1 = 0.319381530, b2 = -0.356563782, b3 = 1.781477937, b4 = -1.821255978, b5 = 1.330274429;
    double t = 1.0 / (1.0 + p * z);
    double pdfZ = (1.0 / sqrt(2 * pi)) * exp(-0.5 * z * z);
    double cdf = 1.0 - pdfZ * (b1 * t + b2 * pow(t, 2) + b3 * pow(t, 3) + b4 * pow(t, 4) + b5 * pow(t, 5));
    return isNegative ? 1.0 - cdf : cdf;
  }

  // 2. Log Gamma (Aproximación de Lanczos) para PDF de T-Student
  double _logGamma(double x) {
    List<double> p = [
      676.5203681218851, -1259.1392167224028, 771.32342877765313,
      -176.61502916214059, 12.507343278686905, -0.13857109526572012,
      9.9843695780195716e-6, 1.5056327351493116e-7
    ];
    double y = x;
    double tmp = x + 7.5;
    tmp = (x + 0.5) * log(tmp) - tmp;
    double ser = 0.99999999999036;
    for (int i = 0; i < p.length; i++) {
      y = y + 1;
      ser += p[i] / y;
    }
    return tmp + log(2.5066282746310005 * ser / x);
  }

  // 3. CDF T-Student (Integración Numérica - Regla de Simpson)
  double _tCDF(double t, int df) {
    if (t == 0) return 0.5;
    bool isNegative = t < 0;
    t = t.abs();
    
    double tPDF(double x) => pow(1 + (x * x) / df, -(df + 1) / 2).toDouble();
    double logC = _logGamma((df + 1) / 2.0) - _logGamma(df / 2.0) - 0.5 * log(df * pi);
    double C = exp(logC);

    int steps = 1000;
    double h = t / steps;
    double sum = tPDF(0) + tPDF(t);
    for (int i = 1; i < steps; i++) {
      double x = i * h;
      sum += tPDF(x) * (i % 2 == 0 ? 2 : 4);
    }
    double area = (h / 3.0) * sum * C;
    double cdf = 0.5 + area;
    return isNegative ? 1.0 - cdf : cdf;
  }

  // 4. CDF Chi-Cuadrada (Transformación de Wilson-Hilferty)
  double _chiSquareCDF(double x, int df) {
    if (x <= 0) return 0.0;
    double z = (pow(x / df, 1.0 / 3.0) - (1.0 - 2.0 / (9.0 * df))) / sqrt(2.0 / (9.0 * df));
    return _normalCDF(z);
  }

  // --- LÓGICA PRINCIPAL ---
  void _calcular() {
    setState(() { _estadisticoCalc = null; _pValue = null; _rechazarH0 = null; });

    int n = _parseI(_nController.text);
    double alpha = double.parse(_nivelSignificancia);

    if (n <= 1) {
      _mostrarError('Error: El tamaño de la muestra n debe ser > 1.');
      return;
    }

    double stat = 0.0;
    double pVal = 0.0;
    String nombreEstat = 'Z';

    // A) PRUEBA Z PARA MEDIAS
    if (_tipoPrueba == 'Media Poblacional (Z)') {
      double mu0 = _parseD(_mu0Controller.text);
      double xBar = _parseD(_mediaController.text);
      double sigma = _parseD(_desviacionController.text);
      if (sigma <= 0) { _mostrarError('Error: σ debe ser > 0.'); return; }
      
      stat = (xBar - mu0) / (sigma / sqrt(n));
      nombreEstat = 'Z';
      
      if (_tipoCola == 'Unilateral Izquierda (<)') {
        pVal = _normalCDF(stat);
      } else if (_tipoCola == 'Unilateral Derecha (>)') pVal = 1.0 - _normalCDF(stat);
      else pVal = 2.0 * (1.0 - _normalCDF(stat.abs()));
    } 
    
    // B) PRUEBA T-STUDENT PARA MEDIAS (Muestras pequeñas)
    else if (_tipoPrueba == 'Media Poblacional (T-Student)') {
      double mu0 = _parseD(_mu0Controller.text);
      double xBar = _parseD(_mediaController.text);
      double s = _parseD(_desviacionController.text);
      if (s <= 0) { _mostrarError('Error: s debe ser > 0.'); return; }
      
      stat = (xBar - mu0) / (s / sqrt(n));
      nombreEstat = 'T';
      int df = n - 1;
      
      if (_tipoCola == 'Unilateral Izquierda (<)') {
        pVal = _tCDF(stat, df);
      } else if (_tipoCola == 'Unilateral Derecha (>)') pVal = 1.0 - _tCDF(stat, df);
      else pVal = 2.0 * (1.0 - _tCDF(stat.abs(), df));
    }
    
    // C) PRUEBA Z PARA PROPORCIONES
    else if (_tipoPrueba == 'Proporción Poblacional (Z)') {
      double p0 = _parseD(_p0Controller.text);
      int x = _parseI(_exitosController.text);
      if (p0 <= 0 || p0 >= 1) { _mostrarError('Error: p0 debe estar entre 0 y 1.'); return; }
      if (x < 0 || x > n) { _mostrarError('Error: Éxitos (x) entre 0 y n.'); return; }
      
      double pHat = x / n;
      stat = (pHat - p0) / sqrt((p0 * (1 - p0)) / n);
      nombreEstat = 'Z';
      
      if (_tipoCola == 'Unilateral Izquierda (<)') {
        pVal = _normalCDF(stat);
      } else if (_tipoCola == 'Unilateral Derecha (>)') pVal = 1.0 - _normalCDF(stat);
      else pVal = 2.0 * (1.0 - _normalCDF(stat.abs()));
    }
    
    // D) PRUEBA CHI-CUADRADA PARA VARIANZAS
    else if (_tipoPrueba == 'Varianza Poblacional (Chi²)') {
      double var0 = _parseD(_var0Controller.text);
      double varM = _parseD(_varMuestralController.text);
      if (var0 <= 0 || varM < 0) { _mostrarError('Error: Las varianzas deben ser > 0.'); return; }
      
      int df = n - 1;
      stat = (df * varM) / var0;
      nombreEstat = 'χ²';
      
      if (_tipoCola == 'Unilateral Izquierda (<)') {
        pVal = _chiSquareCDF(stat, df);
      } else if (_tipoCola == 'Unilateral Derecha (>)') pVal = 1.0 - _chiSquareCDF(stat, df);
      else pVal = 2.0 * min(_chiSquareCDF(stat, df), 1.0 - _chiSquareCDF(stat, df));
    }

    setState(() {
      _estadisticoCalc = stat;
      _nombreEstadistico = nombreEstat;
      _pValue = pVal;
      _rechazarH0 = pVal < alpha;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFE91E63);
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFFCE4EC),
      appBar: AppBar(title: const Text('Pruebas de Hipótesis', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: primaryColor, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdown(
              value: _tipoPrueba, 
              items: ['Media Poblacional (Z)', 'Media Poblacional (T-Student)', 'Proporción Poblacional (Z)', 'Varianza Poblacional (Chi²)'], 
              onChanged: (val) => setState(() { _tipoPrueba = val!; _estadisticoCalc = null; }), 
              isDark: isDark, color: primaryColor
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDropdown(value: _tipoCola, items: ['Bilateral (≠)', 'Unilateral Izquierda (<)', 'Unilateral Derecha (>)'], onChanged: (val) => setState(() { _tipoCola = val!; _estadisticoCalc = null; }), isDark: isDark, color: primaryColor, label: 'Tipo de Prueba')),
                const SizedBox(width: 8),
                Expanded(child: _buildDropdown(value: _nivelSignificancia, items: ['0.01', '0.05', '0.10'], onChanged: (val) => setState(() { _nivelSignificancia = val!; _estadisticoCalc = null; }), isDark: isDark, color: primaryColor, label: 'Significancia (α)')),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildInput(_nController, 'Tamaño de la muestra (n)', isDark),
            
            if (_tipoPrueba.contains('Media Poblacional')) ...[
              _buildInput(_mu0Controller, 'Hipótesis Nula (μ0)', isDark, isDecimal: true),
              _buildInput(_mediaController, 'Media muestral (x̄)', isDark, isDecimal: true),
              _buildInput(_desviacionController, _tipoPrueba.contains('Z') ? 'Desviación poblacional (σ)' : 'Desviación muestral (s)', isDark, isDecimal: true),
            ] 
            else if (_tipoPrueba == 'Proporción Poblacional (Z)') ...[
              _buildInput(_p0Controller, 'Proporción Nula (p0) ej. 0.5', isDark, isDecimal: true),
              _buildInput(_exitosController, 'Casos de éxito observados (x)', isDark),
            ]
            else if (_tipoPrueba == 'Varianza Poblacional (Chi²)') ...[
              _buildInput(_var0Controller, 'Varianza Nula (σ0²)', isDark, isDecimal: true),
              _buildInput(_varMuestralController, 'Varianza muestral (s²)', isDark, isDecimal: true),
            ],
            
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _calcular, icon: const Icon(Icons.rule_rounded, color: Colors.white), label: const Text('Ejecutar Prueba', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            if (_estadisticoCalc != null) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 2)),
                child: Column(
                  children: [
                    Text('Conclusión Técnica', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                    const SizedBox(height: 12),
                    Text(
                      _rechazarH0! ? 'SE RECHAZA H₀\n(Hay un efecto real)' : 'NO SE RECHAZA H₀\n(Todo sigue igual)', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _rechazarH0! ? Colors.redAccent : Colors.green),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: isDark ? Colors.black26 : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        _rechazarH0! 
                            ? '💡 Interpretación:\nComo el Valor-P (${_pValue!.toStringAsFixed(4)}) es MENOR que α ($_nivelSignificancia), la diferencia es estadísticamente significativa.\n\n👉 Sí existe evidencia de que la variable ha cambiado con respecto a la hipótesis nula.' 
                            : '💡 Interpretación:\nComo el Valor-P (${_pValue!.toStringAsFixed(4)}) es MAYOR que α ($_nivelSignificancia), la diferencia NO es estadísticamente significativa.\n\n👉 La variación observada puede deberse al azar.', 
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87), textAlign: TextAlign.left
                      ),
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatText('Estadístico $_nombreEstadistico', _estadisticoCalc!.toStringAsFixed(4), isDark),
                        _StatText('Valor-P', _pValue!.toStringAsFixed(5), isDark),
                      ],
                    )
                  ]
                )
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
            heroTag: 'btn_scan_hipotesis', // Tag único
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Le mandamos el tema 'pruebas_hipotesis' a Python
                  builder: (context) => const ScanProblemScreen(tema: 'pruebas_hipotesis'), 
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
            heroTag: 'btn_asistente_hipotesis',
            onPressed: () => _showAssistant(context, primaryColor),
            backgroundColor: primaryColor, // Rosa/Magenta para combinar con la pantalla
            elevation: 4,
            child: const Icon(Icons.psychology_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required Function(String?) onChanged, required bool isDark, required Color color, String? label}) {
    return Container(
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? const Color(0xFF234060) : color.withValues(alpha: 0.3))),
      child: DropdownButtonFormField<String>(
        initialValue: value, isExpanded: true,
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87)))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), labelText: label, labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13), border: InputBorder.none),
        dropdownColor: isDark ? const Color(0xFF1C3350) : Colors.white,
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, bool isDark, {bool isDecimal = false}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12.0), child: TextField(controller: controller, keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: label, labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54), filled: true, fillColor: isDark ? const Color(0xFF152840) : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))));
  }

  void _showAssistant(BuildContext context, Color color) {
    String contexto = "Prueba: $_tipoPrueba. Cola: $_tipoCola. Alfa: $_nivelSignificancia. ";
    if (_tipoPrueba.contains('Media Poblacional')) {
      contexto += "H0(μ)=${_mu0Controller.text}, x̄=${_mediaController.text}, s/σ=${_desviacionController.text}, n=${_nController.text}. ";
    } else if (_tipoPrueba.contains('Proporción')) {
      contexto += "H0(p)=${_p0Controller.text}, x=${_exitosController.text}, n=${_nController.text}. ";
    } else {
      contexto += "H0(σ²)=${_var0Controller.text}, s²=${_varMuestralController.text}, n=${_nController.text}. ";
    }
    
    if (_estadisticoCalc != null) {
      contexto += "Resultado: $_nombreEstadistico=${_estadisticoCalc!.toStringAsFixed(4)}, p-value=${_pValue!.toStringAsFixed(4)}, Decisión: ${_rechazarH0! ? 'Rechazar H0' : 'No Rechazar H0'}.";
    }

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => _MiniChatAssistantHyp(contextoDatos: contexto, colorTema: color));
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

class _MiniChatAssistantHyp extends StatefulWidget {
  final String contextoDatos; final Color colorTema;
  const _MiniChatAssistantHyp({required this.contextoDatos, required this.colorTema});
  @override
  State<_MiniChatAssistantHyp> createState() => _MiniChatAssistantHypState();
}

class _MiniChatAssistantHypState extends State<_MiniChatAssistantHyp> {
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
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))), child: Row(children: [Icon(Icons.school_rounded, color: widget.colorTema), const SizedBox(width: 8), Text("Tutor IA - Hipótesis", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))), const Spacer(), IconButton(icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54), onPressed: () => Navigator.pop(context))])),
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: chatProvider.messages.length, itemBuilder: (context, index) {
          final msg = chatProvider.messages[index];
          return Align(alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8), decoration: BoxDecoration(color: msg.isUser ? widget.colorTema : (isDark ? const Color(0xFF234060) : const Color(0xFFFCE4EC)), borderRadius: BorderRadius.circular(16).copyWith(bottomRight: msg.isUser ? const Radius.circular(0) : null, bottomLeft: !msg.isUser ? const Radius.circular(0) : null)), child: Text(msg.text, style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A2D4A))))));
        })),
        if (chatProvider.isLoading) Padding(padding: const EdgeInsets.all(8.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: widget.colorTema))),
        Padding(padding: const EdgeInsets.all(12.0), child: Row(children: [
          Expanded(child: TextField(controller: _controller, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(hintText: "¿Dudas sobre el p-value o H0?", hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13), filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF5F5F5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
          const SizedBox(width: 8), CircleAvatar(backgroundColor: widget.colorTema, child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), onPressed: () { if (_controller.text.isNotEmpty) { chatProvider.sendMessage(_controller.text, currentEquation: widget.contextoDatos); _controller.clear(); } })),
        ])),
      ]),
    );
  }
}