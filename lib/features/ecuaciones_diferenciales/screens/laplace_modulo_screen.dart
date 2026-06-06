import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/ecuaciones_provider.dart';
import 'tema_detalle_screen.dart';
import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart';
import 'laplace_screen.dart';

class LaplaceModuloScreen extends StatefulWidget {
  const LaplaceModuloScreen({super.key});

  @override
  State<LaplaceModuloScreen> createState() => _LaplaceModuloScreenState();
}

class _LaplaceModuloScreenState extends State<LaplaceModuloScreen> {
  @override
  void initState() {
    super.initState();
    // Pide los temas de la categoría 'Laplace' a tu base de datos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EcuacionesProvider>().fetchTemasPorCategoria('Laplace');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EcuacionesProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Color naranja asignado en el GridView
    final primaryColor = const Color(0xFFE67E3A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transformada de Laplace'),
        backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
        elevation: 0,
        actions: [
          // NUEVO BOTÓN: Atajo a la Calculadora de Transformadas
          IconButton(
            icon: const Icon(Icons.calculate, color: Colors.white),
            tooltip: 'Calculadora de Laplace',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LaplaceScreen()),
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
                      side: BorderSide(color: isDark ? Colors.transparent : primaryColor.withOpacity(0.3), width: 1),
                    ),
                    color: isDark ? const Color(0xFF1C3350) : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.2),
                        child: Icon(Icons.functions, color: primaryColor),
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
    String contexto = "El usuario está explorando la teoría de la Transformada de Laplace, funciones escalón de Heaviside y transformadas inversas.";
    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales');

    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => EdChatSheet(
        moduleName: 'Laplace',
        contextoDatos: contexto,
        colorTema: color,
      )
    );
  }
}