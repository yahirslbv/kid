import 'package:flutter/material.dart';

import '../data/division_questions.dart';
import '../widgets/kids_question_activity.dart';

class DivisionActivityScreen extends StatelessWidget {
  const DivisionActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KidsQuestionActivity(
      title: 'Divisiones básicas',
      questions: divisionQuestions,
      accentColor: Color(0xFF9B51E0),
    );
  }
}
