class FractionQuestion {
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String hint;
  final int level;
  final int totalParts;
  final int shadedParts;

  const FractionQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.hint,
    required this.level,
    required this.totalParts,
    required this.shadedParts,
  });
}
