import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/app_imports.dart';

class DescriptivaScreen extends StatefulWidget {
  const DescriptivaScreen({super.key});

  @override
  State<DescriptivaScreen> createState() => _DescriptivaScreenState();
}

class _DescriptivaScreenState extends State<DescriptivaScreen> {
  final TextEditingController _dataController = TextEditingController();
  List<double> _datos = [];
  
  double? _media, _mediana, _moda, _varianzaM, _desviacionM, _rango, _q1, _q3, _iqr;
  List<int> _frecuenciasBin = [];
  List<double> _limitesBin = [];

  void _calcular() {
    final text = _dataController.text;
    if (text.isEmpty) return;

    final rawStrings = text.split(RegExp(r'[,\s]+'));
    _datos = rawStrings.map((s) => double.tryParse(s.trim())).where((n) => n != null).cast<double>().toList();

    if (_datos.isEmpty) return;
    _datos.sort();
    int n = _datos.length;

    _media = _datos.reduce((a, b) => a + b) / n;
    _mediana = _calcularMediana(_datos);
    
    Map<double, int> freq = {};
    for (var val in _datos) { freq[val] = (freq[val] ?? 0) + 1; }
    int maxFreq = freq.values.reduce(max);
    _moda = maxFreq > 1 ? freq.entries.firstWhere((e) => e.value == maxFreq).key : null;

    double minVal = _datos.first;
    double maxVal = _datos.last;
    _rango = maxVal - minVal;

    if (n > 1) {
      double sumOfSquaredDiffs = _datos.fold(0.0, (sum, item) => sum + pow(item - _media!, 2));
      _varianzaM = sumOfSquaredDiffs / (n - 1); 
      _desviacionM = sqrt(_varianzaM!);
    } else {
      _varianzaM = 0.0; _desviacionM = 0.0;
    }

    int mid = n ~/ 2;
    _q1 = _calcularMediana(_datos.sublist(0, mid));
    _q3 = _calcularMediana(n % 2 == 1 ? _datos.sublist(mid + 1) : _datos.sublist(mid));
    _iqr = _q3! - _q1!;

    int kBins = max(5, (1 + 3.322 * log(n) / ln10).ceil());
    double binWidth = _rango! == 0 ? 1 : _rango! / kBins;
    
    _limitesBin = List.generate(kBins + 1, (i) => minVal + (i * binWidth));
    _frecuenciasBin = List.filled(kBins, 0);

    for (var val in _datos) {
      int binIndex = ((val - minVal) / binWidth).floor();
      if (binIndex == kBins) binIndex--; 
      _frecuenciasBin[binIndex]++;
    }

    setState(() {});
  }

