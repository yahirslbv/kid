import 'package:flutter/material.dart';

class SafeAiTutorScreen extends StatelessWidget {
  const SafeAiTutorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _KidsPlaceholderScreen(
      title: 'Tutor seguro',
      icon: Icons.psychology_alt_rounded,
    );
  }
}

class _KidsPlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _KidsPlaceholderScreen({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: const Color(0xFF9B51E0)),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
