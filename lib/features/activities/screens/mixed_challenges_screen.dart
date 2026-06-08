import 'package:flutter/material.dart';

import '../../../shared/widgets/kids/progress_stars.dart';
import '../data/mixed_challenge_questions.dart';
import '../models/mixed_challenge_question.dart';
import '../utils/kids_question_selector.dart';

class MixedChallengesScreen extends StatefulWidget {
  const MixedChallengesScreen({super.key});

  @override
  State<MixedChallengesScreen> createState() => _MixedChallengesScreenState();
}

class _MixedChallengesScreenState extends State<MixedChallengesScreen> {
  static const _accentColor = Color(0xFFFFB703);

  late List<MixedChallengeQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;
  bool _finished = false;

  MixedChallengeQuestion get _currentQuestion => _questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  void _startNewRound() {
    _questions = selectRandomQuestions(mixedChallengeQuestions);
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _answered = false;
    _finished = false;
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == _currentQuestion.correctAnswer) {
        _score++;
      }
    });
  }

  void _goNext() {
    if (!_answered) return;
    if (_currentIndex == _questions.length - 1) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  void _restart() => setState(_startNewRound);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF3F8FF),
      appBar: AppBar(
        title: const Text('Retos mixtos'),
        backgroundColor: _accentColor,
        foregroundColor: const Color(0xFF1A2D4A),
      ),
      body: SafeArea(
        child: _finished
            ? _MixedFinished(
                score: _score,
                total: _questions.length,
                onRestart: _restart,
              )
            : _MixedQuestionView(
                question: _currentQuestion,
                currentIndex: _currentIndex,
                total: _questions.length,
                score: _score,
                selectedAnswer: _selectedAnswer,
                answered: _answered,
                onSelectAnswer: _selectAnswer,
                onNext: _goNext,
              ),
      ),
    );
  }
}

class _MixedQuestionView extends StatelessWidget {
  static const _accentColor = Color(0xFFFFB703);

  final MixedChallengeQuestion question;
  final int currentIndex;
  final int total;
  final int score;
  final String? selectedAnswer;
  final bool answered;
  final ValueChanged<String> onSelectAnswer;
  final VoidCallback onNext;

  const _MixedQuestionView({
    required this.question,
    required this.currentIndex,
    required this.total,
    required this.score,
    required this.selectedAnswer,
    required this.answered,
    required this.onSelectAnswer,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCorrect = selectedAnswer == question.correctAnswer;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _ProgressPill(label: '${currentIndex + 1}/$total'),
              const SizedBox(width: 10),
              Expanded(child: ProgressStars(earned: score, total: total)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C3350) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
              ),
            ),
            child: Column(
              children: [
                _CategoryChip(label: question.category),
                const SizedBox(height: 12),
                Text(
                  question.questionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: question.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final answer = question.options[index];
                final showCorrect =
                    answered && answer == question.correctAnswer;
                final showWrong =
                    answered && answer == selectedAnswer && !showCorrect;
                return ElevatedButton(
                  onPressed: answered ? null : () => onSelectAnswer(answer),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    backgroundColor: showCorrect
                        ? const Color(0xFF27AE60)
                        : showWrong
                            ? const Color(0xFFF2994A)
                            : (isDark ? const Color(0xFF1C3350) : Colors.white),
                    foregroundColor: showCorrect || showWrong
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF1A2D4A)),
                    disabledBackgroundColor: showCorrect
                        ? const Color(0xFF27AE60)
                        : showWrong
                            ? const Color(0xFFF2994A)
                            : (isDark ? const Color(0xFF1C3350) : Colors.white),
                    disabledForegroundColor: showCorrect || showWrong
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF1A2D4A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    answer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                );
              },
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 12),
            _MixedFeedback(
              isCorrect: isCorrect,
              explanation: question.explanation,
              hint: question.hint,
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: answered ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: const Color(0xFF1A2D4A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                currentIndex == total - 1
                    ? Icons.emoji_events_rounded
                    : Icons.arrow_forward_rounded,
              ),
              label: Text(
                currentIndex == total - 1 ? 'Terminar' : 'Siguiente',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MixedFeedback extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final String hint;

  const _MixedFeedback({
    required this.isCorrect,
    required this.explanation,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? const Color(0xFF27AE60) : const Color(0xFFF2994A);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        isCorrect ? explanation : hint,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF1A2D4A),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MixedFinished extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;

  const _MixedFinished({
    required this.score,
    required this.total,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFFB703),
              size: 74,
            ),
            const SizedBox(height: 12),
            ProgressStars(earned: score, total: total, size: 32),
            const SizedBox(height: 12),
            Text(
              'Lograste $score de $total puntos.',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Nuevo reto'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  final String label;

  const _ProgressPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB703).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF9A6500),
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB703).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF9A6500),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
