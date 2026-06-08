class OrderNumbersQuestion {
  final String questionText;
  final List<int> numbers;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String hint;
  final int level;

  const OrderNumbersQuestion({
    required this.questionText,
    required this.numbers,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.hint,
    required this.level,
  });
}
