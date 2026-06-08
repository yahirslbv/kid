class PatternQuestion {
  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String hint;
  final String explanation;

  const PatternQuestion({
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    required this.hint,
    required this.explanation,
  });
}
