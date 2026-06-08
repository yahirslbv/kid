import 'package:flutter/material.dart';

import '../models/kids_learning_module.dart';

class LearningModuleCard extends StatelessWidget {
  final KidsLearningModule module;
  final VoidCallback onStart;

  const LearningModuleCard({
    super.key,
    required this.module,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusText = _statusText(module.status);
    final statusColor = _statusColor(module.status);

    return Container(
      padding: const EdgeInsets.all(14),
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: module.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(module.icon, color: module.color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${module.recommendedGrade} • ${module.estimatedMinutes} min',
                      style: TextStyle(
                        color:
                            isDark ? Colors.white70 : const Color(0xFF5E7188),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            module.description,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF5E7188),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onStart,
                icon: Icon(_buttonIcon(module.status), size: 18),
                label: Text(_buttonText(module.status)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusText(KidsModuleStatus status) {
    switch (status) {
      case KidsModuleStatus.available:
        return 'Disponible';
      case KidsModuleStatus.comingSoon:
        return 'Próximamente';
      case KidsModuleStatus.locked:
        return 'Bloqueado';
    }
  }

  Color _statusColor(KidsModuleStatus status) {
    switch (status) {
      case KidsModuleStatus.available:
        return const Color(0xFF27AE60);
      case KidsModuleStatus.comingSoon:
        return const Color(0xFFF2994A);
      case KidsModuleStatus.locked:
        return const Color(0xFF9AA8B8);
    }
  }

  IconData _buttonIcon(KidsModuleStatus status) {
    switch (status) {
      case KidsModuleStatus.available:
        return Icons.play_arrow_rounded;
      case KidsModuleStatus.comingSoon:
        return Icons.notifications_rounded;
      case KidsModuleStatus.locked:
        return Icons.lock_rounded;
    }
  }

  String _buttonText(KidsModuleStatus status) {
    switch (status) {
      case KidsModuleStatus.available:
        return 'Iniciar';
      case KidsModuleStatus.comingSoon:
        return 'Ver';
      case KidsModuleStatus.locked:
        return 'Bloqueado';
    }
  }
}
