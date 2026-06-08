class CompareQuestion {
  final String questionText;
  final int leftNumber;
  final int rightNumber;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String hint;
  final int level;

  const CompareQuestion({
    required this.questionText,
    required this.leftNumber,
    required this.rightNumber,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.hint,
    required this.level,
  });
}
