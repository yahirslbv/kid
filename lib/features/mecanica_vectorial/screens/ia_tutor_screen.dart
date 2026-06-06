import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app.dart';
import '../logic/mecanica_provider.dart';
import '../models/estado_canvas.dart';
import 'mecanica_chat_sheet.dart';

class IaTutorScreen extends StatelessWidget {
  const IaTutorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MecanicaProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Helper para leer el estado del Enum
    String getTextoEstado() {
      switch (provider.estadoCanvas) {
        case EstadoCanvas.vacio: return "Canvas vacío. Dibuja para comenzar.";
        case EstadoCanvas.calculando: return "Analizando física en el servidor...";
        case EstadoCanvas.verificado: return "Diagrama verificado. ${provider.vectores.length} fuerzas detectadas.";
        case EstadoCanvas.error: return "Error de conexión con el motor matemático.";
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── 1. ENCABEZADO ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                const Icon(Icons.psychology_rounded, color: AppColors.skyBlue, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Math IA Tutor',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tu asistente inteligente para resolver problemas.',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── 2. ESTADO DEL DIAGRAMA ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildInfoCard(
              context: context,
              icon: Icons.architecture_rounded,
              title: 'Estado del Diagrama',
              value: getTextoEstado(),
              isDark: isDark,
              isHighlight: true,
            ),
          ),
          const SizedBox(height: 12),

          // ── 3. BOTÓN PARA ABRIR TUTORÍA ──
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                 String contextoMimificado = provider.obtenerContextoParaIA(); 
                 showAssistantMecanica(context, AppColors.skyBlue, contextoMimificado);
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text(
                'Abrir Chat del Tutor IA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.skyBlue.withOpacity(0.1),
                foregroundColor: AppColors.skyBlueDark,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.skyBlueLight, width: 1.5),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── 4. GUÍA PASO A PASO (De la API Matemática) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESULTADOS DEL MOTOR',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 12, 
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                
                _buildInfoCard(
                  context: context,
                  icon: Icons.functions_rounded,
                  title: 'Ecuaciones de equilibrio',
                  value: provider.resultados != null 
                       ? "ΣFx = ${provider.resultados!.sumatoriaFx}\nΣFy = ${provider.resultados!.sumatoriaFy}"
                       : "Esperando cálculo...",
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  context: context,
                  icon: Icons.search_rounded,
                  title: 'Reacciones (Estática Inversa)',
                  value: provider.resultados != null 
                      ? (provider.resultados!.incognitasResueltas.isEmpty 
                          ? "Ninguna reacción detectada" 
                          : provider.resultados!.incognitasResueltas.entries.map((e) => '${e.key} = ${e.value} N').join('\n'))
                      : "Esperando cálculo...",
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  context: context,
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Verificación',
                  value: provider.resultados != null 
                      ? (provider.resultados!.enEquilibrio ? "El sistema está en equilibrio" : "El sistema NO está en equilibrio")
                      : "Esperando cálculo...",
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context, required IconData icon, required String title, required String value, required bool isDark, bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight ? AppColors.skyBlue : (isDark ? AppColors.darkBorder : AppColors.divider),
          width: isHighlight ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isHighlight ? AppColors.skyBlue : AppColors.textSecondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 12, color: isHighlight ? (isDark ? Colors.white : Colors.black87) : AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}