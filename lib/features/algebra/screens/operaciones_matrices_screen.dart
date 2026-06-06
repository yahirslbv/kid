import 'package:flutter/material.dart';
import '../../estadistica/screens/scan_problem_screen.dart';
class OperacionesMatricesScreen extends StatefulWidget {
  const OperacionesMatricesScreen({super.key});

  @override
  State<OperacionesMatricesScreen> createState() => _OperacionesMatricesScreenState();
}

class _OperacionesMatricesScreenState extends State<OperacionesMatricesScreen> {
  int _dimension = 2; // Inicia en 2x2
  
  late List<List<TextEditingController>> _matrizA;
  late List<List<TextEditingController>> _matrizB;
  List<List<double>> _matrizResultado = [];
  String _operacionActual = '';

  @override
  void initState() {
    super.initState();
    _inicializarMatrices();
  }

  void _inicializarMatrices() {
    _matrizA = List.generate(_dimension, (i) => List.generate(_dimension, (j) => TextEditingController(text: '0')));
    _matrizB = List.generate(_dimension, (i) => List.generate(_dimension, (j) => TextEditingController(text: '0')));
    _matrizResultado = [];
    _operacionActual = '';
  }

  @override
  void dispose() {
    for (var fila in _matrizA) { for (var c in fila) { c.dispose(); } }
    for (var fila in _matrizB) { for (var c in fila) { c.dispose(); } }
    super.dispose();
  }

  void _cambiarDimension(int dim) {
    setState(() {
      _dimension = dim;
      _inicializarMatrices();
    });
  }

  double _getValor(TextEditingController controller) {
    return double.tryParse(controller.text) ?? 0.0;
  }

  void _calcular(String operacion) {
    List<List<double>> res = List.generate(_dimension, (i) => List.filled(_dimension, 0.0));
    
    for (int i = 0; i < _dimension; i++) {
      for (int j = 0; j < _dimension; j++) {
        if (operacion == 'Suma') {
          res[i][j] = _getValor(_matrizA[i][j]) + _getValor(_matrizB[i][j]);
        } else if (operacion == 'Resta') {
          res[i][j] = _getValor(_matrizA[i][j]) - _getValor(_matrizB[i][j]);
        } else if (operacion == 'Multiplicacion') {
          double suma = 0;
          for (int k = 0; k < _dimension; k++) {
            suma += _getValor(_matrizA[i][k]) * _getValor(_matrizB[k][j]);
          }
          res[i][j] = suma;
        }
      }
    }

    setState(() {
      _matrizResultado = res;
      _operacionActual = operacion == 'Suma' ? 'A + B =' : (operacion == 'Resta' ? 'A - B =' : 'A × B =');
    });
  }

  Widget _buildMatrizInput(String titulo, List<List<TextEditingController>> matriz, bool isDark) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C3350) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF009688).withValues(alpha: 0.3)),
          ),
          child: Column(
            children: List.generate(_dimension, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_dimension, (j) {
                  return Container(
                    width: 50,
                    margin: const EdgeInsets.all(4),
                    child: TextField(
                      controller: matriz[i][j],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF009688);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(title: const Text('Operaciones con Matrices'), backgroundColor: primaryColor, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Selector de dimensión
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Tamaño: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Radio<int>(value: 2, groupValue: _dimension, activeColor: primaryColor, onChanged: (val) => _cambiarDimension(val!)), const Text("2x2"),
                Radio<int>(value: 3, groupValue: _dimension, activeColor: primaryColor, onChanged: (val) => _cambiarDimension(val!)), const Text("3x3"),
              ],
            ),
            const SizedBox(height: 16),
            
            // Entrada de Matrices
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMatrizInput('Matriz A', _matrizA, isDark),
                  const SizedBox(width: 10),
                  const Text(' Y ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  _buildMatrizInput('Matriz B', _matrizB, isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Botones de Operación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => _calcular('Suma'), style: ElevatedButton.styleFrom(backgroundColor: primaryColor), child: const Text('+ Sumar', style: TextStyle(color: Colors.white))),
                ElevatedButton(onPressed: () => _calcular('Resta'), style: ElevatedButton.styleFrom(backgroundColor: primaryColor), child: const Text('- Restar', style: TextStyle(color: Colors.white))),
                ElevatedButton(onPressed: () => _calcular('Multiplicacion'), style: ElevatedButton.styleFrom(backgroundColor: primaryColor), child: const Text('× Multiplicar', style: TextStyle(color: Colors.white))),
              ],
            ),
            
            // Resultado
            if (_matrizResultado.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(_operacionActual, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor, width: 2)),
                child: Column(
                  children: List.generate(_dimension, (i) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_dimension, (j) {
                        return Container(
                          width: 60,
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          child: Text(_matrizResultado[i][j].toStringAsFixed(1).replaceAll('.0', ''), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        );
                      }),
                    );
                  }),
                ),
              )
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btn_scan_operaciones_matrices', // Etiqueta única
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