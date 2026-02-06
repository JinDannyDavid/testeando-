import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_routes.dart';
import '../../viewmodels/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    // Intentar login con Google
    final success = await _viewModel.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      // Verificar si ya votó
      final alreadyVoted = await _viewModel.checkIfAlreadyVoted();

      if (!mounted) return;

      if (alreadyVoted) {
        // Mostrar mensaje y navegar a resultados
        _showAlreadyVotedDialog();
      } else {
        // Navegar a la pantalla de candidatos y pasar el estudiante
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.candidates,
          arguments: _viewModel.currentStudent,
        );
      }
    } else {
      // Mostrar error
      if (_viewModel.errorMessage != null) {
        _showErrorSnackBar(_viewModel.errorMessage!);
      }
    }
  }

  void _showAlreadyVotedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_outline,
          color: AppColors.success,
          size: 64,
        ),
        title: const Text('Ya has votado'),
        content: const Text(
          'Tu voto ya fue registrado anteriormente. Puedes ver los resultados de la votación.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.results);
            },
            child: const Text('Ver resultados'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.background],
              stops: [0.0, 0.4],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo y título
                    _buildHeader(),

                    const SizedBox(height: 48),

                    // Botón de Google Sign In
                    _buildGoogleSignInButton(),

                    const SizedBox(height: 24),

                    // Información adicional
                    _buildInfoCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icono
        Image.asset(
          'assets/images/logoUC.png',
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 24),

        // Título
        Text(
          AppStrings.loginTitle,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Subtítulo
        const Text(
          'Inicia sesión con tu cuenta de Google institucional',
          style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Texto explicativo
                const Text(
                  'Inicia sesión con:',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Botón de Google Sign In
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: viewModel.isLoading ? null : _handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 2,
                      side: const BorderSide(
                        color: AppColors.divider,
                        width: 1,
                      ),
                    ),
                    icon: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          )
                        : Image.network(
                            'https://www.google.com/favicon.ico',
                            height: 24,
                            width: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.g_mobiledata,
                                size: 32,
                                color: AppColors.primary,
                              );
                            },
                          ),
                    label: Text(
                      viewModel.isLoading
                          ? 'Iniciando sesión...'
                          : 'Continuar con Google',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: AppColors.info.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.info.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.info, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Solo puedes votar con tu correo institucional @continental.edu.pe',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
