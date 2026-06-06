import 'dart:math';
import 'package:flutter/material.dart';
import '../../../shared/app_imports.dart';

class AnovaScreen extends StatefulWidget {
  const AnovaScreen({super.key});

  @override
  State<AnovaScreen> createState() => _AnovaScreenState();
}

class _AnovaScreenState extends State<AnovaScreen> {
  // Lista dinámica de controladores para cada grupo/tratamiento
  final List<TextEditingController> _groupControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(), // Empezamos con 3 grupos por defecto
  ];

  String _nivelSignificancia = '0.05';

  // Variables de resultados
  double? _ssTr, _ssE, _ssT; // Sumas de Cuadrados
  int? _dfTr, _dfE, _dfT;    // Grados de Libertad
  double? _msTr, _msE;       // Cuadrados Medios
  double? _fStat, _pValue;   // Estadístico y P-Value
  bool? _rechazarH0;
  List<Map<String, dynamic>> _resumenGrupos = [];

  @override
  void dispose() {
    for (var controller in _groupControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  void _addGrupo() {
    setState(() {
      _groupControllers.add(TextEditingController());
    });
  }

  void _removeGrupo(int index) {
    if (_groupControllers.length > 2) {
      setState(() {
        _groupControllers[index].dispose();
        _groupControllers.removeAt(index);
      });
    } else {
      _mostrarError('El ANOVA requiere al menos 2 grupos para comparar.');
    }
  }

  // CDF Normal (Para aproximar F)
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

  // CDF Distribución F (Aproximación de Paulson)
  double _fCDF(double f, int df1, int df2) {
    if (f <= 0) return 0.0;
    double z = ((1.0 - 2.0 / (9.0 * df2)) * pow(f, 1.0 / 3.0) - (1.0 - 2.0 / (9.0 * df1))) /
               sqrt((2.0 / (9.0 * df2)) * pow(f, 2.0 / 3.0) + (2.0 / (9.0 * df1)));
    return _normalCDF(z);
  }

  void _calcularANOVA() {
    setState(() {
      _fStat = null; _pValue = null; _resumenGrupos = [];
    });

    List<List<double>> grupos = [];
    int N = 0; // N total
    double sumaTotal = 0;

    for (int i = 0; i < _groupControllers.length; i++) {
      String text = _groupControllers[i].text;
      if (text.trim().isEmpty) continue; // Ignorar grupos vacíos

      List<double> datos = text.split(RegExp(r'[,\s]+'))
          .map((s) => double.tryParse(s.replaceAll(',', '.')))
          .where((n) => n != null).cast<double>().toList();

      if (datos.isNotEmpty) {
        grupos.add(datos);
        N += datos.length;
        sumaTotal += datos.reduce((a, b) => a + b);
      }
    }

    int k = grupos.length; // Número de tratamientos

    if (k < 2) {
      _mostrarError('Error: Debes ingresar datos válidos en al menos 2 grupos.');
      return;
    }
    if (N <= k) {
      _mostrarError('Error: No hay suficientes datos para calcular la varianza (N debe ser > k).');
      return;
    }

    double mediaGlobal = sumaTotal / N;
    double ssTr = 0; // Suma de Cuadrados de Tratamientos
    double ssT = 0;  // Suma de Cuadrados Total

    List<Map<String, dynamic>> resumen = [];

    // Cálculo iterativo
    for (int i = 0; i < k; i++) {
      int ni = grupos[i].length;
      double sumaGrupo = grupos[i].reduce((a, b) => a + b);
      double mediaGrupo = sumaGrupo / ni;
      
      // Para resumen
      double varGrupo = 0;
      if (ni > 1) {
        double ssGrupo = grupos[i].fold(0.0, (sum, val) => sum + pow(val - mediaGrupo, 2));
        varGrupo = ssGrupo / (ni - 1);
      }
      
      resumen.add({
        'nombre': 'Grupo ${i + 1}',
        'n': ni,
        'media': mediaGrupo,
        'varianza': varGrupo
      });

      ssTr += ni * pow(mediaGrupo - mediaGlobal, 2);

      for (double val in grupos[i]) {
        ssT += pow(val - mediaGlobal, 2);
      }
    }

    double ssE = ssT - ssTr; // Suma de Cuadrados del Error
    if (ssE < 0) ssE = 0; // Por precisión de flotantes

    int dfTr = k - 1;
    int dfE = N - k;
    int dfT = N - 1;

    double msTr = ssTr / dfTr;
    double msE = ssE / dfE;

    if (msE == 0) {
      _mostrarError('Error: La varianza dentro de los grupos es 0. F indefinida.');
      return;
    }

    double fCalc = msTr / msE;
    double pVal = 1.0 - _fCDF(fCalc, dfTr, dfE); // Cola derecha
    double alpha = double.parse(_nivelSignificancia);

    setState(() {
      _ssTr = ssTr; _ssE = ssE; _ssT = ssT;
      _dfTr = dfTr; _dfE = dfE; _dfT = dfT;
      _msTr = msTr; _msE = msE;
      _fStat = fCalc;
      _pValue = pVal;
      _rechazarH0 = pVal < alpha;
      _resumenGrupos = resumen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF3F51B5); // Indigo para ANOVA
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFE8EAF6),
      appBar: AppBar(title: const Text('Análisis de Varianza (ANOVA)', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: primaryColor, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? const Color(0xFF234060) : primaryColor.withValues(alpha: 0.3))),
              child: DropdownButtonFormField<String>(
                initialValue: _nivelSignificancia, isExpanded: true,
                items: ['0.01', '0.05', '0.10'].map((i) => DropdownMenuItem(value: i, child: Text(i, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)))).toList(),
                onChanged: (val) => setState(() { _nivelSignificancia = val!; _fStat = null; }),
                decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), labelText: 'Significancia (α)', labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54), border: InputBorder.none),
                dropdownColor: isDark ? const Color(0xFF1C3350) : Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tratamientos (Grupos)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                TextButton.icon(
                  onPressed: _addGrupo, icon: const Icon(Icons.add_circle), label: const Text('Agregar Grupo'),
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                )
              ],
            ),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _groupControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _groupControllers[index],
                          maxLines: 2,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Datos Grupo ${index + 1}',
                            hintText: 'Ej: 12.5, 14, 15.2',
                            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                            labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                            filled: true, fillColor: isDark ? const Color(0xFF152840) : Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                          ),
                        ),
                      ),
                      if (_groupControllers.length > 2)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _removeGrupo(index),
                        )
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _calcularANOVA, icon: const Icon(Icons.table_chart_rounded, color: Colors.white), label: const Text('Generar Tabla ANOVA', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            if (_fStat != null) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 2)),
                child: Column(
                  children: [
                    Text('Conclusión Técnica (α = $_nivelSignificancia)', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                    const SizedBox(height: 12),
                    Text(
                      _rechazarH0! ? 'SE RECHAZA H₀\n(Las medias NO son iguales)' : 'NO SE RECHAZA H₀\n(Las medias son iguales)', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _rechazarH0! ? Colors.redAccent : Colors.green),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: isDark ? Colors.black26 : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        _rechazarH0! 
                            ? '💡 Interpretación:\nComo el Valor-P (${_pValue!.toStringAsFixed(4)}) es MENOR que α, al menos uno de los grupos tiene un promedio estadísticamente distinto a los demás.' 
                            : '💡 Interpretación:\nComo el Valor-P (${_pValue!.toStringAsFixed(4)}) es MAYOR que α, no hay evidencia para decir que los tratamientos afecten de manera diferente. Toda variación es por el azar.', 
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, height: 1.4), textAlign: TextAlign.left
                      ),
                    ),
                  ]
                )
              ),
              const SizedBox(height: 24),
              
              Text('Tabla ANOVA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              
              // TABLA ANOVA CLÁSICA
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white12 : Colors.black12)),
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: WidgetStateProperty.all(primaryColor.withValues(alpha: 0.1)),
                    columns: const [
                      DataColumn(label: Text('Fuente', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('GL (df)', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('SC (SS)', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('CM (MS)', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('F', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('P-Value', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text('Tratamientos')),
                        DataCell(Text('$_dfTr')),
                        DataCell(Text(_ssTr!.toStringAsFixed(2))),
                        DataCell(Text(_msTr!.toStringAsFixed(2))),
                        DataCell(Text(_fStat!.toStringAsFixed(3), style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor))),
                        DataCell(Text(_pValue!.toStringAsFixed(4), style: TextStyle(fontWeight: FontWeight.bold))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Error')),
                        DataCell(Text('$_dfE')),
                        DataCell(Text(_ssE!.toStringAsFixed(2))),
                        DataCell(Text(_msE!.toStringAsFixed(2))),
                        const DataCell(Text('-')),
                        const DataCell(Text('-')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('$_dfT', style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(_ssT!.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('-')),
                        const DataCell(Text('-')),
                        const DataCell(Text('-')),
                      ]),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              Text('Resumen de Grupos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 12),
              
              ..._resumenGrupos.map((g) => Card(
                color: isDark ? const Color(0xFF1C3350) : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
                child: ListTile(
                  title: Text(g['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('n = ${g['n']}  |  Media: ${g['media'].toStringAsFixed(3)}  |  Var: ${g['varianza'].toStringAsFixed(3)}'),
                ),
              )),
              
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
            heroTag: 'btn_scan_anova', // Tag único
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Le mandamos el tema 'pruebas_hipotesis' a Python
                  builder: (context) => const ScanProblemScreen(tema: 'anova'), 
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
            heroTag: 'btn_asistente_anova',
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
    String contexto = _fStat != null 
      ? "Tabla ANOVA Calculada. F=${_fStat!.toStringAsFixed(4)}, p-value=${_pValue!.toStringAsFixed(4)}. dfTr=$_dfTr, dfE=$_dfE. Decisión: ${_rechazarH0! ? 'Rechazar H0' : 'No Rechazar H0'}." 
      : "El usuario está configurando el ANOVA.";
    
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => _MiniChatAssistantAnova(contextoDatos: contexto, colorTema: color));
  }
}

class _MiniChatAssistantAnova extends StatefulWidget {
  final String contextoDatos; final Color colorTema;
  const _MiniChatAssistantAnova({required this.contextoDatos, required this.colorTema});
  @override
  State<_MiniChatAssistantAnova> createState() => _MiniChatAssistantAnovaState();
}

class _MiniChatAssistantAnovaState extends State<_MiniChatAssistantAnova> {
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
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))), child: Row(children: [Icon(Icons.school_rounded, color: widget.colorTema), const SizedBox(width: 8), Text("Tutor IA - ANOVA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))), const Spacer(), IconButton(icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54), onPressed: () => Navigator.pop(context))])),
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: chatProvider.messages.length, itemBuilder: (context, index) {
          final msg = chatProvider.messages[index];
          return Align(alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8), decoration: BoxDecoration(color: msg.isUser ? widget.colorTema : (isDark ? const Color(0xFF234060) : const Color(0xFFE8EAF6)), borderRadius: BorderRadius.circular(16).copyWith(bottomRight: msg.isUser ? const Radius.circular(0) : null, bottomLeft: !msg.isUser ? const Radius.circular(0) : null)), child: Text(msg.text, style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A2D4A))))));
        })),
        if (chatProvider.isLoading) Padding(padding: const EdgeInsets.all(8.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: widget.colorTema))),
        Padding(padding: const EdgeInsets.all(12.0), child: Row(children: [
          Expanded(child: TextField(controller: _controller, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(hintText: "¿Preguntas sobre la Tabla ANOVA?", hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13), filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF5F5F5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
          const SizedBox(width: 8), CircleAvatar(backgroundColor: widget.colorTema, child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), onPressed: () { if (_controller.text.isNotEmpty) { chatProvider.sendMessage(_controller.text, currentEquation: widget.contextoDatos); _controller.clear(); } })),
        ])),
      ]),
    );
  }
}