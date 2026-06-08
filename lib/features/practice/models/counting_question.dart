import 'package:flutter/material.dart';

class CountingQuestion {
  final String questionText;
  final IconData objectIcon;
  final int objectCount;
  final List<int> options;
  final int correctAnswer;
  final String explanation;
  final String hint;
  final int level;

  const CountingQuestion({
    required this.questionText,
    required this.objectIcon,
    required this.objectCount,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.hint,
    required this.level,
  });
}
