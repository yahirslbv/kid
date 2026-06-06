import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart'; 
import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart'; 

class TemaDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> tema;

  const TemaDetalleScreen({super.key, required this.tema});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF5B9BD5);

    // Se extrae la lista de contenido dinámica proveniente de Firebase
    final List<dynamic> contenidoTeorico = tema['contenido'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(tema['titulo'] ?? 'Detalle del Tema', overflow: TextOverflow.ellipsis),
        backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Etiqueta de Bibliografía
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF234060) : primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book, size: 16, color: isDark ? Colors.white70 : primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      tema['bibliografia'] ?? 'Fuente no especificada',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.blue[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Generación dinámica del contenido teórico
              ...contenidoTeorico.map((fragmento) => _renderizarFragmento(fragmento, isDark)).toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAssistant(context, primaryColor, tema),
        backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
        icon: const Icon(Icons.psychology, color: Colors.white),
        label: const Text('Tutor IA', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Motor de renderizado de fragmentos
  Widget _renderizarFragmento(Map<String, dynamic> fragmento, bool isDark) {
    final String tipo = fragmento['tipo'] ?? 'texto';
    final String valor = fragmento['valor'] ?? '';

    switch (tipo) {
      case 'texto':
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Text(
            valor,
            style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black87, height: 1.5),
          ),
        );
      case 'formula_bloque':
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C3350) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? Colors.transparent : Colors.blue.shade100),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                ]
              ),
              child: Math.tex(
                valor,
                textStyle: TextStyle(fontSize: 22, color: isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
        );
      case 'formula_inline':
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Math.tex(
            valor, 
            textStyle: TextStyle(fontSize: 18, color: isDark ? Colors.amber : Colors.blue[900])
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showAssistant(BuildContext context, Color color, Map<String, dynamic> tema) {
    String contexto = "Tema de Ecuaciones Diferenciales: ${tema['titulo']}. Basado en el libro: ${tema['bibliografia']}. El usuario está leyendo la teoría.";
    
    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales');

    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => EdChatSheet(
        moduleName: 'Tutor: ${tema['titulo']}',
        contextoDatos: contexto,
        colorTema: color,
      )
    );
  }
}