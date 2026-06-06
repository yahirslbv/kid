import 'package:flutter/material.dart';

class GraficadorScreen extends StatefulWidget {
  const GraficadorScreen({super.key});

  @override
  State<GraficadorScreen> createState() => _GraficadorScreenState();
}

class _GraficadorScreenState extends State<GraficadorScreen> {
  // TODO: Aquí después conectaremos tu MecanicaProvider para manejar el estado de los vectores

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // 1. ZONA INTERACTIVA: El lienzo (Canvas)
          GestureDetector(
            onPanStart: (details) {
              // TODO: Lógica al empezar a arrastrar (detectar si tocó un nodo/vector)
            },
            onPanUpdate: (details) {
              // TODO: Lógica para actualizar las coordenadas en tiempo real (drag & drop)
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: _DCLPainter(), // motor de renderizado 2D
            ),
          ),

          // 2. INTERFAZ: Menú Flotante Lateral (Basado en Figma)
          Align(
            alignment: Alignment.centerLeft,
            child: _buildFloatingMenu(),
          ),
          
          // Marca de agua central temporal
          const Center(
            child: IgnorePointer( // Para que no interfiera con los toques del canvas
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.architecture, size: 80, color: Colors.black12),
                  SizedBox(height: 16),
                  Text(
                    'Diagrama de Cuerpo Libre',
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black26
                    ),
                  ),
                  Text(
                    'Selecciona una herramienta del menú flotante\ny toca en el canvas para posicionarla.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black26),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Constructor del menú flotante
  Widget _buildFloatingMenu() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Replicando los colores y formas de tu Figma
            _ToolButton(icon: Icons.close, color: Colors.red, isOutlined: true, onTap: (){}),
            const SizedBox(height: 8),
            _ToolButton(icon: Icons.arrow_forward, color: Colors.redAccent, onTap: (){}),
            _ToolButton(icon: Icons.refresh, color: Colors.purple, onTap: (){}),
            _ToolButton(icon: Icons.crop_square, color: Colors.black54, onTap: (){}),
            _ToolButton(icon: Icons.circle_outlined, color: Colors.black54, onTap: (){}),
            _ToolButton(icon: Icons.change_history, color: Colors.black54, onTap: (){}), // Triángulo
            _ToolButton(icon: Icons.anchor, color: Colors.orange, onTap: (){}),
            _ToolButton(icon: Icons.swap_vert, color: Colors.blue, onTap: (){}),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para los botones del menú flotante
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isOutlined;

  const _ToolButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: isOutlined 
        ? Container(
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(icon: Icon(icon, color: color), onPressed: onTap),
          )
        : IconButton(icon: Icon(icon, color: color), onPressed: onTap),
    );
  }
}

// -----------------------------------------------------------------------------
// EL PINCEL NATIVO (CustomPainter)
// -----------------------------------------------------------------------------
class _DCLPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dibujar la cuadrícula (Grid) de fondo
    final Paint gridPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..strokeWidth = 1.0;

    const double gridSize = 40.0;
    
    // Líneas verticales
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    // Líneas horizontales
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Dibujar el Nodo Origen Base (Centro de la pantalla)
    // En la Fase 1, todos los vectores nacen de aquí
    final Paint nodePaint = Paint()
      ..color = Colors.green // Color de UI
      ..style = PaintingStyle.fill;
    
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 6.0, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Cambiar a 'true' cuando el estado matemático/geométrico se actualice
    return false; 
  }
}