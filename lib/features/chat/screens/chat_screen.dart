import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../shared/app_imports.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final currentEquation = context.read<EditorProvider>().equation;
    final languageCode = context.read<LanguageProvider>().appLocale.languageCode; 

    context.read<ChatProvider>().sendMessage(
      text,
      currentEquation: currentEquation,
      languageCode: languageCode, 
    );

    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (chatProvider.messages.isNotEmpty) _scrollToBottom();

    return Container(
      color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      child: Column(
        children: [
          // --- NUEVO: INDICADOR VISUAL DEL MODO ACTUAL ---
          _ModeIndicator(currentSection: chatProvider.currentSection, isDark: isDark),

          Expanded(
            child: chatProvider.messages.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatProvider.messages[index];
                      return _MessageBubble(
                        index: index, 
                        text: msg.text,
                        isUser: msg.isUser,
                        isDark: isDark,
                        isLast: index == chatProvider.messages.length - 1,
                        isTranslating: msg.isTranslating, 
                      );
                    },
                  ),
          ),

          if (chatProvider.isLoading)
            _TypingIndicator(isDark: isDark),

          _ChatInput(
            controller: _controller,
            isDark: isDark,
            onSend: () => _sendMessage(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 110,
            child: BotAvatar(size: 110, animate: true),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.chatEmptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : const Color(0xFF6B8CAE),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            children: [
              AppLocalizations.of(context)!.chatSuggestionDomain,
              AppLocalizations.of(context)!.chatSuggestionIntersect,
              AppLocalizations.of(context)!.chatSuggestionExplain,
            ].map((hint) => _SuggestionChip(hint: hint, isDark: isDark)).toList(),
          ),
        ],
      ),
    );
  }
}

// ── BANNER INDICADOR DE SECCIÓN (NUEVO) ──────────────────────────────────────
class _ModeIndicator extends StatelessWidget {
  final String currentSection;
  final bool isDark;

  const _ModeIndicator({required this.currentSection, required this.isDark});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    
    // Elegimos el ícono dependiendo de la sección
    switch (currentSection) {
      case 'Gráficas':
        icon = Icons.calculate_rounded;
        break;
      case 'Estadística':
        icon = Icons.bar_chart_rounded;
        break;
      case 'Mecánica Vectorial':
        icon = Icons.architecture_rounded;
        break;
      case 'Ecuaciones Diferenciales':
        icon = Icons.show_chart_rounded;
        break;
      default:
        icon = Icons.psychology_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152840) : const Color(0xFFD6E8F7),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF234060) : const Color(0xFFB0CDE8).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF5B9BD5)),
          const SizedBox(width: 8),
          Text(
            'Asistente enfocado en: $currentSection',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF1A2D4A),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── EL RESTO DEL CÓDIGO INTACTO ──────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final int index;
  final String text;
  final bool isUser;
  final bool isDark;
  final bool isLast;
  final bool isTranslating;

  const _MessageBubble({
    required this.index,
    required this.text,
    required this.isUser,
    required this.isDark,
    required this.isLast,
    required this.isTranslating,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _AvatarBot(isDark: isDark),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF5B9BD5), Color(0xFF3A7FC1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUser
                    ? null
                    : isDark
                        ? const Color(0xFF1C3350)
                        : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: isDark
                            ? const Color(0xFF234060)
                            : const Color(0xFFD6E8F7),
                        width: 1.5,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? const Color(0xFF5B9BD5).withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isUser
                      ? Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        )
                      : MarkdownBody(
                          data: text,
                          selectable: false,
                          builders: <String, MarkdownElementBuilder>{
                            'latex': LatexElementBuilder(
                              textStyle: const TextStyle(
                                color: Color(0xFF5B9BD5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          },
                          extensionSet: md.ExtensionSet(
                            <md.BlockSyntax>[
                              LatexBlockSyntax(),
                              ...md.ExtensionSet.gitHubFlavored.blockSyntaxes
                            ],
                            <md.InlineSyntax>[
                              LatexInlineSyntax(),
                              ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                            ],
                          ),
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                              fontSize: 15,
                              height: 1.5,
                            ),
                            tableBorder: TableBorder.all(
                              color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
                              width: 1,
                            ),
                            tableHead: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF5B9BD5) : const Color(0xFF3A7FC1),
                            ),
                            tableCellsPadding: const EdgeInsets.all(8),
                            code: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              backgroundColor: isDark
                                  ? const Color(0xFF0F1E2E)
                                  : const Color(0xFFEBF4FC),
                              color: const Color(0xFF5B9BD5),
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
                              ),
                            ),
                            strong: const TextStyle(
                              color: Color(0xFF5B9BD5),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                  
                  if (!isUser) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: isTranslating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF5B9BD5),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                final langCode = context.read<LanguageProvider>().appLocale.languageCode;
                                context.read<ChatProvider>().translateLocalMessage(index, langCode);
                              },
                              child: Icon(
                                Icons.g_translate_rounded,
                                size: 18,
                                color: isDark ? Colors.white38 : const Color(0xFFB0CDE8),
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _AvatarBot extends StatelessWidget {
  final bool isDark;
  const _AvatarBot({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 36,
      child: BotAvatar(size: 36, animate: false),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  final bool isDark;
  const _TypingIndicator({required this.isDark});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _AvatarBot(isDark: widget.isDark),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1C3350) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(
                color: widget.isDark
                    ? const Color(0xFF234060)
                    : const Color(0xFFD6E8F7),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final delay = i * 0.3;
                    final val = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
                    final bounce = val < 0.5 ? val * 2 : (1 - val) * 2;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 7,
                      height: 7,
                      transform: Matrix4.translationValues(0, -6 * bounce, 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9BD5)
                            .withValues(alpha: 0.4 + bounce * 0.6),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.isDark,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152840) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF234060)
                : const Color(0xFFD6E8F7),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0xFF5B9BD5).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C3350)
                      : const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF234060)
                        : const Color(0xFFD6E8F7),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.chatInputHint,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white30 : const Color(0xFFB0CDE8),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B9BD5), Color(0xFF3A7FC1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B9BD5).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String hint;
  final bool isDark;

  const _SuggestionChip({required this.hint, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final chatProvider = context.read<ChatProvider>();
        final equation = context.read<EditorProvider>().equation;
        final languageCode = context.read<LanguageProvider>().appLocale.languageCode; 

        chatProvider.sendMessage(
          hint,
          currentEquation: equation,
          languageCode: languageCode, 
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C3350) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF234060)
                : const Color(0xFFD6E8F7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B9BD5).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          hint,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : const Color(0xFF5B9BD5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}