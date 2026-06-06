import 'dart:math';
import 'package:flutter/material.dart';

class RegresionLinealScreen extends StatefulWidget {
  const RegresionLinealScreen({super.key});

  @override
  State<RegresionLinealScreen> createState() => _RegresionLinealScreenState();
}

class _RegresionLinealScreenState extends State<RegresionLinealScreen> {
  final _xController = TextEditingController(text: '1, 2, 3, 4, 5');
  final _yController = TextEditingController(text: '2.1, 4.0, 6.2, 8.1, 9.9');

  String _mensajeError = '';
  Map<String, dynamic>? _resultados;

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }

  void _calcularRegresion() {
    setState(() {
      _mensajeError = '';
      _resultados = null;
    });

    try {
      List<double> x = _xController.text.split(',').map((e) => double.parse(e.trim())).toList();
      List<double> y = _yController.text.split(',').map((e) => double.parse(e.trim())).toList();

      if (x.length != y.length) {
        setState(() => _mensajeError = 'Error: Debe haber la misma cantidad de valores en X y en Y.');
        return;
      }

      int n = x.length;
      if (n < 2) {
        setState(() => _mensajeError = 'Error: Se necesitan al menos 2 puntos.');
        return;
      }

      double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;
      for (int i = 0; i < n; i++) {
        sumX += x[i];
        sumY += y[i];
        sumXY += x[i] * y[i];
        sumX2 += x[i] * x[i];
        sumY2 += y[i] * y[i];
      }

      double m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
      double b = (sumY - m * sumX) / n;
      
      // Coeficiente de correlación r
      double rNumerador = n * sumXY - sumX * sumY;
      double rDenominador = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
      double r = rDenominador == 0 ? 0 : rNumerador / rDenominador;

      setState(() {
        _resultados = {
          'n': n, 'sumX': sumX, 'sumY': sumY, 'sumXY': sumXY, 'sumX2': sumX2,
          'm': m, 'b': b, 'r': r,
        };
      });
    } catch (e) {
      setState(() => _mensajeError = 'Error de formato. Usa solo números separados por comas (ej: 1, 2.5, 3).');
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ingresa los valores separados por coma (,)', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _xController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(labelText: 'Valores de X', prefixIcon: Icon(Icons.compare_arrows, color: primaryColor), filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _yController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(labelText: 'Valores de Y', prefixIcon: Icon(Icons.show_chart, color: primaryColor), filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calcularRegresion,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Calcular Regresión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_mensajeError.isNotEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent)), child: Text(_mensajeError, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),

          if (_resultados != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor)),
              child: Column(
                children: [
                  const Text('Ecuación de la Recta', style: TextStyle(fontSize: 14, color: Color(0xFFD84315), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('y = ${_resultados!['m'].toStringAsFixed(4)}x ${(_resultados!['b'] >= 0 ? '+' : '')} ${_resultados!['b'].toStringAsFixed(4)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem('Correlación (r)', _resultados!['r'].toStringAsFixed(4), isDark),
                      _StatItem('Puntos (n)', _resultados!['n'].toString(), isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7))),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sumatorias (Paso a paso)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 12),
                      _SumatoriaItem('Σx', _resultados!['sumX'], isDark),
                      _SumatoriaItem('Σy', _resultados!['sumY'], isDark),
                      _SumatoriaItem('Σxy', _resultados!['sumXY'], isDark),
                      _SumatoriaItem('Σx²', _resultados!['sumX2'], isDark),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _StatItem(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      ],
    );
  }
}

class _SumatoriaItem extends StatelessWidget {
  final String label;
  final double value;
  final bool isDark;
  const _SumatoriaItem(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF9800))),
          Text(value.toStringAsFixed(4), style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }
}