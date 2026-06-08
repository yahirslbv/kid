List<T> selectRandomQuestions<T>(List<T> questions, {int count = 5}) {
  final shuffledQuestions = List<T>.of(questions)..shuffle();
  return List<T>.unmodifiable(shuffledQuestions.take(count));
}
