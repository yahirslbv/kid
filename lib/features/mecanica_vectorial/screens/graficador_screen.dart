import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../app.dart';
import '../logic/mecanica_provider.dart';
import '../models/vector_fuerza.dart';
import 'mecanica_chat_sheet.dart'; 

class GraficadorScreen extends StatefulWidget {
  const GraficadorScreen({super.key});

  @override
  State<GraficadorScreen> createState() => _GraficadorScreenState();
}

class _GraficadorScreenState extends State<GraficadorScreen> {

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MecanicaProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      // --- BOTÓN FLOTANTE ESTILO EDO (TUTOR IA) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Extrae el contexto minificado del Provider limpio
          String contextoMimificado = provider.obtenerContextoParaIA(); 
          showAssistantMecanica(context, AppColors.skyBlue, contextoMimificado);
        },
        backgroundColor: AppColors.skyBlue,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),

      body: Stack(
        children: [
          // 1. EL LIENZO (Conectado a la lista de vectores del Provider)
          CustomPaint(
            size: Size.infinite,
            painter: _DCLPainter(
              gridColor: AppColors.skyBlue.withOpacity(0.1), 
              nodeColor: AppColors.accent,
              vectorColor: AppColors.skyBlueDark,
              vectores: provider.vectores, 
            ),
          ),

          // 2. MENÚ FLOTANTE LATERAL
          Align(
            alignment: Alignment.centerLeft,
            child: _buildFloatingMenu(context, provider),
          ),
          
          // 3. INDICADOR DE CARGA (Si la API está calculando)
          if (provider.estadoCanvas.name == 'calculando')
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.skyBlue),
              ),
            ),

          // 4. MARCA DE AGUA (Lienzo Vacío)
          if (provider.isCanvasEmpty)
            Center(
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.architecture, size: 80, color: AppColors.textSecondary.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'Lienzo Vacío',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textSecondary.withOpacity(0.4)),
                    ),
                    Text(
                      'Usa el botón azul de la izquierda\npara agregar tu primer vector.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary.withOpacity(0.4)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Menú flotante lateral
  Widget _buildFloatingMenu(BuildContext context, MecanicaProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.skyBlueLight, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToolButton(
              icon: Icons.delete_outline, 
              color: Theme.of(context).colorScheme.error, 
              isOutlined: true, 
              onTap: () => provider.limpiarLienzo(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(height: 1, width: 24, color: AppColors.divider),
            ),
            _ToolButton(
              icon: Icons.arrow_outward, 
              color: AppColors.skyBlue, 
              onTap: () => _mostrarDialogoNuevoVector(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  // Modal para agregar vector
  void _mostrarDialogoNuevoVector(BuildContext context, MecanicaProvider provider) {
    double magnitud = 0.0;
    double angulo = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Vector'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Magnitud (ej. 500 N)'),
                onChanged: (val) => magnitud = double.tryParse(val) ?? 0.0,
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Ángulo (0° a 360°)'),
                onChanged: (val) => angulo = double.tryParse(val) ?? 0.0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancelar')
            ),
            ElevatedButton(
              onPressed: () {
                final nuevoVector = VectorFuerza(
                  id: UniqueKey().toString(),
                  magnitud: magnitud,
                  anguloGrados: angulo,
                );
                provider.agregarVector(nuevoVector);
                Navigator.pop(context);
              },
              child: const Text('Trazar'),
            ),
          ],
        );
      }
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isOutlined;

  const _ToolButton({required this.icon, required this.color, required this.onTap, this.isOutlined = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: isOutlined 
        ? Container(
            decoration: BoxDecoration(border: Border.all(color: color, width: 1.5), borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: Icon(icon, color: color), onPressed: onTap),
          )
        : IconButton(icon: Icon(icon, color: color), onPressed: onTap),
    );
  }
}

class _DCLPainter extends CustomPainter {
  final Color gridColor;
  final Color nodeColor;
  final Color vectorColor;
  final List<VectorFuerza> vectores;

  _DCLPainter({required this.gridColor, required this.nodeColor, required this.vectorColor, required this.vectores});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()..color = gridColor..strokeWidth = 1.0;
    const double gridSize = 40.0;
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final Offset center = Offset(size.width / 2, size.height / 2);

    final Paint vectorPaint = Paint()..color = vectorColor..strokeWidth = 3.0..strokeCap = StrokeCap.round;

    for (var vector in vectores) {
      double rad = -vector.anguloGrados * (pi / 180.0);
      double lengthVisual = 100.0; 
      double dx = lengthVisual * cos(rad);
      double dy = lengthVisual * sin(rad);
      Offset destino = Offset(center.dx + dx, center.dy + dy);

      canvas.drawLine(center, destino, vectorPaint);
      canvas.drawCircle(destino, 4.0, vectorPaint);
    }

    final Paint nodePaint = Paint()..color = nodeColor..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8.0, nodePaint);
  }

  @override
  bool shouldRepaint(covariant _DCLPainter oldDelegate) {
    return oldDelegate.vectores.length != vectores.length; 
  }
}