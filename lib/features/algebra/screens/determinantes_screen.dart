import 'package:flutter/material.dart';
import '../../estadistica/screens/scan_problem_screen.dart';
class DeterminantesScreen extends StatefulWidget {
  const DeterminantesScreen({super.key});

  @override
  State<DeterminantesScreen> createState() => _DeterminantesScreenState();
}

class _DeterminantesScreenState extends State<DeterminantesScreen> {
  int _dimension = 3; // Inicia en 3x3 para ser más útil
  late List<List<TextEditingController>> _matriz;
  String _resultado = '';

  @override
  void initState() {
    super.initState();
    _inicializarMatriz();
  }

  void _inicializarMatriz() {
    _matriz = List.generate(_dimension, (i) => List.generate(_dimension, (j) => TextEditingController(text: '0')));
    _resultado = '';
  }

  @override
  void dispose() {
    for (var fila in _matriz) { for (var c in fila) { c.dispose(); } }
    super.dispose();
  }

  void _cambiarDimension(int dim) {
    setState(() { _dimension = dim; _inicializarMatriz(); });
  }

  double _getValor(int i, int j) {
    return double.tryParse(_matriz[i][j].text) ?? 0.0;
  }

  void _calcularDeterminante() {
    double det = 0;
    
    if (_dimension == 2) {
      det = (_getValor(0, 0) * _getValor(1, 1)) - (_getValor(0, 1) * _getValor(1, 0));
    } else if (_dimension == 3) {
      // Regla de Sarrus
      double pos1 = _getValor(0,0) * _getValor(1,1) * _getValor(2,2);
      double pos2 = _getValor(0,1) * _getValor(1,2) * _getValor(2,0);
      double pos3 = _getValor(0,2) * _getValor(1,0) * _getValor(2,1);
      
      double neg1 = _getValor(0,2) * _getValor(1,1) * _getValor(2,0);
      double neg2 = _getValor(0,0) * _getValor(1,2) * _getValor(2,1);
      double neg3 = _getValor(0,1) * _getValor(1,0) * _getValor(2,2);
      
      det = (pos1 + pos2 + pos3) - (neg1 + neg2 + neg3);
    }

    setState(() {
      _resultado = det.toStringAsFixed(2).replaceAll('.00', '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF009688);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(title: const Text('Cálculo de Determinantes'), backgroundColor: primaryColor, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Tamaño de Matriz: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Radio<int>(value: 2, groupValue: _dimension, activeColor: primaryColor, onChanged: (val) => _cambiarDimension(val!)), const Text("2x2"),
                  Radio<int>(value: 3, groupValue: _dimension, activeColor: primaryColor, onChanged: (val) => _cambiarDimension(val!)), const Text("3x3"),
                ],
              ),
              const SizedBox(height: 24),
              
              Text('Ingrese los valores:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C3350) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                ),
                child: Column(
                  children: List.generate(_dimension, (i) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_dimension, (j) {
                        return Container(
                          width: 60,
                          margin: const EdgeInsets.all(6),
                          child: TextField(
                            controller: _matriz[i][j],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _calcularDeterminante,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(200, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Calcular |A|', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              
              if (_resultado.isNotEmpty) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor, width: 2)),
                  child: Column(
                    children: [
                      const Text('Determinante', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('|A| = $_resultado', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                )
              ]
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btn_scan_determinantes', // Etiqueta única
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