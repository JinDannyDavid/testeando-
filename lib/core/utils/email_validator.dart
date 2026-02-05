class EmailValidator {
  // Dominio institucional permitido
  static const String institutionalDomain = '@continental.edu.pe';

  // Expresión regular para validar formato de email
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Valida si el email tiene formato correcto
  static bool isValidFormat(String email) {
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// Valida si el email es del dominio institucional
  static bool isInstitutionalEmail(String email) {
    if (email.isEmpty) return false;
    return email.trim().toLowerCase().endsWith(institutionalDomain);
  }

  /// Validación completa del email
  static String? validate(String? email) {
    if (email == null || email.isEmpty) {
      return 'El correo es requerido';
    }

    final trimmedEmail = email.trim();

    if (!isValidFormat(trimmedEmail)) {
      return 'Ingrese un correo válido';
    }

    if (!isInstitutionalEmail(trimmedEmail)) {
      return 'Debe usar un correo @continental.edu.pe';
    }

    return null; // Email válido
  }

  /// Extrae el código de estudiante del email
  /// Ejemplo: 72188188@continental.edu.pe -> 72188188
  static String extractStudentCode(String email) {
    if (!isInstitutionalEmail(email)) return '';

    final localPart = email.split('@')[0];
    return localPart;
  }
}
