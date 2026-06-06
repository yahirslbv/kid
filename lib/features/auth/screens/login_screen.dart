import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'package:app_links/app_links.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController     = TextEditingController();

  bool _isLoginMode    = true;
  bool _obscurePass    = true;
  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;
  // --- NUEVAS VARIABLES PARA LOS LINKS ---
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    // Iniciar el escuchador de enlaces profundos
    _initDeepLinks();
  }

  // --- NUEVA LÓGICA PARA ESCUCHAR EL CORREO ---
  void _initDeepLinks() {
    _appLinks = AppLinks();

    // 1. Escuchar si la app ya estaba abierta de fondo y tocan el link
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });

    // 2. Escuchar si la app estaba completamente cerrada y la abre el link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    // Verificamos si el link es de Firebase
    if (uri.host == 'math-ia-studio.firebaseapp.com' && uri.path == '/__/auth/action') {
      final mode = uri.queryParameters['mode'];
      final oobCode = uri.queryParameters['oobCode']; // El código secreto de Firebase

      if (mode == 'resetPassword' && oobCode != null) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        // Abrimos el menú para poner la nueva contraseña
        _showNewPasswordDialog(oobCode, isDark);
      }
    }
  }

  // Menú para que escriba y guarde su nueva contraseña
  void _showNewPasswordDialog(String oobCode, bool isDark) {
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Obliga al usuario a usar el menú
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C3350) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7), width: 1.5),
        ),
        title: Text(
          'Nueva Contraseña',
          style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A2D4A)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'El código de tu correo fue validado con éxito. Por favor escribe tu nueva contraseña:',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : const Color(0xFF6B8CAE)),
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: newPassController,
              label: 'Nueva contraseña (Mín. 6 caracteres)',
              icon: Icons.lock_reset,
              obscureText: true,
              isDark: isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF6B8CAE))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9BD5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final newPass = newPassController.text.trim();
              if (newPass.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres'), backgroundColor: Color(0xFFE53935)),
                );
                return;
              }

              Navigator.pop(ctx); // Cerramos el menú
              final error = await context.read<AuthProvider>().confirmPasswordReset(oobCode, newPass);

              if (!mounted) return;

              if (error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Contraseña actualizada con éxito! Ya puedes iniciar sesión.'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error), backgroundColor: const Color(0xFFE53935)),
                );
              }
            },
            child: const Text('Guardar Contraseña', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    final auth     = Provider.of<AuthProvider>(context, listen: false);
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name     = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    String? error;
    if (_isLoginMode) {
      error = await auth.signInWithEmailAndPassword(email, password);
    } else {
      if (name.isEmpty) return;
      error = await auth.createUserWithEmailAndPassword(email, password, name);
    }

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _toggleMode() {
    _animController.reset();
    setState(() => _isLoginMode = !_isLoginMode);
    _animController.forward();
  }

  // --- NUEVO: DIÁLOGO PARA RECUPERAR CONTRASEÑA ---
  void _showForgotPasswordDialog(BuildContext context, bool isDark, AppLocalizations l10n) {
    // Controlador independiente para no afectar el del login
    final resetEmailController = TextEditingController(text: _emailController.text.trim());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C3350) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
            width: 1.5,
          ),
        ),
        title: Text(
          'Recuperar contraseña',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A2D4A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF6B8CAE),
              ),
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: resetEmailController,
              label: l10n.correoElectronico,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              isDark: isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF6B8CAE)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9BD5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;

              // Cerramos el diálogo para mostrar que está cargando/procesando
              Navigator.pop(ctx);
              
              // Mostramos un SnackBar de que se está enviando
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enviando correo...'),
                  backgroundColor: Color(0xFF5B9BD5),
                  duration: Duration(seconds: 1),
                ),
              );

              final error = await context.read<AuthProvider>().sendPasswordResetEmail(email);
              
              if (!mounted) return;

              if (error == null) {
                // Éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('¡Correo enviado! Revisa tu bandeja de entrada o spam.'),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                // Falló
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: const Color(0xFFE53935),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Enviar Enlace', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n   = AppLocalizations.of(context)!;

    return Scaffold(
      // Fondo con gradiente azul suave como la referencia
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F1E2E), const Color(0xFF1C3350)]
                : [const Color(0xFFD6E8F7), const Color(0xFFEBF4FC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── LOGO / HEADER ────────────────────────────────────
                      _buildHeader(isDark, l10n),
                      const SizedBox(height: 36),

                      // ── CARD FORMULARIO ──────────────────────────────────
                      _buildFormCard(auth, isDark, l10n),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        // Ícono con fondo azul como en la referencia
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF5B9BD5),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B9BD5).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: Image.asset('assets/app_icon.png', width: 60, height: 60, fit: BoxFit.cover),
),
        ),
        const SizedBox(height: 20),
        Text(
          ' Graph Math AI Studio',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF1A2D4A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.graficaAnaliza,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : const Color(0xFF6B8CAE),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── CARD FORMULARIO ─────────────────────────────────────────────────────────
  Widget _buildFormCard(AuthProvider auth, bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0xFF234060)
              : const Color(0xFFD6E8F7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF5B9BD5).withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título del modo
          Text(
            _isLoginMode ? l10n.iniciarSesionBtn : l10n.crearCuentaBtn,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A2D4A),
            ),
          ),
          const SizedBox(height: 24),

          // Campo nombre (solo en registro)
          if (!_isLoginMode) ...[
            _buildField(
              controller: _nameController,
              label: l10n.nombreCompleto,
              icon: Icons.person_outline_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 14),
          ],

          // Email
          _buildField(
            controller: _emailController,
            label: l10n.correoElectronico,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // Contraseña
          _buildField(
            controller: _passwordController,
            label: l10n.contrasena,
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePass,
            isDark: isDark,
            suffix: IconButton(
              icon: Icon(
                _obscurePass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: const Color(0xFF6B8CAE),
              ),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ),

          // --- NUEVO: BOTÓN DE OLVIDÉ MI CONTRASEÑA ---
          if (_isLoginMode)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showForgotPasswordDialog(context, isDark, l10n),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: const Color(0xFF5B9BD5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else 
            // Espaciador si estamos en modo registro para mantener el tamaño
            const SizedBox(height: 14),
            
          const SizedBox(height: 16),

          // Botón principal
          auth.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFF5B9BD5),
                    ),
                  ),
                )
              : _buildPrimaryButton(
                  label: _isLoginMode ? l10n.iniciarSesionBtn : l10n.registrarseBtn,
                  onTap: _submit,
                ),

          const SizedBox(height: 12),

          // --- NUEVO: BOTÓN DE GOOGLE ---
          if (!auth.isLoading) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('O continuar con', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : const Color(0xFF6B8CAE))),
                ),
                Expanded(child: Divider(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7))),
              ],
            ),
            const SizedBox(height: 16),
            
            GestureDetector(
              onTap: () async {
                final error = await auth.signInWithGoogle();
                if (error != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: const Color(0xFFE53935)),
                  );
                }
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF152840) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Usamos una pequeña imagen de internet para el logo de Google
                    Image.network('https://cdn-icons-png.flaticon.com/512/300/300221.png', width: 24, height: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Google',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // ------------------------------

          // Continuar como invitado (solo en login)
          if (_isLoginMode && !auth.isLoading)
            _buildSecondaryButton(
              label: l10n.continuarInvitado,
              onTap: () async {
                final error = await auth.signInAsGuest();
                if (error != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: const Color(0xFFE53935),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              isDark: isDark,
            ),

          // Divider decorativo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark
                        ? const Color(0xFF234060)
                        : const Color(0xFFD6E8F7),
                  ),
                ),
              ],
            ),
          ),

          // Toggle login / registro
          Center(
            child: GestureDetector(
              onTap: _toggleMode,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : const Color(0xFF6B8CAE),
                  ),
                  children: [
                    TextSpan(
                      text: _isLoginMode
                          ? l10n.noTienesCuenta
                          : l10n.yaTienesCuenta,
                    ),
                    TextSpan(
                      text: _isLoginMode ? l10n.registrateAccion : l10n.iniciaSesionAccion,
                      style: const TextStyle(
                        color: Color(0xFF5B9BD5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CAMPO DE TEXTO ──────────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1A2D4A),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF5B9BD5)),
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark
            ? const Color(0xFF152840)
            : const Color(0xFFF0F7FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? const Color(0xFF234060)
                : const Color(0xFFD6E8F7),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? const Color(0xFF234060)
                : const Color(0xFFD6E8F7),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF5B9BD5),
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(color: Color(0xFF6B8CAE), fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ── BOTÓN PRINCIPAL ─────────────────────────────────────────────────────────
  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B9BD5), Color(0xFF3A7FC1)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B9BD5).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  // ── BOTÓN SECUNDARIO ────────────────────────────────────────────────────────
  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF152840)
              : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? const Color(0xFF234060)
                : const Color(0xFFD6E8F7),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF6B8CAE),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}