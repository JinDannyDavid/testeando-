import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';

class SplashViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Future<void> checkAuthStatus() async {
    try {
      // Verificar si hay un usuario autenticado
      final user = _authService.currentUser;

      if (user != null && user.email != null) {
        // Si hay un usuario, mantener sesión activa
        // No necesitamos validar email aquí porque ya se validó al iniciar sesión
      }
    } catch (e) {
      print('Error al verificar estado de autenticación: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
