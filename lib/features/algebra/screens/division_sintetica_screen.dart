import 'package:flutter/material.dart';
import '../../estadistica/screens/scan_problem_screen.dart';

class DivisionSinteticaScreen extends StatefulWidget {
  const DivisionSinteticaScreen({super.key});

  @override
  State<DivisionSinteticaScreen> createState() => _DivisionSinteticaScreenState();
}

class _DivisionSinteticaScreenState extends State<DivisionSinteticaScreen> {
  final _coeficientesController = TextEditingController(text: '1, -3, 2, 5');
  final _raizController = TextEditingController(text: '2');

  final List<double> _filaSuperior = [];
  List<double> _filaMedia = [];
  List<double> _filaInferior = [];
  String _resultadoCociente = '';
  String _resultadoResiduo = '';
  String _error = '';

  @override
  void dispose() {
    _coeficientesController.dispose();
    _raizController.dispose();
    super.dispose();
  }

  void _calcularRuffini() {
    setState(() {
      _error = '';
      _filaSuperior.clear();
      _filaMedia.clear();
      _filaInferior.clear();
      _resultadoCociente = '';
      _resultadoResiduo = '';
    });

    try {
      // Leer coeficientes
      List<String> partes = _coeficientesController.text.split(',');
      for (var p in partes) {
        double? val = double.tryParse(p.trim());
        if (val != null) _filaSuperior.add(val);
      }

      double raiz = double.tryParse(_raizController.text.trim()) ?? 0;

      if (_filaSuperior.isEmpty) {
        setState(() => _error = 'Ingresa al menos un coeficiente válido.');
        return;
      }

      _filaMedia = List.filled(_filaSuperior.length, 0.0);
      _filaInferior = List.filled(_filaSuperior.length, 0.0);

      // Primer elemento baja directo
      _filaInferior[0] = _filaSuperior[0];

      // Calcular Ruffini
      for (int i = 1; i < _filaSuperior.length; i++) {
        _filaMedia[i] = _filaInferior[i - 1] * raiz;
        _filaInferior[i] = _filaSuperior[i] + _filaMedia[i];
      }

      // Formatear resultados
      double residuo = _filaInferior.last;
      _resultadoResiduo = 'Residuo: ${residuo.toStringAsFixed(2).replaceAll('.00', '')}';

      List<String> terminos = [];
      int gradoInicial = _filaInferior.length - 2;
      for (int i = 0; i < _filaInferior.length - 1; i++) {
        double coef = _filaInferior[i];
        if (coef != 0) {
          int gradoActual = gradoInicial - i;
          String termino = coef.toStringAsFixed(2).replaceAll('.00', '');
          if (gradoActual > 1) {
            terminos.add('${termino}x^$gradoActual');
          } else if (gradoActual == 1) {
            terminos.add('${termino}x');
          } else {
            terminos.add(termino);
          }
        }
      }
      _resultadoCociente = 'Cociente Q(x) = ${terminos.join(' + ').replaceAll('+ -', '- ')}';
      if (terminos.isEmpty) _resultadoCociente = 'Cociente Q(x) = 0';

    } catch (e) {
      setState(() => _error = 'Verifica el formato. Ej: 1, -3, 2, 5');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF009688);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(title: const Text('División Sintética'), backgroundColor: primaryColor, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Evalúa polinomios dividiendo entre (x - c)", style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 16),
            Card(
              color: isDark ? const Color(0xFF1C3350) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _coeficientesController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(labelText: 'Coeficientes (separados por coma)', hintText: 'Ej: 1, -3, 2, 5', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _raizController, keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(labelText: 'Raíz a evaluar (c)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _calcularRuffini, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Calcular', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
            
            if (_error.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_error, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),

            if (_filaSuperior.isNotEmpty) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor.withValues(alpha: 0.3))),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fila Superior
                      Row(
                        children: [
                          SizedBox(width: 50, child: Text(' ', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor))),
                          Container(width: 2, height: 20, color: primaryColor),
                          ..._filaSuperior.map((v) => SizedBox(width: 60, child: Text(v.toStringAsFixed(1).replaceAll('.0', ''), textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)))),
                        ],
                      ),
                      // Fila Media
                      Row(
                        children: [
                          SizedBox(width: 50, child: Text(_raizController.text, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor))),
                          Container(width: 2, height: 20, color: primaryColor),
                          ..._filaMedia.map((v) => SizedBox(width: 60, child: Text(v == 0 && _filaMedia.indexOf(v) == 0 ? '' : v.toStringAsFixed(1).replaceAll('.0', ''), textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)))),
                        ],
                      ),
                      Container(height: 2, width: 50 + 2 + (_filaSuperior.length * 60).toDouble(), color: primaryColor),
                      // Fila Inferior
                      Row(
                        children: [
                          const SizedBox(width: 50),
                          Container(width: 2, height: 20, color: Colors.transparent),
                          ..._filaInferior.map((v) {
                            bool isLast = _filaInferior.last == v;
                            return SizedBox(
                              width: 60,
                              child: Text(v.toStringAsFixed(1).replaceAll('.0', ''), textAlign: TextAlign.center, style: TextStyle(color: isLast ? Colors.redAccent : (isDark ? Colors.white : Colors.black87), fontWeight: FontWeight.bold)),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_resultadoCociente, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 8),
                    Text(_resultadoResiduo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btn_scan_division_sintetica', // Etiqueta única
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScanProblemScreen(tema: 'tabulador'), 
            ),
          );
        },
        backgroundColor: const Color(0xFF5B9BD5),
        icon: const Icon(Icons.document_scanner, color: Colors.white),
        label: const Text('Escanear Función', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}