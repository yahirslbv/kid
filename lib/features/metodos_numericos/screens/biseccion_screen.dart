import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class BiseccionScreen extends StatefulWidget {
  const BiseccionScreen({super.key});

  @override
  State<BiseccionScreen> createState() => _BiseccionScreenState();
}

class _BiseccionScreenState extends State<BiseccionScreen> {
  final _funcionController = TextEditingController(text: 'x^2 - 4');
  final _aController = TextEditingController(text: '0');
  final _bController = TextEditingController(text: '3');
  final _tolController = TextEditingController(text: '0.001');

  final List<Map<String, dynamic>> _iteraciones = []; // Agregado el 'final'
  String _resultadoFinal = '';
  String _mensajeError = '';

  @override
  void dispose() {
    _funcionController.dispose();
    _aController.dispose();
    _bController.dispose();
    _tolController.dispose();
    super.dispose();
  }

  // --- LÓGICA MATEMÁTICA: MÉTODO DE BISECCIÓN ---
  void _calcularBiseccion() {
    setState(() {
      _iteraciones.clear();
      _resultadoFinal = '';
      _mensajeError = '';
    });

    String funcString = _funcionController.text;
    double a = double.tryParse(_aController.text) ?? 0;
    double b = double.tryParse(_bController.text) ?? 0;
    double tol = double.tryParse(_tolController.text) ?? 0.001;

    try {
      // Sintaxis moderna del paquete math_expressions
      ShuntingYardParser p = ShuntingYardParser();
      Expression exp = p.parse(funcString);
      ContextModel cm = ContextModel();

      // Función auxiliar para evaluar f(x)
      double evaluarFuncion(double valorX) {
        cm.bindVariable(Variable('x'), Number(valorX));
        return exp.evaluate(EvaluationType.REAL, cm);
      }

      double fa = evaluarFuncion(a);
      double fb = evaluarFuncion(b);

      // Regla de Bisección: f(a) y f(b) deben tener signos opuestos
      if (fa * fb >= 0) {
        setState(() {
          _mensajeError = 'Error: f(a) y f(b) deben tener signos opuestos. Intenta con otro intervalo.';
        });
        return;
      }

      double error = double.infinity;
      double cAnterior = a;
      int iteracion = 1;
      int maxIter = 100; // Límite de seguridad

      while (error > tol && iteracion <= maxIter) {
        double c = (a + b) / 2;
        double fc = evaluarFuncion(c);

        if (iteracion > 1) {
          error = ((c - cAnterior) / c).abs() * 100; // Error porcentual relativo
        }

        _iteraciones.add({
          'iter': iteracion,
          'a': a,
          'b': b,
          'c': c,
          'fc': fc,
          'error': iteracion == 1 ? '-' : '${error.toStringAsFixed(4)}%',
        });

        // Condición de parada exacta
        if (fc == 0.0) {
          error = 0.0;
          break;
        }

        // Decidir de qué lado está la raíz
        if (fa * fc < 0) {
          b = c;
          fb = fc;
        } else {
          a = c;
          fa = fc;
        }

        cAnterior = c;
        iteracion++;
      }

      setState(() {
        if (iteracion > maxIter) {
          _mensajeError = 'Se alcanzó el límite máximo de iteraciones sin converger.';
        } else {
          _resultadoFinal = 'Raíz aproximada: ${cAnterior.toStringAsFixed(5)}\nEncontrada en ${_iteraciones.length} iteraciones.';
        }
      });
    } catch (e) {
      setState(() {
        _mensajeError = 'Error al evaluar la función. Verifica la sintaxis (ej: x^2 + 3*x - 4).';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF5B9BD5);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- CARTA DE ENTRADA DE DATOS ---
            Card(
              color: isDark ? const Color(0xFF1C3350) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _funcionController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Función f(x)',
                        hintText: 'Ej: x^3 - x - 2',
                        prefixIcon: const Icon(Icons.functions, color: Color(0xFF5B9BD5)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _aController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Intervalo [ a ]',
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _bController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Intervalo [ b ]',
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tolController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Tolerancia de Error (%)',
                        hintText: 'Ej: 0.01',
                        prefixIcon: const Icon(Icons.track_changes, color: Color(0xFF5B9BD5)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _calcularBiseccion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Calcular Raíz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- MOSTRAR ERRORES O RESULTADOS GLOBALES ---
            if (_mensajeError.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1), 
                  borderRadius: BorderRadius.circular(12), 
                  border: Border.all(color: Colors.redAccent)
                ),
                child: Text(_mensajeError, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            
            if (_resultadoFinal.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1), 
                  borderRadius: BorderRadius.circular(12), 
                  border: Border.all(color: Colors.green)
                ),
                child: Text(_resultadoFinal, style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),

            const SizedBox(height: 16),

            // --- TABLA DE ITERACIONES ---
            if (_iteraciones.isNotEmpty) ...[
              Text('Tabla de Iteraciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C3350) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(primaryColor.withValues(alpha: 0.1)),
                        columns: const [
                          DataColumn(label: Text('i', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('a', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('b', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('c (raíz)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5B9BD5)))),
                          DataColumn(label: Text('f(c)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Error %', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _iteraciones.map((iter) {
                          return DataRow(cells: [
                            DataCell(Text(iter['iter'].toString())),
                            DataCell(Text(iter['a'].toStringAsFixed(4))),
                            DataCell(Text(iter['b'].toStringAsFixed(4))),
                            DataCell(Text(iter['c'].toStringAsFixed(4), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5B9BD5)))),
                            DataCell(Text(iter['fc'].toStringAsFixed(4))),
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
      ),
    );
  }
}