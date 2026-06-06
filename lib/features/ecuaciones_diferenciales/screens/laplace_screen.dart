import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart';

class LaplaceScreen extends StatefulWidget {
  const LaplaceScreen({super.key});

  @override
  State<LaplaceScreen> createState() => _LaplaceScreenState();
}

class _LaplaceScreenState extends State<LaplaceScreen> {
  // Controlador único, pero su significado cambia según el modo
  final TextEditingController _funcionController = TextEditingController();
  final FocusNode _funcionFocus = FocusNode();
  
  // --- CORRECCIÓN 1: Memoria del controlador ---
  TextEditingController? _ultimoControladorActivo;
  
  bool _esInversa = false; // Toggle para Directa o Inversa
  bool _mostrarResultado = false;

  // --- CORRECCIÓN 2: Rastrear cuando el usuario toca la caja ---
  @override
  void initState() {
    super.initState();
    _funcionFocus.addListener(() {
      if (_funcionFocus.hasFocus) {
        _ultimoControladorActivo = _funcionController;
      }
    });
  }

  @override
  void dispose() {
    _funcionController.dispose();
    _funcionFocus.dispose();
    super.dispose();
  }

  // --- LÓGICA DEL TECLADO MATEMÁTICO CORREGIDA ---
  void _insertarSimbolo(String simbolo) {
    if (_ultimoControladorActivo != null) {
      final activeController = _ultimoControladorActivo!;
      final text = activeController.text;
      final selection = activeController.selection;
      
      final start = selection.start >= 0 ? selection.start : text.length;
      final end = selection.end >= 0 ? selection.end : text.length;

      final newText = text.replaceRange(start, end, simbolo);
      activeController.text = newText;

      int offset = start + simbolo.length;
      if (simbolo.endsWith('()') || simbolo.endsWith('{}')) offset -= 1; 
      if (simbolo == r'\frac{}{}') offset -= 3; 
      
      activeController.selection = TextSelection.collapsed(offset: offset);
      
      // CORRECCIÓN 3: Le devolvemos el foco a la caja para seguir escribiendo
      _funcionFocus.requestFocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toca la caja de texto para insertar el símbolo.')),
      );
    }
  }

  void _calcular() {
    if (_funcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa una función en términos de ${_esInversa ? 's' : 't'}.')),
      );
      return;
    }
    
    FocusScope.of(context).unfocus(); 
    setState(() {
      _mostrarResultado = true;
    });
  }

  void _abrirTutorIA(BuildContext context, Color colorTema) {
    final funcion = _funcionController.text.isNotEmpty ? _funcionController.text : "no definida";
    
    String contextoDinamico;
    if (_esInversa) {
      contextoDinamico = "El usuario está usando la Calculadora de Transformada de Laplace Inversa. "
          "Desea encontrar f(t) = L^{-1}{ $funcion }. "
          "Tu tarea es actuar como un tutor matemático. Guíalo paso a paso, priorizando el uso de "
          "fracciones parciales o completado de trinomios cuadrados perfectos si el denominador lo requiere, "
          "y luego el uso de tablas estándar. Usa formato LaTeX con \$\$ para las matemáticas.";
    } else {
      contextoDinamico = "El usuario está usando la Calculadora de Transformada de Laplace Directa. "
          "Desea encontrar F(s) = L{ $funcion }. "
          "Tu tarea es actuar como tutor matemático. Guíalo explicando si es mejor usar la definición integral "
          "\\int_0^\\infty e^{-st} f(t) dt o aplicar linealidad y tablas de transformadas básicas, además de los teoremas de traslación. "
          "Usa formato LaTeX con \$\$ para las matemáticas.";
    }

    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EdChatSheet(
        moduleName: 'Tutor: Laplace',
        contextoDatos: contextoDinamico,
        colorTema: colorTema,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF5B9BD5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transformada de Laplace'),
        backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
        elevation: 0,
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TOGGLE PARA SELECCIONAR MODO ---
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C3350) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModoBoton('Directa \u{2122}', false, isDark, primaryColor),
                      _buildModoBoton('Inversa \u{2122}\u207B\u00B9', true, isDark, primaryColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              Text(
                _esInversa ? 'Planteamiento de la Transformada Inversa:' : 'Planteamiento de la Transformada Directa:',
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 15),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C3350) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.transparent : Colors.blue.shade100),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Math.tex(
                    _esInversa ? r'\mathcal{L}^{-1}\{ F(s) \} = f(t)' : r'\mathcal{L}\{ f(t) \} = F(s)',
                    textStyle: TextStyle(fontSize: 22, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Text(
                _esInversa ? 'Ingresa F(s):' : 'Ingresa f(t):', 
                style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _funcionController,
                focusNode: _funcionFocus,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: _esInversa ? 'Ej. \\frac{1}{s^2 + 4}' : 'Ej. e^{3t} \\sin(2t)',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(_esInversa ? Icons.functions : Icons.show_chart),
                ),
              ),
              
              const SizedBox(height: 15),
              _buildTecladoMatematico(isDark, primaryColor),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _calcular,
                  icon: const Icon(Icons.bolt, color: Colors.white),
                  label: Text(_esInversa ? 'Evaluar Inversa' : 'Aplicar Transformada', style: const TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              if (_mostrarResultado) ...[
                const Divider(),
                const SizedBox(height: 10),
                Text('Operación a realizar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.blue[900])),
                const SizedBox(height: 15),
                _buildPaso(
                  context, 
                  'Notación formal', 
                  _esInversa 
                    ? r'\mathcal{L}^{-1}\left\{ ' + _funcionController.text + r' \right\}'
                    : r'\mathcal{L}\left\{ ' + _funcionController.text + r' \right\}', 
                  isDark
                ),
                
                const SizedBox(height: 10),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirTutorIA(context, primaryColor),
                    icon: const Icon(Icons.psychology),
                    label: Text(_esInversa ? 'Desarrollar fracciones parciales / tablas con IA' : 'Resolver paso a paso con la IA'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.amber : Colors.blue[900],
                      side: BorderSide(color: isDark ? Colors.amber : Colors.blue.shade900),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                  ),
                ),
                const SizedBox(height: 80), 
              ]
            ],
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirTutorIA(context, primaryColor),
        backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
        icon: const Icon(Icons.psychology, color: Colors.white),
        label: const Text('Tutor IA', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Widget para construir los botones del Toggle (Directa / Inversa)
  Widget _buildModoBoton(String titulo, bool esBotonInversa, bool isDark, Color primaryColor) {
    final bool estaSeleccionado = _esInversa == esBotonInversa;
    return GestureDetector(
      onTap: () {
        setState(() {
          _esInversa = esBotonInversa;
          _mostrarResultado = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: estaSeleccionado ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          titulo,
          style: TextStyle(
            color: estaSeleccionado 
                ? Colors.white 
                : (isDark ? Colors.white70 : Colors.blue[900]),
            fontWeight: estaSeleccionado ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTecladoMatematico(bool isDark, Color primaryColor) {
    // Teclado mixto enfocado a s, t y funciones comunes en Laplace
    final Map<String, String> botones = {
      't': 't', 's': 's', '\\frac{x}{y}': r'\frac{}{}', 'x^n': '^{}', 
      'e^{at}': 'e^{}', '\\sin(bt)': '\\sin()', '\\cos(bt)': '\\cos()',
      '\\sinh': '\\sinh()', '\\cosh': '\\cosh()', 'u(t-a)': 'u(t-)',
      '+': '+', '-': '-', '(': '(', ')': ')'
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: botones.entries.map((entrada) {
          return InkWell(
            onTap: () => _insertarSimbolo(entrada.value),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF234060) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Math.tex(
                entrada.key, 
                textStyle: TextStyle(
                  fontSize: 15, 
                  color: isDark ? Colors.amber : Colors.blue[900]
                )
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaso(BuildContext context, String titulo, String formulaLatex, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C3350) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            // CORRECCIÓN 4: SingleChildScrollView para evitar desbordamientos
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                formulaLatex,
                textStyle: TextStyle(fontSize: 18, color: isDark ? Colors.amber : Colors.blue[900]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}