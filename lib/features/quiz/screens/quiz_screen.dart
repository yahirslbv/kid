import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// ─── MODELO DE PREGUNTA ────────────────────────────────────────────────────────
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}

// ─── PANTALLA PRINCIPAL DEL QUIZ ───────────────────────────────────────────────
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Temas disponibles
  static const List<Map<String, dynamic>> _topics = [
    {'title': 'Graficación 2D/3D',           'icon': Icons.auto_graph_rounded,    'color': Color(0xFF5B9BD5)},
    {'title': 'Álgebra y Funciones',          'icon': Icons.calculate_rounded,     'color': Color(0xFF7C6BBD)},
    {'title': 'Mecánica Vectorial',           'icon': Icons.architecture_rounded,  'color': Color(0xFF4CAF7D)},
    {'title': 'Ecuaciones Diferenciales',     'icon': Icons.show_chart_rounded,    'color': Color(0xFFE67E3A)},
    {'title': 'Probabilidad y Estadística',   'icon': Icons.bar_chart_rounded,     'color': Color(0xFFE53935)},
    {'title': 'Métodos Numéricos',            'icon': Icons.calculate_outlined,    'color': Color(0xFF00ACC1)},
  ];

  // Estado
  String? _selectedTopic;
  int _difficulty = 1; // 0=Fácil, 1=Medio, 2=Difícil
  bool _isLoading = false;
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  bool _quizFinished = false;
  String _errorMsg = '';

  static const _difficultyLabels = ['Fácil', 'Medio', 'Difícil'];
  static const _difficultyColors = [Color(0xFF4CAF7D), Color(0xFFE67E3A), Color(0xFFE53935)];

  // ── LLAMADA A GEMINI ─────────────────────────────────────────────────────────
  Future<void> _startQuiz() async {
    if (_selectedTopic == null) return;
    setState(() { _isLoading = true; _errorMsg = ''; });

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) throw Exception('No se encontró GEMINI_API_KEY');

      final difficulty = _difficultyLabels[_difficulty];
      final prompt = '''
Genera exactamente 5 preguntas de opción múltiple sobre el tema: "$_selectedTopic".
Nivel de dificultad: $difficulty.
Responde ÚNICAMENTE con un JSON válido. Sin texto extra, sin markdown, sin comillas de código.
Formato exacto:
[
  {
    "question": "Texto de la pregunta",
    "options": ["Opción A", "Opción B", "Opción C", "Opción D"],
    "correctIndex": 0,
    "explanation": "Explicación breve de por qué es correcta la respuesta"
  }
]
El campo correctIndex es el índice (0-3) de la opción correcta en el arreglo options.
Las preguntas deben ser variadas, educativas y en español.
''';

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'role': 'user', 'parts': [{'text': prompt}]}],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 2048},
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Error ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      String raw = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

      // Limpiar posibles marcadores de markdown
      raw = raw.replaceAll('```json', '').replaceAll('```', '').trim();

      final List<dynamic> parsed = jsonDecode(raw);
      final questions = parsed.map((q) => QuizQuestion.fromJson(q)).toList();

      setState(() {
        _questions = questions;
        _currentIndex = 0;
        _selectedAnswer = null;
        _answered = false;
        _score = 0;
        _quizFinished = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Error al generar las preguntas. Verifica tu conexión e inténtalo de nuevo.';
      });
    }
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    final isCorrect = index == _questions[_currentIndex].correctIndex;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      setState(() => _quizFinished = true);
    }
  }

  void _resetQuiz() {
    setState(() {
      _questions = [];
      _currentIndex = 0;
      _selectedAnswer = null;
      _answered = false;
      _score = 0;
      _quizFinished = false;
      _errorMsg = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(
        title: const Text('Pon a Prueba tus Conocimientos'),
        backgroundColor: const Color(0xFF5B9BD5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? _buildLoading(isDark)
          : _questions.isEmpty
              ? _buildTopicSelector(isDark)
              : _quizFinished
                  ? _buildResults(isDark)
                  : _buildQuestion(isDark),
    );
  }

  // ── PANTALLA DE SELECCIÓN DE TEMA ────────────────────────────────────────────
  Widget _buildTopicSelector(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A7FC1), Color(0xFF5B9BD5)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.quiz_rounded, color: Colors.white, size: 36),
                const SizedBox(height: 10),
                const Text(
                  'Quiz Generado por IA',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecciona un tema y Gemini creará preguntas únicas para ti',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Selección de tema
          Text('Elige un tema:', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A2D4A),
          )),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
            ),
            itemCount: _topics.length,
            itemBuilder: (context, i) {
              final topic = _topics[i];
              final isSelected = _selectedTopic == topic['title'];
              return GestureDetector(
                onTap: () => setState(() => _selectedTopic = topic['title']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (topic['color'] as Color).withValues(alpha: 0.2)
                        : (isDark ? const Color(0xFF1C3350) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? topic['color'] as Color : (isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7)),
                      width: isSelected ? 2 : 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(topic['icon'] as IconData, color: topic['color'] as Color, size: 28),
                      Text(
                        topic['title'] as String,
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Dificultad
          Text('Dificultad:', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A2D4A),
          )),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (i) {
              final isSelected = _difficulty == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _difficulty = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _difficultyColors[i].withValues(alpha: 0.15)
                          : (isDark ? const Color(0xFF1C3350) : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _difficultyColors[i] : (isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7)),
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    child: Text(
                      _difficultyLabels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? _difficultyColors[i] : (isDark ? Colors.white54 : const Color(0xFF6B8CAE)),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          if (_errorMsg.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(_errorMsg, style: const TextStyle(color: Color(0xFFE53935), fontSize: 13))),
              ]),
            ),
          ],

          const SizedBox(height: 24),

          // Botón de iniciar
          GestureDetector(
            onTap: _selectedTopic != null ? _startQuiz : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 54,
              decoration: BoxDecoration(
                gradient: _selectedTopic != null
                    ? const LinearGradient(colors: [Color(0xFF5B9BD5), Color(0xFF3A7FC1)])
                    : null,
                color: _selectedTopic == null
                    ? (isDark ? const Color(0xFF1C3350) : const Color(0xFFD6E8F7))
                    : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _selectedTopic != null ? [
                  BoxShadow(color: const Color(0xFF5B9BD5).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                ] : null,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_rounded,
                      color: _selectedTopic != null ? Colors.white : (isDark ? Colors.white30 : const Color(0xFF6B8CAE)),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Comenzar Quiz',
                      style: TextStyle(
                        color: _selectedTopic != null ? Colors.white : (isDark ? Colors.white30 : const Color(0xFF6B8CAE)),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── LOADING ──────────────────────────────────────────────────────────────────
  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 60, height: 60,
            child: CircularProgressIndicator(strokeWidth: 4, color: Color(0xFF5B9BD5)),
          ),
          const SizedBox(height: 24),
          Text(
            'Gemini está generando\ntus preguntas...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF1A2D4A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedTopic ?? '',
            style: const TextStyle(color: Color(0xFF5B9BD5), fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ── PREGUNTA ─────────────────────────────────────────────────────────────────
  Widget _buildQuestion(bool isDark) {
    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de progreso
          Row(
            children: [
              Text(
                '${_currentIndex + 1} / ${_questions.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : const Color(0xFF6B8CAE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
                    color: const Color(0xFF5B9BD5),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF7D).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '✓ $_score',
                  style: const TextStyle(color: Color(0xFF4CAF7D), fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chip del tema
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF5B9BD5).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _selectedTopic!,
              style: const TextStyle(color: Color(0xFF5B9BD5), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),

          // Pregunta
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C3350) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7)),
            ),
            child: Text(
              q.question,
              style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w600, height: 1.5,
                color: isDark ? Colors.white : const Color(0xFF1A2D4A),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Opciones
          ...List.generate(q.options.length, (i) {
            Color? bgColor;
            Color? borderColor;
            IconData? trailingIcon;

            if (_answered) {
              if (i == q.correctIndex) {
                bgColor = const Color(0xFF4CAF7D).withValues(alpha: 0.15);
                borderColor = const Color(0xFF4CAF7D);
                trailingIcon = Icons.check_circle_rounded;
              } else if (i == _selectedAnswer && i != q.correctIndex) {
                bgColor = const Color(0xFFE53935).withValues(alpha: 0.12);
                borderColor = const Color(0xFFE53935);
                trailingIcon = Icons.cancel_rounded;
              }
            } else if (_selectedAnswer == i) {
              bgColor = const Color(0xFF5B9BD5).withValues(alpha: 0.15);
              borderColor = const Color(0xFF5B9BD5);
            }

            return GestureDetector(
              onTap: () => _selectAnswer(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor ?? (isDark ? const Color(0xFF1C3350) : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor ?? (isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7)),
                    width: borderColor != null ? 2 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: (borderColor ?? const Color(0xFF6B8CAE)).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          ['A', 'B', 'C', 'D'][i],
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: borderColor ?? const Color(0xFF6B8CAE),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        q.options[i],
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                        ),
                      ),
                    ),
                    if (trailingIcon != null)
                      Icon(trailingIcon, color: borderColor, size: 22),
                  ],
                ),
              ),
            );
          }),

          // Explicación
          if (_answered) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9BD5).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF5B9BD5).withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_rounded, color: Color(0xFF5B9BD5), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      q.explanation,
                      style: TextStyle(
                        fontSize: 13, height: 1.5,
                        color: isDark ? Colors.white70 : const Color(0xFF1A2D4A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9BD5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _nextQuestion,
                child: Text(
                  _currentIndex < _questions.length - 1 ? 'Siguiente →' : 'Ver Resultados',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── RESULTADOS ───────────────────────────────────────────────────────────────
  Widget _buildResults(bool isDark) {
    final total = _questions.length;
    final pct = (_score / total * 100).round();
    final Color resultColor = pct >= 80
        ? const Color(0xFF4CAF7D)
        : pct >= 50
            ? const Color(0xFFE67E3A)
            : const Color(0xFFE53935);
    final String resultMsg = pct >= 80
        ? '¡Excelente! Dominas el tema '
        : pct >= 50
            ? 'Buen intento, sigue practicando '
            : 'Necesitas repasar este tema ';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Círculo de resultado
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: resultColor.withValues(alpha: 0.12),
                border: Border.all(color: resultColor, width: 4),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$pct%',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: resultColor),
                    ),
                    Text(
                      '$_score / $total',
                      style: TextStyle(fontSize: 14, color: resultColor.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              resultMsg,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A2D4A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTopic!,
              style: const TextStyle(color: Color(0xFF5B9BD5), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9BD5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _startQuiz,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text('Nuevo Quiz (mismo tema)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF5B9BD5), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _resetQuiz,
                icon: const Icon(Icons.topic_rounded, color: Color(0xFF5B9BD5)),
                label: const Text('Cambiar Tema', style: TextStyle(color: Color(0xFF5B9BD5), fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}