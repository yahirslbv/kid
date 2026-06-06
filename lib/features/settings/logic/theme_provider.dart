import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // 1. Iniciamos en modo sistema por defecto (Obedece al celular)
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // 2. Este 'getter' inteligente nos dice si la pantalla está oscura o clara
  // Sirve para que tu botón (Switch) de la pantalla de ajustes sepa cómo mostrarse
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Si está en automático, lee el ajuste directo del celular
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // 3. Cargar la configuración por si el usuario la forzó antes
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode');

    if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system; // Por defecto el del celular
    }
    notifyListeners();
  }

  // 4. Función para cambiar el tema manualmente desde tu pantalla de Ajustes
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    // Guardamos la decisión del usuario para cuando vuelva a abrir la app
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', isDark ? 'dark' : 'light');
  }
}