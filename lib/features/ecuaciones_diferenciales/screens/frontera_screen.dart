import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart';

class FronteraScreen extends StatefulWidget {
  const FronteraScreen({super.key});

  @override
  State<FronteraScreen> createState() => _FronteraScreenState();
}

class _FronteraScreenState extends State<FronteraScreen> {
  final TextEditingController _fxController = TextEditingController();
  final TextEditingController _lController = TextEditingController();
  
  final FocusNode _fxFocus = FocusNode();
  final FocusNode _lFocus = FocusNode();
  
  // --- CORRECCIÓN: Memoria del controlador ---
  TextEditingController? _ultimoControladorActivo;

  bool _mostrarResultado = false;

  // --- CORRECCIÓN: Rastrear cuando el usuario toca la caja ---
  @override
  void initState() {
    super.initState();
    _fxFocus.addListener(() {
      if (_fxFocus.hasFocus) _ultimoControladorActivo = _fxController;
    });
    _lFocus.addListener(() {
      if (_lFocus.hasFocus) _ultimoControladorActivo = _lController;
    });
  }

  @override
  void dispose() {
    _fxController.dispose();
    _lController.dispose();
    _fxFocus.dispose();
    _lFocus.dispose();
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
      if (simbolo == r'\int_{}^{}') offset -= 4;
      
      activeController.selection = TextSelection.collapsed(offset: offset);
      
      // Devolvemos el foco a la caja correspondiente
      if (activeController == _fxController) {
        _fxFocus.requestFocus();
      } else {
        _lFocus.requestFocus();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se requiere seleccionar una caja de texto para insertar el símbolo.')),
      );
    }
  }

  void _calcular() {
    if (_fxController.text.isEmpty || _lController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Es necesario ingresar la función f(x) y el valor de L.')),
      );
      return;
    }
    
    FocusScope.of(context).unfocus(); 
    setState(() {
      _mostrarResultado = true;
    });
  }

  void _abrirTutorIA(BuildContext context, Color colorTema) {
    final fx = _fxController.text.isNotEmpty ? _fxController.text : "0";
    final lText = _lController.text.isNotEmpty ? _lController.text : "L";

    final contextoDinamico = "El usuario se encuentra en la Calculadora de Series de Fourier (Valores en la Frontera). "
        "La función a expandir es f(x) = $fx en el intervalo de [-$lText, $lText]. "
        "La instrucción operativa es actuar como un tutor matemático objetivo. Si se requiere asistencia, "
        "se debe guiar paso a paso en la formulación y resolución de las integrales para los coeficientes "
        "a_0, a_n y b_n, determinando si la función es par o impar para simplificar los cálculos. "
        "Es obligatorio emplear formato LaTeX con \$\$ para las expresiones matemáticas.";

    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EdChatSheet(
        moduleName: 'Tutor: Series de Fourier',
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
        title: const Text('Valores Frontera / Fourier'),
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
                'Estructura de la Serie Trigonométrica de Fourier:',
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
                  child: Math.tex(
                    r'f(x) = \frac{a_0}{2} + \sum_{n=1}^{\infty} \left( a_n \cos\frac{n\pi x}{L} + b_n \sin\frac{n\pi x}{L} \right)',
                    textStyle: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Text('1. Función f(x):', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _fxController,
                focusNode: _fxFocus,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. x^2',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.functions),
                ),
              ),
              const SizedBox(height: 20),
              
              Text('2. Semilongitud del intervalo (L):', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _lController,
                focusNode: _lFocus,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. \\pi o 2',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.linear_scale),
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
                  icon: const Icon(Icons.waves, color: Colors.white),
                  label: const Text('Plantear Coeficientes', style: TextStyle(fontSize: 16, color: Colors.white)),
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
                Text('Integrales definidas de los coeficientes:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.blue[900])),
                const SizedBox(height: 15),
                _buildPaso(
                  context, 
                  'Coeficiente a\u2080', 
                  r'a_0 = \frac{1}{' + _lController.text + r'} \int_{-' + _lController.text + r'}^{' + _lController.text + r'} (' + _fxController.text + r') dx', 
                  isDark
                ),
                _buildPaso(
                  context, 
                  'Coeficiente a\u2099', 
                  r'a_n = \frac{1}{' + _lController.text + r'} \int_{-' + _lController.text + r'}^{' + _lController.text + r'} (' + _fxController.text + r') \cos\left(\frac{n\pi x}{' + _lController.text + r'}\right) dx', 
                  isDark
                ),
                _buildPaso(
                  context, 
                  'Coeficiente b\u2099', 
                  r'b_n = \frac{1}{' + _lController.text + r'} \int_{-' + _lController.text + r'}^{' + _lController.text + r'} (' + _fxController.text + r') \sin\left(\frac{n\pi x}{' + _lController.text + r'}\right) dx', 
                  isDark
                ),
                
                const SizedBox(height: 10),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirTutorIA(context, primaryColor),
                    icon: const Icon(Icons.psychology),
                    label: const Text('Integrar por partes con IA'),
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
      'x': 'x', 'n': 'n', '\\pi': '\\pi', 'L': 'L',
      '\\frac{x}{y}': r'\frac{}{}', 'x^2': '^2', 'x^n': '^{}',
      '\\sin': '\\sin()', '\\cos': '\\cos()', '\\int': r'\int_{}^{}'
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