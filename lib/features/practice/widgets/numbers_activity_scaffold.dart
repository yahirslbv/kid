import 'package:flutter/material.dart';

import '../../../shared/widgets/kids/progress_stars.dart';
import '../../activities/utils/kids_question_selector.dart';

class NumbersActivityScaffold<Q, A> extends StatefulWidget {
  final String title;
  final Color accentColor;
  final List<Q> questions;
  final String Function(Q question) questionTextBuilder;
  final List<A> Function(Q question) optionsBuilder;
  final A Function(Q question) correctAnswerBuilder;
  final String Function(Q question) explanationBuilder;
  final String Function(Q question) hintBuilder;
  final String Function(A answer) optionLabelBuilder;
  final Widget Function(BuildContext context, Q question)? visualBuilder;
  final int questionCount;

  const NumbersActivityScaffold({
    super.key,
    required this.title,
    required this.accentColor,
    required this.questions,
    required this.questionTextBuilder,
    required this.optionsBuilder,
    required this.correctAnswerBuilder,
    required this.explanationBuilder,
    required this.hintBuilder,
    required this.optionLabelBuilder,
    this.visualBuilder,
    this.questionCount = 5,
  });

  @override
  State<NumbersActivityScaffold<Q, A>> createState() =>
      _NumbersActivityScaffoldState<Q, A>();
}

class _NumbersActivityScaffoldState<Q, A>
    extends State<NumbersActivityScaffold<Q, A>> {
  int _currentIndex = 0;
  int _score = 0;
  A? _selectedAnswer;
  bool _answered = false;
  bool _finished = false;
  late List<Q> _questions;

  Q get _currentQuestion => _questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  @override
  void didUpdateWidget(covariant NumbersActivityScaffold<Q, A> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questions != widget.questions ||
        oldWidget.questionCount != widget.questionCount) {
      _startNewRound();
    }
  }

  void _startNewRound() {
    _questions = selectRandomQuestions(
      widget.questions,
      count: widget.questionCount,
    );
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _answered = false;
    _finished = false;
  }

  void _selectAnswer(A answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == widget.correctAnswerBuilder(_currentQuestion)) {
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
      ),
      body: SafeArea(
        child: _questions.isEmpty
            ? _EmptyNumbersActivity(accentColor: widget.accentColor)
            : _finished
                ? _NumbersActivityFinished(
                    score: _score,
                    total: _questions.length,
                    accentColor: widget.accentColor,
                    onRestart: _restart,
                  )
                : _NumbersActivityQuestion<Q, A>(
                    question: _currentQuestion,
                    currentIndex: _currentIndex,
                    total: _questions.length,
                    score: _score,
                    selectedAnswer: _selectedAnswer,
                    answered: _answered,
                    accentColor: widget.accentColor,
                    questionTextBuilder: widget.questionTextBuilder,
                    optionsBuilder: widget.optionsBuilder,
                    correctAnswerBuilder: widget.correctAnswerBuilder,
                    explanationBuilder: widget.explanationBuilder,
                    hintBuilder: widget.hintBuilder,
                    optionLabelBuilder: widget.optionLabelBuilder,
                    visualBuilder: widget.visualBuilder,
                    onSelectAnswer: _selectAnswer,
                    onNext: _goNext,
                  ),
      ),
    );
  }
}

class _NumbersActivityQuestion<Q, A> extends StatelessWidget {
  final Q question;
  final int currentIndex;
  final int total;
  final int score;
  final A? selectedAnswer;
  final bool answered;
  final Color accentColor;
  final String Function(Q question) questionTextBuilder;
  final List<A> Function(Q question) optionsBuilder;
  final A Function(Q question) correctAnswerBuilder;
  final String Function(Q question) explanationBuilder;
  final String Function(Q question) hintBuilder;
  final String Function(A answer) optionLabelBuilder;
  final Widget Function(BuildContext context, Q question)? visualBuilder;
  final ValueChanged<A> onSelectAnswer;
  final VoidCallback onNext;

