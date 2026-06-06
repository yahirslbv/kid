import 'package:flutter/material.dart';

import '../data/multiplication_questions.dart';
import '../widgets/kids_question_activity.dart';

class MultiplicationActivityScreen extends StatelessWidget {
  const MultiplicationActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KidsQuestionActivity(
      title: 'Multiplicaciones básicas',
      questions: multiplicationQuestions,
      accentColor: Color(0xFFF2994A),
    );
  }
}
