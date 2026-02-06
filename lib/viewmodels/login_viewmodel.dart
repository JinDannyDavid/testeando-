import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';
import '../core/utils/email_validator.dart';
import '../data/models/student_model.dart';
import '../data/repositories/student_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StudentRepository _studentRepository = StudentRepository();

  // Estado de la UI
  bool _isLoading = false;
  String? _errorMessage;
  StudentModel? _currentStudent;
  User? _firebaseUser;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  StudentModel? get currentStudent => _currentStudent;
  User? get firebaseUser => _firebaseUser;

  /// Verifica si hay un usuario ya autenticado
  bool get isAlreadySignedIn {
    final user = _authService.currentUser;
    return user != null &&
        user.email != null &&
        EmailValidator.isInstitutionalEmail(user.email!);
  }

  /// Inicia sesión con Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      // Verificar si ya hay un usuario autenticado
      if (isAlreadySignedIn) {
        final email = _authService.currentUser!.email!;
        final studentCode = EmailValidator.extractStudentCode(email);

        // Obtener o crear estudiante en la base de datos
        _currentStudent = await _studentRepository.getOrCreateStudent(
          email,
          studentCode,
        );
        _setLoading(false);
        return true;
      }

      // Iniciar sesión con Google
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential == null) {
        // Si devuelve null, puede ser que el usuario canceló o el email no es institucional
        final currentUser = _authService.currentUser;
        if (currentUser != null) {
          await _authService.signOut();
        }
        _setError('Debes usar tu correo institucional @continental.edu.pe');
        _setLoading(false);
        return false;
      }

      _firebaseUser = userCredential.user;

      if (_firebaseUser == null) {
        _setError('Error al obtener información del usuario');
        _setLoading(false);
        return false;
      }

      final email = _firebaseUser!.email;

      if (email == null) {
        _setError('No se pudo obtener el email');
        _setLoading(false);
        return false;
      }

      // Validar que sea email institucional (seguridad adicional)
      if (!EmailValidator.isInstitutionalEmail(email)) {
        await _authService.signOut();
        _setError('Debes usar tu correo institucional @continental.edu.pe');
        _setLoading(false);
        return false;
      }

      // Extraer código de estudiante
      final studentCode = EmailValidator.extractStudentCode(email);

      // Obtener o crear estudiante en la base de datos
      _currentStudent = await _studentRepository.getOrCreateStudent(
        email,
        studentCode,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      // Manejar otros errores
      _setError('Error al iniciar sesión: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Verifica si el estudiante ya votó
  Future<bool> checkIfAlreadyVoted() async {
    if (_currentStudent == null) return false;

    final student = await _studentRepository.getStudentByEmail(
      _currentStudent!.email,
    );

    return student?.hasVoted ?? false;
  }

  /// Cierra sesión
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentStudent = null;
      _firebaseUser = null;
      notifyListeners();
    } catch (e) {
      _setError('Error al cerrar sesión');
    }
  }

  /// Limpia el error
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Establece un mensaje de error
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Establece el estado de carga
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
