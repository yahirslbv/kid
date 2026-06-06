import 'package:flutter/material.dart';

// IMPORTAMOS DIRECTAMENTE LAS CALCULADORAS EN LUGAR DE LAS LISTAS DE TEORÍA
import 'edo_calculadoras_screen.dart';
import 'segundo_orden_calc_screen.dart';
import 'laplace_screen.dart';

// Estos se quedan igual porque ya son calculadoras/pantallas directas
import 'sistemas_series_screen.dart';
import 'frontera_screen.dart';
import 'edp_screen.dart';

class EcuacionesMainScreen extends StatelessWidget {
  const EcuacionesMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> modulos = [
      {
        'titulo': '1er Orden',
        'subtitulo': 'Separables, Exactas, Lineales',
        'icono': Icons.looks_one,
        'color': const Color(0xFF5B9BD5),
        'ruta': const EdoCalculadorasScreen(), // <-- RUTA DIRECTA AL HUB
      },
      {
        'titulo': '2do Orden Lineal',
        'subtitulo': 'Homogéneas y No Homogéneas',
        'icono': Icons.looks_two,
        'color': const Color(0xFF7C6BBD),
        'ruta': const SegundoOrdenCalcScreen(), // <-- RUTA DIRECTA A LA CALCULADORA
      },
      {
        'titulo': 'Laplace',
        'subtitulo': 'Transformadas y PVI',
        'icono': Icons.transform,
        'color': const Color(0xFFE67E3A),
        'ruta': const LaplaceScreen(), // <-- RUTA DIRECTA A LA CALCULADORA
      },
      {
        'titulo': 'Sistemas de ED',
        'subtitulo': 'Eigenvalores y Eigenvectores',
        'icono': Icons.account_tree,
        'color': const Color(0xFF4DB6AC),
        'ruta': const SistemasSeriesScreen(),
      },
      {
        'titulo': 'Frontera y Series',
        'subtitulo': 'Sturm-Liouville y Frobenius',
        'icono': Icons.waves,
        'color': const Color(0xFFF06292),
        'ruta': const FronteraScreen(),
      },
      {
        'titulo': 'EDPs',
        'subtitulo': 'Calor, Onda y Laplace',
        'icono': Icons.grid_3x3,
        'color': const Color(0xFF81C784),
        'ruta': const EdpScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ecuaciones Diferenciales'),
        backgroundColor: isDark ? const Color(0xFF1C3350) : const Color(0xFF2C3E50),
        elevation: 0,
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF4F7F6),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: modulos.length,
          itemBuilder: (context, index) {
            final mod = modulos[index];
            return _buildModuloCard(context, mod, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildModuloCard(BuildContext context, Map<String, dynamic> mod, bool isDark) {
    return Card(
      elevation: 4,
      shadowColor: mod['color'].withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF1C3350) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => mod['ruta']),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mod['color'].withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(mod['icono'], size: 40, color: mod['color']),
              ),
              const Spacer(),
              Text(
                mod['titulo'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mod['subtitulo'],
                textAlign: TextAlign.center,
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
  }
}