import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @cuenta.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get cuenta;

  /// No description provided for @iniciaSesion.
  ///
  /// In es, this message translates to:
  /// **'Inicia Sesión o Regístrate'**
  String get iniciaSesion;

  /// No description provided for @iniciaSesionSub.
  ///
  /// In es, this message translates to:
  /// **'Guarda tus gráficos y chats en la nube'**
  String get iniciaSesionSub;

  /// No description provided for @preferencias.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get preferencias;

  /// No description provided for @temaOscuro.
  ///
  /// In es, this message translates to:
  /// **'Tema Oscuro'**
  String get temaOscuro;

  /// No description provided for @idiomaApp.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la App'**
  String get idiomaApp;

  /// No description provided for @acercaDe.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get acercaDe;

  /// No description provided for @acercaDeSub.
  ///
  /// In es, this message translates to:
  /// **'Acerca de Graph Math AI Studio'**
  String get acercaDeSub;

  /// No description provided for @editorModo3D.
  ///
  /// In es, this message translates to:
  /// **'Modo 3D'**
  String get editorModo3D;

  /// No description provided for @errorConexion.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión'**
  String get errorConexion;

  /// No description provided for @errorGenerar.
  ///
  /// In es, this message translates to:
  /// **'No pude generar una respuesta.'**
  String get errorGenerar;

  /// No description provided for @navEstudio.
  ///
  /// In es, this message translates to:
  /// **'Estudio'**
  String get navEstudio;

  /// No description provided for @navAsistente.
  ///
  /// In es, this message translates to:
  /// **'Asistente IA'**
  String get navAsistente;

  /// No description provided for @navAjustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navAjustes;

  /// No description provided for @editorFuncion2D.
  ///
  /// In es, this message translates to:
  /// **'Función f(x)'**
  String get editorFuncion2D;

  /// No description provided for @editorFuncion3D.
  ///
  /// In es, this message translates to:
  /// **'Función f(x, y)'**
  String get editorFuncion3D;

  /// No description provided for @editorHint2D.
  ///
  /// In es, this message translates to:
  /// **'Ej. sin(x) * x'**
  String get editorHint2D;

  /// No description provided for @editorHint3D.
  ///
  /// In es, this message translates to:
  /// **'Ej. x^2 + y^2'**
  String get editorHint3D;

  /// No description provided for @chatVacio.
  ///
  /// In es, this message translates to:
  /// **'¡Pregúntame sobre tu función!\nEj: ¿Cuál es el dominio?'**
  String get chatVacio;

  /// No description provided for @chatHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu duda...'**
  String get chatHint;

  /// No description provided for @chatTitle.
  ///
  /// In es, this message translates to:
  /// **'Asistente de Matemáticas'**
  String get chatTitle;

  /// No description provided for @chatEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Pregúntame sobre tu función\no escribe una ecuación para analizar'**
  String get chatEmptySubtitle;

  /// No description provided for @chatSuggestionDomain.
  ///
  /// In es, this message translates to:
  /// **'¿Cuál es el dominio?'**
  String get chatSuggestionDomain;

  /// No description provided for @chatSuggestionIntersect.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde corta al eje Y?'**
  String get chatSuggestionIntersect;

  /// No description provided for @chatSuggestionExplain.
  ///
  /// In es, this message translates to:
  /// **'Explica la función'**
  String get chatSuggestionExplain;

  /// No description provided for @chatInputHint.
  ///
  /// In es, this message translates to:
  /// **'Pregunta sobre tu función...'**
  String get chatInputHint;

  /// No description provided for @graficaAnaliza.
  ///
  /// In es, this message translates to:
  /// **'Grafica, analiza y aprende con IA'**
  String get graficaAnaliza;

  /// No description provided for @iniciarSesionBtn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get iniciarSesionBtn;

  /// No description provided for @crearCuentaBtn.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get crearCuentaBtn;

  /// No description provided for @nombreCompleto.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get nombreCompleto;

  /// No description provided for @correoElectronico.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get correoElectronico;

  /// No description provided for @contrasena.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get contrasena;

  /// No description provided for @registrarseBtn.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get registrarseBtn;

  /// No description provided for @continuarInvitado.
  ///
  /// In es, this message translates to:
  /// **'Continuar como invitado'**
  String get continuarInvitado;

  /// No description provided for @noTienesCuenta.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get noTienesCuenta;

  /// No description provided for @yaTienesCuenta.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get yaTienesCuenta;

  /// No description provided for @registrateAccion.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get registrateAccion;

  /// No description provided for @iniciaSesionAccion.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get iniciaSesionAccion;

  /// No description provided for @ingresaFuncion.
  ///
  /// In es, this message translates to:
  /// **'Ingresa una función para graficar'**
  String get ingresaFuncion;

  /// No description provided for @proximamente.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get proximamente;

  /// No description provided for @funcionValida.
  ///
  /// In es, this message translates to:
  /// **'Válida ✓'**
  String get funcionValida;

  /// No description provided for @funcionInvalida.
  ///
  /// In es, this message translates to:
  /// **'Inválida'**
  String get funcionInvalida;

  /// No description provided for @cuentaRegistrada.
  ///
  /// In es, this message translates to:
  /// **'Cuenta registrada'**
  String get cuentaRegistrada;

  /// No description provided for @usuario.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get usuario;

  /// No description provided for @entrar.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get entrar;

  /// No description provided for @salir.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get salir;

  /// No description provided for @seleccionarIdioma.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar idioma'**
  String get seleccionarIdioma;

  /// No description provided for @valorarApp.
  ///
  /// In es, this message translates to:
  /// **'Valorar la app'**
  String get valorarApp;

  /// No description provided for @perfilAppbar.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get perfilAppbar;

  /// No description provided for @iniciaSesionPerfil.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para ver tu perfil.'**
  String get iniciaSesionPerfil;

  /// No description provided for @miPerfilTitulo.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get miPerfilTitulo;

  /// No description provided for @estadoCuentaInfo.
  ///
  /// In es, this message translates to:
  /// **'Estado de la Cuenta'**
  String get estadoCuentaInfo;

  /// No description provided for @usuarioPremium.
  ///
  /// In es, this message translates to:
  /// **'Usuario PREMIUM'**
  String get usuarioPremium;

  /// No description provided for @usuarioBasico.
  ///
  /// In es, this message translates to:
  /// **'Usuario Básico (Gratis)'**
  String get usuarioBasico;

  /// No description provided for @proximamenteMejorar.
  ///
  /// In es, this message translates to:
  /// **'Próximamente: Mejorar a Premium'**
  String get proximamenteMejorar;

  /// No description provided for @btnMejorarPremium.
  ///
  /// In es, this message translates to:
  /// **'Mejorar a Premium'**
  String get btnMejorarPremium;

  /// No description provided for @btnCerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get btnCerrarSesion;

  /// No description provided for @seleccionaAvatar.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un Avatar'**
  String get seleccionaAvatar;

  /// No description provided for @subirGaleria.
  ///
  /// In es, this message translates to:
  /// **'Subir desde la galería'**
  String get subirGaleria;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
