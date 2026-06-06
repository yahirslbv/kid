import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/app_imports.dart';
class ControlCalidadScreen extends StatefulWidget {
  const ControlCalidadScreen({super.key});

  @override
  State<ControlCalidadScreen> createState() => _ControlCalidadScreenState();
}

class _ControlCalidadScreenState extends State<ControlCalidadScreen> {
  String _tipoGrafico = 'Gráfico X̄ (Medias)'; // Opciones: X̄, R

  // Lista dinámica para los subgrupos (muestras)
  final List<TextEditingController> _muestrasControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  // Resultados
  List<double> _medias = [];
  List<double> _rangos = [];
  double? _xBarBar; // Gran media
  double? _rBar;    // Rango promedio
  double? _uclX, _lclX, _clX; // Límites para X̄
  double? _uclR, _lclR, _clR; // Límites para R
  int _n = 0; // Tamaño de subgrupo
  
  bool _fueraDeControlX = false;
  bool _fueraDeControlR = false;

  // Tabla de constantes para gráficos de control (n de 2 a 10)
  // Formato: n: [A2, D3, D4]
  final Map<int, List<double>> _constantes = {
    2: [1.880, 0.000, 3.267],
    3: [1.023, 0.000, 2.574],
    4: [0.729, 0.000, 2.282],
    5: [0.577, 0.000, 2.114],
    6: [0.483, 0.000, 2.004],
    7: [0.419, 0.076, 1.924],
    8: [0.373, 0.136, 1.864],
    9: [0.337, 0.184, 1.816],
    10: [0.308, 0.223, 1.777],
  };

