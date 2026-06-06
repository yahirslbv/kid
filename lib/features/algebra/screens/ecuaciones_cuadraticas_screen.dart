import 'dart:math';
import 'package:flutter/material.dart';
import '../../estadistica/screens/scan_problem_screen.dart';

class EcuacionesCuadraticasScreen extends StatefulWidget {
  const EcuacionesCuadraticasScreen({super.key});

  @override
  State<EcuacionesCuadraticasScreen> createState() => _EcuacionesCuadraticasScreenState();
}

class _EcuacionesCuadraticasScreenState extends State<EcuacionesCuadraticasScreen> {
  final _aController = TextEditingController(text: '1');
  final _bController = TextEditingController(text: '0');
  final _cController = TextEditingController(text: '-4');

  String _resultadoX1 = '';
  String _resultadoX2 = '';
  String _discriminante = '';
  String _tipoRaiz = '';

  @override
  void dispose() { 
    _aController.dispose(); 
    _bController.dispose(); 
    _cController.dispose(); 
    super.dispose(); 
  }

  void _calcularGeneral() {
    double a = double.tryParse(_aController.text) ?? 0;
    double b = double.tryParse(_bController.text) ?? 0;
    double c = double.tryParse(_cController.text) ?? 0;

    if (a == 0) {
      setState(() { 
        _tipoRaiz = "No es una ecuación cuadrática (A no puede ser 0)"; 
        _resultadoX1 = ""; 
        _resultadoX2 = ""; 
        _discriminante = ""; 
      });
      return;
    }

    double d = (b * b) - (4 * a * c);
    String res1, res2, tipo;

    if (d > 0) {
      tipo = "Raíces reales y distintas";
      res1 = ((-b + sqrt(d)) / (2 * a)).toStringAsFixed(4);
      res2 = ((-b - sqrt(d)) / (2 * a)).toStringAsFixed(4);
    } else if (d == 0) {
      tipo = "Raíces reales e iguales";
      res1 = (-b / (2 * a)).toStringAsFixed(4);
      res2 = res1;
    } else {
      tipo = "Raíces complejas / imaginarias";
      double realPart = -b / (2 * a);
      double imaginaryPart = sqrt(-d) / (2 * a);
      res1 = "${realPart.toStringAsFixed(4)} + ${imaginaryPart.toStringAsFixed(4)}i";
      res2 = "${realPart.toStringAsFixed(4)} - ${imaginaryPart.toStringAsFixed(4)}i";
    }

    setState(() { 
      _discriminante = "Δ = ${d.toStringAsFixed(2)}"; 
      _tipoRaiz = tipo; 
      _resultadoX1 = "x₁ = $res1"; 
      _resultadoX2 = "x₂ = $res2"; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF009688);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(
        title: const Text('Fórmula General'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Resuelve: Ax² + Bx + C = 0", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            Card(
              color: isDark ? const Color(0xFF1C3350) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: _aController, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'A', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                    const SizedBox(width: 8), const Text("x² +", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _bController, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'B', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                    const SizedBox(width: 8), const Text("x +", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _cController, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'C', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _calcularGeneral, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Resolver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
            const SizedBox(height: 24),
            
            // --- SOLUCIÓN DE DIBUJO ---
            if (_tipoRaiz.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor)),
                child: Column(
                  children: [
                    // Mostramos el texto principal o de error, cambiando a rojo si fue error
                    Text(
                      _tipoRaiz, 
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w600, 
                        color: _resultadoX1.isEmpty ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black54)
                      )
                    ),
                    
                    // Solo dibujamos los números de las respuestas si NO fue un error
                    if (_resultadoX1.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(_discriminante, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const Divider(height: 24),
                      Text(_resultadoX1, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor)),
                      const SizedBox(height: 8),
                      Text(_resultadoX2, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor)),
                    ]
                  ],
                ),
              )
            ]
            // --------------------------
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btn_scan_ecuaciones_cuadraticas', 
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScanProblemScreen(tema: 'ecuaciones_cuadraticas'),
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