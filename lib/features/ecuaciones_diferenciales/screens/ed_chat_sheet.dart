import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../chat/logic/chat_provider.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class EdChatSheet extends StatefulWidget {
  final String moduleName;
  final String contextoDatos;
  final Color colorTema;
  final String? initialMessage;

  const EdChatSheet({
    super.key,
    required this.moduleName,
    required this.contextoDatos,
    required this.colorTema,
    this.initialMessage,
  });

  @override
  State<EdChatSheet> createState() => _EdChatSheetState();
}

class _EdChatSheetState extends State<EdChatSheet> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Variable para rastrear la cantidad de mensajes y evitar renders infinitos
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    // Si entramos con un mensaje inicial (desde una calculadora), lo disparamos
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Verificar que el widget siga en pantalla antes de enviar el mensaje
        if (mounted) {
          _sendInitialMessage();
        }
      });
    }
  }

  @override
  void dispose() {
    // Es importante liberar los controladores para evitar fugas de memoria
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendInitialMessage() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendMessage(
      widget.initialMessage!,
      currentEquation: widget.contextoDatos,
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Auto-scroll solo cuando llega un mensaje nuevo (evita bugs de rendimiento)
    if (chatProvider.messages.length > _previousMessageCount) {
      _previousMessageCount = chatProvider.messages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToBottom();
      });
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1E2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle de arrastre y título
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: widget.colorTema.withOpacity(0.2),
                  child: Icon(Icons.auto_awesome, color: widget.colorTema, size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Asistente: ${widget.moduleName}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text("Basado en Ross & Edwards", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          const Divider(),

          // Lista de mensajes
          Expanded(
            child: chatProvider.messages.isEmpty && chatProvider.isLoading
                ? Center(child: CircularProgressIndicator(color: widget.colorTema))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(15),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatProvider.messages[index];
                      final isUser = msg.isUser;
                      return _buildChatBubble(msg.text, isUser, isDark);
                    },
                  ),
          ),

          if (chatProvider.isLoading && chatProvider.messages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: widget.colorTema, backgroundColor: widget.colorTema.withOpacity(0.1)),
            ),

          // Input de texto
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 15,
              left: 15,
              right: 15,
              top: 10,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C3350) : Colors.grey[100],
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Pregunta sobre el paso a paso...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                    ),
                    onSubmitted: (_) => _handleSend(chatProvider),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: widget.colorTema),
                  onPressed: () => _handleSend(chatProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend(ChatProvider chatProvider) {
    if (_messageController.text.trim().isEmpty) return;
    // <-- CORRECCIÓN: Usar currentEquation en lugar de contexto
    chatProvider.sendMessage(
      _messageController.text.trim(),
      currentEquation: widget.contextoDatos,
    );
    _messageController.clear();
  }

  Widget _buildChatBubble(String text, bool isUser, bool isDark) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser 
              ? widget.colorTema 
              : (isDark ? const Color(0xFF234060) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isUser ? 15 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 15),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
        ),
        child: isUser 
            ? Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ) 
            : _renderMathOrText(text, isDark),
      ),
    );
  }

  // Método auxiliar para intentar renderizar LaTeX si el mensaje es de la IA
  Widget _renderMathOrText(String text, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    
    // Si detectamos patrones comunes de ecuaciones intentamos usar Math.tex
    if (text.contains(r'\') || text.contains('^') || text.contains('_') || text.contains(r'$')) {
      try {
        // Limpiamos los delimitadores comunes de bloque que usan las IAs
        String cleanText = text.replaceAll(r'\[', '').replaceAll(r'\]', '').replaceAll(r'$$', '');
        return Math.tex(
          cleanText,
          textStyle: TextStyle(color: textColor, fontSize: 16),
          mathStyle: MathStyle.display,
        );
      } catch (e) {
        // Si falla el parseo de LaTeX, hace un fallback seguro a texto normal
        return Text(text, style: TextStyle(color: textColor, fontSize: 14));
      }
    }
    
    return Text(text, style: TextStyle(color: textColor, fontSize: 14));
  }
}