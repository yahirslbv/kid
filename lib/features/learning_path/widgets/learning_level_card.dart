import 'package:flutter/material.dart';

import '../models/kids_learning_level.dart';

class LearningLevelCard extends StatelessWidget {
  final KidsLearningLevel level;
  final bool selected;
  final VoidCallback onTap;

  const LearningLevelCard({
    super.key,
    required this.level,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        width: 190,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? level.color.withValues(alpha: isDark ? 0.28 : 0.16)
              : (isDark ? const Color(0xFF1C3350) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? level.color
                : (isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7)),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(level.icon, color: level.color, size: 30),
            const SizedBox(height: 10),
            Text(
              level.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              level.gradeRange,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF5E7188),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
