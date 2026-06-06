class KidsQuestion {
  final String questionText;
  final List<int> options;
  final int correctAnswer;
  final String explanation;
  final int level;

  const KidsQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.level,
  });
}
