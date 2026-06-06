import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart';

class SegundoOrdenCalcScreen extends StatefulWidget {
  const SegundoOrdenCalcScreen({super.key});

  @override
  State<SegundoOrdenCalcScreen> createState() => _SegundoOrdenCalcScreenState();
}

class _SegundoOrdenCalcScreenState extends State<SegundoOrdenCalcScreen> {
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _cController = TextEditingController();
  
  final FocusNode _aFocus = FocusNode();
  final FocusNode _bFocus = FocusNode();
  final FocusNode _cFocus = FocusNode();
  
  // --- MEMORIA DEL TECLADO ---
  TextEditingController? _ultimoControladorActivo;

  bool _mostrarResultado = false;

  @override
  void initState() {
    super.initState();
    _aFocus.addListener(() {
      if (_aFocus.hasFocus) _ultimoControladorActivo = _aController;
    });
    _bFocus.addListener(() {
      if (_bFocus.hasFocus) _ultimoControladorActivo = _bController;
    });
    _cFocus.addListener(() {
      if (_cFocus.hasFocus) _ultimoControladorActivo = _cController;
    });
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _cController.dispose();
    _aFocus.dispose();
    _bFocus.dispose();
    _cFocus.dispose();
    super.dispose();
  }

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
      if (simbolo.endsWith('()') || simbolo.endsWith('{}')) {
        offset -= 1; 
      }
      if (simbolo == r'\frac{}{}') {
        offset -= 3; 
      }
      
      activeController.selection = TextSelection.collapsed(offset: offset);

      // Le devolvemos el foco a la caja correspondiente
      if (activeController == _aController) {
        _aFocus.requestFocus();
      } else if (activeController == _bController) {
        _bFocus.requestFocus();
      } else {
        _cFocus.requestFocus();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se requiere seleccionar una caja de texto para insertar el símbolo.')),
      );
    }
  }

  void _calcular() {
    if (_aController.text.isEmpty || _bController.text.isEmpty || _cController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Es necesario ingresar los valores de a, b y c.')),
      );
      return;
    }
    
    FocusScope.of(context).unfocus(); 
    setState(() {
      _mostrarResultado = true;
    });
  }

  void _abrirTutorIA(BuildContext context, Color colorTema) {
    final aText = _aController.text.isNotEmpty ? _aController.text : "1";
    final bText = _bController.text.isNotEmpty ? _bController.text : "0";
    final cText = _cController.text.isNotEmpty ? _cController.text : "0";

    final contextoDinamico = "El usuario se encuentra en la Calculadora de Ecuaciones de Segundo Orden Homogéneas. "
        "La ecuación diferencial planteada es: ($aText)y'' + ($bText)y' + ($cText)y = 0. "
        "La instrucción operativa es actuar como un tutor matemático objetivo. Si se requiere asistencia, "
        "se debe guiar paso a paso en la formulación de la ecuación característica ($aText)r^2 + ($bText)r + ($cText) = 0, "
        "la obtención de sus raíces mediante la fórmula general o factorización, y la construcción de la solución general "
        "dependiendo de si las raíces son reales distintas, reales repetidas o complejas conjugadas. "
        "Es obligatorio emplear formato LaTeX con \$\$ para las expresiones matemáticas.";

    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EdChatSheet(
        moduleName: 'Tutor: EDO 2do Orden',
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
        title: const Text('EDO 2do Orden Homogéneas'),
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
                'Estructura lineal con coeficientes constantes:',
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
                    r'a \frac{d^2y}{dx^2} + b \frac{dy}{dx} + c y = 0',
                    textStyle: TextStyle(fontSize: 22, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1. a:', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _aController,
                          focusNode: _aFocus,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Ej. 1',
                            filled: true,
                            fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('2. b:', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _bController,
                          focusNode: _bFocus,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Ej. -5',
                            filled: true,
                            fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('3. c:', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _cController,
                          focusNode: _cFocus,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Ej. 6',
                            filled: true,
                            fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 25),
              _buildTecladoMatematico(isDark, primaryColor),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _calcular,
                  icon: const Icon(Icons.account_tree_rounded, color: Colors.white),
                  label: const Text('Generar Polinomio', style: TextStyle(fontSize: 16, color: Colors.white)),
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
                Text('Sustitución de forma e^{rx}:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.blue[900])),
                const SizedBox(height: 15),
                _buildPaso(context, '1. Ecuación Característica', r'(' + _aController.text + r')r^2 + (' + _bController.text + r')r + (' + _cController.text + r') = 0', isDark),
                
                const SizedBox(height: 10),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirTutorIA(context, primaryColor),
                    icon: const Icon(Icons.psychology),
                    label: const Text('Calcular raíces y solución general con IA'),
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

  Widget _buildTecladoMatematico(bool isDark, Color primaryColor) {
    final Map<String, String> botones = {
      '-': '-', '+': '+', 'x^2': '^2', '\\frac{x}{y}': r'\frac{}{}', 
      '\\sqrt{x}': '\\sqrt{}', '\\pi': '\\pi', 
      'k': 'k', '\\omega': '\\omega', 'e^x': 'e^{}', '\\ln': '\\ln()'
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