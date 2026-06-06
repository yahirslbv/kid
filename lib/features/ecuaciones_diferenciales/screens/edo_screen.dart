import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/ecuaciones_provider.dart';
import 'tema_detalle_screen.dart';
import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart'; // El componente de chat centralizado
import 'edo_calculadoras_screen.dart'; // <-- NUEVO: Importamos la pantalla de calculadoras

class EdoScreen extends StatefulWidget {
  const EdoScreen({super.key});

  @override
  State<EdoScreen> createState() => _EdoScreenState();
}

class _EdoScreenState extends State<EdoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EcuacionesProvider>().fetchTemasPorCategoria('EDOs');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EcuacionesProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Este color coincide con el que le dimos a este módulo en el GridView
    final primaryColor = const Color(0xFF5B9BD5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EDOs de 1er Orden'),
        backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
        elevation: 0,
        actions: [
          // <-- NUEVO: Botón de calculadoras en la barra superior
          IconButton(
            icon: const Icon(Icons.calculate, color: Colors.white),
            tooltip: 'Calculadoras y Solvers',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EdoCalculadorasScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
        child: provider.isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: provider.temasCargados.length,
                itemBuilder: (context, index) {
                  final tema = provider.temasCargados[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: isDark ? Colors.transparent : Colors.blue.shade100, width: 1),
                    ),
                    color: isDark ? const Color(0xFF1C3350) : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.2),
                        child: Icon(Icons.menu_book, color: primaryColor),
                      ),
                      title: Text(
                        tema['titulo'] ?? 'Tema sin título',
                        style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.blue[900]),
                      ),
                      subtitle: Text(
                        'Fuente: ${tema['bibliografia'] ?? 'Desconocida'}',
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TemaDetalleScreen(tema: tema),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAssistant(context, primaryColor),
        backgroundColor: primaryColor,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  void _showAssistant(BuildContext context, Color color) {
    String contexto = "El usuario está en el módulo de EDOs de 1er Orden explorando los temas disponibles.";
    
    // Configuramos la sección de forma global para que coincida con el switch en chat_provider
    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales');

    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => EdChatSheet(
        moduleName: 'EDOs de 1er Orden',
        contextoDatos: contexto,
        colorTema: color,
      )
    );
  }
} 