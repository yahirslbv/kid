enum BeforeAfterMode { before, after }

class BeforeAfterQuestion {
  final String questionText;
  final int baseNumber;
  final BeforeAfterMode mode;
  final List<int> options;
  final int correctAnswer;
  final String explanation;
  final String hint;
  final int level;

  const BeforeAfterQuestion({
    required this.questionText,
    required this.baseNumber,
    required this.mode,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.hint,
    required this.level,
  });
}
