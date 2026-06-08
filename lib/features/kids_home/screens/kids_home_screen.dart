import 'package:flutter/material.dart';

import '../../../shared/widgets/kids/coming_soon_screen.dart';
import '../../../shared/widgets/kids/kids_feature_card.dart';
import '../../../shared/widgets/kids/progress_stars.dart';
import '../../../shared/widgets/kids/reward_badge.dart';
import '../../activities/screens/addition_subtraction_activity_screen.dart';
import '../../activities/screens/division_activity_screen.dart';
import '../../activities/screens/fractions_activity_screen.dart';
import '../../activities/screens/geometry_activity_screen.dart';
import '../../activities/screens/mixed_challenges_screen.dart';
import '../../activities/screens/multiplication_activity_screen.dart';
import '../../learning_path/screens/learning_path_screen.dart';
import '../../parent_zone/screens/parent_zone_screen.dart';
import '../../practice/screens/measurement_module_screen.dart';
import '../../practice/screens/money_module_screen.dart';
import '../../practice/screens/numbers_module_screen.dart';
import '../../practice/screens/patterns_module_screen.dart';
import '../../practice/screens/time_module_screen.dart';
import '../../practice/screens/word_problems_screen.dart';
import '../../rewards/screens/rewards_screen.dart';
import '../../safe_ai_tutor/screens/safe_ai_tutor_screen.dart';

class KidsHomeScreen extends StatelessWidget {
  const KidsHomeScreen({super.key});

