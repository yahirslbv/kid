import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/app_imports.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Función para decidir cómo dibujar la imagen
  ImageProvider? _getImageProvider(String photoData) {
    if (photoData.isEmpty) return null;
    if (photoData.startsWith('http')) {
      return NetworkImage(photoData); 
    } else {
      return MemoryImage(base64Decode(photoData)); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Instanciamos el diccionario de traducciones
    final l10n = AppLocalizations.of(context)!;

    if (user == null || user.isAnonymous) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.perfilAppbar)), 
        body: Center(child: Text(l10n.iniciaSesionPerfil)), 
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF1A2D4A)),
        title: Text(
          l10n.miPerfilTitulo, 
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2D4A), fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              // Pasamos l10n a la función del BottomSheet
              onTap: () => authProvider.isLoading 
                  ? null 
                  : _showAvatarPicker(context, authProvider, isDark, l10n),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: authProvider.isPremium ? const Color(0xFFFFD700) : const Color(0xFF5B9BD5),
                      image: authProvider.photoUrl.isNotEmpty
                          ? DecorationImage(
                              image: _getImageProvider(authProvider.photoUrl)!,
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: (authProvider.isPremium ? Colors.amber : const Color(0xFF5B9BD5)).withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: authProvider.photoUrl.isEmpty
                        ? Icon(
                            authProvider.isPremium ? Icons.workspace_premium : Icons.person,
                            color: Colors.white,
                            size: 50,
                          )
                        : null,
                  ),
                  
                  if (authProvider.isLoading)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9BD5),
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC), width: 3),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    )
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              authProvider.userName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A)),
            ),
            const SizedBox(height: 5),
            Text(
              user.email ?? '',
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : const Color(0xFF6B8CAE)),
            ),
            // --- BOTÓN DE CAMBIAR CORREO (ABAJO) ---
            InkWell(
              onTap: () => _showChangeEmailDialog(context, authProvider, isDark),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9BD5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF5B9BD5).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email_outlined, size: 16, color: Color(0xFF5B9BD5)),
                    const SizedBox(width: 8),
                    const Text(
                      'Cambiar correo', 
                      style: TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF5B9BD5)
                      )
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C3350) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: authProvider.isPremium ? Colors.amber : (isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7))),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CABECERA (El estado actual) ---
                  Row(
                    children: [
                      Icon(
                        authProvider.isPremium ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: authProvider.isPremium ? Colors.amber : Colors.grey,
                        size: 30,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.estadoCuentaInfo, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey)),
                            Text(
                              authProvider.isPremium ? l10n.usuarioPremium : l10n.usuarioBasico, 
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: authProvider.isPremium ? Colors.amber : (isDark ? Colors.white : const Color(0xFF1A2D4A)),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  Divider(color: isDark ? Colors.white12 : Colors.black12),
                  const SizedBox(height: 12),
                  
                  // --- LISTA DE BENEFICIOS ---
                  Text(
                    'Tus beneficios actuales:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF6B8CAE)),
                  ),
                  const SizedBox(height: 12),
                  
                  if (authProvider.isPremium) ...[
                    // Beneficios si ES Premium
                    _buildBenefitItem(Icons.check_circle_rounded, 'Escáner matemático ilimitado', Colors.green, isDark),
                    _buildBenefitItem(Icons.check_circle_rounded, 'Tutor IA experto sin restricciones', Colors.green, isDark),
                    _buildBenefitItem(Icons.check_circle_rounded, 'Soluciones paso a paso detalladas', Colors.green, isDark),
                    _buildBenefitItem(Icons.check_circle_rounded, 'Experiencia limpia sin anuncios', Colors.green, isDark),
                  ] else ...[
                    // Beneficios/Límites si es Básico (Gratis)
                    _buildBenefitItem(Icons.check_circle_outline_rounded, 'Escáner matemático básico', Colors.grey, isDark),
                    _buildBenefitItem(Icons.info_outline_rounded, 'Límite diario de consultas al Tutor IA', Colors.orange, isDark),
                    _buildBenefitItem(Icons.info_outline_rounded, 'Contiene anuncios publicitarios', Colors.orange, isDark),
                    
                    const SizedBox(height: 20),
                    
                    // Botón para invitar a comprar Premium
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          // Aquí irá la navegación a tu pasarela de pago (RevenueCat/Google Play)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('¡Suscripciones próximamente!'), 
                              backgroundColor: Colors.amber,
                              behavior: SnackBarBehavior.floating,
                            )
                          );
                        },
                        icon: const Icon(Icons.workspace_premium_rounded, size: 20),
                        label: const Text('Mejorar a Premium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                Navigator.of(context).pop(); 
                await authProvider.signOut(); 
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text(l10n.btnCerrarSesion, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), 
            )
          ],
        ),
      ),
    );
  }

  // --- DIÁLOGO PARA CAMBIAR CORREO (De la nube) ---
  void _showChangeEmailDialog(BuildContext context, AuthProvider authProvider, bool isDark) {
    final newEmailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isObscured = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1C3350) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7), width: 1.5),
            ),
            title: Text('Cambiar Correo', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A2D4A))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Por seguridad, ingresa tu contraseña actual para confirmar el cambio de correo electrónico.',
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF6B8CAE)),
                ),
                const SizedBox(height: 16),
                
                // Campo Nuevo Correo
                TextField(
                  controller: newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2D4A), fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Nuevo Correo',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Color(0xFF5B9BD5)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF152840) : const Color(0xFFF0F7FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Campo Contraseña Actual
                TextField(
                  controller: passwordController,
                  obscureText: isObscured,
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2D4A), fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Contraseña Actual',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF5B9BD5)),
                    suffixIcon: IconButton(
                      icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.grey),
                      onPressed: () => setState(() => isObscured = !isObscured),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF152840) : const Color(0xFFF0F7FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
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
                  final newEmail = newEmailController.text.trim();
                  final password = passwordController.text.trim();

                  if (newEmail.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor llena todos los campos'), backgroundColor: Color(0xFFE53935)),
                    );
                    return;
                  }

                  // Mostramos un cargando manual en el snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Actualizando...'), duration: Duration(seconds: 1), backgroundColor: Color(0xFF5B9BD5)),
                  );

                  Navigator.pop(ctx); // Cierra el modal

                  final error = await context.read<AuthProvider>().changeUserEmail(newEmail, password);

                  if (!context.mounted) return;

                  if (error == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Enlace enviado! Revisa la bandeja del nuevo correo para confirmar el cambio.'), 
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: const Color(0xFFE53935)),
                    );
                  }
                },
                child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- SELECCIONAR AVATAR (Con tu l10n local) ---
  void _showAvatarPicker(BuildContext context, AuthProvider authProvider, bool isDark, AppLocalizations l10n) {
    final List<String> appAvatars = [
      'https://api.dicebear.com/9.x/bottts/png?seed=Math1',
      'https://api.dicebear.com/9.x/bottts/png?seed=Math2',
      'https://api.dicebear.com/9.x/bottts/png?seed=Math3',
      'https://api.dicebear.com/9.x/bottts/png?seed=Math4',
      'https://api.dicebear.com/9.x/bottts/png?seed=Math5',
      'https://api.dicebear.com/9.x/bottts/png?seed=Math6',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF152840) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Usamos la nueva traducción aquí
              Text(l10n.seleccionaAvatar, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))),
              const SizedBox(height: 20),
              
              SizedBox(
                height: 150,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  ),
                  itemCount: appAvatars.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        authProvider.updateProfilePicture(appAvatars[index]);
                        Navigator.pop(context); 
                      },
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFEBF4FC),
                        backgroundImage: NetworkImage(appAvatars[index]),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF5B9BD5).withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library, color: Color(0xFF5B9BD5)),
                ),
                // Usamos la nueva traducción aquí
                title: Text(l10n.subirGaleria, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2D4A), fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(context); 
                  
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 15, 
                  );
                  
                  if (image != null) {
                    await authProvider.uploadProfileImage(File(image.path));
                  }
                },
              ),
            ],
          ),
        );
        
      },
    );
  }
    // --- WIDGET PARA DIBUJAR CADA BENEFICIO ---
    Widget _buildBenefitItem(IconData icon, String text, Color iconColor, bool isDark) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF1A2D4A),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }