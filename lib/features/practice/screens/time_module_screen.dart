import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/practice_module_scaffold.dart';

class TimeModuleScreen extends StatelessWidget {
  const TimeModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PracticeModuleScaffold(
      title: 'Reloj y tiempo',
      subtitle: 'Horas, días y problemas simples.',
      icon: Icons.schedule_rounded,
      color: Color(0xFF2F80ED),
      topContent: _ClockHeader(),
      items: [
        PracticeModuleItem(
          title: 'Leer la hora',
          description: 'Observa manecillas del reloj.',
          icon: Icons.access_time_rounded,
          color: Color(0xFF2F80ED),
        ),
        PracticeModuleItem(
          title: 'Antes y después',
          description: 'Ordena momentos del día.',
          icon: Icons.swap_vert_rounded,
          color: Color(0xFFF2994A),
        ),
        PracticeModuleItem(
          title: 'Días de la semana',
          description: 'Aprende ayer, hoy y mañana.',
          icon: Icons.calendar_month_rounded,
          color: Color(0xFF27AE60),
        ),
        PracticeModuleItem(
          title: 'Problemas de tiempo',
          description: 'Calcula cuánto tarda algo.',
          icon: Icons.timer_rounded,
          color: Color(0xFF9B51E0),
        ),
      ],
      examples: [
        PracticeExample(
          prompt: 'Si son las 3:00 y pasa 1 hora, ¿qué hora es?',
          answer: '4:00',
          hint: 'Avanza una hora.',
        ),
      ],
    );
  }
}

class _ClockHeader extends StatelessWidget {
  const _ClockHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10243A) : const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: const Color(0xFF2F80ED).withValues(alpha: 0.35)),
      ),
      child: const SizedBox(
        height: 145,
        child: CustomPaint(
          painter: _ClockPainter(),
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  const _ClockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.42;
    final facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF2F80ED)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final handPaint = Paint()
      ..color = const Color(0xFF1A2D4A)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, facePaint);
    canvas.drawCircle(center, radius, strokePaint);
    canvas.drawLine(center, center + Offset(0, -radius * 0.55), handPaint);
    canvas.drawLine(center, center + Offset(radius * 0.42, 0), handPaint);
    canvas.drawCircle(center, 6, Paint()..color = const Color(0xFF2F80ED));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
