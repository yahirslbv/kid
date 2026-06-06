import 'package:flutter/material.dart';
import '../../metodos_numericos/screens/euler_screen.dart';
import '../../metodos_numericos/screens/rk4_screen.dart';
import 'separables_screen.dart';
import 'exactas_screen.dart';
import 'lineales_screen.dart'; 
import 'bernoulli_screen.dart';
import 'campos_pendientes_screen.dart';

class EdoCalculadorasScreen extends StatelessWidget {
  const EdoCalculadorasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF5B9BD5); // Color del módulo de EDOs

    return DefaultTabController(
      length: 2, // 2 pestañas: Analíticos y Numéricos
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calculadoras EDO'),
          backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.calculate), text: "Métodos Analíticos"),
              Tab(icon: Icon(Icons.computer), text: "Métodos Numéricos"),
            ],
          ),
        ),
        body: Container(
          color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
          child: TabBarView(
            children: [
              // PESTAÑA 1: MÉTODOS ANALÍTICOS
              _buildAnaliticosTab(context, isDark, primaryColor),

              // PESTAÑA 2: MÉTODOS NUMÉRICOS
              _buildNumericosTab(context, isDark, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnaliticosTab(BuildContext context, bool isDark, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            "Soluciones exactas paso a paso",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        // --- 1. VARIABLES SEPARABLES ---
        _SolverCard(
          title: "Variables Separables",
          subtitle: "Integra f(x)dx = g(y)dy",
          icon: Icons.call_split,
          color: primaryColor,
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const SeparablesScreen())
            );
          },
        ),
        // --- 2. ECUACIONES EXACTAS ---
        _SolverCard(
          title: "Ecuaciones Exactas",
          subtitle: "Verifica My = Nx y halla F(x,y)=C",
          icon: Icons.fact_check,
          color: primaryColor,
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const ExactasScreen())
            );
          },
        ),
        // --- 3. EDOs LINEALES ---
        _SolverCard(
          title: "EDO Lineal de 1er Orden",
          subtitle: "Usa factor integrante μ(x)",
          icon: Icons.functions, 
          color: primaryColor,
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const LinealesScreen())
            );
          },
        ),
        // --- 4. ECUACIÓN DE BERNOULLI (NUEVO) ---
        _SolverCard(
          title: "Ecuación de Bernoulli",
          subtitle: "Sustitución u = y^(1-n)",
          icon: Icons.transform,
          color: primaryColor,
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const BernoulliScreen())
            );
          },
        ),
        // --- 5. CAMPO DE PENDIENTES ---
        _SolverCard(
          title: "Campo de Pendientes",
          subtitle: "Visualiza la familia de soluciones",
          icon: Icons.show_chart,
          color: primaryColor,
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const CamposPendientesScreen())
            );
          },
        ),
      ],
    );
  }

  Widget _buildNumericosTab(BuildContext context, bool isDark, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
         const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            "Aproximaciones algorítmicas (Importadas)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        // --- 1. MÉTODO DE EULER ---
        _SolverCard(
          title: "Método de Euler",
          subtitle: "Aproximación lineal paso a paso",
          icon: Icons.trending_up,
          color: Colors.teal, 
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const EulerScreen())
            );
          },
        ),
        // --- 2. RUNGE-KUTTA RK4 ---
        _SolverCard(
          title: "Runge-Kutta (RK4)",
          subtitle: "Alta precisión con 4 pendientes",
          icon: Icons.polyline,
          color: Colors.teal,
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const RungeKuttaScreen()) 
            );
          },
        ),
      ],
    );
  }
}

// Widget auxiliar para mantener el diseño de las tarjetas limpio
class _SolverCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SolverCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF1C3350) : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title, 
          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)
        ),
        subtitle: Text(
          subtitle, 
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
        onTap: onTap,
      ),
    );
  }
}