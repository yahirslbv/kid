import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../shared/app_imports.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n         = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final user         = authProvider.user;
    final isGuest      = user == null || user.isAnonymous;
    final isDark       = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // ── CARD DE CUENTA ──
          _SectionLabel(label: l10n.cuenta, isDark: isDark),
          const SizedBox(height: 10),
          _AccountCard(
            isGuest: isGuest,
            user: user,
            isDark: isDark,
            l10n: l10n,
            onTap: () async => await authProvider.signOut(),
          ),

          const SizedBox(height: 24),

          // ── PREFERENCIAS ──
          _SectionLabel(label: l10n.preferencias, isDark: isDark),
          const SizedBox(height: 10),
          _PreferencesCard(isDark: isDark, l10n: l10n),

          const SizedBox(height: 24),

          // ── ACERCA DE ──
          _SectionLabel(label: l10n.acercaDe, isDark: isDark),
          const SizedBox(height: 10),
          _AboutCard(isDark: isDark, l10n: l10n),

          const SizedBox(height: 32),

          // ── VERSIÓN ──
          Center(
            child: Text(
              'Math AI Studio v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white24 : const Color(0xFFB0CDE8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? Colors.white38 : const Color(0xFF6B8CAE),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _SettingsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0xFF5B9BD5).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ── CARD DE CUENTA ACTUALIZADO PARA BASE64 ──
class _AccountCard extends StatelessWidget {
  final bool isGuest;
  final dynamic user;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _AccountCard({
    required this.isGuest,
    required this.user,
    required this.isDark,
    required this.l10n,
    required this.onTap,
  });

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
    final photoUrl = authProvider.photoUrl;

    return _SettingsCard(
      isDark: isDark,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: isGuest
                      ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500])
                      : const LinearGradient(colors: [Color(0xFF5B9BD5), Color(0xFF3A7FC1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  
                  // USAMOS LA FUNCIÓN AQUÍ
                  image: !isGuest && photoUrl.isNotEmpty
                      ? DecorationImage(
                          image: _getImageProvider(photoUrl)!,
                          fit: BoxFit.cover,
                        )
                      : null,
                      
                  boxShadow: [
                    BoxShadow(color: (isGuest ? Colors.grey : const Color(0xFF5B9BD5)).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: (!isGuest && photoUrl.isNotEmpty)
                    ? null
                    : Icon(isGuest ? Icons.person_outline_rounded : Icons.person_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGuest ? l10n.iniciaSesion : authProvider.userName,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A2D4A)),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isGuest ? l10n.iniciaSesionSub : (user?.email ?? l10n.cuentaRegistrada),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : const Color(0xFF6B8CAE)),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (isGuest) {
                    await authProvider.signOut();
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: isGuest ? const Color(0xFF5B9BD5) : const Color(0xFFD6E8F7), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    isGuest ? l10n.entrar : 'Ver Perfil',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isGuest ? Colors.white : const Color(0xFF5B9BD5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const _PreferencesCard({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      isDark: isDark,
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return _SettingsTile(
              isDark: isDark,
              icon: Icons.dark_mode_rounded,
              iconColor: const Color(0xFF5B9BD5),
              title: l10n.temaOscuro,
              trailing: _StyledSwitch(
                value: themeProvider.isDarkMode,
                onChanged: themeProvider.toggleTheme,
              ),
              showDivider: true,
            );
          },
        ),
        Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            return _SettingsTile(
              isDark: isDark,
              icon: Icons.language_rounded,
              iconColor: const Color(0xFFF5A623),
              title: l10n.idiomaApp,
              subtitle: languageProvider.languageName,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : const Color(0xFFB0CDE8),
              ),
              showDivider: false,
              onTap: () => _showLanguageDialog(context, languageProvider, l10n),
            );
          },
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider languageProvider, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C3350) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7), width: 1.5),
        ),
        title: Text(l10n.seleccionarIdioma, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A2D4A))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              flag: '🇲🇽',
              label: 'Español',
              isSelected: languageProvider.languageName == 'Español',
              isDark: isDark,
              onTap: () { languageProvider.changeLanguage('es'); Navigator.pop(context); },
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              flag: '🇺🇸',
              label: 'English',
              isSelected: languageProvider.languageName == 'English',
              isDark: isDark,
              onTap: () { languageProvider.changeLanguage('en'); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const _AboutCard({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      isDark: isDark,
      children: [
        _SettingsTile(
          isDark: isDark,
          icon: Icons.info_outline_rounded,
          iconColor: const Color(0xFF5B9BD5),
          title: l10n.acercaDeSub,
          trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : const Color(0xFFB0CDE8)),
          showDivider: true,
          // --- AQUÍ CONECTAMOS EL BOTÓN CON LA FUNCIÓN DEL DIÁLOGO ---
          onTap: () => _showAboutDialog(context), 
        ),
        _SettingsTile(
          isDark: isDark,
          icon: Icons.star_outline_rounded,
          iconColor: const Color(0xFFF5A623),
          title: l10n.valorarApp,
          trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : const Color(0xFFB0CDE8)),
          showDivider: false,
          onTap: () async {
            // Este es tu enlace oficial directo a tu app en Google Play
            final Uri playStoreUrl = Uri.parse('https://play.google.com/store/apps/details?id=com.juancarlos.graphmathaistudio');
            
            try {
              // Intentamos abrir la app de la Play Store directamente
              await launchUrl(
                playStoreUrl, 
                mode: LaunchMode.externalApplication, // Esto fuerza a que se abra la app de la tienda, no el navegador web
              );
            } catch (e) {
              // Si falla (por ejemplo, si el celular no tiene la Play Store instalada)
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo abrir la tienda de aplicaciones.'), 
                    backgroundColor: Colors.redAccent
                  )
                );
              }
            }
          },
        ),
      ],
    );
  }

  // --- FUNCIÓN QUE CONSTRUYE EL CUADRO DE DIÁLOGO ---
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C3350) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7), 
            width: 1.5
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contenedor del Logo
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B9BD5).withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                // Usamos el icono nativo de tus assets
                child: Image.asset('assets/app_icon.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            
            // Título de la App
            Text(
              'Graph Math AI Studio',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A2D4A),
              ),
            ),
            const SizedBox(height: 6),
            
            // Versión
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9BD5).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Versión 1.0.0',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF5B9BD5),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Descripción
            Text(
              'Tu tutor personal inteligente. Escanea problemas, genera tabuladores interactivos y domina Álgebra, Estadística y Métodos Numéricos con la ayuda de Inteligencia Artificial.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF6B8CAE),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            
            // Créditos
            const Divider(),
            const SizedBox(height: 12),
            Text(
              '''Desarrollado con ❤️ por:
               Cruz Hernandez Juan Carlos
               Victor Yahir Medrano Barrera
               Lenin Baku Cortez Hernández''',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 20),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9BD5),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Aceptar', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),
        ],
      ),
    );
  }
}
class _SettingsTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showDivider;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.isDark, required this.icon, required this.iconColor, required this.title,
    this.subtitle, this.trailing, required this.showDivider, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A2D4A))),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : const Color(0xFF6B8CAE))),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, indent: 68, endIndent: 16, color: isDark ? const Color(0xFF234060) : const Color(0xFFEBF4FC)),
      ],
    );
  }
}

class _StyledSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _StyledSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: const Color(0xFF5B9BD5),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xFFD6E8F7),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag, required this.label, required this.isSelected, required this.isDark, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B9BD5).withValues(alpha: 0.12) : (isDark ? const Color(0xFF152840) : const Color(0xFFF0F7FF)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF5B9BD5) : (isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7)), width: 1.5),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? const Color(0xFF5B9BD5) : (isDark ? Colors.white : const Color(0xFF1A2D4A)))),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF5B9BD5), size: 20),
          ],
        ),
      ),
    );
  }
}