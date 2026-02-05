class AppStrings {
  // General
  static const String appName = 'Votación EPIC';
  static const String universityName = 'Universidad Continental';
  static const String careerName = 'Ingeniería de Sistemas e Informática';

  // Splash
  static const String splashTitle = 'Elección de Delegado';
  static const String splashSubtitle = 'EPIC 2024';

  // Login
  static const String loginTitle = '¡Bienvenido!';
  static const String loginSubtitle =
      'Ingresa tu correo institucional para votar';
  static const String emailLabel = 'Correo institucional';
  static const String emailHint = 'tu.correo@continental.edu.pe';
  static const String loginButton = 'Ingresar';
  static const String emailError = 'Debe usar un correo @continental.edu.pe';
  static const String emailInvalid = 'Ingrese un correo válido';

  // Location
  static const String locationError =
      'Debes estar en la universidad para votar';
  static const String checkingLocation = 'Verificando ubicación...';
  static const String locationPermissionDenied =
      'Permiso de ubicación denegado';

  // Candidates
  static const String candidatesTitle = 'Candidatos';
  static const String candidatesSubtitle = 'Selecciona a tu candidato';
  static const String noCandidates = 'No hay candidatos disponibles';
  static const String voteButton = 'Votar';

  // Vote Confirmation
  static const String confirmTitle = 'Confirmar voto';
  static const String confirmMessage = '¿Estás seguro de votar por';
  static const String confirmButton = 'Confirmar voto';
  static const String cancelButton = 'Cancelar';

  // Vote Success
  static const String successTitle = '¡Voto registrado!';
  static const String successMessage =
      'Tu voto ha sido registrado exitosamente';
  static const String viewResultsButton = 'Ver resultados';
  static const String finishButton = 'Finalizar';

  // Results
  static const String resultsTitle = 'Resultados';
  static const String totalVotes = 'Total de votos';
  static const String noResults = 'Aún no hay resultados disponibles';

  // Errors
  static const String alreadyVoted = 'Ya has votado anteriormente';
  static const String errorGeneral = 'Ocurrió un error. Intenta nuevamente';
  static const String errorConnection = 'Error de conexión';
}
