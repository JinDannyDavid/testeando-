import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../utils/email_validator.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Iniciar sesión con Google usando Firebase Auth directamente
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Configurar Firebase Auth para Google Sign In
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.setCustomParameters({
        'hd': 'continental.edu.pe',
      }); // Restringir a dominio institucional

      // Iniciar sesión con Google
      UserCredential userCredential;

      if (kIsWeb) {
        // Para web, usar popup
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Para mobile/desktop, usar redirect
        userCredential = await _auth.signInWithProvider(googleProvider);
      }

      // Validar email institucional
      if (!EmailValidator.isInstitutionalEmail(
        userCredential.user?.email ?? '',
      )) {
        await signOut();
        return null;
      }

      return userCredential;
    } catch (e) {
      print('Error en Google Sign In: $e');

      // Manejar cualquier error
      if (e.toString().contains('People API') ||
          e.toString().contains('403') ||
          e.toString().contains('PERMISSION_DENIED')) {
        return null;
      }

      rethrow;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
      rethrow;
    }
  }

  /// Validar si el email es institucional
  bool isInstitutionalEmail(String email) {
    return EmailValidator.isInstitutionalEmail(email);
  }

  /// Obtener código de estudiante del email
  String getStudentCode(String email) {
    return EmailValidator.extractStudentCode(email);
  }
}