  @override
  void dispose() {
    for (var controller in _muestrasControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  void _addMuestra() {
    setState(() { _muestrasControllers.add(TextEditingController()); });
  }

  void _removeMuestra(int index) {
    if (_muestrasControllers.length > 2) {
      setState(() {
        _muestrasControllers[index].dispose();
        _muestrasControllers.removeAt(index);
      });
    } else {
      _mostrarError('Se requieren al menos 2 muestras para evaluar el control.');
    }
  }

  void _calcular() {
    setState(() {
      _xBarBar = null; _rBar = null; 
      _medias = []; _rangos = [];
      _fueraDeControlX = false; _fueraDeControlR = false;
    });

    List<List<double>> datosProcesados = [];
    int tamanoSubgrupo = -1;

    for (var controller in _muestrasControllers) {
      String text = controller.text.trim();
      if (text.isEmpty) continue;

      List<double> valores = text.split(RegExp(r'[,\s]+'))
          .map((s) => double.tryParse(s.replaceAll(',', '.')))
          .where((n) => n != null).cast<double>().toList();

      if (valores.isNotEmpty) {
        if (tamanoSubgrupo == -1) {
          tamanoSubgrupo = valores.length;
        } else if (valores.length != tamanoSubgrupo) {
          _mostrarError('Error: Todos los subgrupos deben tener el mismo número de observaciones (n).');
          return;
        }
        datosProcesados.add(valores);
      }
    }

    int k = datosProcesados.length; // Número de subgrupos
    _n = tamanoSubgrupo;

    if (k < 2) {
      _mostrarError('Ingresa al menos 2 subgrupos válidos.');
      return;
    }
    if (_n < 2 || _n > 10) {
      _mostrarError('El tamaño del subgrupo (n) debe estar entre 2 y 10 para usar la tabla estándar.');
      return;
    }

    double sumMedias = 0;
    double sumRangos = 0;

    for (var subgrupo in datosProcesados) {
      double media = subgrupo.reduce((a, b) => a + b) / _n;
      double minVal = subgrupo.reduce(min);
      double maxVal = subgrupo.reduce(max);
      double rango = maxVal - minVal;

      _medias.add(media);
      _rangos.add(rango);
      sumMedias += media;
      sumRangos += rango;
    }

    double xBarBar = sumMedias / k;
    double rBar = sumRangos / k;

    // Obtener constantes
    double a2 = _constantes[_n]![0];
    double d3 = _constantes[_n]![1];
    double d4 = _constantes[_n]![2];

    // Calcular Límites X̄
    double uclX = xBarBar + (a2 * rBar);
    double lclX = xBarBar - (a2 * rBar);
    
    // Calcular Límites R
    double uclR = d4 * rBar;
    double lclR = d3 * rBar;

    // Evaluar estado de control
    for (double m in _medias) {
      if (m > uclX || m < lclX) _fueraDeControlX = true;
    }
    for (double r in _rangos) {
      if (r > uclR || r < lclR) _fueraDeControlR = true;
    }

    setState(() {
      _xBarBar = xBarBar; _clX = xBarBar; _uclX = uclX; _lclX = lclX;
      _rBar = rBar;       _clR = rBar;    _uclR = uclR; _lclR = lclR;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF607D8B); // Blue Grey
    
    List<FlSpot> spots = [];
    double maxY = 0, minY = 0, ucl = 0, lcl = 0, cl = 0;
    bool fueraDeControl = false;

    if (_xBarBar != null) {
      if (_tipoGrafico == 'Gráfico X̄ (Medias)') {
        for (int i = 0; i < _medias.length; i++) {
          spots.add(FlSpot(i.toDouble(), _medias[i]));
        }
        ucl = _uclX!; lcl = _lclX!; cl = _clX!;
        maxY = max(_medias.reduce(max), ucl) * 1.05;
        minY = min(_medias.reduce(min), lcl) * 0.95;
        fueraDeControl = _fueraDeControlX;
      } else {
        for (int i = 0; i < _rangos.length; i++) {
          spots.add(FlSpot(i.toDouble(), _rangos[i]));
        }
        ucl = _uclR!; lcl = _lclR!; cl = _clR!;
        maxY = max(_rangos.reduce(max), ucl) * 1.1;
        minY = min(_rangos.reduce(min), lcl) * 0.9;
        if (minY < 0) minY = 0; // El rango no puede ser negativo
        fueraDeControl = _fueraDeControlR;
      }
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFECEFF1),
      appBar: AppBar(title: const Text('Control de Calidad (X̄, R)', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: primaryColor, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subgrupos (Muestras)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                TextButton.icon(
                  onPressed: _addMuestra, icon: const Icon(Icons.add_circle), label: const Text('Agregar Muestra'),
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                )
              ],
            ),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _muestrasControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _muestrasControllers[index],
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Muestra ${index + 1}',
                            hintText: 'Ej: 10.1, 9.8, 10.2, 10.0',
                            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                            labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                            filled: true, fillColor: isDark ? const Color(0xFF152840) : Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                          ),
                        ),
                      ),
                      if (_muestrasControllers.length > 2)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _removeMuestra(index),
                        )
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _calcular, icon: const Icon(Icons.verified_rounded, color: Colors.white), label: const Text('Generar Gráficos de Control', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            if (_xBarBar != null) ...[
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? const Color(0xFF234060) : primaryColor.withValues(alpha: 0.3))),
                child: DropdownButtonFormField<String>(
                  initialValue: _tipoGrafico, isExpanded: true,
                  items: ['Gráfico X̄ (Medias)', 'Gráfico R (Rangos)'].map((i) => DropdownMenuItem(value: i, child: Text(i, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)))).toList(),
                  onChanged: (val) => setState(() { _tipoGrafico = val!; }),
                  decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), border: InputBorder.none),
                  dropdownColor: isDark ? const Color(0xFF1C3350) : Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 2)),
                child: Column(
                  children: [
                    Text('Estado del Proceso ($_tipoGrafico)', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                    const SizedBox(height: 12),
                    Text(
                      fueraDeControl ? 'FUERA DE CONTROL' : 'BAJO CONTROL ESTADÍSTICO', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: fueraDeControl ? Colors.redAccent : Colors.green),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: isDark ? Colors.black26 : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        fueraDeControl 
                            ? '🚨 Alerta: Existen puntos que sobrepasan los límites de control (LCS o LCI). El proceso requiere intervención y revisión de causas asignables.' 
                            : '✅ El proceso se encuentra estable. Toda la variación observada es producto de causas comunes (aleatorias).', 
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, height: 1.4), textAlign: TextAlign.left
                      ),
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatText('LCS', ucl.toStringAsFixed(3), isDark, color: Colors.redAccent),
                        _StatText('Central', cl.toStringAsFixed(3), isDark, color: primaryColor),
                        _StatText('LCI', lcl.toStringAsFixed(3), isDark, color: Colors.redAccent),
                      ],
                    )
                  ]
                )
              ),
              const SizedBox(height: 24),
              
              Text('$_tipoGrafico (n = $_n)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              
              Container(
                height: 300,
                padding: const EdgeInsets.only(top: 30, right: 20, left: 10, bottom: 10),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white12 : Colors.black12)),
                child: LineChart(
                  LineChartData(
                    minX: 0, maxX: (_muestrasControllers.length - 1).toDouble(), minY: minY, maxY: maxY,
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem('Muestra ${spot.x.toInt() + 1}\nValor: ${spot.y.toStringAsFixed(3)}', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                          }).toList();
                        },
                      ),
                    ),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(y: ucl, color: Colors.redAccent, strokeWidth: 2, dashArray: [5, 5], label: HorizontalLineLabel(show: true, alignment: Alignment.topRight, padding: const EdgeInsets.only(right: 5, bottom: 5), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 10), labelResolver: (line) => 'LCS')),
                        HorizontalLine(y: cl, color: primaryColor, strokeWidth: 2, label: HorizontalLineLabel(show: true, alignment: Alignment.topRight, padding: const EdgeInsets.only(right: 5, bottom: 5), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 10), labelResolver: (line) => 'CL')),
                        HorizontalLine(y: lcl, color: Colors.redAccent, strokeWidth: 2, dashArray: [5, 5], label: HorizontalLineLabel(show: true, alignment: Alignment.topRight, padding: const EdgeInsets.only(right: 5, top: 5), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 10), labelResolver: (line) => 'LCI')),
                      ],
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 22, getTitlesWidget: (val, meta) => Padding(padding: const EdgeInsets.only(top: 6.0), child: Text((val.toInt() + 1).toString(), style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54))))),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text(val.toStringAsFixed(2), style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54)))),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: false), // Desactivado para que resalten los límites
                    borderData: FlBorderData(show: true, border: Border(left: BorderSide(color: isDark ? Colors.white24 : Colors.black12), bottom: BorderSide(color: isDark ? Colors.white24 : Colors.black12))),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false,
                        color: Colors.blueAccent,
                        barWidth: 2,
                        dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                          bool outOfBounds = spot.y > ucl || spot.y < lcl;
                          return FlDotCirclePainter(radius: 4, color: outOfBounds ? Colors.redAccent : Colors.blueAccent, strokeWidth: 1, strokeColor: Colors.white);
                        }),
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
            heroTag: 'btn_scan_control_calidad', // Tag único
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Le mandamos el tema 'pruebas_hipotesis' a Python
                  builder: (context) => const ScanProblemScreen(tema: 'control_calidad'), 
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
            heroTag: 'btn_asistente_control_calidad',
            onPressed: () => _showAssistant(context, primaryColor),
            backgroundColor: primaryColor, // Rosa/Magenta para combinar con la pantalla
            elevation: 4,
            child: const Icon(Icons.psychology_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showAssistant(BuildContext context, Color color) {
    String contexto = _xBarBar != null 
      ? "Control de Calidad (n=$_n). X-bar-bar=${_xBarBar!.toStringAsFixed(3)}, R-bar=${_rBar!.toStringAsFixed(3)}. Límites X: [${_lclX!.toStringAsFixed(3)}, ${_uclX!.toStringAsFixed(3)}]. Límites R: [${_lclR!.toStringAsFixed(3)}, ${_uclR!.toStringAsFixed(3)}]. Estado: ${_fueraDeControlX || _fueraDeControlR ? 'Fuera de control' : 'Bajo control'}." 
      : "El usuario está en la pantalla de Control de Calidad.";
    
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => _MiniChatAssistantQC(contextoDatos: contexto, colorTema: color));
  }
}

