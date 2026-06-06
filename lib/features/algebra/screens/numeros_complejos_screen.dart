import 'package:flutter/material.dart';
import '../../estadistica/screens/scan_problem_screen.dart';
class NumerosComplejosScreen extends StatefulWidget {
  const NumerosComplejosScreen({super.key});

  @override
  State<NumerosComplejosScreen> createState() => _NumerosComplejosScreenState();
}

class _NumerosComplejosScreenState extends State<NumerosComplejosScreen> {
  final _a1Controller = TextEditingController(text: '3');
  final _b1Controller = TextEditingController(text: '2');
  final _a2Controller = TextEditingController(text: '1');
  final _b2Controller = TextEditingController(text: '-4');

  String _resultado = '';
  String _operacionNombre = '';

  @override
  void dispose() {
    _a1Controller.dispose(); _b1Controller.dispose();
    _a2Controller.dispose(); _b2Controller.dispose();
    super.dispose();
  }

  void _calcular(String operacion) {
    double a1 = double.tryParse(_a1Controller.text) ?? 0;
    double b1 = double.tryParse(_b1Controller.text) ?? 0;
    double a2 = double.tryParse(_a2Controller.text) ?? 0;
    double b2 = double.tryParse(_b2Controller.text) ?? 0;

    double resReal = 0;
    double resImag = 0;
    String nombre = '';

    if (operacion == 'suma') {
      resReal = a1 + a2; resImag = b1 + b2; nombre = 'Z₁ + Z₂';
    } else if (operacion == 'resta') {
      resReal = a1 - a2; resImag = b1 - b2; nombre = 'Z₁ - Z₂';
    } else if (operacion == 'multi') {
      resReal = (a1 * a2) - (b1 * b2);
      resImag = (a1 * b2) + (a2 * b1);
      nombre = 'Z₁ × Z₂';
    } else if (operacion == 'div') {
      double divisor = (a2 * a2) + (b2 * b2);
      if (divisor == 0) {
        setState(() { _resultado = 'Error: División por 0'; _operacionNombre = ''; });
        return;
      }
      resReal = ((a1 * a2) + (b1 * b2)) / divisor;
      resImag = ((a2 * b1) - (a1 * b2)) / divisor;
      nombre = 'Z₁ ÷ Z₂';
    }

    String signo = resImag >= 0 ? '+' : '-';
    setState(() {
      _operacionNombre = nombre;
      _resultado = '${resReal.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')} $signo ${resImag.abs().toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')}i';
    });
  }

  Widget _buildComplejoInput(String titulo, TextEditingController rCtrl, TextEditingController iCtrl, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: TextField(controller: rCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Real (a)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            Expanded(child: TextField(controller: iCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Imag (b)', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
            const Padding(padding: EdgeInsets.only(left: 4.0), child: Text('i', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic))),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF009688);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(title: const Text('Números Complejos'), backgroundColor: primaryColor, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: isDark ? const Color(0xFF1C3350) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildComplejoInput('Número Z₁', _a1Controller, _b1Controller, isDark),
                    const Divider(height: 32),
                    _buildComplejoInput('Número Z₂', _a2Controller, _b2Controller, isDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBtn('+', () => _calcular('suma'), primaryColor),
                _buildBtn('-', () => _calcular('resta'), primaryColor),
                _buildBtn('×', () => _calcular('multi'), primaryColor),
                _buildBtn('÷', () => _calcular('div'), primaryColor),
              ],
            ),
            if (_resultado.isNotEmpty) ...[
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor)),
                child: Column(
                  children: [
                    if (_operacionNombre.isNotEmpty) Text(_operacionNombre, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(_resultado, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btn_scan_numeros_complejos', // Etiqueta única
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

  Widget _buildBtn(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color, shape: const CircleBorder(), padding: const EdgeInsets.all(16)),
      child: Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}