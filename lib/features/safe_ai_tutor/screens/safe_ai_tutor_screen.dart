import 'package:flutter/material.dart';

class SafeAiTutorScreen extends StatelessWidget {
  const SafeAiTutorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2D4A);
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF5E7188);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF3F8FF),
      appBar: AppBar(
        title: const Text('Tutor seguro'),
        backgroundColor: const Color(0xFF9B51E0),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
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
                      const Icon(
                        Icons.psychology_alt_rounded,
                        color: Color(0xFF9B51E0),
                        size: 42,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ayuda con pistas',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'El tutor ayudará a pensar paso a paso, no solo a dar respuestas.',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _PromptButton(label: 'Dame una pista', icon: Icons.lightbulb),
                _PromptButton(label: 'Explícalo con dibujos', icon: Icons.draw),
                _PromptButton(
                    label: 'Revisa mi respuesta', icon: Icons.check_circle),
                _PromptButton(
                    label: 'Hazme un ejemplo parecido',
                    icon: Icons.auto_awesome),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: false,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Modo demostración. La IA se conectará después.',
                filled: true,
                fillColor: isDark ? const Color(0xFF1C3350) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'La IA se conectará después con reglas de seguridad.',
              style: TextStyle(
                color: mutedColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PromptButton({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: null,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(150, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