class _StatText extends StatelessWidget {
  final String label, value; final bool isDark; final Color color;
  const _StatText(this.label, this.value, this.isDark, {required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _MiniChatAssistantQC extends StatefulWidget {
  final String contextoDatos; final Color colorTema;
  const _MiniChatAssistantQC({required this.contextoDatos, required this.colorTema});
  @override
  State<_MiniChatAssistantQC> createState() => _MiniChatAssistantQCState();
}

class _MiniChatAssistantQCState extends State<_MiniChatAssistantQC> {
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
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))), child: Row(children: [Icon(Icons.school_rounded, color: widget.colorTema), const SizedBox(width: 8), Text("Tutor IA - Calidad", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))), const Spacer(), IconButton(icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54), onPressed: () => Navigator.pop(context))])),
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: chatProvider.messages.length, itemBuilder: (context, index) {
          final msg = chatProvider.messages[index];
          return Align(alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8), decoration: BoxDecoration(color: msg.isUser ? widget.colorTema : (isDark ? const Color(0xFF234060) : const Color(0xFFECEFF1)), borderRadius: BorderRadius.circular(16).copyWith(bottomRight: msg.isUser ? const Radius.circular(0) : null, bottomLeft: !msg.isUser ? const Radius.circular(0) : null)), child: Text(msg.text, style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A2D4A))))));
        })),
        if (chatProvider.isLoading) Padding(padding: const EdgeInsets.all(8.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: widget.colorTema))),
        Padding(padding: const EdgeInsets.all(12.0), child: Row(children: [
          Expanded(child: TextField(controller: _controller, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(hintText: "¿Dudas sobre LCS, LCI o causas?", hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13), filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF5F5F5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
          const SizedBox(width: 8), CircleAvatar(backgroundColor: widget.colorTema, child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), onPressed: () { if (_controller.text.isNotEmpty) { chatProvider.sendMessage(_controller.text, currentEquation: widget.contextoDatos); _controller.clear(); } })),
        ])),
      ]),
    );
  }
}