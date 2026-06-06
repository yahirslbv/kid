import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart';

class EdpScreen extends StatefulWidget {
  const EdpScreen({super.key});

  @override
  State<EdpScreen> createState() => _EdpScreenState();
}

class _EdpScreenState extends State<EdpScreen> {
  final TextEditingController _edpController = TextEditingController();
  final TextEditingController _condicionesController = TextEditingController();
  
  final FocusNode _edpFocus = FocusNode();
  final FocusNode _condicionesFocus = FocusNode();
  
  // --- CORRECCIÓN: Memoria del controlador ---
  TextEditingController? _ultimoControladorActivo;

  bool _mostrarResultado = false;

  // --- CORRECCIÓN: Rastrear cuando el usuario toca la caja ---
  @override
  void initState() {
    super.initState();
    _edpFocus.addListener(() {
      if (_edpFocus.hasFocus) _ultimoControladorActivo = _edpController;
    });
    _condicionesFocus.addListener(() {
      if (_condicionesFocus.hasFocus) _ultimoControladorActivo = _condicionesController;
    });
  }

  @override
  void dispose() {
    _edpController.dispose();
    _condicionesController.dispose();
    _edpFocus.dispose();
    _condicionesFocus.dispose();
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
      if (simbolo == r'\frac{\partial}{\partial}') offset -= 13;
      
      activeController.selection = TextSelection.collapsed(offset: offset);
      
      // Devolvemos el foco a la caja correspondiente
      if (activeController == _edpController) {
        _edpFocus.requestFocus();
      } else {
        _condicionesFocus.requestFocus();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se requiere seleccionar una caja de texto para insertar el símbolo.')),
      );
    }
  }

  void _calcular() {
    if (_edpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Es necesario ingresar la Ecuación en Derivadas Parciales.')),
      );
      return;
    }
    
    FocusScope.of(context).unfocus(); 
    setState(() {
      _mostrarResultado = true;
    });
  }

  void _abrirTutorIA(BuildContext context, Color colorTema) {
    final edp = _edpController.text.isNotEmpty ? _edpController.text : "No especificada";
    final condiciones = _condicionesController.text.isNotEmpty ? _condicionesController.text : "Sin condiciones iniciales/frontera";

    final contextoDinamico = "El usuario se encuentra en la Calculadora de Ecuaciones en Derivadas Parciales (EDP). "
        "Intenta resolver la EDP: $edp, sujeta a las condiciones: $condiciones. "
        "La instrucción operativa es actuar como un tutor matemático objetivo. Si se requiere asistencia, "
        "se debe guiar paso a paso en la aplicación del Método de Separación de Variables (ej. u(x,t) = X(x)T(t)), "
        "la obtención de las EDOs separadas mediante la constante \u03BB, y la resolución de problemas de Sturm-Liouville "
        "aplicando las condiciones de frontera dadas para armar la serie solución. "
        "Es obligatorio emplear formato LaTeX con \$\$ para las expresiones matemáticas.";

    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EdChatSheet(
        moduleName: 'Tutor: EDPs',
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
        title: const Text('Derivadas Parciales (EDP)'),
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
                'Estructura general de una EDP lineal de segundo orden:',
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 15),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C3350) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.transparent : Colors.blue.shade100),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      r'A\frac{\partial^2 u}{\partial x^2} + B\frac{\partial^2 u}{\partial x \partial y} + C\frac{\partial^2 u}{\partial y^2} + \dots = 0',
                      textStyle: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Text('1. Ecuación Diferencial Parcial:', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _edpController,
                focusNode: _edpFocus,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: r'Ej. \frac{\partial u}{\partial t} = \alpha^2 \frac{\partial^2 u}{\partial x^2}',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.functions),
                ),
              ),
              const SizedBox(height: 20),
              
              Text('2. Condiciones Iniciales / Frontera:', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _condicionesController,
                focusNode: _condicionesFocus,
                maxLines: 2,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. u(0,t) = 0, u(L,t) = 0\nu(x,0) = f(x)',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Icon(Icons.border_style),
                  ),
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
                  icon: const Icon(Icons.call_split, color: Colors.white),
                  label: const Text('Plantear Separación', style: TextStyle(fontSize: 16, color: Colors.white)),
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
                Text('Método de Separación de Variables:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.blue[900])),
                const SizedBox(height: 15),
                _buildPaso(
                  context, 
                  '1. Proponer solución producto', 
                  r'u(x,t) = X(x)T(t)', 
                  isDark
                ),
                _buildPaso(
                  context, 
                  '2. Derivar y sustituir en la EDP', 
                  r'\frac{\partial u}{\partial t} = X(x)T^\prime(t), \quad \frac{\partial^2 u}{\partial x^2} = X^{\prime\prime}(x)T(t)', 
                  isDark
                ),
                
                const SizedBox(height: 10),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirTutorIA(context, primaryColor),
                    icon: const Icon(Icons.psychology),
                    label: const Text('Separar EDOs y resolver con IA'),
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
      'u': 'u', 'x': 'x', 'y': 'y', 't': 't',
      '\\partial': '\\partial', '\\frac{\\partial}{\\partial}': r'\frac{\partial}{\partial}', 
      '\\alpha^2': '\\alpha^2', 'c^2': 'c^2',
      '\\frac{x}{y}': r'\frac{}{}', 'x^2': '^2', '=': '=',
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