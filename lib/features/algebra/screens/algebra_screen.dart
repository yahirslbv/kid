import 'package:flutter/material.dart';
import '../../../shared/app_imports.dart';

class AlgebraScreen extends StatelessWidget {
  const AlgebraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF5B9BD5);

    // Aquí definimos las tarjetas de las herramientas de Álgebra
    final tools = [
      {
        'title': 'Tabulador',
        'icon': Icons.table_view_rounded,
        'description': 'Genera tablas de valores para cualquier función f(x).',
      },
      {
        'title': 'Fórmula General',
        'icon': Icons.functions_rounded,
        'description': 'Resuelve ecuaciones cuadráticas (reales e imaginarias).',
      },
      {
        'title': 'Operaciones con Matrices',
        'icon': Icons.grid_4x4_rounded,
        'description': 'Suma, resta y multiplicación de matrices 2x2 y 3x3.',
      },
      {
        'title': 'Determinantes',
        'icon': Icons.calculate_outlined,
        'description': 'Calcula el determinante exacto de una matriz.',
      },
      {
        'title': 'División Sintética',
        'icon': Icons.linear_scale_rounded,
        'description': 'Regla de Ruffini para polinomios de grado superior.',
      },
      {
        'title': 'Números Complejos',
        'icon': Icons.bolt_rounded,
        'description': 'Operaciones con números imaginarios (a + bi).',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── BANNER INTRODUCTORIO (Igual que en Métodos Numéricos) ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C3350) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Álgebra y Funciones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Selecciona la herramienta algebraica o calculadora que necesites.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : const Color(0xFF6B8CAE),
                  ),
                ),
              ],
            ),
          ),

          // ── GRID DE HERRAMIENTAS ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: tools.length,
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  return GestureDetector(
                    onTap: () {
                      if (tool['title'] == 'Tabulador') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const TabuladorScreen()));
                      } else if (tool['title'] == 'Fórmula General') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EcuacionesCuadraticasScreen()));
                      } else if (tool['title'] == 'Operaciones con Matrices') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OperacionesMatricesScreen()));
                      } else if (tool['title'] == 'Determinantes') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DeterminantesScreen()));
                      } else if (tool['title'] == 'División Sintética') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DivisionSinteticaScreen()));
                      } else if (tool['title'] == 'Números Complejos') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NumerosComplejosScreen()));
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C3350) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                tool['icon'] as IconData,
                                size: 32,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              tool['title'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tool['description'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn_asistente_algebra', 
        onPressed: () {
          context.read<ChatProvider>().setSection('Álgebra y Funciones');
          _showAssistant(context);
        },
        backgroundColor: const Color(0xFF6B8CAE),
        elevation: 4,
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
      ),
    );
  }

  void _showAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _MiniChatAssistantAlgebra(),
    );
  }
}

// ── ASISTENTE RÁPIDO PARA ÁLGEBRA ──
class _MiniChatAssistantAlgebra extends StatefulWidget {
  const _MiniChatAssistantAlgebra();
  @override
  State<_MiniChatAssistantAlgebra> createState() => _MiniChatAssistantAlgebraState();
}

class _MiniChatAssistantAlgebraState extends State<_MiniChatAssistantAlgebra> {
  final _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF5B9BD5);
    final chatProvider = context.watch<ChatProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))),
            child: Row(
              children: [
                Icon(Icons.calculate_rounded, color: primaryColor),
                const SizedBox(width: 8),
                Text("Tutor de Álgebra", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))),
                const Spacer(),
                IconButton(icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54), onPressed: () => Navigator.pop(context))
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final msg = chatProvider.messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: msg.isUser ? primaryColor : (isDark ? const Color(0xFF234060) : const Color(0xFFEBF4FC)),
                      borderRadius: BorderRadius.circular(16).copyWith(bottomRight: msg.isUser ? const Radius.circular(0) : null, bottomLeft: !msg.isUser ? const Radius.circular(0) : null),
                    ),
                    child: Text(msg.text, style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A2D4A)))),
                  ),
                );
              },
            ),
          ),
          if (chatProvider.isLoading) const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Pregunta sobre factorizaciones, polinomios...",
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                      filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: primaryColor,
                  child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), onPressed: () {
                    if (_controller.text.isNotEmpty) { chatProvider.sendMessage(_controller.text); _controller.clear(); }
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