import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../chat/logic/chat_provider.dart';

// Método global para abrir el asistente desde cualquier pantalla de mecánica
void showAssistantMecanica(BuildContext context, Color color, String contextoJson) {
  context.read<ChatProvider>().setSection('Mecánica Vectorial Estática');

  showModalBottomSheet(
    context: context, 
    isScrollControlled: true, 
    backgroundColor: Colors.transparent, 
    builder: (context) => MiniChatAssistantMecanica(contextoDatos: contextoJson, colorTema: color)
  );
}

class MiniChatAssistantMecanica extends StatefulWidget {
  final String contextoDatos; 
  final Color colorTema;
  
  const MiniChatAssistantMecanica({super.key, required this.contextoDatos, required this.colorTema});
  
  @override
  State<MiniChatAssistantMecanica> createState() => _MiniChatAssistantMecanicaState();
}

class _MiniChatAssistantMecanicaState extends State<MiniChatAssistantMecanica> {
  final _controller = TextEditingController();
  
  @override
  void dispose() { 
    _controller.dispose(); 
    super.dispose(); 
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom; 

    return Container(
      height: MediaQuery.of(context).size.height * 0.70 + bottomInset, 
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), 
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))), 
            child: Row(
              children: [
                Icon(Icons.architecture_rounded, color: widget.colorTema), // Ícono adaptado
                const SizedBox(width: 8), 
                Text(
                  "Tutor IA - Estática", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))
                ), 
                const Spacer(), 
                IconButton(
                  icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54), 
                  onPressed: () => Navigator.pop(context)
                )
              ]
            )
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16), 
              itemCount: chatProvider.messages.length, 
              itemBuilder: (context, index) {
                final msg = chatProvider.messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft, 
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8), 
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), 
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8), 
                    decoration: BoxDecoration(
                      color: msg.isUser ? widget.colorTema : (isDark ? const Color(0xFF234060) : const Color(0xFFE8EAF6)), 
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: msg.isUser ? const Radius.circular(0) : null, 
                        bottomLeft: !msg.isUser ? const Radius.circular(0) : null
                      )
                    ), 
                    child: Text(
                      msg.text, 
                      style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A2D4A)))
                    )
                  )
                );
              }
            )
          ),
          if (chatProvider.isLoading) 
            Padding(
              padding: const EdgeInsets.all(8.0), 
              child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: widget.colorTema))
            ),
          Padding(
            padding: const EdgeInsets.all(12.0), 
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller, 
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87), 
                    decoration: InputDecoration(
                      hintText: "¿Tienes alguna duda con tu diagrama?", 
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13), 
                      filled: true, 
                      fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF5F5F5), 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), 
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                    )
                  )
                ),
                const SizedBox(width: 8), 
                CircleAvatar(
                  backgroundColor: widget.colorTema, 
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), 
                    onPressed: () { 
                      if (_controller.text.isNotEmpty) { 
                        chatProvider.sendMessage(_controller.text, currentEquation: widget.contextoDatos); 
                        _controller.clear(); 
                      } 
                    }
                  )
                ),
              ]
            )
          ),
        ],
      ),
    );
  }
}