  static const _mainModules = [
    _KidsModule(
      title: 'Números',
      subtitle: 'Cuenta y compara',
      route: 'numbers',
      icon: Icons.looks_one_rounded,
      color: Color(0xFF2F80ED),
    ),
    _KidsModule(
      title: 'Sumas y restas',
      subtitle: 'Junta y quita',
      route: 'addition_subtraction',
      icon: Icons.add_circle_rounded,
      color: Color(0xFF27AE60),
    ),
    _KidsModule(
      title: 'Multiplicaciones',
      subtitle: 'Grupos iguales',
      route: 'multiplication',
      icon: Icons.close_rounded,
      color: Color(0xFFF2994A),
    ),
    _KidsModule(
      title: 'Divisiones',
      subtitle: 'Reparte en partes',
      route: 'division',
      icon: Icons.call_split_rounded,
      color: Color(0xFF9B51E0),
    ),
    _KidsModule(
      title: 'Fracciones',
      subtitle: 'Partes de un todo',
      route: 'fractions',
      icon: Icons.pie_chart_rounded,
      color: Color(0xFFEB5757),
    ),
    _KidsModule(
      title: 'Figuras',
      subtitle: 'Formas y medidas',
      route: 'geometry',
      icon: Icons.category_rounded,
      color: Color(0xFF00A6A6),
    ),
    _KidsModule(
      title: 'Patrones',
      subtitle: 'Lo que sigue',
      route: 'patterns',
      icon: Icons.pattern_rounded,
      color: Color(0xFFF2994A),
    ),
    _KidsModule(
      title: 'Dinero',
      subtitle: 'Compra y cambio',
      route: 'money',
      icon: Icons.payments_rounded,
      color: Color(0xFF27AE60),
    ),
    _KidsModule(
      title: 'Reloj y tiempo',
      subtitle: 'Horas y días',
      route: 'time',
      icon: Icons.schedule_rounded,
      color: Color(0xFF2F80ED),
    ),
    _KidsModule(
      title: 'Medición',
      subtitle: 'Largo y peso',
      route: 'measurement',
      icon: Icons.straighten_rounded,
      color: Color(0xFF00A6A6),
    ),
    _KidsModule(
      title: 'Problemas',
      subtitle: 'Lee y resuelve',
      route: 'word_problems',
      icon: Icons.psychology_alt_rounded,
      color: Color(0xFFEB5757),
    ),
    _KidsModule(
      title: 'Retos mixtos',
      subtitle: 'Todo mezclado',
      route: 'mixed_challenges',
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFFFB703),
    ),
  ];

  static const _supportModules = [
    _KidsModule(
      title: 'Camino',
      subtitle: 'Tu ruta',
      route: 'learning_path',
      icon: Icons.route_rounded,
      color: Color(0xFF2F80ED),
    ),
    _KidsModule(
      title: 'Recompensas',
      subtitle: 'Medallas',
      route: 'rewards',
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFFFB703),
    ),
    _KidsModule(
      title: 'Padres',
      subtitle: 'Control',
      route: 'parent_zone',
      icon: Icons.family_restroom_rounded,
      color: Color(0xFF00A6A6),
    ),
    _KidsModule(
      title: 'Tutor seguro',
      subtitle: 'Pistas',
      route: 'safe_tutor',
      icon: Icons.shield_rounded,
      color: Color(0xFF9B51E0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF3F8FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Math Kids AI'),
        backgroundColor: const Color(0xFF2F80ED),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const _KidsHomeHeader(),
            const SizedBox(height: 16),
            _QuickActions(onOpenRoute: (route) => _openRoute(context, route)),
            const SizedBox(height: 18),
            _SectionTitle(
              title: 'Módulos principales',
              subtitle: 'Elige una aventura para practicar',
            ),
            const SizedBox(height: 10),
            _ModuleGrid(
              modules: _mainModules,
              onTap: (module) => _openRoute(context, module.route),
            ),
            const SizedBox(height: 18),
            _SectionTitle(
              title: 'Acompañamiento',
              subtitle: 'Ruta, premios y seguridad',
            ),
            const SizedBox(height: 10),
            _ModuleGrid(
              modules: _supportModules,
              onTap: (module) => _openRoute(context, module.route),
            ),
          ],
        ),
      ),
    );
  }

  void _openRoute(BuildContext context, String route) {
    final screen = _screenForRoute(route);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _screenForRoute(String route) {
    switch (route) {
      case 'numbers':
        return const NumbersModuleScreen();
      case 'addition_subtraction':
        return const AdditionSubtractionActivityScreen();
      case 'multiplication':
        return const MultiplicationActivityScreen();
      case 'division':
        return const DivisionActivityScreen();
      case 'fractions':
        return const FractionsActivityScreen();
      case 'geometry':
        return const GeometryActivityScreen();
      case 'patterns':
        return const PatternsModuleScreen();
      case 'money':
        return const MoneyModuleScreen();
      case 'time':
        return const TimeModuleScreen();
      case 'measurement':
        return const MeasurementModuleScreen();
      case 'word_problems':
        return const WordProblemsScreen();
      case 'mixed_challenges':
        return const MixedChallengesScreen();
      case 'learning_path':
        return const LearningPathScreen();
      case 'rewards':
        return const RewardsScreen();
      case 'parent_zone':
        return const ParentZoneScreen();
      case 'safe_tutor':
        return const SafeAiTutorScreen();
      default:
        return const ComingSoonScreen(
          title: 'Próximamente',
          description: 'Esta aventura está en preparación.',
          icon: Icons.construction_rounded,
        );
    }
  }
}

class _KidsHomeHeader extends StatelessWidget {
  const _KidsHomeHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2D4A);
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF5E7188);

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
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF2F80ED),
                  size: 34,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, explorador!',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hoy puedes ganar nuevas estrellas.',
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
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
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
              ProgressStars(earned: 3, total: 5),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final ValueChanged<String> onOpenRoute;

  const _QuickActions({required this.onOpenRoute});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            label: 'Continuar',
            icon: Icons.play_arrow_rounded,
            color: const Color(0xFF27AE60),
            onTap: () => onOpenRoute('learning_path'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            label: 'Retos',
            icon: Icons.emoji_events_rounded,
            color: const Color(0xFFFFB703),
            onTap: () => onOpenRoute('mixed_challenges'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            label: 'Premios',
            icon: Icons.workspace_premium_rounded,
            color: const Color(0xFF9B51E0),
            onTap: () => onOpenRoute('rewards'),
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        height: 74,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1A2D4A),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
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
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF5E7188),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  final List<_KidsModule> modules;
  final ValueChanged<_KidsModule> onTap;

  const _ModuleGrid({
    required this.modules,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: modules.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final module = modules[index];
        return KidsFeatureCard(
          title: module.title,
          subtitle: module.subtitle,
          icon: module.icon,
          color: module.color,
          onTap: () => onTap(module),
        );
      },
    );
  }
}

class _KidsModule {
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;

  const _KidsModule({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.color,
  });
}
