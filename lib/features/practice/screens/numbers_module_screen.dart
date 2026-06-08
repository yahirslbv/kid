import 'package:flutter/material.dart';

import '../../../shared/widgets/kids/kids_feature_card.dart';
import 'before_after_number_activity_screen.dart';
import 'compare_numbers_activity_screen.dart';
import 'counting_objects_activity_screen.dart';
import 'order_numbers_activity_screen.dart';

class NumbersModuleScreen extends StatelessWidget {
  const NumbersModuleScreen({super.key});

  static const _activities = [
    _NumbersActivityLink(
      title: 'Contar objetos',
      subtitle: 'Cuenta dibujos',
      route: 'counting',
      icon: Icons.filter_9_plus_rounded,
      color: Color(0xFF2F80ED),
    ),
    _NumbersActivityLink(
      title: 'Mayor o menor',
      subtitle: 'Compara numeros',
      route: 'compare',
      icon: Icons.compare_arrows_rounded,
      color: Color(0xFF00A6A6),
    ),
    _NumbersActivityLink(
      title: 'Ordenar numeros',
      subtitle: 'Ponlos en fila',
      route: 'order',
      icon: Icons.sort_rounded,
      color: Color(0xFFF2994A),
    ),
    _NumbersActivityLink(
      title: 'Anterior y siguiente',
      subtitle: 'Encuentra vecinos',
      route: 'before_after',
      icon: Icons.skip_next_rounded,
      color: Color(0xFF9B51E0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2D4A);
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF5E7188);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF3F8FF),
      appBar: AppBar(
        title: const Text('Numeros y conteo'),
        backgroundColor: const Color(0xFF2F80ED),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C3350) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF234060)
                      : const Color(0xFFD6E8F7),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F80ED).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.looks_one_rounded,
                      color: Color(0xFF2F80ED),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Numeros y conteo',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aprende a contar, comparar y ordenar numeros',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Elige una practica',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              itemCount: _activities.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return KidsFeatureCard(
                  title: activity.title,
                  subtitle: activity.subtitle,
                  icon: activity.icon,
                  color: activity.color,
                  onTap: () => _openActivity(context, activity.route),
                );
              },
            ),
            const SizedBox(height: 18),
            _TipPanel(
              color: const Color(0xFF2F80ED),
              text:
                  'Cada practica muestra 5 ejercicios nuevos. Si fallas, veras una pista amable.',
            ),
          ],
        ),
      ),
    );
  }

  void _openActivity(BuildContext context, String route) {
    final screen = switch (route) {
      'counting' => const CountingObjectsActivityScreen(),
      'compare' => const CompareNumbersActivityScreen(),
      'order' => const OrderNumbersActivityScreen(),
      'before_after' => const BeforeAfterNumberActivityScreen(),
      _ => const CountingObjectsActivityScreen(),
    };

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _TipPanel extends StatelessWidget {
  final String text;
  final Color color;

  const _TipPanel({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: color, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumbersActivityLink {
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;

  const _NumbersActivityLink({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.color,
  });
}
