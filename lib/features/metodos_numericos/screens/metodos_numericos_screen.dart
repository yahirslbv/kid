import 'package:flutter/material.dart';
import '../../../shared/app_imports.dart';

class MetodosNumericosScreen extends StatelessWidget {
  const MetodosNumericosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Lista de herramientas de Métodos Numéricos
    final List<Map<String, dynamic>> tools = [
      {
        'title': 'Raíces de Ecuaciones',
        'subtitle': 'Bisección, Newton-Raphson, Secante',
        'icon': Icons.timeline_rounded,
        'color': const Color(0xFF5B9BD5), // Azul
      },
      {
        'title': 'Sistemas Lineales',
        'subtitle': 'Gauss-Jordan, Jacobi, Gauss-Seidel',
        'icon': Icons.grid_on_rounded,
        'color': const Color(0xFF4CAF50), // Verde
      },
      {
        'title': 'Ajuste de Curvas',
        'subtitle': 'Interpolación, Mínimos Cuadrados',
        'icon': Icons.insights_rounded,
        'color': const Color(0xFFFF9800), // Naranja
      },
      {
        'title': 'Integración Numérica',
        'subtitle': 'Trapecio, Simpson 1/3 y 3/8',
        'icon': Icons.area_chart_rounded,
        'color': const Color(0xFF9C27B0), // Morado
      },
      {
        'title': 'Ecuaciones Diferenciales',
        'subtitle': 'Euler, Runge-Kutta (RK4)',
        'icon': Icons.waves_rounded,
        'color': const Color(0xFFE91E63), // Rosa
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner introductorio
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
                  'Métodos Numéricos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Selecciona el método numérico para aproximar tu solución.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : const Color(0xFF6B8CAE),
                  ),
                ),
              ],
            ),
          ),

          // Grid de calculadoras
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85, 
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return _ToolCard(
                  title: tool['title'],
                  subtitle: tool['subtitle'],
                  icon: tool['icon'],
                  color: tool['color'],
                  isDark: isDark,
                  onTap: () {
                    // --- ACTUALIZADO: AHORA MANDA A LA PANTALLA AGRUPADORA ---
                    if (tool['title'] == 'Raíces de Ecuaciones') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RaicesEcuacionesScreen()),
                      );  
                    }
                    else if (tool['title'] == 'Sistemas Lineales') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SistemasLinealesScreen()));
                    } 
                    else if (tool['title'] == 'Ajuste de Curvas') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AjusteCurvasScreen()));
                    }
                    else if (tool['title'] == 'Integración Numérica') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const IntegracionNumericaScreen()));
                    }
                    else if (tool['title'] == 'Ecuaciones Diferenciales') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EcuacionesDiferencialesScreen()));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Reemplaza el floatingActionButton actual por esta columna:
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn_asistente_metodos',
        onPressed: () {
          context.read<ChatProvider>().setSection('Métodos Numéricos');
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
      builder: (context) => const _MiniChatAssistantNumericos(),
    );
  }
}

// ── WIDGET PARA LAS CARTAS DEL MENÚ ──
class _ToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title, 
    required this.subtitle, 
    required this.icon, 
    required this.color, 
    required this.isDark, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C3350) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : color.withValues(alpha: 0.1), 
              blurRadius: 12, 
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15), 
                borderRadius: BorderRadius.circular(12)
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A), height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : const Color(0xFF6B8CAE), height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── ASISTENTE RÁPIDO PARA MÉTODOS NUMÉRICOS (BOTTOM SHEET) ──
class _MiniChatAssistantNumericos extends StatefulWidget {
  const _MiniChatAssistantNumericos();

  @override
  State<_MiniChatAssistantNumericos> createState() => _MiniChatAssistantNumericosState();
}

class _MiniChatAssistantNumericosState extends State<_MiniChatAssistantNumericos> {
  final _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                const Icon(Icons.code_rounded, color: Color(0xFF5B9BD5)),
                const SizedBox(width: 8),
                Text("Tutor Numérico", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))),
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
                      color: msg.isUser ? const Color(0xFF5B9BD5) : (isDark ? const Color(0xFF234060) : const Color(0xFFEBF4FC)),
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
                      hintText: "Duda sobre Bisección, errores...",
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                      filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF5B9BD5),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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