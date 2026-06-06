import '../models/kids_question.dart';

const multiplicationQuestions = [
  KidsQuestion(
    questionText: '2 x 3 = ?',
    options: [4, 5, 6, 8],
    correctAnswer: 6,
    explanation: '2 grupos de 3 hacen 6.',
    hint: 'Cuenta de 3 en 3 dos veces: 3, 6.',
    level: 1,
  ),
  KidsQuestion(
    questionText: '3 x 4 = ?',
    options: [7, 10, 12, 14],
    correctAnswer: 12,
    explanation: '3 grupos de 4 son 4 + 4 + 4 = 12.',
    hint: 'Suma 4 tres veces.',
    level: 1,
  ),
  KidsQuestion(
    questionText: '4 x 5 = ?',
    options: [16, 18, 20, 25],
    correctAnswer: 20,
    explanation: '4 grupos de 5 suman 20.',
    hint: 'Cuenta de 5 en 5: 5, 10, 15, 20.',
    level: 1,
  ),
  KidsQuestion(
    questionText: '5 x 2 = ?',
    options: [7, 10, 12, 15],
    correctAnswer: 10,
    explanation: '5 grupos de 2 son 10.',
    hint: 'Puedes sumar 2 cinco veces.',
    level: 1,
  ),
  KidsQuestion(
    questionText: '10 x 4 = ?',
    options: [14, 30, 40, 50],
    correctAnswer: 40,
    explanation: '10 + 10 + 10 + 10 = 40.',
    hint: 'Multiplicar por 10 ayuda: 4 grupos de 10 son 40.',
    level: 1,
  ),
];
