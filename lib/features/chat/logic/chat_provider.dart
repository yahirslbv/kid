import 'dart:math'; 
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translator/translator.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as genai; 

class ChatMessage {
  String text; 
  final bool isUser;
  bool isTranslating; 
  
  ChatMessage({
    required this.text, 
    required this.isUser,
    this.isTranslating = false,
  });
}

class ChatSession {
  final String id;
  final String title;
  final String topic;
  ChatSession({required this.id, required this.title, this.topic = 'General'});
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  final _translator = GoogleTranslator();
  final List<Map<String, dynamic>> _history = [];

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentChatId;
  List<ChatSession> _chatSessions = [];
  String _currentLanguage = 'es'; 

  // --- CONCIENCIA DE UBICACIÓN Y TOPIC ---
  String _currentSection = 'General'; 
  String get currentSection => _currentSection;

  List<ChatSession> get chatSessions => _chatSessions;

  ChatProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null && !user.isAnonymous) {
        fetchUserChats();
      } else {
        clearChat();
        _chatSessions.clear();
        notifyListeners();
      }
    });
  }

  void setSection(String topic) {
    if (_currentSection != topic) {
      _currentSection = topic;
      debugPrint("🤖 Asistente cambió al modo y sección: $_currentSection");
      
      clearChat();
      fetchUserChats(); 
    }
  }

  Future<void> fetchUserChats() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .orderBy('createdAt', descending: true)
          .get();

      _chatSessions = snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatSession(
          id: doc.id,
          title: data['title'] ?? 'Nuevo Chat',
          topic: data.containsKey('topic') ? data['topic'] : 'General',
        );
      }).toList();
      notifyListeners();
      
    } catch (e) {
      debugPrint("Error obteniendo chats: $e");
    }
  }

  // --- INSTRUCCIÓN DINÁMICA SEGÚN LA SECCIÓN ---
  String get _systemInstruction {
    String baseInstruction = 
        'Eres un profesor universitario experto y amigable.\n'
        'Responde SIEMPRE en el idioma con código: $_currentLanguage.\n'
        'Reglas:\n'
        '1. Explica los conceptos de forma clara, didáctica y conversacional.\n'
        '2. Si tienes que mostrar una fórmula matemática, usa SIEMPRE el formato LaTeX envuelto en símbolos de dólar (\$).\n'
        '3. Usa negritas y viñetas para organizar tu texto.\n'
        '4. Si el usuario pide datos o comparaciones, genérale tablas en formato Markdown.\n'
        '5. Si el usuario te hace una pregunta que NO tiene nada que ver con el contexto actual, dile educadamente que en este chat solo puedes hablar sobre el tema actual.\n\n';

    // Para detectar cualquier variante de la sección de Ecuaciones
    if (_currentSection.contains('Ecuaciones Diferenciales')) {
      return '${baseInstruction}Contexto Actual: Eres un experto en Ecuaciones Diferenciales basado en:\n- "Differential Equations 3rd Ed." de Shepley L. Ross\n- "Elementary Differential Equations" de Edwards & Penney\n- "Ecuaciones Diferenciales" de Irineo Peral Alonso\nCita el capítulo y sección del libro al explicar cada método. Resuelve paso a paso mostrando cada transformación algebraica.';
    }

    switch (_currentSection) {
      case 'Gráficas':
        return '${baseInstruction}Contexto Actual: Eres un experto en cálculo, álgebra y análisis de funciones 2D y 3D. Ayuda a entender la gráfica matemática actual.';
      case 'Estadística':
        return '${baseInstruction}Contexto Actual: Eres un profesor titular de Probabilidad y Estadística para Ingenieros. Basa tus respuestas rigurosamente en la metodología del libro "Probabilidad y Estadística para Ingenieros" de Miller y Freund (Richard A. Johnson). Utiliza teoría exacta extraída de la base de datos cuando se te proporcione.';
      case 'Mecánica Vectorial':
        return '${baseInstruction}Contexto Actual: Eres un profesor universitario de Física y Mecánica Vectorial (Estática y Dinámica). Basa tus respuestas en el libro de "Mecánica Vectorial para Ingenieros" de Beer & Johnston.';
      case 'Métodos Numéricos':
        return '${baseInstruction}Contexto Actual: Eres un experto en Métodos Numéricos y Análisis Numérico. Ayuda a resolver problemas usando algoritmos como Bisección, Newton-Raphson, Gauss-Seidel, Interpolación y Runge-Kutta. Explica las iteraciones y el cálculo de errores de forma clara.';  
      default:
        return '${baseInstruction}Contexto Actual: Eres un tutor general de matemáticas y ciencias. Responde de manera general sin asumir un tema específico a menos que se indique lo contrario.';
    }
  }

  Future<List<double>> _getEmbedding(String text) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No se encontró GEMINI_API_KEY en el archivo .env');
    }

    final model = genai.GenerativeModel(
      model: 'gemini-embedding-001', 
      apiKey: apiKey,
    );

    try {
      final content = genai.Content.text(text);
      final result = await model.embedContent(
        content,
        taskType: genai.TaskType.retrievalQuery, 
      );
      return result.embedding.values;
    } catch (e) {
      debugPrint('Error en SDK al vectorizar: $e');
      throw Exception('Error al vectorizar la pregunta');
    }
  }

  Future<String> _buscarEnLibros(List<double> vectorPregunta) async {
    try {
      final querySnapshot = await _firestore.collection('knowledge_base').get();
      List<Map<String, dynamic>> resultados = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('embedding') && data.containsKey('texto')) {
          
          List<double> docVector = [];
          var rawVector = data['embedding'];
          
          if (rawVector is List) {
            docVector = rawVector.map((e) => (e as num).toDouble()).toList();
          } else {
            docVector = (rawVector as VectorValue).toArray().map((e) => (e as num).toDouble()).toList();
          }

          if (docVector.isNotEmpty) {
             double similitud = _cosineSimilarity(vectorPregunta, docVector);
             resultados.add({
               'texto': data['texto'],
               'score': similitud
             });
          }
        }
      }

      resultados.sort((a, b) => b['score'].compareTo(a['score']));
      String contextoExtraido = "";
      for (int i = 0; i < min(3, resultados.length); i++) {
        contextoExtraido += resultados[i]['texto'] + "\n\n";
      }
      return contextoExtraido.trim();
    } catch (e) {
      debugPrint("Error buscando en la base de datos vectorial: $e");
      return ""; 
    }
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  Future<void> sendMessage(String text, {String? currentEquation, String? languageCode}) async {
    if (text.isEmpty) return;
    if (languageCode != null && languageCode.isNotEmpty) {
      _currentLanguage = languageCode;
    }

    _isLoading = true;
    _messages.add(ChatMessage(text: text, isUser: true));
    notifyListeners();

    try {
      String extractoDelLibro = "";

      // --- RAG ACTIVADO PARA ESTADÍSTICA Y ECUACIONES DIFERENCIALES ---
      if (_currentSection == 'Estadística' || _currentSection.contains('Ecuaciones Diferenciales')) {
        final vectorPregunta = await _getEmbedding(text);
        extractoDelLibro = await _buscarEnLibros(vectorPregunta);
      }

      String promptToSend = 'Pregunta: "$text".\n';
          
      if (extractoDelLibro.isNotEmpty) {
        promptToSend += 
          'Usa EXCLUSIVAMENTE esta teoría extraída de los libros oficiales para responder de forma precisa y detallada:\n'
          '--- INICIO TEORÍA ---\n$extractoDelLibro\n--- FIN TEORÍA ---\n';
      }

      if (currentEquation != null && currentEquation.isNotEmpty) {
        if (_currentSection == 'Gráficas') {
          promptToSend += '\nFunción matemática en análisis: f(x) = $currentEquation.';
        } else if (_currentSection == 'Estadística' || _currentSection.contains('Ecuaciones Diferenciales')) {
          promptToSend += '\n[DATOS O CONTEXTO ESTADÍSTICO/MATEMÁTICO EN PANTALLA]: $currentEquation.';
        } else {
          promptToSend += '\n[CONTEXTO ACTUAL]: $currentEquation.';
        }
      }

      _history.add({
        'role': 'user',
        'parts': [{'text': promptToSend}],
      });

      final responseText = await _callGeminiAPI();

      _history.add({
        'role': 'model',
        'parts': [{'text': responseText}],
      });

      _messages.add(ChatMessage(text: responseText, isUser: false));

      final user = _auth.currentUser;
      if (user != null && !user.isAnonymous) {
        await _saveChatToFirestore(text, responseText, user.uid);
      }

    } catch (e) {
      String errorMsg = _parseError(e.toString());
      _messages.add(ChatMessage(text: errorMsg, isUser: false));
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> translateLocalMessage(int index, String targetLanguageCode) async {
    if (index < 0 || index >= _messages.length) return;
    final msg = _messages[index];
    if (msg.isUser || msg.text.isEmpty) return;

    msg.isTranslating = true;
    notifyListeners();

    try {
      final translation = await _translator.translate(msg.text, to: targetLanguageCode);
      msg.text = translation.text;
    } catch (e) {
      debugPrint("Error al traducir localmente: $e");
    } finally {
      msg.isTranslating = false;
      notifyListeners();
    }
  }

  Future<void> _saveChatToFirestore(String userText, String botResponse, String uid) async {
    final chatRef = _firestore.collection('users').doc(uid).collection('chats');
    try {
      if (_currentChatId == null) {
        final newChat = await chatRef.add({
          'title': userText,
          'topic': _currentSection, 
          'createdAt': FieldValue.serverTimestamp(),
          'messages': [
            {'text': userText, 'isUser': true},
            {'text': botResponse, 'isUser': false},
          ]
        });
        _currentChatId = newChat.id;
        await fetchUserChats();
      } else {
        await chatRef.doc(_currentChatId).update({
          'messages': FieldValue.arrayUnion([
            {'text': userText, 'isUser': true},
            {'text': botResponse, 'isUser': false},
          ])
        });
      }
    } catch (e) {
      debugPrint("Error guardando en Firestore: $e");
    }
  }

  Future<void> loadChatSession(String chatId) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;

    _isLoading = true;
    _currentChatId = chatId;
    _messages.clear();
    _history.clear();
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(user.uid).collection('chats').doc(chatId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        if (data.containsKey('topic')) {
          _currentSection = data['topic'];
        }

        final msgs = data['messages'] as List<dynamic>;
        
        for (var msg in msgs) {
          final text = msg['text'] as String;
          final isUser = msg['isUser'] as bool;
          
          _messages.add(ChatMessage(text: text, isUser: isUser));
          _history.add({
            'role': isUser ? 'user' : 'model',
            'parts': [{'text': text}],
          });
        }
      }
    } catch (e) {
      debugPrint("Error cargando historial de chat: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _callGeminiAPI() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No se encontró GEMINI_API_KEY en el archivo .env');
    }

    const model = 'gemini-3-flash-preview';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': _systemInstruction} 
        ]
      },
      'contents': _history,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 4096,
      },
    });

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 360));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final candidate = data['candidates']?[0];
      final text = candidate?['content']?['parts']?[0]?['text'];
      final finishReason = candidate?['finishReason'];

      if (finishReason == 'MAX_TOKENS') {
        return (text ?? '') + '\n\n*(Nota: La respuesta fue demasiado larga y se truncó)*';
      }
      return text ?? 'No pude generar una respuesta.';
    } else {
      final error = jsonDecode(response.body);
      final message = error['error']?['message'] ?? 'Error desconocido';
      throw Exception('${response.statusCode}: $message');
    }
  }

  String _parseError(String error) {
    if (error.contains('429') || error.contains('quota') || error.contains('RESOURCE_EXHAUSTED')) {
      return '⏳ Demasiadas solicitudes seguidas. Espera unos segundos e intenta de nuevo.';
    } else if (error.contains('401') || error.contains('API_KEY') || error.contains('invalid')) {
      return '🔑 La API Key no es válida. Verifica tu archivo .env.';
    } else if (error.contains('timeout') || error.contains('TimeoutException')) {
      return '🌐 La conexión tardó demasiado. Revisa la conexión a internet e intenta de nuevo.';
    } else if (error.contains('GEMINI_API_KEY')) {
      return '⚠️ No se encontró la API Key. Asegúrate de tener el archivo .env configurado.';
    }
    return '❌ Ocurrió un error. Intenta de nuevo en unos momentos.';
  }

  Future<void> deleteChat(String chatId) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      await _firestore.collection('users').doc(user.uid).collection('chats').doc(chatId).delete();
      _chatSessions.removeWhere((session) => session.id == chatId);

      if (_currentChatId == chatId) {
        clearChat();
      } else {
        notifyListeners(); 
      }
    } catch (e) {
      debugPrint("Error eliminando chat: $e");
    }
  }

  void clearChat() {
    _currentChatId = null;
    _messages.clear();
    _history.clear();
    notifyListeners();
  }
}