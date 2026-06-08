class WordProblemQuestion {
  final String statement;
  final List<String> importantData;
  final String suggestedOperation;
  final List<String> options;
  final String correctAnswer;
  final String hint;
  final String explanation;

  const WordProblemQuestion({
    required this.statement,
    required this.importantData,
    required this.suggestedOperation,
    required this.options,
    required this.correctAnswer,
    required this.hint,
    required this.explanation,
  });
}
