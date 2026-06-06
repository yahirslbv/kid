import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../shared/app_imports.dart';
import '../../quiz/screens/quiz_screen.dart';
import '../../ecuaciones_diferenciales/screens/ecuaciones_main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // --- 1. NUEVO: Variable para controlar la pantalla actual de la pestaña "Estudio" ---
  Widget _currentStudyScreen = const EditorScreen();

  // --- 2. ACTUALIZADO: Ahora la lista de pantallas es dinámica ---
  List<Widget> get _screens => [
        // Índice 0
        _currentStudyScreen, // Muestra lo que el usuario eligió en el menú
        // Índice 1
        (_currentStudyScreen is GraficadorScreen)
            ? const IaTutorScreen()
            : const ChatScreen(),
        // Índice 2
        const SettingsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // --- 3. ACTUALIZADO: Los botones 2D/3D de arriba SOLO salen si estamos en la graficadora ---
    final isEditor = _selectedIndex == 0 && _currentStudyScreen is EditorScreen;

    return Scaffold(
      appBar: _buildAppBar(context, l10n, isDark, isEditor),
      drawer: _buildDrawer(context, isDark),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(context, l10n, isDark),
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    bool isEditor,
  ) {
    return AppBar(
      backgroundColor: const Color(0xFF5B9BD5),
      elevation: 0,
      titleSpacing: 20,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/app_icon.png',
              width: 34,
              height: 34,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Graph Math AI Studio',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (isEditor) _build2D3DToggle(context),
        const SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }

  // ── TOGGLE 2D / 3D ──────────────────────────────────────────────────────────
  Widget _build2D3DToggle(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final is3D = provider.is3DMode;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleChip(
            label: '2D',
            isActive: !is3D,
            onTap: () {
              if (is3D) provider.toggleMode();
            },
          ),
          _toggleChip(
            label: '3D',
            isActive: is3D,
            onTap: () {
              if (!is3D) provider.toggleMode();
            },
          ),
        ],
      ),
    );
  }

  Widget _toggleChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF3A7FC1) : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── BOTTOM NAVIGATION ────────────────────────────────────────────────────────
  Widget _buildBottomNav(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152840) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF5B9BD5).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              _navItem(
                context: context,
                icon: Icons.show_chart_rounded,
                label: l10n.navEstudio,
                index: 0,
                isDark: isDark,
              ),
              _navItem(
                context: context,
                icon: Icons.psychology_rounded,
                label: l10n.navAsistente,
                index: 1,
                isDark: isDark,
              ),
              _navItem(
                context: context,
                icon: Icons.tune_rounded,
                label: l10n.navAjustes,
                index: 2,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isActive = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 48 : 0,
                height: 3,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9BD5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Icon(
                icon,
                size: 24,
                color: isActive
                    ? const Color(0xFF5B9BD5)
                    : isDark
                        ? Colors.white38
                        : const Color(0xFF6B8CAE),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF5B9BD5)
                      : isDark
                          ? Colors.white38
                          : const Color(0xFF6B8CAE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── MENÚ LATERAL (DRAWER) ───────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context, bool isDark) {
    final authProvider = context.watch<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final isGuest = authProvider.user == null || authProvider.user!.isAnonymous;
    final userName = isGuest ? 'Invitado' : authProvider.userName;

    // --- NUEVO: LÓGICA PARA CARGAR LA FOTO DE PERFIL ---
    final photoUrl = authProvider.photoUrl;
    ImageProvider? imageProvider;

    if (photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        imageProvider = NetworkImage(photoUrl);
      } else {
        try {
          imageProvider = MemoryImage(base64Decode(photoUrl));
        } catch (e) {
          debugPrint("Error cargando imagen: $e");
        }
      }
    }
    // ---------------------------------------------------

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF152840) : Colors.white,
      child: Column(
        children: [
          // ── HEADER DEL MENÚ ──
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(top: 40, bottom: 16, left: 16, right: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF5B9BD5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- NUEVO: CONTENEDOR DE LA IMAGEN O ÍCONO ---
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    // Si tenemos foto, la ponemos de fondo
                    image: imageProvider != null
                        ? DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                    // Un pequeño borde blanco para que se vea elegante
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4), width: 2),
                  ),
                  // Si NO hay foto, mostramos el ícono de la persona
                  child: imageProvider == null
                      ? const Icon(Icons.person, color: Colors.white, size: 36)
                      : null,
                ),
                // ----------------------------------------------

                const SizedBox(height: 12),
                Text(
                  'Hola, $userName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ── OPCIONES FIJAS (Tus herramientas) ──

          _buildDrawerItem(
            context: context,
            icon: Icons.school_rounded,
            title: 'Modo Primaria',
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KidsHomeScreen()),
              );
            },
          ),

          const Divider(indent: 16, endIndent: 16),

          _buildDrawerItem(
            context: context,
            icon: Icons.auto_graph_rounded,
            title: 'Graficación 2D/3D',
            isDark: isDark,
            onTap: () {
              chatProvider.setSection('Gráficas');
              Navigator.pop(context);

              // CAMBIA EL CONTENIDO DE LA PESTAÑA A GRAFICACIÓN
              setState(() {
                _currentStudyScreen = const EditorScreen();
                _selectedIndex = 0;
              });
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.calculate_rounded,
            title: 'Álgebra y Funciones',
            isDark: isDark,
            onTap: () {
              chatProvider.setSection('Álgebra');
              Navigator.pop(context);

              // CAMBIA EL CONTENIDO DE LA PESTAÑA A ALGEBRA
              setState(() {
                _currentStudyScreen = const AlgebraScreen();
                _selectedIndex = 0;
              });
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.architecture_rounded,
            title: 'Mecánica Vectorial Estática',
            isDark: isDark,
            onTap: () {
              chatProvider.setSection('Mecánica Vectorial Estática');
              Navigator.pop(context);

              setState(() {
                _currentStudyScreen = const GraficadorScreen();
                _selectedIndex = 0;
              });
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.show_chart_rounded,
            title: 'Ecuaciones Diferenciales',
            isDark: isDark,
            onTap: () {
              chatProvider.setSection('Ecuaciones Diferenciales');
              Navigator.pop(context);
              // --- ACTUALIZADO: Conexión con el nuevo módulo de ecuaciones ---
              setState(() {
                _currentStudyScreen = const EcuacionesMainScreen();
                _selectedIndex = 0;
              });
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.bar_chart_rounded,
            title: 'Probabilidad y Estadística',
            isDark: isDark,
            onTap: () {
              chatProvider.setSection('Estadística');
              Navigator.pop(context);

              // CAMBIA EL CONTENIDO DE LA PESTAÑA A ESTADÍSTICA
              setState(() {
                _currentStudyScreen = const EstadisticaScreen();
                _selectedIndex = 0;
              });
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.calculate_outlined,
            title: 'Métodos Numéricos',
            isDark: isDark,
            onTap: () {
              chatProvider.setSection('Métodos Numéricos');
              Navigator.pop(context);
              setState(() {
                _currentStudyScreen = const MetodosNumericosScreen();
                _selectedIndex = 0;
              });
            },
          ),

          const Divider(indent: 16, endIndent: 16),

          _buildDrawerItem(
            context: context,
            icon: Icons.quiz_rounded,
            title: 'Pon a Prueba tus Conocimientos',
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuizScreen()),
              );
            },
          ),

          const Divider(),

          // ── SECCIÓN DE HISTORIAL DE IA ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historial de IA',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isGuest)
                  IconButton(
                    icon: Icon(Icons.add_circle_outline,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF5B9BD5)),
                    tooltip: 'Nuevo Chat',
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<ChatProvider>().clearChat();
                      setState(() => _selectedIndex = 1);
                    },
                  )
              ],
            ),
          ),

          // ── LÓGICA DE INVITADO VS REGISTRADO ──
          if (isGuest)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_toggle_off,
                          size: 48,
                          color: isDark ? Colors.white30 : Colors.black26),
                      const SizedBox(height: 16),
                      Text(
                        'Inicia sesión o regístrate para guardar tu historial de conversaciones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.chatSessions.isEmpty) {
                    return Center(
                        child: Text(
                      'No hay chats recientes',
                      style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54),
                    ));
                  }

                  // 1. AGRUPAR LOS CHATS POR MATERIA (TOPIC)
                  final groupedChats = <String, List<ChatSession>>{};
                  for (var session in chatProvider.chatSessions) {
                    groupedChats
                        .putIfAbsent(session.topic, () => [])
                        .add(session);
                  }

                  // 2. CREAR EL ACORDEÓN (EXPANSION TILE)
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: groupedChats.entries.map((entry) {
                      final topic = entry.key;
                      final sessions = entry.value;

                      // Asignar un ícono dependiendo de la materia
                      IconData topicIcon = Icons.folder_rounded;
                      if (topic == 'Gráficas' || topic == 'Álgebra')
                        topicIcon = Icons.auto_graph_rounded;
                      if (topic == 'Mecánica Vectorial')
                        topicIcon = Icons.architecture_rounded;
                      if (topic == 'Estadística')
                        topicIcon = Icons.bar_chart_rounded;
                      if (topic == 'Ecuaciones Diferenciales')
                        topicIcon = Icons.show_chart_rounded;
                      if (topic == 'Métodos Numéricos')
                        topicIcon = Icons.calculate_outlined;

                      return ExpansionTile(
                        leading:
                            Icon(topicIcon, color: const Color(0xFF5B9BD5)),
                        iconColor:
                            const Color(0xFF5B9BD5), // Color de la flechita
                        collapsedIconColor:
                            isDark ? Colors.white54 : Colors.black54,
                        title: Text(
                          topic,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A2D4A),
                            fontSize: 14,
                          ),
                        ),
                        // Aquí se despliegan los chats de esta materia
                        children: sessions.map((session) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left:
                                    16.0), // Indentación para que parezca subcarpeta
                            child: ListTile(
                              leading: Icon(Icons.chat_bubble_outline,
                                  size: 18,
                                  color: isDark
                                      ? Colors.white54
                                      : const Color(0xFF6B8CAE)),
                              title: Text(
                                session.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87),
                              ),
                              // --- NUEVO: BOTÓN DE ELIMINAR (Bote de basura) ---
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 18, color: Colors.redAccent),
                                onPressed: () async {
                                  // Un pequeño diálogo de seguridad antes de borrar
                                  final confirmar = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: isDark
                                          ? const Color(0xFF1C3350)
                                          : Colors.white,
                                      title: Text('Eliminar Chat',
                                          style: TextStyle(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87)),
                                      content: Text(
                                          '¿Seguro que deseas eliminar este chat de tu historial?',
                                          style: TextStyle(
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black54)),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Cancelar',
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Eliminar',
                                              style: TextStyle(
                                                  color: Colors.redAccent,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  );

                                  // Si el usuario dijo que sí, ejecutamos la función de borrar
                                  if (confirmar == true) {
                                    chatProvider.deleteChat(session.id);
                                  }
                                },
                              ),
                              // --------------------------------------------------
                              onTap: () {
                                Navigator.pop(context);
                                chatProvider.loadChatSession(session.id);
                                setState(() {
                                  if (session.topic == 'Álgebra') {
                                    _currentStudyScreen = const AlgebraScreen();
                                  } else if (session.topic == 'Estadística') {
                                    _currentStudyScreen =
                                        const EstadisticaScreen();
                                  } else if (session.topic ==
                                      'Métodos Numéricos') {
                                    _currentStudyScreen =
                                        const MetodosNumericosScreen();
                                  } else if (session.topic ==
                                      'Ecuaciones Diferenciales') {
                                    // --- ACTUALIZADO: Recuperación del historial para esta materia ---
                                    _currentStudyScreen =
                                        const EcuacionesMainScreen();
                                  } else if (session.topic == 'Gráficas' ||
                                      session.topic == 'General') {
                                    _currentStudyScreen = const EditorScreen();
                                  } else if (session.topic ==
                                      'Mecánica Vectorial') {
                                    _currentStudyScreen =
                                        const GraficadorScreen();
                                  }

                                  // Finalmente, te manda a la pestaña 1 (El Chat)
                                  _selectedIndex = 1;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // Widget auxiliar para estilizar cada elemento de la lista del menú
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : const Color(0xFF6B8CAE),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1A2D4A),
        ),
      ),
      onTap: onTap,
    );
  }
}
