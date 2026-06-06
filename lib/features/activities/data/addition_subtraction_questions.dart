import '../models/kids_question.dart';

const additionSubtractionQuestions = [
  KidsQuestion(
    questionText: '4 + 3 = ?',
    options: [5, 6, 7, 8],
    correctAnswer: 7,
    explanation: 'Cuenta 4 y agrega 3 más: 5, 6, 7.',
    hint: 'Empieza en 4 y da 3 saltitos hacia adelante.',
    level: 1,
  ),
  KidsQuestion(
    questionText: '6 + 2 = ?',
    options: [7, 8, 9, 10],
    correctAnswer: 8,
    explanation: 'Empieza en 6 y avanza dos pasos: 7, 8.',
    hint: 'Para sumar 2, cuenta dos números después del 6.',
    level: 1,
  ),
  KidsQuestion(
    questionText: '5 + 5 = ?',
    options: [9, 10, 11, 12],
    correctAnswer: 10,
    explanation: 'Dos grupos de 5 hacen 10.',
    hint: 'Piensa en una mano con 5 dedos y otra mano con 5 dedos.',
    level: 1,
  ),
  KidsQuestion(
    questionText: '9 - 4 = ?',
    options: [4, 5, 6, 7],
    correctAnswer: 5,
    explanation: 'Si tienes 9 y quitas 4, quedan 5.',
    hint: 'Empieza en 9 y retrocede 4 pasos.',
    level: 1,
  ),
  KidsQuestion(
    questionText: '8 - 3 = ?',
    options: [3, 4, 5, 6],
    correctAnswer: 5,
    explanation: 'Retrocede desde 8 tres pasos: 7, 6, 5.',
    hint: 'Para restar 3, cuenta hacia atrás tres veces desde 8.',
    level: 1,
  ),
];
