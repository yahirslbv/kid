import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart';

class SistemasSeriesScreen extends StatelessWidget {
  const SistemasSeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF4DB6AC); // Teal para Sistemas/Series

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sistemas y Series'),
          backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.grid_4x4), text: "Sistemas (2x2)"),
              Tab(icon: Icon(Icons.waves), text: "Series de Potencias"),
            ],
          ),
        ),
        body: Container(
          color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
          child: TabBarView(
            children: [
              _SistemasTab(primaryColor: primaryColor, isDark: isDark),
              _SeriesTab(primaryColor: primaryColor, isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// PESTAÑA 1: SISTEMAS DE EDOs (Matriz 2x2 y Eigenvalores)
// =====================================================================
class _SistemasTab extends StatefulWidget {
  final Color primaryColor;
  final bool isDark;

  const _SistemasTab({required this.primaryColor, required this.isDark});

  @override
  State<_SistemasTab> createState() => _SistemasTabState();
}

class _SistemasTabState extends State<_SistemasTab> {
  final TextEditingController _a11Controller = TextEditingController();
  final TextEditingController _a12Controller = TextEditingController();
  final TextEditingController _a21Controller = TextEditingController();
  final TextEditingController _a22Controller = TextEditingController();
  
  bool _mostrarResultado = false;
  
  // Variables calculadas
  double _traza = 0;
  double _det = 0;
  String _polinomioLatex = "";

  @override
  void dispose() {
    _a11Controller.dispose();
    _a12Controller.dispose();
    _a21Controller.dispose();
    _a22Controller.dispose();
    super.dispose();
  }

  void _calcular() {
    if (_a11Controller.text.isEmpty || _a12Controller.text.isEmpty || 
        _a21Controller.text.isEmpty || _a22Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa los 4 componentes de la matriz A.')),
      );
      return;
    }
    
    // Convertir a doubles
    double a11 = double.tryParse(_a11Controller.text) ?? 0;
    double a12 = double.tryParse(_a12Controller.text) ?? 0;
    double a21 = double.tryParse(_a21Controller.text) ?? 0;
    double a22 = double.tryParse(_a22Controller.text) ?? 0;

    // Calcular Traza y Determinante
    _traza = a11 + a22;
    _det = (a11 * a22) - (a12 * a21);

    // Formatear el polinomio característico: λ^2 - Tλ + D = 0
    String fmt(double v) => v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
    
    String tStr = _traza == 0 ? "" : (_traza > 0 ? "- ${fmt(_traza)}" : "+ ${fmt(_traza.abs())}");
    if (_traza == 1) tStr = "- ";
    if (_traza == -1) tStr = "+ ";

    String dStr = _det == 0 ? "" : (_det > 0 ? "+ ${fmt(_det)}" : "- ${fmt(_det.abs())}");

    _polinomioLatex = r'\lambda^2 ' + (tStr.isNotEmpty ? tStr + r'\lambda ' : '') + dStr + ' = 0';

    FocusScope.of(context).unfocus(); 
    setState(() => _mostrarResultado = true);
  }

  void _abrirTutorIA() {
    final a11 = _a11Controller.text;
    final a12 = _a12Controller.text;
    final a21 = _a21Controller.text;
    final a22 = _a22Controller.text;

    final contexto = "El usuario quiere resolver el Sistema EDO X' = AX con matriz A=[[$a11, $a12], [$a21, $a22]]. "
        "El polinomio característico es $_polinomioLatex. "
        "Guíalo obteniendo los Eigenvalores (λ), los Eigenvectores y armando la solución general.";

    final chatProvider = context.read<ChatProvider>();
    chatProvider.setSection('Ecuaciones Diferenciales');
    
    // CORRECCIÓN: Envío directo del mensaje uniendo el contexto y la pregunta
    chatProvider.sendMessage(
      "$contexto\n\nAyúdame a resolver este sistema de EDOs. Ya calculé el polinomio característico: \$\$$_polinomioLatex\$\$"
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EdChatSheet(
        moduleName: 'Sistemas Matriciales',
        contextoDatos: contexto,
        colorTema: widget.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Math.tex(
              r'X^\prime = \begin{pmatrix} a_{11} & a_{12} \\ a_{21} & a_{22} \end{pmatrix} X',
              textStyle: TextStyle(fontSize: 22, color: widget.isDark ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 30),

          Text('Ingresa la Matriz A:', style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 15),
          
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1C3350) : Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildMatrixField('a11', _a11Controller)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildMatrixField('a12', _a12Controller)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _buildMatrixField('a21', _a21Controller)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildMatrixField('a22', _a22Controller)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _calcular,
              icon: const Icon(Icons.calculate, color: Colors.white),
              label: const Text('Calcular Polinomio', style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 30),

          if (_mostrarResultado) ...[
            const Divider(),
            const SizedBox(height: 15),
            _buildResultadoLocal('Traza (T = a + d)', _traza),
            _buildResultadoLocal('Determinante (D = ad - bc)', _det),
            
            const SizedBox(height: 10),
            Text('Polinomio Característico:', style: TextStyle(fontSize: 16, color: widget.isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.primaryColor),
              ),
              child: Center(
                child: Math.tex(_polinomioLatex, textStyle: TextStyle(fontSize: 20, color: widget.isDark ? Colors.amber : widget.primaryColor)),
              ),
            ),
            
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _abrirTutorIA,
                icon: const Icon(Icons.psychology, color: Colors.white),
                label: const Text('Calcular Eigenvalores con IA', style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE67E3A), // Naranja para resaltar la IA
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 40), 
          ]
        ],
      ),
    );
  }

  Widget _buildMatrixField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
      textAlign: TextAlign.center,
      style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: widget.isDark ? const Color(0xFF234060) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildResultadoLocal(String titulo, double valor) {
    String valStr = valor == valor.truncateToDouble() ? valor.toInt().toString() : valor.toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white70 : Colors.black87)),
          Text(valStr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.amber : widget.primaryColor)),
        ],
      ),
    );
  }
}

