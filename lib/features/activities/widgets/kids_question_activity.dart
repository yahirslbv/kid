import 'package:flutter/material.dart';

import '../../../shared/widgets/kids/progress_stars.dart';
import '../models/kids_question.dart';
import '../utils/kids_question_selector.dart';

class KidsQuestionActivity extends StatefulWidget {
  final String title;
  final List<KidsQuestion> questions;
  final Color accentColor;

  const KidsQuestionActivity({
    super.key,
    required this.title,
    required this.questions,
    required this.accentColor,
  });

  @override
  State<KidsQuestionActivity> createState() => _KidsQuestionActivityState();
}

class _KidsQuestionActivityState extends State<KidsQuestionActivity> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _finished = false;
  late List<KidsQuestion> _questions;

  KidsQuestion get _currentQuestion => _questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  @override
  void didUpdateWidget(covariant KidsQuestionActivity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questions != widget.questions) {
      _startNewRound();
    }
  }

  void _startNewRound() {
    _questions = selectRandomQuestions(widget.questions);
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _answered = false;
    _finished = false;
  }

  void _selectAnswer(int answer) {
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
        title: Text(widget.title),
        backgroundColor: widget.accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _questions.isEmpty
            ? _EmptyActivity(accentColor: widget.accentColor)
            : _finished
                ? _ActivityFinished(
                    score: _score,
                    total: _questions.length,
                    accentColor: widget.accentColor,
                    onRestart: _restart,
                  )
                : _ActivityQuestion(
                    question: _currentQuestion,
                    currentIndex: _currentIndex,
                    total: _questions.length,
                    score: _score,
                    selectedAnswer: _selectedAnswer,
                    answered: _answered,
                    accentColor: widget.accentColor,
                    onSelectAnswer: _selectAnswer,
                    onNext: _goNext,
                  ),
      ),
    );
  }
}

class _ActivityQuestion extends StatelessWidget {
  final KidsQuestion question;
  final int currentIndex;
  final int total;
  final int score;
  final int? selectedAnswer;
  final bool answered;
  final Color accentColor;
  final ValueChanged<int> onSelectAnswer;
  final VoidCallback onNext;

  const _ActivityQuestion({
    required this.question,
    required this.currentIndex,
    required this.total,
    required this.score,
    required this.selectedAnswer,
    required this.answered,
    required this.accentColor,
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
              _ProgressPill(
                label: '${currentIndex + 1}/$total',
                accentColor: accentColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ProgressStars(earned: score, total: total, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
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
                  'Resuelve',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.questionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
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
                childAspectRatio: 1.45,
              ),
              itemBuilder: (context, index) {
                final answer = question.options[index];
                return _AnswerButton(
                  answer: answer,
                  isSelected: selectedAnswer == answer,
                  isCorrectAnswer: answer == question.correctAnswer,
                  showResult: answered,
                  accentColor: accentColor,
                  onTap: () => onSelectAnswer(answer),
                );
              },
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 12),
            _FeedbackPanel(
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
                backgroundColor: accentColor,
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

class _AnswerButton extends StatelessWidget {
  final int answer;
  final bool isSelected;
  final bool isCorrectAnswer;
  final bool showResult;
  final Color accentColor;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.answer,
    required this.isSelected,
    required this.isCorrectAnswer,
    required this.showResult,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _resolveColor(isDark);

    return InkWell(
      onTap: showResult ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
          color: color.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.border, width: 2),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$answer',
                style: TextStyle(
                  color: color.foreground,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (showResult && (isSelected || isCorrectAnswer)) ...[
                const SizedBox(width: 8),
                Icon(
                  isCorrectAnswer
                      ? Icons.check_circle_rounded
                      : Icons.favorite_rounded,
                  color: color.foreground,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _AnswerButtonColors _resolveColor(bool isDark) {
    if (showResult && isCorrectAnswer) {
      return const _AnswerButtonColors(
        background: Color(0xFFE7F7EE),
        border: Color(0xFF27AE60),
        foreground: Color(0xFF166534),
      );
    }

    if (showResult && isSelected && !isCorrectAnswer) {
      return const _AnswerButtonColors(
        background: Color(0xFFFFF3D7),
        border: Color(0xFFF2994A),
        foreground: Color(0xFF9A4D00),
      );
    }

    if (isSelected) {
      return _AnswerButtonColors(
        background: accentColor.withValues(alpha: 0.12),
        border: accentColor,
        foreground: isDark ? Colors.white : const Color(0xFF1A2D4A),
      );
    }

    return _AnswerButtonColors(
      background: isDark ? const Color(0xFF1C3350) : Colors.white,
      border: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
      foreground: isDark ? Colors.white : const Color(0xFF1A2D4A),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final String hint;

  const _FeedbackPanel({
    required this.isCorrect,
    required this.explanation,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? const Color(0xFF27AE60) : const Color(0xFFF2994A);
    final message = isCorrect ? '¡Muy bien!' : 'Casi. Mira esta pista:';
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
                  message,
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

class _ActivityFinished extends StatelessWidget {
  final int score;
  final int total;
  final Color accentColor;
  final VoidCallback onRestart;

  const _ActivityFinished({
    required this.score,
    required this.total,
    required this.accentColor,
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
                    backgroundColor: accentColor,
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

class _EmptyActivity extends StatelessWidget {
  final Color accentColor;

  const _EmptyActivity({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lightbulb_rounded, color: accentColor, size: 42),
            const SizedBox(height: 12),
            Text(
              'Esta actividad no tiene preguntas todavía.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF5E7188),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  final String label;
  final Color accentColor;

  const _ProgressPill({
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accentColor,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AnswerButtonColors {
  final Color background;
  final Color border;
  final Color foreground;

  const _AnswerButtonColors({
    required this.background,
    required this.border,
    required this.foreground,
  });
}
