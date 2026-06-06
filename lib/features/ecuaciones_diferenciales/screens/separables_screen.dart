import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart'; 

class SeparablesScreen extends StatefulWidget {
  const SeparablesScreen({super.key});

  @override
  State<SeparablesScreen> createState() => _SeparablesScreenState();
}

class _SeparablesScreenState extends State<SeparablesScreen> {
  final TextEditingController _fxController = TextEditingController();
  final TextEditingController _gyController = TextEditingController();
  
  final FocusNode _fxFocus = FocusNode();
  final FocusNode _gyFocus = FocusNode();
  
  // --- CORRECCIÓN 1: Memoria del último controlador seleccionado ---
  TextEditingController? _ultimoControladorActivo;
  
  bool _mostrarResultado = false;

  // --- CORRECCIÓN 2: Escuchamos quién tiene el foco ---
  @override
  void initState() {
    super.initState();
    _fxFocus.addListener(() {
      if (_fxFocus.hasFocus) _ultimoControladorActivo = _fxController;
    });
    _gyFocus.addListener(() {
      if (_gyFocus.hasFocus) _ultimoControladorActivo = _gyController;
    });
  }

  @override
  void dispose() {
    _fxController.dispose();
    _gyController.dispose();
    _fxFocus.dispose();
    _gyFocus.dispose();
    super.dispose();
  }

  // --- LÓGICA DEL TECLADO MATEMÁTICO CORREGIDA ---
  void _insertarSimbolo(String simbolo) {
    // Usamos nuestra variable de memoria en lugar del .hasFocus instantáneo
    if (_ultimoControladorActivo != null) {
      final activeController = _ultimoControladorActivo!;
      final text = activeController.text;
      final selection = activeController.selection;
      
      // Determina la posición actual del cursor (o lo manda al final si no hay)
      final start = selection.start >= 0 ? selection.start : text.length;
      final end = selection.end >= 0 ? selection.end : text.length;

      // Inserta el símbolo en la caja de texto
      final newText = text.replaceRange(start, end, simbolo);
      activeController.text = newText;

      // --- Magia del Cursor ---
      int offset = start + simbolo.length;
      if (simbolo.endsWith('()') || simbolo.endsWith('{}')) {
        offset -= 1; // Lo mete adentro del paréntesis o llave final
      }
      if (simbolo == r'\frac{}{}') {
        offset -= 3; // Lo mete adentro del numerador en las fracciones
      }
      
      activeController.selection = TextSelection.collapsed(offset: offset);
      
      // CORRECCIÓN 3: Le devolvemos el foco a la caja de texto para que 
      // el cursor siga parpadeando después de picar el botón
      if (activeController == _fxController) {
        _fxFocus.requestFocus();
      } else {
        _gyFocus.requestFocus();
      }
      
    } else {
      // Si no hay ninguna caja enfocada en la memoria, avisa al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toca una caja de texto primero para insertar el símbolo.')),
      );
    }
  }

  void _calcular() {
    if (_fxController.text.isEmpty || _gyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa ambas funciones.')),
      );
      return;
    }
    
    FocusScope.of(context).unfocus(); 
    setState(() {
      _mostrarResultado = true;
    });
  }

  void _abrirTutorIA(BuildContext context, Color colorTema) {
    final fx = _fxController.text.isNotEmpty ? _fxController.text : "no definida";
    final gy = _gyController.text.isNotEmpty ? _gyController.text : "no definida";

    final contextoDinamico = "El usuario está usando la Calculadora de Ecuaciones de Variables Separables. "
        "Actualmente está intentando resolver la ecuación: dy/dx = ($fx) * ($gy). "
        "Tu tarea es actuar como un tutor matemático amable. Si te hace una pregunta, guíalo paso a paso "
        "para integrar f(x) respecto a x, y 1/g(y) respecto a y. Usa formato LaTeX con \$\$ para las matemáticas.";

    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EdChatSheet(
        moduleName: 'Tutor: EDOs Separables',
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
        title: const Text('Variables Separables'),
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
              Text(
                'Lleva tu ecuación a la forma estándar:',
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
                    r'\frac{dy}{dx} = f(x) \cdot g(y)',
                    textStyle: TextStyle(fontSize: 24, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Text('1. Ingresa f(x):', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _fxController,
                focusNode: _fxFocus, // Conectamos el detector de enfoque
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. 2x',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.functions),
                ),
              ),
              const SizedBox(height: 20),
              
              Text('2. Ingresa g(y):', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _gyController,
                focusNode: _gyFocus, // Conectamos el detector de enfoque
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. y^2',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.functions),
                ),
              ),
              
              const SizedBox(height: 15),
              // --- EL WIDGET DEL TECLADO MATEMÁTICO ---
              _buildTecladoMatematico(isDark, primaryColor),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _calcular,
                  icon: const Icon(Icons.account_tree_rounded, color: Colors.white),
                  label: const Text('Plantear Solución', style: TextStyle(fontSize: 16, color: Colors.white)),
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
                Text('Procedimiento analítico:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.blue[900])),
                const SizedBox(height: 15),
                _buildPaso(context, '1. Separar variables', r'\frac{dy}{' + _gyController.text + r'} = (' + _fxController.text + r') dx', isDark),
                _buildPaso(context, '2. Integrar ambos lados', r'\int \frac{dy}{' + _gyController.text + r'} = \int (' + _fxController.text + r') dx + C', isDark),
                
                const SizedBox(height: 10),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirTutorIA(context, primaryColor),
                    icon: const Icon(Icons.psychology),
                    label: const Text('¿No sabes cómo integrar esto? Pregúntale a la IA'),
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

  // --- UI DEL TECLADO ---
  Widget _buildTecladoMatematico(bool isDark, Color primaryColor) {
    final Map<String, String> botones = {
      'x': 'x', 'y': 'y', 'x^2': '^2', 'x^y': '^{}', 
      '\\sqrt{x}': '\\sqrt{}', '\\frac{x}{y}': r'\frac{}{}', 
      '\\sin': '\\sin()', '\\cos': '\\cos()', 'e^x': 'e^{}', '\\ln': '\\ln()'
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF234060) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Math.tex(
                entrada.key, 
                textStyle: TextStyle(
                  fontSize: 16, 
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