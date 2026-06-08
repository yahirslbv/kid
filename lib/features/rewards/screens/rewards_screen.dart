import 'package:flutter/material.dart';

import '../../../shared/widgets/kids/progress_stars.dart';
import '../../../shared/widgets/kids/reward_badge.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2D4A);
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF5E7188);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF3F8FF),
      appBar: AppBar(
        title: const Text('Recompensas'),
        backgroundColor: const Color(0xFFFFB703),
        foregroundColor: const Color(0xFF1A2D4A),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C3350) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF234060)
                      : const Color(0xFFD6E8F7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFFFB703),
                        size: 42,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '42 estrellas locales',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ProgressStars(earned: 4, total: 5, size: 30),
                  const SizedBox(height: 10),
                  Text(
                    'El progreso se guarda solo de forma simulada por ahora.',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Medallas',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                RewardBadge(
                  label: 'Primer ejercicio',
                  icon: Icons.flag_rounded,
                  color: Color(0xFF27AE60),
                ),
                RewardBadge(
                  label: 'Sumas completadas',
                  icon: Icons.add_circle_rounded,
                  color: Color(0xFF27AE60),
                ),
                RewardBadge(
                  label: 'Multiplicador inicial',
                  icon: Icons.close_rounded,
                  color: Color(0xFFF2994A),
                ),
                RewardBadge(
                  label: 'Explorador de figuras',
                  icon: Icons.category_rounded,
                  color: Color(0xFF00A6A6),
                ),
                RewardBadge(
                  label: 'Racha de práctica',
                  icon: Icons.local_fire_department_rounded,
                  color: Color(0xFFEB5757),
                  unlocked: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
