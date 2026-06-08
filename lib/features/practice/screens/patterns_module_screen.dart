import 'package:flutter/material.dart';

import '../../activities/models/pattern_question.dart';
import '../widgets/practice_module_scaffold.dart';

const patternQuestions = [
  PatternQuestion(
    prompt: '2, 4, 6, __',
    options: ['7', '8', '9', '10'],
    correctAnswer: '8',
    hint: 'El patrón suma 2 cada vez.',
    explanation: '2, 4, 6, 8 sigue contando de dos en dos.',
  ),
  PatternQuestion(
    prompt: '5, 10, 15, __',
    options: ['16', '18', '20', '25'],
    correctAnswer: '20',
    hint: 'Cuenta de 5 en 5.',
    explanation: 'Después de 15 viene 20.',
  ),
  PatternQuestion(
    prompt: 'Círculo, cuadrado, círculo, cuadrado, __',
    options: ['Círculo', 'Triángulo', 'Rectángulo', 'Hexágono'],
    correctAnswer: 'Círculo',
    hint: 'Las figuras se alternan.',
    explanation: 'Después de cuadrado vuelve círculo.',
  ),
];

class PatternsModuleScreen extends StatelessWidget {
  const PatternsModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PracticeModuleScaffold(
      title: 'Patrones',
      subtitle: 'Encuentra lo que sigue.',
      icon: Icons.pattern_rounded,
      color: const Color(0xFFF2994A),
      items: const [
        PracticeModuleItem(
          title: 'Secuencias numéricas',
          description: 'Suma o resta el mismo salto.',
          icon: Icons.format_list_numbered_rounded,
          color: Color(0xFFF2994A),
        ),
        PracticeModuleItem(
          title: 'Patrones visuales',
          description: 'Alterna figuras y colores.',
          icon: Icons.dashboard_customize_rounded,
          color: Color(0xFF2F80ED),
        ),
        PracticeModuleItem(
          title: 'Completar espacios',
          description: 'Descubre la pieza que falta.',
          icon: Icons.extension_rounded,
          color: Color(0xFF9B51E0),
        ),
      ],
      examples: patternQuestions
          .map(
            (question) => PracticeExample(
              prompt: question.prompt,
              answer: question.correctAnswer,
              hint: question.hint,
            ),
          )
          .toList(),
    );
  }
}
