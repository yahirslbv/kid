import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../../shared/app_imports.dart';

class TabuladorScreen extends StatefulWidget {
  const TabuladorScreen({super.key});

  @override
  State<TabuladorScreen> createState() => _TabuladorScreenState();
}

class _TabuladorScreenState extends State<TabuladorScreen> {
  final _funcionController = TextEditingController(text: 'x^2 - 4');
  final _x0Controller     = TextEditingController(text: '-5');
  final _xfController     = TextEditingController(text: '5');
  final _pasoController   = TextEditingController(text: '1');

  final List<Map<String, dynamic>> _tabla = [];
  String _mensajeError = '';

  @override
  void dispose() {
    _funcionController.dispose();
    _x0Controller.dispose();
    _xfController.dispose();
    _pasoController.dispose();
    super.dispose();
  }

  // ── Genera la tabla con la función actual ──────────────────────────────────
  void _tabular() {
    setState(() { _tabla.clear(); _mensajeError = ''; });

    final funcString = _funcionController.text.trim();
    final x0   = double.tryParse(_x0Controller.text)   ?? 0;
    final xf   = double.tryParse(_xfController.text)   ?? 0;
    final paso = double.tryParse(_pasoController.text)  ?? 1;

    if (paso <= 0) {
      setState(() => _mensajeError = 'El paso debe ser mayor a 0.');
      return;
    }
    if (x0 > xf) {
      setState(() => _mensajeError = 'x inicial no puede ser mayor a x final.');
      return;
    }

    try {
      final parser  = ShuntingYardParser();
      final exp     = parser.parse(funcString);
      final cm      = ContextModel();
      double currentX = x0;
      int limiter = 0;

      while (currentX <= xf + 0.0001 && limiter < 1000) {
        cm.bindVariable(Variable('x'), Number(currentX));
        final fDeX = exp.evaluate(EvaluationType.REAL, cm);
        _tabla.add({'x': currentX, 'fx': fDeX});
        currentX += paso;
        limiter++;
      }
    } catch (e) {
      setState(() => _mensajeError = 'Error de sintaxis. Usa "x" como variable.');
    }
  }

  // ── Abre el scanner y espera que devuelva la función ───────────────────────
  Future<void> _abrirScanner() async {
    // ScanProblemScreen devuelve un String con la función cuando tema='tabulador'
    final String? funcionEscaneada = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanProblemScreen(tema: 'tabulador'),
      ),
    );

    // Si el usuario escaneó algo válido, lo metemos al campo y tabulamos
    if (funcionEscaneada != null && funcionEscaneada.isNotEmpty) {
      setState(() {
        _funcionController.text = funcionEscaneada;
        _mensajeError = '';
      });
      // Auto-tabular con la función recién escaneada
      _tabular();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark        = Theme.of(context).brightness == Brightness.dark;
    final primaryColor  = const Color(0xFF009688);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(
        title: const Text('Tabulador de Funciones'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Tarjeta de inputs ───────────────────────────────────────────
            Card(
              color: isDark ? const Color(0xFF1C3350) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _funcionController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Función f(x)',
                        prefixIcon: const Icon(Icons.functions),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _inputField(_x0Controller,   'x inicial', isDark),
                        const SizedBox(width: 12),
                        _inputField(_xfController,   'x final',   isDark),
                        const SizedBox(width: 12),
                        _inputField(_pasoController, 'Paso',      isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _tabular,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Generar Tabla',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Error ───────────────────────────────────────────────────────
            if (_mensajeError.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Text(_mensajeError,
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),

            // ── Tabla ───────────────────────────────────────────────────────
            if (_tabla.isNotEmpty)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C3350) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7)),
                  ),
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(primaryColor.withValues(alpha: 0.1)),
                      columnSpacing: 60,
                      columns: const [
                        DataColumn(
                            label: Text('x',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16))),
                        DataColumn(
                            label: Text('f(x)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF009688)))),
                      ],
                      rows: _tabla
                          .map((row) => DataRow(cells: [
                                DataCell(Text(
                                    (row['x'] as double).toStringAsFixed(2))),
                                DataCell(Text(
                                    (row['fx'] as double).toStringAsFixed(4),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))),
                              ]))
                          .toList(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),

      // ── FABs: Escanear + Chatbot ──────────────────────────────────────────
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Botón chatbot
          FloatingActionButton(
            heroTag: 'btn_chat_tabulador',
            onPressed: () {
              context.read<ChatProvider>().setSection('Tabulador de Funciones');
              _showAssistant(context);
            },
            backgroundColor: const Color(0xFF6B8CAE),
            mini: true,
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
          ),
          const SizedBox(height: 12),
          // Botón escanear
          FloatingActionButton.extended(
            heroTag: 'btn_scan_tabulador',
            onPressed: _abrirScanner,
            backgroundColor: const Color(0xFF5B9BD5),
            icon: const Icon(Icons.document_scanner, color: Colors.white),
            label: const Text('Escanear Función',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _MiniChatTabulador(),
    );
  }

  // ── Helper campo numérico ─────────────────────────────────────────────────
  Widget _inputField(TextEditingController ctrl, String label, bool isDark) {
    return Expanded(
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}


// ── ASISTENTE RÁPIDO PARA TABULADOR ──────────────────────────────────────────
class _MiniChatTabulador extends StatefulWidget {
  const _MiniChatTabulador();
  @override
  State<_MiniChatTabulador> createState() => _MiniChatTabuladorState();
}

class _MiniChatTabuladorState extends State<_MiniChatTabulador> {
  final _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF009688);
    final chatProvider = context.watch<ChatProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12)),
            ),
            child: Row(
              children: [
                Icon(Icons.functions, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Tutor de Funciones',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: isDark ? Colors.white54 : Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ── Mensajes ──────────────────────────────────────────────────────
          Expanded(
            child: chatProvider.messages.isEmpty
                ? Center(
                    child: Text(
                      'Pregúntame sobre funciones, derivadas, dominio, intersecciones...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatProvider.messages[index];
                      return Align(
                        alignment: msg.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: msg.isUser
                                ? primaryColor
                                : (isDark
                                    ? const Color(0xFF234060)
                                    : const Color(0xFFEBF4FC)),
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight: msg.isUser
                                  ? const Radius.circular(0)
                                  : null,
                              bottomLeft: !msg.isUser
                                  ? const Radius.circular(0)
                                  : null,
                            ),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: msg.isUser
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.white
                                      : const Color(0xFF1A2D4A)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (chatProvider.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),

          // ── Input ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Pregunta sobre la función...',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 13),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0F1E2E)
                          : const Color(0xFFF0F7FF),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        chatProvider.sendMessage(_controller.text);
                        _controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}