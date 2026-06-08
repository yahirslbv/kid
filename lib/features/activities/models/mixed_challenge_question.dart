class MixedChallengeQuestion {
  final String category;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String hint;
  final int level;

  const MixedChallengeQuestion({
    required this.category,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.hint,
    required this.level,
  });
}
