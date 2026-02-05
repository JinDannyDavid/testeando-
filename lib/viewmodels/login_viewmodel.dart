import 'package:flutter/material.dart';
import '../core/utils/email_validator.dart';
import '../data/models/student_model.dart';
import '../data/repositories/student_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final StudentRepository _studentRepository = StudentRepository();

  // Estado de la UI
  bool _isLoading = false;
  String? _errorMessage;
  StudentModel? _currentStudent;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  StudentModel? get currentStudent => _currentStudent;

  // Controlador de texto del email
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  /// Valida el email ingresado
  String? validateEmail(String? value) {
    return EmailValidator.validate(value);
  }

  /// Inicia sesión con el email institucional
  Future<bool> login() async {
    _setLoading(true);
    _clearError();

    try {
      final email = emailController.text.trim();

      // Validar email
      final validationError = EmailValidator.validate(email);
      if (validationError != null) {
        _setError(validationError);
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
      _setError('Error al iniciar sesión. Intenta nuevamente.');
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

  /// Limpia los datos del formulario
  void clearForm() {
    emailController.clear();
    _clearError();
    notifyListeners();
  }
}
