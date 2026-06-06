import 'package:flutter/material.dart';

import '../../activities/screens/addition_subtraction_activity_screen.dart';
import '../../../shared/widgets/kids/kids_feature_card.dart';
import '../../../shared/widgets/kids/progress_stars.dart';
import '../../../shared/widgets/kids/reward_badge.dart';

class KidsHomeScreen extends StatelessWidget {
  const KidsHomeScreen({super.key});

  static const _topics = [
    _KidsTopic(
      title: 'Números',
      subtitle: 'Cuenta y compara',
      icon: Icons.looks_one_rounded,
      color: Color(0xFF2F80ED),
    ),
    _KidsTopic(
      title: 'Sumas y restas',
      subtitle: 'Junta y quita',
      icon: Icons.add_circle_rounded,
      color: Color(0xFF27AE60),
    ),
    _KidsTopic(
      title: 'Multiplicaciones',
      subtitle: 'Grupos iguales',
      icon: Icons.close_rounded,
      color: Color(0xFFF2994A),
    ),
    _KidsTopic(
      title: 'Divisiones',
      subtitle: 'Reparte en partes',
      icon: Icons.call_split_rounded,
      color: Color(0xFF9B51E0),
    ),
    _KidsTopic(
      title: 'Fracciones',
      subtitle: 'Mitades y cuartos',
      icon: Icons.pie_chart_rounded,
      color: Color(0xFFEB5757),
    ),
    _KidsTopic(
      title: 'Figuras',
      subtitle: 'Formas y medidas',
      icon: Icons.category_rounded,
      color: Color(0xFF00A6A6),
    ),
    _KidsTopic(
      title: 'Retos',
      subtitle: 'Practica jugando',
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFFFB703),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF3F8FF);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A2D4A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF5E7188);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Math Kids AI'),
        backgroundColor: const Color(0xFF2F80ED),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _KidsHeader(
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  isDark: isDark,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final topic = _topics[index];
                  return KidsFeatureCard(
                    title: topic.title,
                    subtitle: topic.subtitle,
                    icon: topic.icon,
                    color: topic.color,
                    onTap: () => _openTopic(context, topic.title),
                  );
                }, childCount: _topics.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTopic(BuildContext context, String topic) {
    if (topic == 'Sumas y restas') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AdditionSubtractionActivityScreen(),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$topic estará listo pronto.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _KidsHeader extends StatelessWidget {
  final Color titleColor;
  final Color subtitleColor;
  final bool isDark;

  const _KidsHeader({
    required this.titleColor,
    required this.subtitleColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Color(0xFF2F80ED),
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modo Primaria',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Elige una aventura',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              RewardBadge(
                label: 'Primer paso',
                icon: Icons.flag_rounded,
                color: Color(0xFF27AE60),
              ),
              RewardBadge(
                label: 'Racha 3',
                icon: Icons.local_fire_department_rounded,
                color: Color(0xFFF2994A),
                unlocked: false,
              ),
              ProgressStars(earned: 2, total: 5),
            ],
          ),
        ],
      ),
    );
  }
}

class _KidsTopic {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KidsTopic({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