  const _NumbersActivityQuestion({
    required this.question,
    required this.currentIndex,
    required this.total,
    required this.score,
    required this.selectedAnswer,
    required this.answered,
    required this.accentColor,
    required this.questionTextBuilder,
    required this.optionsBuilder,
    required this.correctAnswerBuilder,
    required this.explanationBuilder,
    required this.hintBuilder,
    required this.optionLabelBuilder,
    required this.visualBuilder,
    required this.onSelectAnswer,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2D4A);
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF5E7188);
    final correctAnswer = correctAnswerBuilder(question);
    final isCorrect = answered && selectedAnswer == correctAnswer;
    final options = optionsBuilder(question);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _ProgressPill(
              label: '${currentIndex + 1}/$total',
              accentColor: accentColor,
            ),
            const SizedBox(width: 10),
            Expanded(child: ProgressStars(earned: score, total: total)),
          ],
        ),
        const SizedBox(height: 16),
        if (visualBuilder != null) ...[
          visualBuilder!(context, question),
          const SizedBox(height: 14),
        ],
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C3350) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
            ),
          ),
          child: Column(
            children: [
              Text(
                'Elige una respuesta',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                questionTextBuilder(question),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 25,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...options.map(
          (answer) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _NumbersAnswerButton(
              label: optionLabelBuilder(answer),
              isSelected: selectedAnswer == answer,
              isCorrectAnswer: answer == correctAnswer,
              showResult: answered,
              accentColor: accentColor,
              onTap: () => onSelectAnswer(answer),
            ),
          ),
        ),
        if (answered) ...[
          const SizedBox(height: 2),
          _FeedbackPanel(
            isCorrect: isCorrect,
            explanation: explanationBuilder(question),
            hint: hintBuilder(question),
          ),
        ],
        const SizedBox(height: 14),
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
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _NumbersAnswerButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isCorrectAnswer;
  final bool showResult;
  final Color accentColor;
  final VoidCallback onTap;

  const _NumbersAnswerButton({
    required this.label,
    required this.isSelected,
    required this.isCorrectAnswer,
    required this.showResult,
    required this.accentColor,
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
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.foreground,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (showResult && (isSelected || isCorrectAnswer)) ...[
              const SizedBox(width: 8),
              Icon(
                isCorrectAnswer
                    ? Icons.check_circle_rounded
                    : Icons.lightbulb_rounded,
                color: colors.foreground,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  _AnswerColors _resolveColors(bool isDark) {
    if (showResult && isCorrectAnswer) {
      return const _AnswerColors(
        background: Color(0xFFE7F7EE),
        border: Color(0xFF27AE60),
        foreground: Color(0xFF166534),
      );
    }

    if (showResult && isSelected && !isCorrectAnswer) {
      return const _AnswerColors(
        background: Color(0xFFFFF3D7),
        border: Color(0xFFF2994A),
        foreground: Color(0xFF9A4D00),
      );
    }

    if (isSelected) {
      return _AnswerColors(
        background: accentColor.withValues(alpha: 0.12),
        border: accentColor,
        foreground: isDark ? Colors.white : const Color(0xFF1A2D4A),
      );
    }

    return _AnswerColors(
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
    final message = isCorrect ? 'Muy bien!' : 'Casi. Mira esta pista:';
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

class _NumbersActivityFinished extends StatelessWidget {
  final int score;
  final int total;
  final Color accentColor;
  final VoidCallback onRestart;

  const _NumbersActivityFinished({
    required this.score,
    required this.total,
    required this.accentColor,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2D4A);
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF5E7188);

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
                size: 74,
              ),
              const SizedBox(height: 12),
              Text(
                'Buen trabajo!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              ProgressStars(earned: score, total: total, size: 32),
              const SizedBox(height: 10),
              Text(
                'Puntuacion: $score/$total',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              _FinishedButton(
                label: 'Intentar otra vez',
                icon: Icons.refresh_rounded,
                color: accentColor,
                onPressed: onRestart,
              ),
              const SizedBox(height: 10),
              _FinishedButton(
                label: 'Volver a Numeros',
                icon: Icons.looks_one_rounded,
                color: const Color(0xFF00A6A6),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
              _FinishedButton(
                label: 'Volver al inicio',
                icon: Icons.home_rounded,
                color: const Color(0xFF9B51E0),
                onPressed: () => Navigator.popUntil(context, (route) {
                  return route.isFirst;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinishedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _FinishedButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _EmptyNumbersActivity extends StatelessWidget {
  final Color accentColor;

  const _EmptyNumbersActivity({required this.accentColor});

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
              'Esta actividad no tiene preguntas todavia.',
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

class _AnswerColors {
  final Color background;
  final Color border;
  final Color foreground;

  const _AnswerColors({
    required this.background,
    required this.border,
    required this.foreground,
  });
}
