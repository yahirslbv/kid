import 'package:flutter/material.dart';

class LagrangeScreen extends StatefulWidget {
  const LagrangeScreen({super.key});

  @override
  State<LagrangeScreen> createState() => _LagrangeScreenState();
}

class _LagrangeScreenState extends State<LagrangeScreen> {
  final _xController = TextEditingController(text: '1, 3, 5, 7');
  final _yController = TextEditingController(text: '2, 4, 8, 12');
  final _xIntController = TextEditingController(text: '4'); // Punto a interpolar

  String _mensajeError = '';
  String _resultadoFinal = '';
  String _desarrollo = '';

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _xIntController.dispose();
    super.dispose();
  }

  void _calcularLagrange() {
    setState(() {
      _mensajeError = '';
      _resultadoFinal = '';
      _desarrollo = '';
    });

    try {
      List<double> x = _xController.text.split(',').map((e) => double.parse(e.trim())).toList();
      List<double> y = _yController.text.split(',').map((e) => double.parse(e.trim())).toList();
      double xInt = double.parse(_xIntController.text.trim());

      if (x.length != y.length) {
        setState(() => _mensajeError = 'X y Y deben tener la misma cantidad de datos.');
        return;
      }

      int n = x.length;
      double yResult = 0;
      String pasos = '';

      for (int i = 0; i < n; i++) {
        double term = y[i];
        String termString = 'L$i(x) = ${y[i]}';
        
        for (int j = 0; j < n; j++) {
          if (i != j) {
            term *= (xInt - x[j]) / (x[i] - x[j]);
            termString += ' * [($xInt - ${x[j]}) / (${x[i]} - ${x[j]})]';
          }
        }
        yResult += term;
        pasos += '$termString\n= ${term.toStringAsFixed(4)}\n\n';
      }

      setState(() {
        _resultadoFinal = 'f($xInt) ≈ ${yResult.toStringAsFixed(4)}';
        _desarrollo = pasos.trim();
      });

    } catch (e) {
      setState(() => _mensajeError = 'Formato inválido. Usa números separados por comas.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFFF9800);

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
                    controller: _xController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(labelText: 'Valores de X', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _yController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(labelText: 'Valores de f(X) o Y', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _xIntController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(labelText: 'Valor a interpolar (x)', filled: true, fillColor: primaryColor.withValues(alpha: 0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calcularLagrange,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Interpolar Valor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_mensajeError.isNotEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent)), child: Text(_mensajeError, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),

          if (_resultadoFinal.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green)),
              child: Center(child: Text(_resultadoFinal, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green))),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7))),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Desarrollo de Polinomios L(x)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 12),
                      Text(_desarrollo, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.grey)),
                    ],
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