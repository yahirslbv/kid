import 'package:flutter/material.dart';

import '../data/order_numbers_questions.dart';
import '../models/order_numbers_question.dart';
import '../widgets/numbers_activity_scaffold.dart';

class OrderNumbersActivityScreen extends StatelessWidget {
  const OrderNumbersActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NumbersActivityScaffold<OrderNumbersQuestion, String>(
      title: 'Ordenar numeros',
      accentColor: const Color(0xFFF2994A),
      questions: orderNumbersQuestions,
      questionTextBuilder: (question) {
        return '${question.questionText}\n${question.numbers.join(', ')}';
      },
      optionsBuilder: (question) => question.options,
      correctAnswerBuilder: (question) => question.correctAnswer,
      explanationBuilder: (question) => question.explanation,
      hintBuilder: (question) => question.hint,
      optionLabelBuilder: (answer) => answer,
      visualBuilder: (context, question) {
        return _OrderNumbersPreview(question: question);
      },
    );
  }
}

class _OrderNumbersPreview extends StatelessWidget {
  final OrderNumbersQuestion question;

  const _OrderNumbersPreview({required this.question});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2D4A);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Numeros para ordenar',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: question.numbers.map((number) {
              return Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2994A).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF2994A).withValues(alpha: 0.45),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Color(0xFF9A4D00),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
