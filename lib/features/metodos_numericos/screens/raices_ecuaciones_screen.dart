import 'package:flutter/material.dart';
import '../../../shared/app_imports.dart';

class RaicesEcuacionesScreen extends StatelessWidget {
  const RaicesEcuacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF5B9BD5);

    return DefaultTabController(
      length: 3, // Número de pestañas
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
        appBar: AppBar(
          title: const Text('Raíces de Ecuaciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: primaryColor,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'Bisección'),
              Tab(text: 'Newton-R.'),
              Tab(text: 'Secante'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Pestaña 1
            BiseccionScreen(),
            // Pestaña 2
            NewtonRaphsonScreen(),
            // Pestaña 3
            SecanteScreen(),
          ],
        ),
        
        // --- NUEVO: BOTÓN FLOTANTE DEL ASISTENTE ---
        // --- MODIFICADO: COLUMNA CON AMBOS BOTONES ---
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 1. Botón del Escáner
            FloatingActionButton.extended(
              heroTag: 'btn_scan_raices', // Tag único para el escáner
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Le enviamos a Python el tema general de "raíces"
                    builder: (context) => const ScanProblemScreen(tema: 'raices'), 
                  ),
                );
              },
              backgroundColor: const Color(0xFF5B9BD5),
              icon: const Icon(Icons.document_scanner, color: Colors.white),
              label: const Text('Escanear Función', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            // 2. Botón del Asistente (El que ya tenías)
            FloatingActionButton(
              heroTag: 'btn_asistente_raices', 
              onPressed: () {
                context.read<ChatProvider>().setSection('Métodos Numéricos');
                _showAssistant(context);
              },
              backgroundColor: const Color(0xFF6B8CAE),
              elevation: 4,
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // --- NUEVA FUNCIÓN: MOSTRAR EL BOTTOM SHEET ---
  void _showAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _MiniChatAssistantRaices(),
    );
  }
}

// ── ASISTENTE RÁPIDO PARA RAÍCES DE ECUACIONES (BOTTOM SHEET) ──
class _MiniChatAssistantRaices extends StatefulWidget {
  const _MiniChatAssistantRaices();

  @override
  State<_MiniChatAssistantRaices> createState() => _MiniChatAssistantRaicesState();
}

class _MiniChatAssistantRaicesState extends State<_MiniChatAssistantRaices> {
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
                      hintText: "Dudas sobre Bisección, Newton...",
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