import 'package:flutter/material.dart';

class PracticeModuleItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const PracticeModuleItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class PracticeExample {
  final String prompt;
  final String answer;
  final String hint;

  const PracticeExample({
    required this.prompt,
    required this.answer,
    required this.hint,
  });
}

class PracticeModuleScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<PracticeModuleItem> items;
  final List<PracticeExample> examples;
  final Widget? topContent;

  const PracticeModuleScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.items,
    this.examples = const [],
    this.topContent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2D4A);
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF5E7188);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF3F8FF),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
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
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 34),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
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
            const SizedBox(height: 16),
            if (topContent != null) ...[
              topContent!,
              const SizedBox(height: 16),
            ],
            Text(
              'Practica por partes',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PracticeItemCard(item: item),
              ),
            ),
            if (examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Ejemplos locales',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              ...examples.map(
                (example) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PracticeExampleCard(example: example, color: color),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PracticeItemCard extends StatelessWidget {
  final PracticeModuleItem item;

  const _PracticeItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
        ),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: item.color, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF5E7188),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.lock_clock_rounded, color: Color(0xFF9AA8B8)),
        ],
      ),
    );
  }
}

class _PracticeExampleCard extends StatelessWidget {
  final PracticeExample example;
  final Color color;

  const _PracticeExampleCard({
    required this.example,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            example.prompt,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A2D4A),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pista: ${example.hint}',
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF5E7188),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Respuesta: ${example.answer}',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
