import 'package:flutter/material.dart';
import '../../../shared/app_imports.dart';

// Importamos todas las pantallas de estadística que hemos creado
import 'intervalos_confianza_screen.dart';
import 'pruebas_hipotesis_screen.dart';
import 'regresion_correlacion_screen.dart';
import 'anova_screen.dart';
import 'control_calidad_screen.dart';

class EstadisticaScreen extends StatelessWidget {
  const EstadisticaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Lista de herramientas basadas en el libro de Miller & Freund
    final List<Map<String, dynamic>> tools = [
      {
        'title': 'Estadística Descriptiva',
        'subtitle': 'Media, Varianza, Cuartiles',
        'icon': Icons.data_exploration_rounded,
        'color': const Color(0xFF5B9BD5),
      },
      {
        'title': 'Distribuciones Discretas',
        'subtitle': 'Binomial, Poisson, Hipergeométrica',
        'icon': Icons.bar_chart_rounded,
        'color': const Color(0xFF4CAF50),
      },
      {
        'title': 'Distribuciones Continuas',
        'subtitle': 'Normal, Exponencial, Weibull',
        'icon': Icons.show_chart_rounded,
        'color': const Color(0xFFFF9800), 
      },
      {
        'title': 'Intervalos de Confianza',
        'subtitle': 'Estimación de medias y varianzas',
        'icon': Icons.compare_arrows_rounded,
        'color': const Color(0xFF9C27B0),
      },
      {
        'title': 'Pruebas de Hipótesis',
        'subtitle': 'Pruebas Z, T-Student, Chi-cuadrada',
        'icon': Icons.rule_rounded,
        'color': const Color(0xFFE91E63),
      },
      {
        'title': 'Regresión y Correlación',
        'subtitle': 'Mínimos cuadrados, R-cuadrado',
        'icon': Icons.insights_rounded,
        'color': const Color(0xFF00BCD4),
      },
      {
        'title': 'Análisis de Varianza',
        'subtitle': 'ANOVA de uno y dos factores',
        'icon': Icons.table_chart_rounded,
        'color': const Color(0xFF3F51B5),
      },
      {
        'title': 'Control de Calidad',
        'subtitle': 'Gráficos de control X̄, R, S',
        'icon': Icons.verified_rounded,
        'color': const Color(0xFF607D8B),
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
                  'Probabilidad y Estadistica',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Selecciona el módulo estadístico que necesitas para resolver tu problema.',
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
                    // --- NAVEGACIÓN REFACTORIZADA CON SWITCH ---
                    switch (tool['title']) {
                      case 'Estadística Descriptiva':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DescriptivaScreen()));
                      case 'Distribuciones Discretas':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DistribucionesDiscretasScreen()));
                      case 'Distribuciones Continuas':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DistribucionesContinuasScreen()));
                      case 'Intervalos de Confianza':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const IntervalosConfianzaScreen()));
                      case 'Pruebas de Hipótesis':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PruebasHipotesisScreen()));
                      case 'Regresión y Correlación':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RegresionCorrelacionScreen()));
                      case 'Análisis de Varianza':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AnovaScreen()));
                      case 'Control de Calidad':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ControlCalidadScreen()));
                      
                      default:
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Módulo de ${tool['title']} en desarrollo...'),
                            backgroundColor: const Color(0xFF5B9BD5),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Dejamos solo el asistente en el menú principal
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn_asistente_estadistica',
        onPressed: () => _showAssistant(context),
        backgroundColor: const Color(0xFF6B8CAE),
        elevation: 4,
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
      ),
    );
  }

  void _showAssistant(BuildContext context) {
    context.read<ChatProvider>().setSection('Estadística');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _MiniChatAssistantStats(),
    );
  }
}

// ── WIDGET PARA LAS CARTAS DEL MENÚ ───────────────────────────────────────────
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
    required this.onTap,
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
          border: Border.all(
            color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : const Color(0xFF6B8CAE),
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── ASISTENTE RÁPIDO PARA ESTADÍSTICA (BOTTOM SHEET) ──────────────────────────
class _MiniChatAssistantStats extends StatefulWidget {
  const _MiniChatAssistantStats();

  @override
  State<_MiniChatAssistantStats> createState() => _MiniChatAssistantStatsState();
}

class _MiniChatAssistantStatsState extends State<_MiniChatAssistantStats> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: Color(0xFF5B9BD5)),
                const SizedBox(width: 8),
                Text(
                  "Tutor de Miller & Freund",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A)),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),

          // Historial de mensajes
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
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: msg.isUser ? const Radius.circular(0) : null,
                        bottomLeft: !msg.isUser ? const Radius.circular(0) : null,
                      ),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A2D4A))),
                    ),
                  ),
                );
              },
            ),
          ),

          if (chatProvider.isLoading)
            const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),

          // Input de texto
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Duda sobre distribuciones, ANOVA...",
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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