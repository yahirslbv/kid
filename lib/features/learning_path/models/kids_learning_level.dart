import 'package:flutter/material.dart';

import 'kids_learning_module.dart';

class KidsLearningLevel {
  final String id;
  final String title;
  final String subtitle;
  final String gradeRange;
  final String description;
  final IconData icon;
  final Color color;
  final List<KidsLearningModule> modules;

  const KidsLearningLevel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.gradeRange,
    required this.description,
    required this.icon,
    required this.color,
    required this.modules,
  });
}
