import 'package:flutter/material.dart';

import '../data/compare_numbers_questions.dart';
import '../models/compare_question.dart';
import '../widgets/numbers_activity_scaffold.dart';

class CompareNumbersActivityScreen extends StatelessWidget {
  const CompareNumbersActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NumbersActivityScaffold<CompareQuestion, String>(
      title: 'Mayor o menor',
      accentColor: const Color(0xFF00A6A6),
      questions: compareNumbersQuestions,
      questionTextBuilder: (question) => question.questionText,
      optionsBuilder: (question) => question.options,
      correctAnswerBuilder: (question) => question.correctAnswer,
      explanationBuilder: (question) => question.explanation,
      hintBuilder: (question) => question.hint,
      optionLabelBuilder: (answer) => answer,
      visualBuilder: (context, question) {
        return _CompareNumbersPreview(question: question);
      },
    );
  }
}

class _CompareNumbersPreview extends StatelessWidget {
  final CompareQuestion question;

  const _CompareNumbersPreview({required this.question});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF5E7188);

    return Row(
      children: [
        Expanded(
          child: _NumberCard(
            label: 'Primero',
            number: question.leftNumber,
            color: const Color(0xFF00A6A6),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Icon(Icons.compare_arrows_rounded, color: mutedColor, size: 28),
              const SizedBox(height: 4),
              Text(
                'compara',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _NumberCard(
            label: 'Segundo',
            number: question.rightNumber,
            color: const Color(0xFFF2994A),
          ),
        ),
      ],
    );
  }
}

class _NumberCard extends StatelessWidget {
  final String label;
  final int number;
  final Color color;

  const _NumberCard({
    required this.label,
    required this.number,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 132,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.42), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF5E7188),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$number',
            style: TextStyle(
              color: color,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