// =====================================================================
// PESTAÑA 2: SERIES DE POTENCIAS (Integración con IA)
// =====================================================================
class _SeriesTab extends StatefulWidget {
  final Color primaryColor;
  final bool isDark;

  const _SeriesTab({required this.primaryColor, required this.isDark});

  @override
  State<_SeriesTab> createState() => _SeriesTabState();
}

class _SeriesTabState extends State<_SeriesTab> {
  final TextEditingController _edoController = TextEditingController();
  final TextEditingController _x0Controller = TextEditingController(text: "0");

  void _resolverConIA() {
    if (_edoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa la EDO a resolver.')));
      return;
    }

    final edo = _edoController.text;
    final x0 = _x0Controller.text.isEmpty ? "0" : _x0Controller.text;
    
    final contexto = "El usuario quiere resolver la EDO: $edo mediante Series de Potencias centradas en x_0 = $x0. "
        "Guíalo paso a paso para sustituir y = Σ c_n (x-x_0)^n, ajustar índices, encontrar la relación de recurrencia "
        "y dar los primeros términos de la serie solución.";

    final chatProvider = context.read<ChatProvider>();
    chatProvider.setSection('Ecuaciones Diferenciales');
    
    // CORRECCIÓN: Envío directo uniendo contexto y pregunta en un solo string
    chatProvider.sendMessage(
      "$contexto\n\nResuelve por Series de Potencias alrededor de x_0 = $x0 esta ecuación: $edo"
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EdChatSheet(
        moduleName: 'Series de Potencias',
        contextoDatos: contexto,
        colorTema: widget.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Math.tex(
              r'y = \sum_{n=0}^{\infty} c_n (x - x_0)^n',
              textStyle: TextStyle(fontSize: 22, color: widget.isDark ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 30),

          Text('1. Ingresa la Ecuación Diferencial:', style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          TextField(
            controller: _edoController,
            style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: "Ej. y'' - xy = 0",
              filled: true,
              fillColor: widget.isDark ? const Color(0xFF234060) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: Icon(Icons.functions, color: widget.primaryColor),
            ),
          ),
          const SizedBox(height: 20),

          Text('2. Punto de expansión (x_0):', style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          TextField(
            controller: _x0Controller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: "Por lo general es 0",
              filled: true,
              fillColor: widget.isDark ? const Color(0xFF234060) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: Icon(Icons.adjust, color: widget.primaryColor),
            ),
          ),
          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.primaryColor.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: widget.primaryColor, size: 30),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    'Debido a los desplazamientos de índices y relaciones de recurrencia, el Asistente IA desarrollará la suma infinita paso a paso.',
                    style: TextStyle(fontSize: 13, color: widget.isDark ? Colors.white70 : Colors.black87),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _resolverConIA,
              icon: const Icon(Icons.send, color: Colors.white),
              label: const Text('Resolver Serie con IA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}