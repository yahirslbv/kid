import 'package:flutter/material.dart';

class GaussJordanScreen extends StatefulWidget {
  const GaussJordanScreen({super.key});

  @override
  State<GaussJordanScreen> createState() => _GaussJordanScreenState();
}

class _GaussJordanScreenState extends State<GaussJordanScreen> {
  int _n = 3; // Tamaño por defecto 3x3
  List<List<TextEditingController>> _controllers = [];
  final List<double> _resultados = [];
  String _mensajeError = '';

  @override
  void initState() {
    super.initState();
    _inicializarMatriz();
  }

  void _inicializarMatriz() {
    // Genera una matriz de N filas y N+1 columnas (la +1 es para los resultados)
    _controllers = List.generate(
      _n,
      (i) => List.generate(_n + 1, (j) => TextEditingController(text: '')),
    );
    _resultados.clear();
    _mensajeError = '';
  }

  void _cambiarTamano(int? nuevoN) {
    if (nuevoN != null && nuevoN != _n) {
      setState(() {
        _n = nuevoN;
        _inicializarMatriz();
      });
    }
  }

  void _calcularGaussJordan() {
    setState(() {
      _mensajeError = '';
      _resultados.clear();
    });

    // 1. Extraer los datos de los TextFields a una matriz de tipo double
    List<List<double>> matriz = [];
    try {
      for (int i = 0; i < _n; i++) {
        List<double> fila = [];
        for (int j = 0; j <= _n; j++) {
          String val = _controllers[i][j].text;
          if (val.isEmpty) val = '0';
          fila.add(double.parse(val));
        }
        matriz.add(fila);
      }
    } catch (e) {
      setState(() => _mensajeError = 'Por favor, ingresa solo números válidos.');
      return;
    }

    // 2. Algoritmo de Eliminación de Gauss-Jordan con pivoteo parcial
    for (int i = 0; i < _n; i++) {
      // Buscar pivote máximo
      double maxEl = matriz[i][i].abs();
      int maxRow = i;
      for (int k = i + 1; k < _n; k++) {
        if (matriz[k][i].abs() > maxEl) {
          maxEl = matriz[k][i].abs();
          maxRow = k;
        }
      }

      // Intercambiar fila si el máximo no está en i
      if (maxRow != i) {
        List<double> temp = matriz[i];
        matriz[i] = matriz[maxRow];
        matriz[maxRow] = temp;
      }

      // Validar división por cero (Sistema sin solución única)
      if (matriz[i][i] == 0) {
        setState(() => _mensajeError = 'El sistema no tiene solución única (matriz singular).');
        return;
      }

      // Hacer que el elemento diagonal sea 1
      double pivote = matriz[i][i];
      for (int j = i; j <= _n; j++) {
        matriz[i][j] /= pivote;
      }

      // Hacer que los demás elementos en la columna sean 0
      for (int k = 0; k < _n; k++) {
        if (k != i) {
          double factor = matriz[k][i];
          for (int j = i; j <= _n; j++) {
            matriz[k][j] -= factor * matriz[i][j];
          }
        }
      }
    }

    // 3. Extraer los resultados de la última columna
    setState(() {
      for (int i = 0; i < _n; i++) {
        _resultados.add(matriz[i][_n]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF4CAF50); // Verde

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- CONTROLES SUPERIORES (Tamaño) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tamaño del Sistema:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryColor.withValues(alpha: 0.5))),
                child: DropdownButton<int>(
                  value: _n,
                  underline: const SizedBox(),
                  dropdownColor: isDark ? const Color(0xFF1C3350) : Colors.white,
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('2 x 2')),
                    DropdownMenuItem(value: 3, child: Text('3 x 3')),
                    DropdownMenuItem(value: 4, child: Text('4 x 4')),
                  ],
                  onChanged: _cambiarTamano,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- MATRIZ DINÁMICA ---
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7))),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_n, (i) {
                    return Row(
                      children: List.generate(_n + 1, (j) {
                        bool isResult = j == _n; // La última columna es la de los resultados
                        return Container(
                          width: 60,
                          margin: EdgeInsets.only(right: isResult ? 0 : 8, bottom: 8, left: isResult ? 16 : 0),
                          child: TextField(
                            controller: _controllers[i][j],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: isResult ? FontWeight.bold : FontWeight.normal),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isResult ? primaryColor.withValues(alpha: 0.1) : (isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              hintText: isResult ? 'b${i + 1}' : 'a${i + 1}${j + 1}',
                              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- BOTÓN DE CALCULAR ---
          ElevatedButton(
            onPressed: _calcularGaussJordan,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Resolver Sistema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 16),

          // --- RESULTADOS ---
          if (_mensajeError.isNotEmpty)
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent)), child: Text(_mensajeError, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
          
          if (_resultados.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryColor)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Solución Exacta:', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: List.generate(_n, (i) {
                      // Lista de variables clásicas
                      final variables = ['x', 'y', 'z', 'w'];
                      
                      return Chip(
                        label: Text(
                          '${variables[i]} = ${_resultados[i].toStringAsFixed(4)}', // <-- Cambiamos la x1 por la letra
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87 
                          )
                        ),
                        backgroundColor: isDark ? const Color(0xFF1C3350) : Colors.white, 
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                      );
                    }),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}