  double _calcularMediana(List<double> lista) {
    if (lista.isEmpty) return 0.0;
    int mid = lista.length ~/ 2;
    return lista.length % 2 == 1 ? lista[mid] : (lista[mid - 1] + lista[mid]) / 2.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(title: const Text('Estadística Descriptiva'), backgroundColor: const Color(0xFF5B9BD5)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _dataController,
              maxLines: 3,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Ingresa los datos del problema',
                hintText: 'Ej: 12.5, 14, 15, 16.2, 18',
                filled: true,
                fillColor: isDark ? const Color(0xFF152840) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B9BD5), padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _calcular,
              icon: const Icon(Icons.analytics, color: Colors.white),
              label: const Text('Procesar Datos', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            
            if (_media != null) ...[
              const SizedBox(height: 24),
              Text('Histograma de Frecuencias', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16)),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _frecuenciasBin.reduce(max) * 1.2,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                        if (value.toInt() >= _limitesBin.length - 1) return const SizedBox();
                        return Padding(padding: const EdgeInsets.only(top: 5), child: Text(_limitesBin[value.toInt()].toStringAsFixed(1), style: const TextStyle(fontSize: 10)));
                      })),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(_frecuenciasBin.length, (index) => BarChartGroupData(x: index, barRods: [BarChartRodData(toY: _frecuenciasBin[index].toDouble(), color: const Color(0xFF5B9BD5), width: 20, borderRadius: BorderRadius.zero)])),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2,
                children: [
                  _StatCard('n (Muestra)', _datos.length.toString(), isDark), _StatCard('Media (x̄)', _media!.toStringAsFixed(3), isDark),
                  _StatCard('Mediana', _mediana!.toStringAsFixed(3), isDark), _StatCard('Moda', _moda != null ? _moda!.toStringAsFixed(3) : 'Amodal', isDark),
                  _StatCard('Var. Muestral (s²)', _varianzaM!.toStringAsFixed(3), isDark), _StatCard('Desv. Est. (s)', _desviacionM!.toStringAsFixed(3), isDark),
                  _StatCard('Cuartil 1 (Q1)', _q1!.toStringAsFixed(3), isDark), _StatCard('Cuartil 3 (Q3)', _q3!.toStringAsFixed(3), isDark),
                  _StatCard('Rango IQR', _iqr!.toStringAsFixed(3), isDark), _StatCard('Rango Total', _rango!.toStringAsFixed(3), isDark),
                ],
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
            heroTag: 'btn_scan_descriptiva', // Tag único
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Le mandamos el tema 'descriptiva' a Python
                  builder: (context) => const ScanProblemScreen(tema: 'descriptiva'), 
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
            heroTag: 'btn_asistente_descriptiva',
            onPressed: () => _showAssistant(context),
            backgroundColor: const Color(0xFF6B8CAE),
            elevation: 4,
            child: const Icon(Icons.psychology_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showAssistant(BuildContext context) {
    String contexto = _dataController.text.isNotEmpty 
        ? "Conjunto de datos: [${_dataController.text}]" 
        : "El usuario aún no ingresa datos.";
        
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => _MiniChatAssistantDesc(contextoDatos: contexto)
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final bool isDark;
  const _StatCard(this.title, this.value, this.isDark);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF152840) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : const Color(0xFF6B8CAE))),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5B9BD5))),
      ]),
    );
  }
}

class _MiniChatAssistantDesc extends StatefulWidget {
  final String contextoDatos;
  const _MiniChatAssistantDesc({required this.contextoDatos});
  @override
  State<_MiniChatAssistantDesc> createState() => _MiniChatAssistantDescState();
}

class _MiniChatAssistantDescState extends State<_MiniChatAssistantDesc> {
  final _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.70 + bottomInset, padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))),
          child: Row(children: [const Icon(Icons.school_rounded, color: Color(0xFF5B9BD5)), const SizedBox(width: 8), Text("Tutor IA - Descriptiva", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))), const Spacer(), IconButton(icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54), onPressed: () => Navigator.pop(context))]),
        ),
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: chatProvider.messages.length, itemBuilder: (context, index) {
          final msg = chatProvider.messages[index];
          return Align(alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8), decoration: BoxDecoration(color: msg.isUser ? const Color(0xFF5B9BD5) : (isDark ? const Color(0xFF234060) : const Color(0xFFEBF4FC)), borderRadius: BorderRadius.circular(16).copyWith(bottomRight: msg.isUser ? const Radius.circular(0) : null, bottomLeft: !msg.isUser ? const Radius.circular(0) : null)), child: Text(msg.text, style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A2D4A))))));
        })),
        if (chatProvider.isLoading) const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5B9BD5)))),
        Padding(padding: const EdgeInsets.all(12.0), child: Row(children: [
          Expanded(child: TextField(controller: _controller, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(hintText: "¿Preguntas sobre varianza o cuartiles?", hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13), filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF5F5F5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
          const SizedBox(width: 8),
          CircleAvatar(backgroundColor: const Color(0xFF5B9BD5), child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), onPressed: () {
            if (_controller.text.isNotEmpty) { 
              chatProvider.sendMessage(_controller.text, currentEquation: widget.contextoDatos); 
              _controller.clear(); 
            }
          })),
        ])),
      ]),
    );
  }
}