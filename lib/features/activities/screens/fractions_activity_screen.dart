import 'package:flutter/material.dart';

import '../../../shared/widgets/kids/progress_stars.dart';
import '../data/fraction_questions.dart';
import '../models/fraction_question.dart';
import '../utils/kids_question_selector.dart';

class FractionsActivityScreen extends StatefulWidget {
  const FractionsActivityScreen({super.key});

  @override
  State<FractionsActivityScreen> createState() =>
      _FractionsActivityScreenState();
}

class _FractionsActivityScreenState extends State<FractionsActivityScreen> {
  static const _accentColor = Color(0xFFEB5757);

  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;
  bool _finished = false;
  late List<FractionQuestion> _questions;

  FractionQuestion get _currentQuestion => _questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  void _startNewRound() {
    _questions = selectRandomQuestions(fractionQuestions);
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

  void _restart() {
    setState(_startNewRound);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF3F8FF),
      appBar: AppBar(
        title: const Text('Fracciones visuales'),
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _finished
            ? _FractionsFinished(
                score: _score,
                total: _questions.length,
                onRestart: _restart,
              )
            : _FractionQuestionView(
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

class _FractionQuestionView extends StatelessWidget {
  static const _accentColor = Color(0xFFEB5757);

  final FractionQuestion question;
  final int currentIndex;
  final int total;
  final int score;
  final String? selectedAnswer;
  final bool answered;
  final ValueChanged<String> onSelectAnswer;
  final VoidCallback onNext;

  const _FractionQuestionView({
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
    final textColor = isDark ? Colors.white : const Color(0xFF1A2D4A);
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF5E7188);
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
              Expanded(
                child: ProgressStars(earned: score, total: total, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
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
                Text(
                  question.questionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                FractionBar(
                  totalParts: question.totalParts,
                  shadedParts: question.shadedParts,
                  accentColor: _accentColor,
                ),
                const SizedBox(height: 14),
                Text(
                  '${question.shadedParts} de ${question.totalParts} partes',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: question.options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
              ),
              itemBuilder: (context, index) {
                final answer = question.options[index];
                return _FractionAnswerButton(
                  answer: answer,
                  isSelected: selectedAnswer == answer,
                  isCorrectAnswer: answer == question.correctAnswer,
                  showResult: answered,
                  onTap: () => onSelectAnswer(answer),
                );
              },
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 12),
            _FractionFeedback(
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
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
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
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FractionBar extends StatelessWidget {
  final int totalParts;
  final int shadedParts;
  final Color accentColor;

  const FractionBar({
    super.key,
    required this.totalParts,
    required this.shadedParts,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeTotal = totalParts < 1 ? 1 : totalParts;
    final safeShaded = shadedParts.clamp(0, safeTotal);

    return Semantics(
      label: '$safeShaded de $safeTotal partes coloreadas',
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF10243A) : const Color(0xFFFFF8F8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentColor.withValues(alpha: 0.65)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: List.generate(safeTotal, (index) {
            final isShaded = index < safeShaded;
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isShaded
                      ? accentColor
                      : (isDark
                          ? const Color(0xFF1C3350)
                          : const Color(0xFFFFFFFF)),
                  border: Border(
                    right: index == safeTotal - 1
                        ? BorderSide.none
                        : BorderSide(
                            color: isDark
                                ? const Color(0xFF234060)
                                : const Color(0xFFD6E8F7),
                            width: 2,
                          ),
                  ),
                ),
                child: isShaded
                    ? const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 26,
                      )
                    : null,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _FractionAnswerButton extends StatelessWidget {
  final String answer;
  final bool isSelected;
  final bool isCorrectAnswer;
  final bool showResult;
  final VoidCallback onTap;

  const _FractionAnswerButton({
    required this.answer,
    required this.isSelected,
    required this.isCorrectAnswer,
    required this.showResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _resolveColors(isDark);

    return InkWell(
      onTap: showResult ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border, width: 2),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                answer,
                style: TextStyle(
                  color: colors.foreground,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (showResult && (isSelected || isCorrectAnswer)) ...[
                const SizedBox(width: 8),
                Icon(
                  isCorrectAnswer
                      ? Icons.check_circle_rounded
                      : Icons.favorite_rounded,
                  color: colors.foreground,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _FractionButtonColors _resolveColors(bool isDark) {
    if (showResult && isCorrectAnswer) {
      return const _FractionButtonColors(
        background: Color(0xFFE7F7EE),
        border: Color(0xFF27AE60),
        foreground: Color(0xFF166534),
      );
    }

    if (showResult && isSelected && !isCorrectAnswer) {
      return const _FractionButtonColors(
        background: Color(0xFFFFF3D7),
        border: Color(0xFFF2994A),
        foreground: Color(0xFF9A4D00),
      );
    }

    if (isSelected) {
      return const _FractionButtonColors(
        background: Color(0xFFFFE5E5),
        border: Color(0xFFEB5757),
        foreground: Color(0xFF1A2D4A),
      );
    }

    return _FractionButtonColors(
      background: isDark ? const Color(0xFF1C3350) : Colors.white,
      border: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
      foreground: isDark ? Colors.white : const Color(0xFF1A2D4A),
    );
  }
}

class _FractionFeedback extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final String hint;

  const _FractionFeedback({
    required this.isCorrect,
    required this.explanation,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? const Color(0xFF27AE60) : const Color(0xFFF2994A);
    final bodyText = isCorrect ? explanation : hint;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.celebration_rounded : Icons.lightbulb_rounded,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? '¡Muy bien!' : 'Casi. Mira esta pista:',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bodyText,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF1A2D4A),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FractionsFinished extends StatelessWidget {
  static const _accentColor = Color(0xFFEB5757);

  final int score;
  final int total;
  final VoidCallback onRestart;

  const _FractionsFinished({
    required this.score,
    required this.total,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2D4A);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C3350) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFFFB703),
                size: 72,
              ),
              const SizedBox(height: 12),
              Text(
                '¡Actividad terminada!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              ProgressStars(earned: score, total: total, size: 32),
              const SizedBox(height: 10),
              Text(
                'Lograste $score de $total puntos.',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF5E7188),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: onRestart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Practicar otra vez',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
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
        color: const Color(0xFFEB5757).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFEB5757),
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FractionButtonColors {
  final Color background;
  final Color border;
  final Color foreground;

  const _FractionButtonColors({
    required this.background,
    required this.border,
    required this.foreground,
  });
}
