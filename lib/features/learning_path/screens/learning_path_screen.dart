import 'package:flutter/material.dart';

import '../../../shared/widgets/kids/coming_soon_screen.dart';
import '../../activities/screens/addition_subtraction_activity_screen.dart';
import '../../activities/screens/division_activity_screen.dart';
import '../../activities/screens/fractions_activity_screen.dart';
import '../../activities/screens/geometry_activity_screen.dart';
import '../../activities/screens/mixed_challenges_screen.dart';
import '../../activities/screens/multiplication_activity_screen.dart';
import '../../practice/screens/measurement_module_screen.dart';
import '../../practice/screens/money_module_screen.dart';
import '../../practice/screens/numbers_module_screen.dart';
import '../../practice/screens/patterns_module_screen.dart';
import '../../practice/screens/time_module_screen.dart';
import '../../practice/screens/word_problems_screen.dart';
import '../data/kids_learning_levels_data.dart';
import '../models/kids_learning_level.dart';
import '../models/kids_learning_module.dart';
import '../widgets/learning_level_card.dart';
import '../widgets/learning_module_card.dart';

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  int _selectedLevelIndex = 0;

  KidsLearningLevel get _selectedLevel =>
      kidsLearningLevels[_selectedLevelIndex];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2D4A);
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF5E7188);
    final availableCount = _selectedLevel.modules
        .where((module) => module.status == KidsModuleStatus.available)
        .length;
    final progress = availableCount / _selectedLevel.modules.length;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF3F8FF),
      appBar: AppBar(
        title: const Text('Mi camino de aprendizaje'),
        backgroundColor: const Color(0xFF2F80ED),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Elige tu nivel',
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kidsLearningLevels.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final level = kidsLearningLevels[index];
                  return LearningLevelCard(
                    level: level,
                    selected: index == _selectedLevelIndex,
                    onTap: () => setState(() => _selectedLevelIndex = index),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedLevel.icon,
                        color: _selectedLevel.color,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedLevel.title,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedLevel.description,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      backgroundColor: isDark
                          ? const Color(0xFF234060)
                          : const Color(0xFFD6E8F7),
                      color: _selectedLevel.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$availableCount de ${_selectedLevel.modules.length} módulos listos',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._selectedLevel.modules.map(
              (module) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LearningModuleCard(
                  module: module,
                  onStart: () => _openModule(context, module),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openModule(BuildContext context, KidsLearningModule module) {
    if (module.status != KidsModuleStatus.available ||
        module.activityRoute == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ComingSoonScreen(
            title: module.title,
            description: module.status == KidsModuleStatus.locked
                ? 'Este módulo se desbloqueará más adelante.'
                : 'Estamos preparando esta aventura.',
            icon: module.icon,
            color: module.color,
            suggestedAction: 'Prueba otro módulo disponible por ahora.',
          ),
        ),
      );
      return;
    }

    final screen = _screenForRoute(module.activityRoute!);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _screenForRoute(String route) {
    switch (route) {
      case 'numbers':
        return const NumbersModuleScreen();
      case 'patterns':
        return const PatternsModuleScreen();
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
      default:
        return const ComingSoonScreen(
          title: 'Próximamente',
          description: 'Este módulo ya está en preparación.',
          icon: Icons.construction_rounded,
        );
    }
  }
}
