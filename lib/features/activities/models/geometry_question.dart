class GeometryQuestion {
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String hint;
  final int level;
  final GeometryShapeType? shapeType;
  final int? sides;
  final int? vertices;

  const GeometryQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.hint,
    required this.level,
    this.shapeType,
    this.sides,
    this.vertices,
  });
}

enum GeometryShapeType {
  circle,
  square,
  triangle,
  rectangle,
  pentagon,
  hexagon,
}
