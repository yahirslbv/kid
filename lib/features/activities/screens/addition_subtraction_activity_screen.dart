import 'package:flutter/material.dart';

import '../data/addition_subtraction_questions.dart';
import '../widgets/kids_question_activity.dart';

class AdditionSubtractionActivityScreen extends StatelessWidget {
  const AdditionSubtractionActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KidsQuestionActivity(
      title: 'Sumas y restas básicas',
      questions: additionSubtractionQuestions,
      accentColor: Color(0xFF27AE60),
    );
  }
}
