import 'package:flutter/material.dart';

class ParentZoneScreen extends StatelessWidget {
  const ParentZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2D4A);
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF5E7188);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF3F8FF),
      appBar: AppBar(
        title: const Text('Zona para padres'),
        backgroundColor: const Color(0xFF00A6A6),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _InfoPanel(
              title: 'Acompaña el aprendizaje',
              description:
                  'Aquí podrás revisar progreso, elegir grado, controlar el tutor IA y ver historial de actividades.',
              icon: Icons.family_restroom_rounded,
              color: const Color(0xFF00A6A6),
            ),
            const SizedBox(height: 14),
            _SettingCard(
              title: 'Perfil del niño',
              subtitle: 'Nombre y avatar en preparación.',
              icon: Icons.child_care_rounded,
              color: const Color(0xFF2F80ED),
              trailing: Text('Demo', style: TextStyle(color: mutedColor)),
            ),
            _SettingCard(
              title: 'Grado escolar',
              subtitle: 'Selector visual local.',
              icon: Icons.school_rounded,
              color: const Color(0xFF27AE60),
              trailing: DropdownButton<String>(
                value: '3°',
                items: const ['1°', '2°', '3°', '4°', '5°', '6°']
                    .map((grade) => DropdownMenuItem(
                          value: grade,
                          child: Text(grade),
                        ))
                    .toList(),
                onChanged: null,
              ),
            ),
            _SettingCard(
              title: 'Tiempo de uso',
              subtitle: 'Límite diario no guardado todavía.',
              icon: Icons.timer_rounded,
              color: const Color(0xFFF2994A),
              trailing: Text('30 min', style: TextStyle(color: textColor)),
            ),
            _SettingCard(
              title: 'Progreso por tema',
              subtitle: 'Resumen local simulado.',
              icon: Icons.bar_chart_rounded,
              color: const Color(0xFF9B51E0),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
            _SettingCard(
              title: 'Seguridad del tutor IA',
              subtitle: 'La IA todavía no está conectada.',
              icon: Icons.shield_rounded,
              color: const Color(0xFFEB5757),
              trailing: Switch(value: false, onChanged: null),
            ),
            const SizedBox(height: 8),
            Text(
              'Estas opciones son una vista previa. No se guarda información todavía.',
              style: TextStyle(
                color: mutedColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _InfoPanel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF5E7188),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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

class _SettingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget trailing;

  const _SettingCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF5E7188),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}
