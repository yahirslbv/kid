import 'package:flutter/material.dart';

import '../data/before_after_questions.dart';
import '../models/before_after_question.dart';
import '../widgets/numbers_activity_scaffold.dart';

class BeforeAfterNumberActivityScreen extends StatelessWidget {
  const BeforeAfterNumberActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NumbersActivityScaffold<BeforeAfterQuestion, int>(
      title: 'Anterior y siguiente',
      accentColor: const Color(0xFF9B51E0),
      questions: beforeAfterQuestions,
      questionTextBuilder: (question) => question.questionText,
      optionsBuilder: (question) => question.options,
      correctAnswerBuilder: (question) => question.correctAnswer,
      explanationBuilder: (question) => question.explanation,
      hintBuilder: (question) => question.hint,
      optionLabelBuilder: (answer) => '$answer',
      visualBuilder: (context, question) {
        return _BeforeAfterPreview(question: question);
      },
    );
  }
}

class _BeforeAfterPreview extends StatelessWidget {
  final BeforeAfterQuestion question;

  const _BeforeAfterPreview({required this.question});

  @override
  Widget build(BuildContext context) {
    final isBefore = question.mode == BeforeAfterMode.before;
    final leftLabel = isBefore ? '?' : '${question.baseNumber - 1}';
    final rightLabel = isBefore ? '${question.baseNumber + 1}' : '?';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SequenceCard(
              label: leftLabel,
              muted: !isBefore,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SequenceCard(
              label: '${question.baseNumber}',
              highlighted: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SequenceCard(
              label: rightLabel,
              muted: isBefore,
            ),
          ),
        ],
      ),
    );
  }
}

class _SequenceCard extends StatelessWidget {
  final String label;
  final bool highlighted;
  final bool muted;

  const _SequenceCard({
    required this.label,
    this.highlighted = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlighted
        ? const Color(0xFF9B51E0)
        : muted
            ? const Color(0xFF9AA8B8)
            : const Color(0xFFF2994A);

    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: color.withValues(alpha: highlighted ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 2),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: highlighted ? 42 : 34,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
