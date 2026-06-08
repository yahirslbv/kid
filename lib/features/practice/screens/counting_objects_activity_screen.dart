import 'package:flutter/material.dart';

import '../data/counting_questions.dart';
import '../models/counting_question.dart';
import '../widgets/numbers_activity_scaffold.dart';

class CountingObjectsActivityScreen extends StatelessWidget {
  const CountingObjectsActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NumbersActivityScaffold<CountingQuestion, int>(
      title: 'Contar objetos',
      accentColor: const Color(0xFF2F80ED),
      questions: countingQuestions,
      questionTextBuilder: (question) => question.questionText,
      optionsBuilder: (question) => question.options,
      correctAnswerBuilder: (question) => question.correctAnswer,
      explanationBuilder: (question) => question.explanation,
      hintBuilder: (question) => question.hint,
      optionLabelBuilder: (answer) => '$answer',
      visualBuilder: (context, question) {
        return _ObjectCounterPreview(question: question);
      },
    );
  }
}

class _ObjectCounterPreview extends StatelessWidget {
  final CountingQuestion question;

  const _ObjectCounterPreview({required this.question});

  @override
  Widget build(BuildContext context) {
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
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: List.generate(
          question.objectCount,
          (index) => Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2F80ED).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              question.objectIcon,
              color: const Color(0xFF2F80ED),
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
