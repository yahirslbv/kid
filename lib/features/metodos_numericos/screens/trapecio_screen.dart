import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class TrapecioScreen extends StatefulWidget {
  const TrapecioScreen({super.key});

  @override
  State<TrapecioScreen> createState() => _TrapecioScreenState();
}

class _TrapecioScreenState extends State<TrapecioScreen> {
  final _funcionController = TextEditingController(text: 'x^2');
  final _aController = TextEditingController(text: '0');
  final _bController = TextEditingController(text: '2');
  final _nController = TextEditingController(text: '4');

  final List<Map<String, dynamic>> _tabla = [];
  String _resultadoFinal = '';
  String _mensajeError = '';

  @override
  void dispose() {
    _funcionController.dispose();
    _aController.dispose();
    _bController.dispose();
    _nController.dispose();
    super.dispose();
  }

  void _calcularTrapecio() {
    setState(() {
      _tabla.clear();
      _resultadoFinal = '';
      _mensajeError = '';
    });

    String funcString = _funcionController.text;
    double a = double.tryParse(_aController.text) ?? 0;
    double b = double.tryParse(_bController.text) ?? 0;
    int n = int.tryParse(_nController.text) ?? 1;

    if (n <= 0) {
      setState(() => _mensajeError = 'El número de intervalos (n) debe ser mayor a 0.');
      return;
    }

    try {
      ShuntingYardParser p = ShuntingYardParser();
      Expression exp = p.parse(funcString);
      ContextModel cm = ContextModel();

      double evaluar(double valorX) {
        cm.bindVariable(Variable('x'), Number(valorX));
        return exp.evaluate(EvaluationType.REAL, cm);
      }

      double h = (b - a) / n;
      double suma = evaluar(a) + evaluar(b);
      
      _tabla.add({'i': 0, 'xi': a, 'fxi': evaluar(a), 'coef': 1});

      for (int i = 1; i < n; i++) {
        double xi = a + i * h;
        double fxi = evaluar(xi);
        suma += 2 * fxi;
        _tabla.add({'i': i, 'xi': xi, 'fxi': fxi, 'coef': 2});
      }
      
      _tabla.add({'i': n, 'xi': b, 'fxi': evaluar(b), 'coef': 1});

      double resultado = (h / 2) * suma;

      setState(() {
        _resultadoFinal = 'I ≈ ${resultado.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() => _mensajeError = 'Error al evaluar la función. Verifica la sintaxis.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF9C27B0);

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
                  TextField(
                    controller: _funcionController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(labelText: 'Función f(x)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _aController, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'Límite Inf (a)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: _bController, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'Límite Sup (b)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(labelText: 'Intervalos (n)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calcularTrapecio,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Calcular Integral', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
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
                        DataColumn(label: Text('f(x_i)', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Multiplicador', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _tabla.map((row) {
                        return DataRow(cells: [
                          DataCell(Text(row['i'].toString())),
                          DataCell(Text(row['xi'].toStringAsFixed(4))),
                          DataCell(Text(row['fxi'].toStringAsFixed(4))),
                          DataCell(Text('x ${row['coef']}', style: const TextStyle(color: Colors.grey))),
                        ]);
                      }).toList(),
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