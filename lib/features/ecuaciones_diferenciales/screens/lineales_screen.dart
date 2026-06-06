import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart';

class LinealesScreen extends StatefulWidget {
  const LinealesScreen({super.key});

  @override
  State<LinealesScreen> createState() => _LinealesScreenState();
}

class _LinealesScreenState extends State<LinealesScreen> {
  final TextEditingController _pxController = TextEditingController();
  final TextEditingController _qxController = TextEditingController();
  
  final FocusNode _pxFocus = FocusNode();
  final FocusNode _qxFocus = FocusNode();
  
  TextEditingController? _ultimoControladorActivo;
  
  bool _mostrarResultado = false;

  @override
  void initState() {
    super.initState();
    _pxFocus.addListener(() {
      if (_pxFocus.hasFocus) _ultimoControladorActivo = _pxController;
    });
    _qxFocus.addListener(() {
      if (_qxFocus.hasFocus) _ultimoControladorActivo = _qxController;
    });
  }

  @override
  void dispose() {
    _pxController.dispose();
    _qxController.dispose();
    _pxFocus.dispose();
    _qxFocus.dispose();
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
      
      if (activeController == _pxController) {
        _pxFocus.requestFocus();
      } else {
        _qxFocus.requestFocus();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una caja de texto primero para insertar el símbolo.')),
      );
    }
  }

  void _calcular() {
    if (_pxController.text.isEmpty || _qxController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa P(x) y Q(x).')),
      );
      return;
    }
    
    FocusScope.of(context).unfocus(); 
    setState(() {
      _mostrarResultado = true;
    });
  }

  void _abrirTutorIA(BuildContext context, Color colorTema) {
    final pxText = _pxController.text.isNotEmpty ? _pxController.text : "no definida";
    final qxText = _qxController.text.isNotEmpty ? _qxController.text : "no definida";

    final contextoDinamico = "El usuario está usando la Calculadora de Ecuaciones Diferenciales Lineales. "
        "Intenta resolver la ecuación en su forma estándar: dy/dx + ($pxText)y = ($qxText). "
        "La tarea es actuar como un tutor matemático objetivo. Si se solicita ayuda, se debe guiar paso a paso "
        "para encontrar el factor integrante mu(x) = e^{\\int P(x)dx} y posteriormente resolver la integral de Q(x)*mu(x). "
        "Se debe utilizar formato LaTeX con \$\$ para las expresiones matemáticas.";

    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EdChatSheet(
        moduleName: 'Tutor: EDOs Lineales',
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
        title: const Text('Ecuaciones Lineales'),
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
                'Lleva la ecuación a su forma estándar:',
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
                    r'\frac{dy}{dx} + P(x)y = Q(x)',
                    textStyle: TextStyle(fontSize: 22, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Text('1. Ingresa P(x):', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _pxController,
                focusNode: _pxFocus,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. 2/x',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.functions),
                ),
              ),
              const SizedBox(height: 20),
              
              Text('2. Ingresa Q(x):', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _qxController,
                focusNode: _qxFocus,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. x^2',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.functions),
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
                _buildPaso(context, '1. Calcular Factor Integrante', r'\mu(x) = e^{\int (' + _pxController.text + r') dx}', isDark),
                _buildPaso(context, '2. Plantear Integral General', r'y \cdot \mu(x) = \int \mu(x) \cdot (' + _qxController.text + r') dx + C', isDark),
                
                const SizedBox(height: 10),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirTutorIA(context, primaryColor),
                    icon: const Icon(Icons.psychology),
                    label: const Text('Solicitar desarrollo paso a paso'),
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