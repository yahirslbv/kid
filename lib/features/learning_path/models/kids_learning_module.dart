import 'package:flutter/material.dart';

enum KidsModuleStatus {
  available,
  comingSoon,
  locked,
}

class KidsLearningModule {
  final String id;
  final String title;
  final String description;
  final String levelId;
  final String recommendedGrade;
  final KidsModuleStatus status;
  final String? activityRoute;
  final IconData icon;
  final int estimatedMinutes;
  final Color color;

  const KidsLearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.levelId,
    required this.recommendedGrade,
    required this.status,
    required this.icon,
    required this.estimatedMinutes,
    required this.color,
    this.activityRoute,
  });
}
