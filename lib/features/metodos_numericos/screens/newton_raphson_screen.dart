import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class NewtonRaphsonScreen extends StatefulWidget {
  const NewtonRaphsonScreen({super.key});

  @override
  State<NewtonRaphsonScreen> createState() => _NewtonRaphsonScreenState();
}

class _NewtonRaphsonScreenState extends State<NewtonRaphsonScreen> {
  final _funcionController = TextEditingController(text: 'x^2 - 4');
  final _derivadaController = TextEditingController(text: '2*x');
  final _x0Controller = TextEditingController(text: '3');
  final _tolController = TextEditingController(text: '0.001');

  final List<Map<String, dynamic>> _iteraciones = [];
  String _resultadoFinal = '';
  String _mensajeError = '';

  @override
  void dispose() {
    _funcionController.dispose();
    _derivadaController.dispose();
    _x0Controller.dispose();
    _tolController.dispose();
    super.dispose();
  }

  void _calcularNewton() {
    setState(() {
      _iteraciones.clear();
      _resultadoFinal = '';
      _mensajeError = '';
    });

    String funcString = _funcionController.text;
    String derString = _derivadaController.text;
    double x0 = double.tryParse(_x0Controller.text) ?? 0;
    double tol = double.tryParse(_tolController.text) ?? 0.001;

    try {
      ShuntingYardParser p = ShuntingYardParser();
      Expression expF = p.parse(funcString);
      Expression expD = p.parse(derString);
      ContextModel cm = ContextModel();

      double evaluar(Expression exp, double valorX) {
        cm.bindVariable(Variable('x'), Number(valorX));
        return exp.evaluate(EvaluationType.REAL, cm);
      }

      double error = double.infinity;
      double xi = x0;
      int iteracion = 1;
      int maxIter = 50;

      while (error > tol && iteracion <= maxIter) {
        double fxi = evaluar(expF, xi);
        double dxi = evaluar(expD, xi);

        if (dxi == 0) {
          setState(() => _mensajeError = 'Error: La derivada f\'(x) es cero. División por cero.');
          return;
        }

        double xSiguiente = xi - (fxi / dxi);

        if (iteracion > 1) {
          error = ((xSiguiente - xi) / xSiguiente).abs() * 100;
        }

        _iteraciones.add({
          'iter': iteracion,
          'xi': xi,
          'fxi': fxi,
          'dxi': dxi,
          'x_next': xSiguiente,
          'error': iteracion == 1 ? '-' : '${error.toStringAsFixed(4)}%',
        });

        if (fxi == 0.0 || error <= tol) {
          xi = xSiguiente;
          break;
        }

        xi = xSiguiente;
        iteracion++;
      }

      setState(() {
        if (iteracion > maxIter) {
          _mensajeError = 'Se alcanzó el límite máximo de iteraciones sin converger.';
        } else {
          _resultadoFinal = 'Raíz aproximada: ${xi.toStringAsFixed(5)}\nEncontrada en ${_iteraciones.length} iteraciones.';
        }
      });
    } catch (e) {
      setState(() => _mensajeError = 'Error al evaluar. Verifica la sintaxis (ej: 2*x).');
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
                      decoration: InputDecoration(labelText: 'Función f(x)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _derivadaController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(labelText: 'Derivada f\'(x)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(controller: _x0Controller, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'Valor inicial x0', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(controller: _tolController, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'Error (%)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _calcularNewton,
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Calcular Raíz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_mensajeError.isNotEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent)), child: Text(_mensajeError, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
            if (_resultadoFinal.isNotEmpty) Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)), child: Text(_resultadoFinal, style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            const SizedBox(height: 16),
            if (_iteraciones.isNotEmpty) ...[
              Text('Tabla de Iteraciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7))),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(primaryColor.withValues(alpha: 0.1)),
                        columns: const [
                          DataColumn(label: Text('i', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('x_i', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('f(x_i)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('f\'(x_i)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('x_i+1', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5B9BD5)))),
                          DataColumn(label: Text('Error %', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _iteraciones.map((iter) {
                          return DataRow(cells: [
                            DataCell(Text(iter['iter'].toString())),
                            DataCell(Text(iter['xi'].toStringAsFixed(4))),
                            DataCell(Text(iter['fxi'].toStringAsFixed(4))),
                            DataCell(Text(iter['dxi'].toStringAsFixed(4))),
                            DataCell(Text(iter['x_next'].toStringAsFixed(4), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5B9BD5)))),
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