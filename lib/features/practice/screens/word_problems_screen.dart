import 'package:flutter/material.dart';

import '../../activities/models/word_problem_question.dart';

const wordProblemQuestions = [
  WordProblemQuestion(
    statement: 'Ana tiene 8 canicas y Luis le da 4 más. ¿Cuántas tiene ahora?',
    importantData: ['8 canicas', '4 más'],
    suggestedOperation: 'Suma',
    options: ['10', '11', '12', '13'],
    correctAnswer: '12',
    hint: 'Cuando te dan más, suma.',
    explanation: 'Sumamos 8 + 4 = 12 canicas.',
  ),
  WordProblemQuestion(
    statement:
        'Tienes 15 pesos y compras una paleta de 6 pesos. ¿Cuánto queda?',
    importantData: ['15 pesos', '6 pesos'],
    suggestedOperation: 'Resta',
    options: ['7', '8', '9', '10'],
    correctAnswer: '9',
    hint: 'Si gastas, quitas.',
    explanation: 'Restamos 15 - 6 = 9 pesos.',
  ),
  WordProblemQuestion(
    statement: 'Hay 3 bolsas con 5 dulces cada una. ¿Cuántos dulces hay?',
    importantData: ['3 bolsas', '5 dulces cada una'],
    suggestedOperation: 'Multiplicación',
    options: ['10', '12', '15', '20'],
    correctAnswer: '15',
    hint: 'Son grupos iguales.',
    explanation: 'Multiplicamos 3 x 5 = 15 dulces.',
  ),
];

class WordProblemsScreen extends StatelessWidget {
  const WordProblemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2D4A);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF3F8FF),
      appBar: AppBar(
        title: const Text('Problemas razonados'),
        backgroundColor: const Color(0xFFEB5757),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Lee, busca datos y elige operación',
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            ...wordProblemQuestions.map(
              (question) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WordProblemCard(question: question),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordProblemCard extends StatelessWidget {
  final WordProblemQuestion question;

  const _WordProblemCard({required this.question});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.statement,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A2D4A),
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip(label: 'Datos: ${question.importantData.join(', ')}'),
              _MiniChip(label: 'Operación: ${question.suggestedOperation}'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Pista: ${question.hint}',
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF5E7188),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            question.explanation,
            style: const TextStyle(
              color: Color(0xFFEB5757),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;

  const _MiniChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEB5757).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFEB5757),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
