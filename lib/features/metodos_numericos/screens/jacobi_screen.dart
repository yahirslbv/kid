import 'package:flutter/material.dart';

class JacobiScreen extends StatefulWidget {
  const JacobiScreen({super.key});

  @override
  State<JacobiScreen> createState() => _JacobiScreenState();
}

class _JacobiScreenState extends State<JacobiScreen> {
  int _n = 3;
  List<List<TextEditingController>> _controllers = [];
  final _tolController = TextEditingController(text: '0.001');
  
  final List<Map<String, dynamic>> _iteraciones = [];
  String _mensajeError = '';
  String _resultadoFinal = '';

  @override
  void initState() {
    super.initState();
    _inicializarMatriz();
  }

  @override
  void dispose() {
    _tolController.dispose();
    super.dispose();
  }

  void _inicializarMatriz() {
    _controllers = List.generate(
      _n, (i) => List.generate(_n + 1, (j) => TextEditingController(text: '')),
    );
    _iteraciones.clear();
    _mensajeError = '';
    _resultadoFinal = '';
  }

  void _cambiarTamano(int? nuevoN) {
    if (nuevoN != null && nuevoN != _n) {
      setState(() {
        _n = nuevoN;
        _inicializarMatriz();
      });
    }
  }

  void _calcularJacobi() {
    setState(() {
      _mensajeError = '';
      _resultadoFinal = '';
      _iteraciones.clear();
    });

    List<List<double>> A = [];
    List<double> b = [];
    double tol = double.tryParse(_tolController.text) ?? 0.001;

    try {
      for (int i = 0; i < _n; i++) {
        List<double> fila = [];
        for (int j = 0; j <= _n; j++) {
          String val = _controllers[i][j].text;
          if (val.isEmpty) val = '0';
          if (j == _n) {
            b.add(double.parse(val));
          } else {
            fila.add(double.parse(val));
          }
        }
        A.add(fila);
      }
    } catch (e) {
      setState(() => _mensajeError = 'Ingresa solo números válidos.');
      return;
    }

    // Verificar ceros en la diagonal
    for (int i = 0; i < _n; i++) {
      if (A[i][i] == 0) {
        setState(() => _mensajeError = 'Error: Cero en la diagonal principal (A[$i][$i]). El método fallará. Intenta reordenar las filas.');
        return;
      }
    }

    List<double> x = List.filled(_n, 0.0); // Valores iniciales
    List<double> xNew = List.filled(_n, 0.0);
    double error = double.infinity;
    int iteracion = 1;
    int maxIter = 100;

    while (error > tol && iteracion <= maxIter) {
      double maxErrorActual = 0;

      for (int i = 0; i < _n; i++) {
        double sum = 0;
        for (int j = 0; j < _n; j++) {
          if (i != j) {
            sum += A[i][j] * x[j];
          }
        }
        xNew[i] = (b[i] - sum) / A[i][i];

        if (xNew[i].isNaN || xNew[i].isInfinite) {
           setState(() => _mensajeError = 'El sistema diverge. La matriz no es diagonalmente dominante.');
           return;
        }

        if (iteracion > 1 && xNew[i] != 0) {
          double err = ((xNew[i] - x[i]) / xNew[i]).abs() * 100;
          if (err > maxErrorActual) maxErrorActual = err;
        }
      }

      error = iteracion == 1 ? 100.0 : maxErrorActual;

      _iteraciones.add({
        'iter': iteracion,
        'x': List<double>.from(xNew), // CORRECCIÓN: Agregar <double>
        'error': iteracion == 1 ? '-' : '${error.toStringAsFixed(4)}%',
      });

      x = List<double>.from(xNew); // CORRECCIÓN: Agregar <double>
      iteracion++;
    }

    setState(() {
      if (iteracion > maxIter) {
        _mensajeError = 'Se alcanzó el límite de iteraciones. El sistema podría no converger.';
      } else {
        _resultadoFinal = 'Sistema convergido en ${_iteraciones.length} iteraciones.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF4CAF50);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Tamaño:', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: primaryColor.withValues(alpha: 0.5))),
                child: DropdownButton<int>(
                  value: _n, underline: const SizedBox(), dropdownColor: isDark ? const Color(0xFF1C3350) : Colors.white,
                  items: const [DropdownMenuItem(value: 2, child: Text('2x2')), DropdownMenuItem(value: 3, child: Text('3x3')), DropdownMenuItem(value: 4, child: Text('4x4'))],
                  onChanged: _cambiarTamano,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _tolController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                  decoration: InputDecoration(labelText: 'Tolerancia %', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7))),
              // CORRECCIÓN: Doble Scroll 
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_n, (i) {
                      return Row(
                        children: List.generate(_n + 1, (j) {
                          bool isResult = j == _n;
                          return Container(
                            width: 55, margin: EdgeInsets.only(right: isResult ? 0 : 8, bottom: 8, left: isResult ? 16 : 0),
                            child: TextField(
                              controller: _controllers[i][j], textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: isResult ? FontWeight.bold : FontWeight.normal),
                              decoration: InputDecoration(filled: true, fillColor: isResult ? primaryColor.withValues(alpha: 0.1) : (isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF)), contentPadding: const EdgeInsets.symmetric(vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), hintText: isResult ? 'b${i + 1}' : 'a${i + 1}${j + 1}', hintStyle: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _calcularJacobi,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Resolver (Jacobi)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 12),
          if (_mensajeError.isNotEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent)), child: Text(_mensajeError, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
          if (_resultadoFinal.isNotEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)), child: Text(_resultadoFinal, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          if (_iteraciones.isNotEmpty) ...[
            const SizedBox(height: 12),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7))),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(primaryColor.withValues(alpha: 0.1)),
                      columns: [
                        const DataColumn(label: Text('k', style: TextStyle(fontWeight: FontWeight.bold))),
                        ...List.generate(_n, (index) {
                          final variables = ['x', 'y', 'z', 'w'];
                          return DataColumn(
                            label: Text(variables[index], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)))
                          );
                        }),
                        const DataColumn(label: Text('Error %', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _iteraciones.map((iter) {
                        return DataRow(cells: [
                          DataCell(Text(iter['iter'].toString())),
                          ...List.generate(_n, (index) => DataCell(Text((iter['x'] as List<double>)[index].toStringAsFixed(4)))),
                          DataCell(Text(iter['error'].toString())),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}