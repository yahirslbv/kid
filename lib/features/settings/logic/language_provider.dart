import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  // Empezamos con Español ('es') por defecto
  Locale _appLocale = const Locale('es');

  Locale get appLocale => _appLocale;

  // Para mostrar el nombre del idioma en el menú
  String get languageName => _appLocale.languageCode == 'es' ? 'Español' : 'English';

  void changeLanguage(String languageCode) {
    if (_appLocale.languageCode != languageCode) {
      _appLocale = Locale(languageCode);
      notifyListeners(); // Actualiza toda la app
    }
  }
}