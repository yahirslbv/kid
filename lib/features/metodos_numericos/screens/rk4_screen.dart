import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class RungeKuttaScreen extends StatefulWidget {
  const RungeKuttaScreen({super.key});

  @override
  State<RungeKuttaScreen> createState() => _RungeKuttaScreenState();
}

class _RungeKuttaScreenState extends State<RungeKuttaScreen> {
  final _funcionController = TextEditingController(text: 'x - y');
  final _x0Controller = TextEditingController(text: '0');
  final _y0Controller = TextEditingController(text: '2');
  final _xfController = TextEditingController(text: '1'); 
  final _hController = TextEditingController(text: '0.25'); 

  final List<Map<String, dynamic>> _tabla = [];
  String _resultadoFinal = '';
  String _mensajeError = '';

  @override
  void dispose() {
    _funcionController.dispose();
    _x0Controller.dispose();
    _y0Controller.dispose();
    _xfController.dispose();
    _hController.dispose();
    super.dispose();
  }

  void _calcularRK4() {
    setState(() { _tabla.clear(); _resultadoFinal = ''; _mensajeError = ''; });

    String funcString = _funcionController.text;
    double x0 = double.tryParse(_x0Controller.text) ?? 0;
    double y0 = double.tryParse(_y0Controller.text) ?? 0;
    double xf = double.tryParse(_xfController.text) ?? 0;
    double h = double.tryParse(_hController.text) ?? 0.1;

    if (h <= 0) {
      setState(() => _mensajeError = 'El tamaño de paso (h) debe ser mayor a 0.');
      return;
    }

    int n = ((xf - x0) / h).round();
    if (n <= 0 || n > 1000) {
      setState(() => _mensajeError = 'Verifica los valores. El número de pasos debe ser entre 1 y 1000.');
      return;
    }

    try {
      ShuntingYardParser p = ShuntingYardParser();
      Expression exp = p.parse(funcString);
      ContextModel cm = ContextModel();

      double evaluar(double valX, double valY) {
        cm.bindVariable(Variable('x'), Number(valX));
        cm.bindVariable(Variable('y'), Number(valY));
        return exp.evaluate(EvaluationType.REAL, cm);
      }

      double x = x0;
      double y = y0;

      for (int i = 0; i <= n; i++) {
        if (i == n) {
          _tabla.add({'i': i, 'x': x, 'y': y, 'k1': '-', 'k2': '-', 'k3': '-', 'k4': '-'});
          break;
        }
        
        double k1 = evaluar(x, y);
        double k2 = evaluar(x + h/2, y + (h/2) * k1);
        double k3 = evaluar(x + h/2, y + (h/2) * k2);
        double k4 = evaluar(x + h, y + h * k3);
        
        double yNext = y + (h/6) * (k1 + 2*k2 + 2*k3 + k4);
        
        _tabla.add({'i': i, 'x': x, 'y': y, 'k1': k1, 'k2': k2, 'k3': k3, 'k4': k4});
        
        x = x + h;
        y = yNext;
      }

      setState(() => _resultadoFinal = 'y(${xf.toStringAsFixed(2)}) ≈ ${y.toStringAsFixed(6)}');
    } catch (e) {
      setState(() => _mensajeError = 'Error en la función. Usa variables x e y (ej: 2*x + y).');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFE91E63);

    return Padding(
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
                  TextField(controller: _funcionController, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'Función f(x, y) = dy/dx', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _x0Controller, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'x0 (Inicial)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: _y0Controller, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'y0 (Inicial)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _xfController, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'x a evaluar (Xf)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: _hController, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'Paso (h)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _calcularRK4, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Calcular RK4', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          if (_mensajeError.isNotEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent)), child: Text(_mensajeError, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
          if (_resultadoFinal.isNotEmpty) Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor)), child: Center(child: Text(_resultadoFinal, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)))),
          
          if (_tabla.isNotEmpty) ...[
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7))),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(primaryColor.withValues(alpha: 0.1)),
                      columns: const [
                        DataColumn(label: Text('i', style: TextStyle(fontWeight: FontWeight.bold))), 
                        DataColumn(label: Text('x_i', style: TextStyle(fontWeight: FontWeight.bold))), 
                        DataColumn(label: Text('y_i', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE91E63)))), 
                        DataColumn(label: Text('k1', style: TextStyle(fontWeight: FontWeight.bold))), 
                        DataColumn(label: Text('k2', style: TextStyle(fontWeight: FontWeight.bold))), 
                        DataColumn(label: Text('k3', style: TextStyle(fontWeight: FontWeight.bold))), 
                        DataColumn(label: Text('k4', style: TextStyle(fontWeight: FontWeight.bold)))
                      ],
                      rows: _tabla.map((row) => DataRow(cells: [
                        DataCell(Text(row['i'].toString())), 
                        DataCell(Text(row['x'] is String ? row['x'] : (row['x'] as double).toStringAsFixed(4))), 
                        DataCell(Text(row['y'] is String ? row['y'] : (row['y'] as double).toStringAsFixed(6), style: const TextStyle(fontWeight: FontWeight.bold))), 
                        DataCell(Text(row['k1'] is String ? row['k1'] : (row['k1'] as double).toStringAsFixed(4))), 
                        DataCell(Text(row['k2'] is String ? row['k2'] : (row['k2'] as double).toStringAsFixed(4))), 
                        DataCell(Text(row['k3'] is String ? row['k3'] : (row['k3'] as double).toStringAsFixed(4))), 
                        DataCell(Text(row['k4'] is String ? row['k4'] : (row['k4'] as double).toStringAsFixed(4)))
                      ])).toList(),
                    ),
                  ),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}