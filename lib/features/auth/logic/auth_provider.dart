import 'dart:io';
import 'dart:convert'; // <--- NUEVO: Para convertir a Base64
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_links/app_links.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AppLinks _appLinks;
  
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  bool _isPremium = false;
  String _userName = '';
  String _photoUrl = ''; 

  bool get isPremium => _isPremium;
  String get userName => _userName;
  String get photoUrl => _photoUrl; 

  AuthProvider() {

    _initDeepLinks();

    _auth.authStateChanges().listen((user) async {
      _user = user;
      
      if (user != null && !user.isAnonymous) {
        try {
          // Refrescamos al usuario por si acaba de confirmar un cambio de correo
          await user.reload();
          _user = _auth.currentUser;

          DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            _isPremium = data['isPremium'] ?? false;
            _userName = data['name'] ?? 'Usuario';
            _photoUrl = data['photoUrl'] ?? ''; 

            // --- NUEVO: SINCRONIZACIÓN MÁGICA DE CORREO ---
            // Si el usuario ya confirmó su nuevo correo en el link, lo guardamos en la base de datos
            if (_user!.email != null && data['email'] != _user!.email) {
              await _firestore.collection('users').doc(_user!.uid).update({
                'email': _user!.email,
              });
            }
          }
        } catch (e) {
          debugPrint("Error leyendo datos: $e");
        }
      } else {
        _isPremium = false;
        _userName = '';
        _photoUrl = ''; 
      }
      notifyListeners();
    });
  }

  // ---ATRAPAR EL CORREO DE CAMBIO DE EMAIL ---
  void _initDeepLinks() {
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen(_handleBackgroundLink);
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleBackgroundLink(uri);
    });
  }

  Future<void> _handleBackgroundLink(Uri uri) async {
    // Si el enlace viene de Firebase...
    if (uri.host == 'math-ia-studio.firebaseapp.com' && uri.path == '/__/auth/action') {
      final mode = uri.queryParameters['mode'];
      final oobCode = uri.queryParameters['oobCode'];

      // Y si el enlace es específicamente para confirmar un NUEVO CORREO...
      if (mode == 'verifyAndChangeEmail' && oobCode != null) {
        try {
          _setLoading(true);
          
          // 1. Le decimos a Firebase: "Aplica este código, el usuario sí autorizó el cambio"
          await _auth.applyActionCode(oobCode);
          
          // 2. Refrescamos al usuario para descargar su nuevo correo a la app
          await _auth.currentUser?.reload();
          _user = _auth.currentUser;

          // 3. Lo guardamos en tu base de datos (Firestore) automáticamente
          if (_user != null && _user!.email != null) {
            await _firestore.collection('users').doc(_user!.uid).update({
              'email': _user!.email,
            });
          }
          
          _setLoading(false);
          notifyListeners(); // Actualizamos la pantalla de Perfil al instante
        } catch (e) {
          _setLoading(false);
          debugPrint("Error aplicando el enlace de correo: $e");
        }
      }
    }
  }

  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return null; 
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message;
    }
  }

  Future<String?> signInAsGuest() async {
    try {
      _setLoading(true);
      await _auth.signInAnonymously();
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'Error';
    }
  }

  // --- NUEVO: INICIAR SESIÓN CON GOOGLE ---
  Future<String?> signInWithGoogle() async {
    try {
      _setLoading(true);

      // Somos explícitos pidiendo acceso al correo
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      final googleUser = await googleSignIn.signIn();
      
      // Si el usuario cancela la ventana
      if (googleUser == null) {
        _setLoading(false);
        return null; 
      }

      // Obtenemos las llaves de seguridad
      final googleAuth = await googleUser.authentication;

      // Creamos la credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciamos sesión en Firebase
      UserCredential userCred = await _auth.signInWithCredential(credential);

      // Guardamos en Firestore si es un usuario NUEVO
      if (userCred.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCred.user!.uid).set({
          'uid': userCred.user!.uid,
          'email': userCred.user!.email,
          'name': userCred.user!.displayName ?? 'Usuario de Google',
          'isPremium': false,
          'aiQueriesUsed': 0,
          'photoUrl': userCred.user!.photoURL ?? '', // Foto de Google
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _setLoading(false);
      return null; 
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'Error de autenticación con Google.';
    } catch (e) {
      _setLoading(false);
      debugPrint("Error de Google: $e");
      return 'Ocurrió un error inesperado al conectar con Google.';
    }
  }

  Future<String?> createUserWithEmailAndPassword(String email, String password, String name) async {
    try {
      _setLoading(true);
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      if (cred.user != null) {
        
        // --- NUEVO: ENVIAR CORREO DE BIENVENIDA / VERIFICACIÓN ---
        // Esto le manda un correo automático al instante de registrarse
        await cred.user!.sendEmailVerification();

        // Guardamos sus datos en la base de datos
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'email': email,
          'name': name,
          'isPremium': false,
          'aiQueriesUsed': 0,
          'photoUrl': '', 
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      // Hacemos los errores un poco más amigables en español
      if (e.code == 'email-already-in-use') {
        return 'Este correo ya está registrado.';
      } else if (e.code == 'weak-password') {
        return 'La contraseña es muy débil (Mínimo 6 caracteres).';
      }
      return e.message;
    }
  }

  Future<void> updateProfilePicture(String urlOrBase64) async {
    if (_user != null && !_user!.isAnonymous) {
      try {
        await _firestore.collection('users').doc(_user!.uid).update({'photoUrl': urlOrBase64});
        _photoUrl = urlOrBase64;
        notifyListeners();
      } catch (e) {
        debugPrint("Error actualizando foto: $e");
      }
    }
  }

  // --- NUEVA LÓGICA BASE64 (Sin usar Firebase Storage) ---
  Future<void> uploadProfileImage(File imageFile) async {
    if (_user == null || _user!.isAnonymous) return;
    
    try {
      _setLoading(true);
      
      // 1. Leemos la imagen física como bytes
      final bytes = await imageFile.readAsBytes();
      
      // 2. La convertimos a un texto largo (Base64)
      final base64String = base64Encode(bytes);

      // 3. Guardamos ese texto directamente en tu Firestore
      await updateProfilePicture(base64String);

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint("Error convirtiendo imagen: $e");
    }
  }

  // --- NUEVO: MÉTODO PARA RECUPERAR CONTRASEÑA ---
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return null; // Si devuelve null, significa que se envió correctamente
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      // Personalizamos el mensaje de error para que sea más amigable
      if (e.code == 'user-not-found') {
        return 'No hay ningún usuario registrado con este correo.';
      } else if (e.code == 'invalid-email') {
        return 'El formato del correo no es válido.';
      }
      return e.message ?? 'Ocurrió un error al intentar enviar el correo.';
    } catch (e) {
      _setLoading(false);
      return 'Ocurrió un error inesperado.';
    }
  }

  // --- NUEVO: MÉTODO PARA APLICAR LA NUEVA CONTRASEÑA ---
  Future<String?> confirmPasswordReset(String code, String newPassword) async {
    try {
      _setLoading(true);
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
      _setLoading(false);
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'Error al cambiar la contraseña. El enlace puede haber expirado.';
    } catch (e) {
      _setLoading(false);
      return 'Error inesperado.';
    }
  }

  // --- MÉTODO PARA CAMBIAR CORREO ELECTRÓNICO ---
  Future<String?> changeUserEmail(String newEmail, String currentPassword) async {
    try {
      _setLoading(true);
      if (_user != null && _user!.email != null) {
        
        // 1. Reautenticar
        AuthCredential credential = EmailAuthProvider.credential(
          email: _user!.email!,
          password: currentPassword,
        );
        await _user!.reauthenticateWithCredential(credential);

        // 2. Enviar correo de verificación
        await _user!.verifyBeforeUpdateEmail(newEmail);

        // OJO: Ya no actualizamos Firestore aquí. 
        // El constructor de arriba lo hará automáticamente cuando el usuario confirme.
        
        _setLoading(false);
        return null; // Éxito
      }
      _setLoading(false);
      return 'No se encontró una sesión activa.';
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'La contraseña actual es incorrecta.';
      } else if (e.code == 'invalid-email') {
        return 'El formato del nuevo correo no es válido.';
      } else if (e.code == 'email-already-in-use') {
        return 'Ese correo ya pertenece a otra cuenta.';
      } else if (e.code == 'requires-recent-login') {
        return 'Por seguridad, cierra sesión, vuelve a entrar e intenta de nuevo.';
      }
      return e.message ?? 'Error al actualizar el correo.';
    } catch (e) {
      _setLoading(false);
      return 'Ocurrió un error inesperado.';
    }
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}